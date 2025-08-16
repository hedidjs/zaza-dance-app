import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';
import '../../../../shared/models/user_model.dart';

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
  
  // Mock data - TODO: Replace with real data from Supabase
  List<UserModel> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Load users from Supabase
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data for demonstration
    _users = [
      UserModel(
        id: '1',
        email: 'admin@zazadance.com',
        displayName: 'מנהל ראשי',
        role: AppConstants.roleAdmin,
        phone: '050-1234567',
        address: 'תל אביב',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      UserModel(
        id: '2',
        email: 'instructor@zazadance.com',
        displayName: 'דני המדריך',
        role: AppConstants.roleInstructor,
        phone: '052-7654321',
        address: 'רמת גן',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
      UserModel(
        id: '3',
        email: 'parent@example.com',
        displayName: 'שרה כהן',
        role: AppConstants.roleParent,
        phone: '054-9876543',
        address: 'פתח תקווה',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
      UserModel(
        id: '4',
        email: 'student@example.com',
        displayName: 'נועה לוי',
        role: AppConstants.roleStudent,
        phone: '055-1357924',
        address: 'בת ים',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
      ),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  List<UserModel> get _filteredUsers {
    List<UserModel> filtered = List.from(_users);
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) =>
        user.displayName.contains(_searchQuery) ||
        user.email.contains(_searchQuery) ||
        (user.phone?.contains(_searchQuery) ?? false)
      ).toList();
    }
    
    // Filter by role
    if (_selectedRole != 'all') {
      filtered = filtered.where((user) => user.role == _selectedRole).toList();
    }
    
    // Sort
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.displayName.compareTo(b.displayName);
          break;
        case 'email':
          comparison = a.email.compareTo(b.email);
          break;
        case 'role':
          comparison = a.role.compareTo(b.role);
          break;
        case 'created_at':
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }
      return _sortDescending ? -comparison : comparison;
    });
    
    return filtered;
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
            onPressed: () => Navigator.of(context).pop(),
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
              onPressed: _loadUsers,
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
                color: AppColors.neonBlue.withOpacity(0.3),
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
                    AppConstants.roleStudent: 'תלמידים',
                    AppConstants.roleParent: 'הורים',
                    AppConstants.roleInstructor: 'מדריכים',
                    AppConstants.roleAdmin: 'מנהלים',
                  },
                  (value) => setState(() => _selectedRole = value!),
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
                  (value) => setState(() => _sortBy = value!),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _sortDescending = !_sortDescending),
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
          color: AppColors.neonBlue.withOpacity(0.3),
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
    final students = _users.where((u) => u.role == AppConstants.roleStudent).length;
    final parents = _users.where((u) => u.role == AppConstants.roleParent).length;
    final instructors = _users.where((u) => u.role == AppConstants.roleInstructor).length;
    final admins = _users.where((u) => u.role == AppConstants.roleAdmin).length;

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
          color: AppColors.neonBlue.withOpacity(0.3),
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
    final filteredUsers = _filteredUsers;

    if (filteredUsers.isEmpty) {
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
                  : 'אין משתמשים',
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
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: filteredUsers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
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
              color: roleColor.withOpacity(0.3),
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
                  backgroundImage: user.profileImageUrl != null
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
                  child: user.profileImageUrl == null
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
                            color: roleColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: roleColor.withOpacity(0.5),
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
                          '${_formatDate(user.createdAt)}',
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
                  if (user.role != AppConstants.roleAdmin)
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
                  onPressed: () => Navigator.of(context).pop(),
                  glowColor: AppColors.neonTurquoise,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return AppColors.error;
      case AppConstants.roleInstructor:
        return AppColors.neonPink;
      case AppConstants.roleParent:
        return AppColors.neonTurquoise;
      case AppConstants.roleStudent:
      default:
        return AppColors.neonGreen;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return Icons.admin_panel_settings;
      case AppConstants.roleInstructor:
        return Icons.school;
      case AppConstants.roleParent:
        return Icons.family_restroom;
      case AppConstants.roleStudent:
      default:
        return Icons.person;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return 'מנהל';
      case AppConstants.roleInstructor:
        return 'מדריך';
      case AppConstants.roleParent:
        return 'הורה';
      case AppConstants.roleStudent:
      default:
        return 'תלמיד';
    }
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
              color: _getRoleColor(user.role).withOpacity(0.3),
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
                if (user.address != null) _buildDetailRow('כתובת', user.address!),
                _buildDetailRow('תאריך הצטרפות', _formatDate(user.createdAt)),
                _buildDetailRow('עדכון אחרון', _formatDate(user.updatedAt)),
              ],
            ),
          ),
          actions: [
            NeonButton(
              text: 'סגור',
              onPressed: () => Navigator.of(context).pop(),
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
    // TODO: Implement add user dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('הוספת משתמש בפיתוח'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showEditUserDialog(UserModel user) {
    // TODO: Implement edit user dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('עריכת משתמש בפיתוח'),
        backgroundColor: AppColors.info,
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
              color: AppColors.error.withOpacity(0.3),
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
            'האם אתה בטוח שברצונך למחוק את המשתמש ${user.displayName}?\nפעולה זו לא ניתנת לביטול.',
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'ביטול',
                style: TextStyle(color: AppColors.secondaryText),
              ),
            ),
            NeonButton(
              text: 'מחק',
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUser(user);
              },
              glowColor: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  void _deleteUser(UserModel user) {
    // TODO: Implement user deletion
    setState(() {
      _users.removeWhere((u) => u.id == user.id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('המשתמש ${user.displayName} נמחק'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
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
              color: AppColors.warning.withOpacity(0.3),
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'ביטול',
                style: TextStyle(color: AppColors.secondaryText),
              ),
            ),
            NeonButton(
              text: 'שלח',
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Send password reset email
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('אימייל לאיפוס סיסמה נשלח ל-${user.displayName}'),
                    backgroundColor: AppColors.info,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              glowColor: AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }
}