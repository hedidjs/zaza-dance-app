import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';
import '../../../../shared/models/user_model.dart';
import '../../services/admin_user_service.dart';

/// עמוד ניהול משתמשים עבור מנהלי זזה דאנס
class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRole = 'all';
  String _sortBy = 'created_at';
  bool _sortDescending = true;
  
  List<UserModel> _users = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  
  // פרטי עריכת משתמש
  final _editFormKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedEditRole = 'student';
  
  // פרטי יצירת משתמש
  final _createFormKey = GlobalKey<FormState>();
  final _createFirstNameController = TextEditingController();
  final _createLastNameController = TextEditingController();
  final _createEmailController = TextEditingController();
  final _createPhoneController = TextEditingController();
  final _createAddressController = TextEditingController();
  String _selectedCreateRole = 'student';

  @override
  void initState() {
    super.initState();
    _loadUsers(isRefresh: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _createFirstNameController.dispose();
    _createLastNameController.dispose();
    _createEmailController.dispose();
    _createPhoneController.dispose();
    _createAddressController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 0;
      _hasMoreData = true;
      _users.clear();
    }
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await AdminUserService.getAllUsers(
        role: _selectedRole == 'all' ? null : _selectedRole,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        sortBy: _sortBy,
        sortOrder: _sortDescending ? 'desc' : 'asc',
        isActive: true,
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      if (result.isSuccess && result.data != null) {
        setState(() {
          if (isRefresh) {
            _users = result.data!;
          } else {
            _users.addAll(result.data!);
          }
          _hasMoreData = result.data!.length == _pageSize;
          _currentPage++;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = result.message;
          _isLoading = false;
        });
        _showErrorSnackBar(result.message);
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'שגיאה בטעינת נתונים: $e';
        _isLoading = false;
      });
      _showErrorSnackBar('שגיאה בטעינת נתונים');
    }
  }

  List<UserModel> get _filteredUsers {
    // Since we're using server-side filtering, just return the users
    return _users;
  }
  
  Timer? _searchDebounceTimer;
  
  void _debounceSearch() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadUsers(isRefresh: true);
    });
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
  
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);

    if (!isAdmin) {
      return _buildAccessDeniedView();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: NeonText(
            text: 'ניהול משתמשים',
            fontSize: 24,
            glowColor: AppColors.neonBlue,
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.primaryText,
            ),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.person_add,
                color: AppColors.neonGreen,
              ),
              onPressed: _showAddUserDialog,
              tooltip: 'הוסף משתמש',
            ),
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: AppColors.neonTurquoise,
              ),
              onPressed: () => _loadUsers(isRefresh: true),
              tooltip: 'רענן',
            ),
          ],
        ),
        body: AnimatedGradientBackground(
          child: SafeArea(
            child: Column(
              children: [
                // כלי חיפוש וסינון
                _buildSearchAndFilters(),
                
                // סטטיסטיקות משתמשים
                _buildUserStats(),
                
                // רשימת משתמשים
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.neonTurquoise,
                          ),
                        )
                      : _buildUsersList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // שדה חיפוש
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.cardGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppColors.neonBlue.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: AppColors.primaryText),
              decoration: InputDecoration(
                hintText: 'חפש משתמשים...',
                hintStyle: TextStyle(color: AppColors.secondaryText),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.neonBlue,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.secondaryText,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _debounceSearch();
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // סינונים
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'תפקיד',
                  _selectedRole,
                  {
                    'all': 'הכל',
                    'student': 'תלמידים',
                    'parent': 'הורים',
                    'instructor': 'מדריכים',
                    'admin': 'מנהלים',
                  },
                  (value) {
                    setState(() => _selectedRole = value!);
                    _loadUsers(isRefresh: true);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown(
                  'מיון',
                  _sortBy,
                  const {
                    'created_at': 'תאריך הצטרפות',
                    'name': 'שם',
                    'email': 'אימייל',
                    'role': 'תפקיד',
                  },
                  (value) {
                    setState(() => _sortBy = value!);
                    _loadUsers(isRefresh: true);
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() => _sortDescending = !_sortDescending);
                  _loadUsers(isRefresh: true);
                },
                icon: Icon(
                  _sortDescending ? Icons.arrow_downward : Icons.arrow_upward,
                  color: AppColors.neonTurquoise,
                ),
                tooltip: _sortDescending ? 'יורד' : 'עולה',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    Map<String, String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.neonBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        dropdownColor: AppColors.darkSurface,
        style: GoogleFonts.assistant(
          color: AppColors.primaryText,
          fontSize: 14,
        ),
        underline: Container(),
        isExpanded: true,
        icon: Icon(
          Icons.arrow_drop_down,
          color: AppColors.secondaryText,
        ),
        hint: Text(
          label,
          style: GoogleFonts.assistant(
            color: AppColors.secondaryText,
            fontSize: 14,
          ),
        ),
        items: options.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserStats() {
    final totalUsers = _users.length;
    final students = _users.where((u) => u.role == UserRole.student).length;
    final parents = _users.where((u) => u.role == UserRole.parent).length;
    final instructors = _users.where((u) => u.role == UserRole.instructor).length;
    final admins = _users.where((u) => u.role == UserRole.admin).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('סך הכל', totalUsers.toString(), AppColors.neonBlue),
          _buildStatItem('תלמידים', students.toString(), AppColors.neonGreen),
          _buildStatItem('הורים', parents.toString(), AppColors.neonTurquoise),
          _buildStatItem('מדריכים', instructors.toString(), AppColors.neonPink),
          _buildStatItem('מנהלים', admins.toString(), AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        NeonText(
          text: value,
          fontSize: 20,
          glowColor: color,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.assistant(
            color: AppColors.secondaryText,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildUsersList() {
    if (_hasError && _users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 20),
            NeonText(
              text: 'שגיאה בטעינת נתונים',
              fontSize: 18,
              glowColor: AppColors.error,
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage,
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            NeonButton(
              text: 'נסה שוב',
              onPressed: () => _loadUsers(isRefresh: true),
              glowColor: AppColors.neonBlue,
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: AppColors.secondaryText,
            ),
            const SizedBox(height: 20),
            NeonText(
              text: _searchQuery.isNotEmpty 
                  ? 'לא נמצאו משתמשים'
                  : 'אין משתמשים במערכת',
              fontSize: 18,
              glowColor: AppColors.neonBlue,
            ),
            const SizedBox(height: 10),
            Text(
              _searchQuery.isNotEmpty 
                  ? 'נסה לשנות את החיפוש או הסינון'
                  : 'הוסף משתמשים חדשים למערכת',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _users.length + (_hasMoreData ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == _users.length) {
          // Load more indicator
          return Center(
            child: _isLoading
                ? CircularProgressIndicator(
                    color: AppColors.neonTurquoise,
                  )
                : NeonButton(
                    text: 'טען עוד',
                    onPressed: () => _loadUsers(),
                    glowColor: AppColors.neonBlue,
                  ),
          );
        }
        
        final user = _users[index];
        return _buildUserCard(user, index);
      },
    );
  }

  Widget _buildUserCard(UserModel user, int index) {
    final roleColor = _getRoleColor(user.role);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showUserDetails(user),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.cardGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: roleColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // תמונת פרופיל
              NeonGlowContainer(
                glowColor: roleColor,
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.darkSurface,
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Icon(
                          _getRoleIcon(user.role),
                          color: roleColor,
                          size: 25,
                        )
                      : null,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // פרטי משתמש
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: GoogleFonts.assistant(
                        color: AppColors.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: GoogleFonts.assistant(
                        color: AppColors.secondaryText,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: roleColor.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _getRoleDisplayName(user.role),
                            style: GoogleFonts.assistant(
                              color: roleColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(user.createdAt),
                          style: GoogleFonts.assistant(
                            color: AppColors.secondaryText,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // פעולות
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.secondaryText,
                ),
                color: AppColors.darkSurface,
                onSelected: (value) => _handleUserAction(value, user),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, color: AppColors.info, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'צפה בפרטים',
                          style: GoogleFonts.assistant(color: AppColors.primaryText),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: AppColors.neonTurquoise, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'ערוך',
                          style: GoogleFonts.assistant(color: AppColors.primaryText),
                        ),
                      ],
                    ),
                  ),
                  if (user.role != UserRole.admin)
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: AppColors.error, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'מחק',
                            style: GoogleFonts.assistant(color: AppColors.primaryText),
                          ),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'reset_password',
                    child: Row(
                      children: [
                        Icon(Icons.lock_reset, color: AppColors.warning, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'איפוס סיסמה',
                          style: GoogleFonts.assistant(color: AppColors.primaryText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: (index * 100).ms).slideX(begin: 0.3);
  }

  Widget _buildAccessDeniedView() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: AnimatedGradientBackground(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 120,
                  color: AppColors.error,
                ),
                const SizedBox(height: 30),
                NeonText(
                  text: 'גישה מוגבלת',
                  fontSize: 28,
                  glowColor: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'דף זה מיועד למנהלים בלבד',
                  style: GoogleFonts.assistant(
                    color: AppColors.secondaryText,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                NeonButton(
                  text: 'חזור',
                  onPressed: () => context.pop(),
                  glowColor: AppColors.neonTurquoise,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.error;
      case UserRole.instructor:
        return AppColors.neonPink;
      case UserRole.parent:
        return AppColors.neonTurquoise;
      case UserRole.student:
        return AppColors.neonGreen;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.instructor:
        return Icons.school;
      case UserRole.parent:
        return Icons.family_restroom;
      case UserRole.student:
        return Icons.person;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    return role.displayName;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleUserAction(String action, UserModel user) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'delete':
        _showDeleteUserDialog(user);
        break;
      case 'reset_password':
        _resetUserPassword(user);
        break;
    }
  }

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: _getRoleColor(user.role).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(
                _getRoleIcon(user.role),
                color: _getRoleColor(user.role),
              ),
              const SizedBox(width: 8),
              NeonText(
                text: 'פרטי משתמש',
                fontSize: 18,
                glowColor: _getRoleColor(user.role),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('שם מלא', user.displayName),
                _buildDetailRow('אימייל', user.email),
                _buildDetailRow('תפקיד', _getRoleDisplayName(user.role)),
                if (user.phone != null) _buildDetailRow('טלפון', user.phone!),
                _buildDetailRow('תאריך הצטרפות', _formatDate(user.createdAt)),
                if (user.updatedAt != null) _buildDetailRow('עדכון אחרון', _formatDate(user.updatedAt!)),
              ],
            ),
          ),
          actions: [
            NeonButton(
              text: 'סגור',
              onPressed: () => context.pop(),
              glowColor: _getRoleColor(user.role),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.assistant(
                color: AppColors.primaryText,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    _createFirstNameController.clear();
    _createLastNameController.clear();
    _createEmailController.clear();
    _createPhoneController.clear();
    _createAddressController.clear();
    _selectedCreateRole = 'student';
    
    showDialog(
      context: context,
      builder: (context) => _buildCreateUserDialog(),
    );
  }
  
  Widget _buildCreateUserDialog() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: AppColors.neonGreen.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.person_add, color: AppColors.neonGreen),
            const SizedBox(width: 8),
            NeonText(
              text: 'הוסף משתמש חדש',
              fontSize: 18,
              glowColor: AppColors.neonGreen,
            ),
          ],
        ),
        content: Form(
          key: _createFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFormField(
                  controller: _createFirstNameController,
                  label: 'שם פרטי',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'שם פרטי הוא שדה חובה';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _createLastNameController,
                  label: 'שם משפחה',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'שם משפחה הוא שדה חובה';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _createEmailController,
                  label: 'כתובת אימייל',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'כתובת אימייל היא שדה חובה';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'כתובת אימייל לא תקינה';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _createPhoneController,
                  label: 'מספר טלפון (אופציונלי)',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _createAddressController,
                  label: 'כתובת (אופציונלי)',
                ),
                const SizedBox(height: 16),
                _buildRoleDropdown(
                  value: _selectedCreateRole,
                  onChanged: (value) => setState(() => _selectedCreateRole = value!),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'ביטול',
              style: TextStyle(color: AppColors.secondaryText),
            ),
          ),
          NeonButton(
            text: 'יצירה',
            onPressed: _createUser,
            glowColor: AppColors.neonGreen,
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(UserModel user) {
    _firstNameController.text = user.firstName ?? '';
    _lastNameController.text = user.lastName ?? '';
    _emailController.text = user.email;
    _phoneController.text = user.phone ?? '';
    _addressController.text = user.address ?? '';
    _selectedEditRole = user.role.value;
    
    showDialog(
      context: context,
      builder: (context) => _buildEditUserDialog(user),
    );
  }
  
  Widget _buildEditUserDialog(UserModel user) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: AppColors.neonTurquoise.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.edit, color: AppColors.neonTurquoise),
            const SizedBox(width: 8),
            NeonText(
              text: 'ערוך משתמש',
              fontSize: 18,
              glowColor: AppColors.neonTurquoise,
            ),
          ],
        ),
        content: Form(
          key: _editFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFormField(
                  controller: _firstNameController,
                  label: 'שם פרטי',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'שם פרטי הוא שדה חובה';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _lastNameController,
                  label: 'שם משפחה',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'שם משפחה הוא שדה חובה';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _emailController,
                  label: 'כתובת אימייל',
                  keyboardType: TextInputType.emailAddress,
                  enabled: false, // Email can't be changed
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _phoneController,
                  label: 'מספר טלפון',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _addressController,
                  label: 'כתובת',
                ),
                const SizedBox(height: 16),
                _buildRoleDropdown(
                  value: _selectedEditRole,
                  onChanged: (value) => setState(() => _selectedEditRole = value!),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'ביטול',
              style: TextStyle(color: AppColors.secondaryText),
            ),
          ),
          NeonButton(
            text: 'שמירה',
            onPressed: () => _updateUser(user),
            glowColor: AppColors.neonTurquoise,
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppColors.error.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: AppColors.error),
              const SizedBox(width: 8),
              NeonText(
                text: 'מחיקת משתמש',
                fontSize: 18,
                glowColor: AppColors.error,
              ),
            ],
          ),
          content: Text(
            'האם אתה בטוח שברצונך למחוק את המשתמש ${user.displayName}?\nפעולה זו תסמן את המשתמש כלא פעיל.',
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'ביטול',
                style: TextStyle(color: AppColors.secondaryText),
              ),
            ),
            NeonButton(
              text: 'מחק',
              onPressed: () {
                context.pop();
                _deleteUser(user);
              },
              glowColor: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  void _deleteUser(UserModel user) async {
    try {
      final result = await AdminUserService.deleteUser(user.id);
      
      if (result.isSuccess) {
        _showSuccessSnackBar(result.message);
        _loadUsers(isRefresh: true);
      } else {
        _showErrorSnackBar(result.message);
      }
    } catch (e) {
      _showErrorSnackBar('שגיאה במחיקת משתמש: $e');
    }
  }

  void _resetUserPassword(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppColors.warning.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.lock_reset, color: AppColors.warning),
              const SizedBox(width: 8),
              NeonText(
                text: 'איפוס סיסמה',
                fontSize: 18,
                glowColor: AppColors.warning,
              ),
            ],
          ),
          content: Text(
            'האם לשלוח אימייל לאיפוס סיסמה ל-${user.displayName}?',
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'ביטול',
                style: TextStyle(color: AppColors.secondaryText),
              ),
            ),
            NeonButton(
              text: 'שלח',
              onPressed: () {
                context.pop();
                _sendPasswordReset(user);
              },
              glowColor: AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }
  
  void _sendPasswordReset(UserModel user) async {
    try {
      final result = await AdminUserService.sendPasswordReset(user.email);
      
      if (result.isSuccess) {
        _showSuccessSnackBar(result.message);
      } else {
        _showErrorSnackBar(result.message);
      }
    } catch (e) {
      _showErrorSnackBar('שגיאה בשליחת איפוס סיסמה: $e');
    }
  }
  
  void _createUser() async {
    if (!_createFormKey.currentState!.validate()) return;
    
    try {
      final displayName = '${_createFirstNameController.text.trim()} ${_createLastNameController.text.trim()}';
      
      final result = await AdminUserService.createUser(
        email: _createEmailController.text.trim(),
        displayName: displayName,
        role: _selectedCreateRole,
        phone: _createPhoneController.text.trim().isEmpty ? null : _createPhoneController.text.trim(),
        address: _createAddressController.text.trim().isEmpty ? null : _createAddressController.text.trim(),
      );
      
      if (result.isSuccess) {
        if (mounted) {
          context.pop();
          _showSuccessSnackBar(result.message);
          _loadUsers(isRefresh: true);
        }
      } else {
        _showErrorSnackBar(result.message);
      }
    } catch (e) {
      _showErrorSnackBar('שגיאה ביצירת משתמש: $e');
    }
  }
  
  void _updateUser(UserModel user) async {
    if (!_editFormKey.currentState!.validate()) return;
    
    try {
      final updateData = <String, dynamic>{
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'display_name': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      };
      
      // Check if role changed
      if (_selectedEditRole != user.role.value) {
        final roleResult = await AdminUserService.changeUserRole(user.id, _selectedEditRole);
        if (!roleResult.isSuccess) {
          _showErrorSnackBar(roleResult.message);
          return;
        }
      }
      
      final result = await AdminUserService.updateUser(user.id, updateData);
      
      if (result.isSuccess) {
        if (mounted) {
          context.pop();
          _showSuccessSnackBar(result.message);
          _loadUsers(isRefresh: true);
        }
      } else {
        _showErrorSnackBar(result.message);
      }
    } catch (e) {
      _showErrorSnackBar('שגיאה בעדכון משתמש: $e');
    }
  }
  
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      enabled: enabled,
      style: GoogleFonts.assistant(
        color: enabled ? AppColors.primaryText : AppColors.secondaryText,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.neonBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        filled: true,
        fillColor: enabled ? AppColors.darkCard : AppColors.darkSurface,
      ),
    );
  }
  
  Widget _buildRoleDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      style: GoogleFonts.assistant(color: AppColors.primaryText),
      dropdownColor: AppColors.darkSurface,
      decoration: InputDecoration(
        labelText: 'תפקיד',
        labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.neonBlue, width: 2),
        ),
        filled: true,
        fillColor: AppColors.darkCard,
      ),
      items: const [
        DropdownMenuItem(value: 'student', child: Text('תלמיד')),
        DropdownMenuItem(value: 'parent', child: Text('הורה')),
        DropdownMenuItem(value: 'instructor', child: Text('מדריך')),
        DropdownMenuItem(value: 'admin', child: Text('מנהל')),
      ],
    );
  }
}