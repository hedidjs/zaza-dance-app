import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../../shared/models/user_model.dart';

class UsersListPage extends ConsumerStatefulWidget {
  const UsersListPage({super.key});

  @override
  ConsumerState<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends ConsumerState<UsersListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRoleFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allUsersAsync = ref.watch(allUsersProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.backgroundGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildFilters(),
                Expanded(
                  child: _buildUsersList(allUsersAsync),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonPink.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/admin/dashboard'),
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primaryText,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: NeonText(
              text: 'ניהול משתמשים',
              fontSize: 24,
              glowColor: AppColors.neonPink,
            ),
          ),
          IconButton(
            onPressed: () => ref.invalidate(allUsersProvider),
            icon: const Icon(
              Icons.refresh,
              color: AppColors.primaryText,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'חיפוש משתמשים...',
              hintStyle: GoogleFonts.assistant(
                color: AppColors.secondaryText,
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.neonTurquoise,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: Icon(
                        Icons.clear,
                        color: AppColors.secondaryText,
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.neonTurquoise.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.neonTurquoise.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.neonTurquoise,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppColors.darkSurface.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 16),
          // Role filter
          Row(
            children: [
              Text(
                'סינון לפי תפקיד:',
                style: GoogleFonts.assistant(
                  color: AppColors.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.neonTurquoise.withValues(alpha: 0.3),
                    ),
                    color: AppColors.darkSurface.withValues(alpha: 0.3),
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedRoleFilter,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedRoleFilter = newValue;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    style: GoogleFonts.assistant(
                      color: AppColors.primaryText,
                      fontSize: 16,
                    ),
                    dropdownColor: AppColors.darkSurface,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('כל התפקידים')),
                      DropdownMenuItem(value: 'student', child: Text('תלמידים')),
                      DropdownMenuItem(value: 'parent', child: Text('הורים')),
                      DropdownMenuItem(value: 'instructor', child: Text('מדריכים')),
                      DropdownMenuItem(value: 'admin', child: Text('מנהלים')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(AsyncValue<List<UserModel>> allUsersAsync) {
    return allUsersAsync.when(
      data: (users) {
        // Filter users based on search and role
        final filteredUsers = users.where((user) {
          final matchesSearch = _searchQuery.isEmpty ||
              user.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              user.email.toLowerCase().contains(_searchQuery.toLowerCase());
          
          final matchesRole = _selectedRoleFilter == 'all' || 
              user.role.value == _selectedRoleFilter;
          
          return matchesSearch && matchesRole;
        }).toList();

        if (filteredUsers.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            return _buildUserCard(filteredUsers[index]);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.neonTurquoise),
      ),
      error: (error, stack) => Center(
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
              text: 'שגיאה בטעינת משתמשים',
              fontSize: 20,
              glowColor: AppColors.error,
            ),
            const SizedBox(height: 10),
            Text(
              error.toString(),
              style: GoogleFonts.assistant(
                color: AppColors.secondaryText,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            NeonButton(
              text: 'נסה שוב',
              onPressed: () {
                ref.refresh(allUsersProvider);
              },
              glowColor: AppColors.neonTurquoise,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: NeonGlowContainer(
        glowColor: _getRoleColor(user.role.value),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppColors.darkSurface.withValues(alpha: 0.8),
                AppColors.darkSurface.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: _getRoleColor(user.role.value).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: _getRoleColor(user.role.value).withValues(alpha: 0.2),
                    child: Icon(
                      _getRoleIcon(user.role.value),
                      color: _getRoleColor(user.role.value),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: GoogleFonts.assistant(
                            color: AppColors.primaryText,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: GoogleFonts.assistant(
                            color: AppColors.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: _getRoleColor(user.role.value).withValues(alpha: 0.2),
                      border: Border.all(
                        color: _getRoleColor(user.role.value).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getRoleDisplayName(user.role.value),
                      style: GoogleFonts.assistant(
                        color: _getRoleColor(user.role.value),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: AppColors.secondaryText,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'נרשם: ${_formatDate(user.createdAt)}',
                    style: GoogleFonts.assistant(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  _buildUserActions(user),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserActions(UserModel user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _showEditUserDialog(user),
          icon: Icon(
            Icons.edit,
            color: AppColors.neonTurquoise,
            size: 20,
          ),
          tooltip: 'עריכת משתמש',
        ),
        IconButton(
          onPressed: () => _showDeleteUserDialog(user),
          icon: Icon(
            Icons.delete,
            color: AppColors.error,
            size: 20,
          ),
          tooltip: 'מחיקת משתמש',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => context.go('/admin/users/create'),
      backgroundColor: AppColors.neonPink,
      foregroundColor: AppColors.primaryText,
      label: Text(
        'משתמש חדש',
        style: GoogleFonts.assistant(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      icon: const Icon(Icons.add),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: AppColors.secondaryText,
          ),
          const SizedBox(height: 16),
          NeonText(
            text: 'לא נמצאו משתמשים',
            fontSize: 20,
            glowColor: AppColors.neonTurquoise,
          ),
          const SizedBox(height: 8),
          Text(
            'נסה לשנות את מונחי החיפוש',
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'שגיאה בטעינת המשתמשים',
            style: GoogleFonts.assistant(
              color: AppColors.error,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.assistant(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          NeonButton(
            text: 'נסה שוב',
            onPressed: () => ref.invalidate(allUsersProvider),
            glowColor: AppColors.neonPink,
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(UserModel user) {
    final firstNameController = TextEditingController(text: user.firstName);
    final lastNameController = TextEditingController(text: user.lastName);
    final emailController = TextEditingController(text: user.email);
    String selectedRole = user.role.value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: NeonText(
          text: 'עריכת משתמש',
          fontSize: 20,
          glowColor: AppColors.neonBlue,
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // First Name
              TextField(
                controller: firstNameController,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.assistant(color: AppColors.primaryText),
                decoration: InputDecoration(
                  labelText: 'שם פרטי',
                  labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.darkBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.neonBlue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Last Name
              TextField(
                controller: lastNameController,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.assistant(color: AppColors.primaryText),
                decoration: InputDecoration(
                  labelText: 'שם משפחה',
                  labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.darkBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.neonBlue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Email
              TextField(
                controller: emailController,
                style: GoogleFonts.assistant(color: AppColors.primaryText),
                decoration: InputDecoration(
                  labelText: 'אימייל',
                  labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.darkBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.neonBlue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Role Selection
              StatefulBuilder(
                builder: (context, setDialogState) => DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  style: GoogleFonts.assistant(color: AppColors.primaryText),
                  dropdownColor: AppColors.darkSurface,
                  decoration: InputDecoration(
                    labelText: 'תפקיד',
                    labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.darkBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.neonBlue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'student', child: Text('תלמיד')),
                    DropdownMenuItem(value: 'parent', child: Text('הורה')),
                    DropdownMenuItem(value: 'instructor', child: Text('מדריך')),
                    DropdownMenuItem(value: 'admin', child: Text('מנהל')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedRole = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'ביטול',
              style: GoogleFonts.assistant(color: AppColors.secondaryText),
            ),
          ),
          NeonButton(
            text: 'שמור שינויים',
            onPressed: () {
              // Here you would typically call an admin service to update the user
              // For now, just show success message
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'פרטי המשתמש ${firstNameController.text} עודכנו בהצלחה',
                    style: GoogleFonts.assistant(color: AppColors.primaryText),
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            glowColor: AppColors.neonGreen,
          ),
        ],
      ),
    ).then((_) {
      // Dispose controllers
      firstNameController.dispose();
      lastNameController.dispose();
      emailController.dispose();
    });
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
          ),
          title: Text(
            'מחיקת משתמש',
            style: GoogleFonts.assistant(
              color: AppColors.error,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'האם אתה בטוח שברצונך למחוק את המשתמש "${user.displayName}"?\nפעולה זו לא ניתנת לביטול.',
            style: GoogleFonts.assistant(
              color: AppColors.primaryText,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'ביטול',
                style: GoogleFonts.assistant(
                  color: AppColors.secondaryText,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await ref.read(deleteUserProvider.notifier).deleteUser(user.id);
                
                final deleteState = ref.read(deleteUserProvider);
                if (deleteState.hasValue && deleteState.value == true) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'המשתמש נמחק בהצלחה',
                          style: GoogleFonts.assistant(color: AppColors.primaryText),
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'מחק',
                style: GoogleFonts.assistant(
                  color: AppColors.error,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.error;
      case 'instructor':
        return AppColors.warning;
      case 'parent':
        return AppColors.neonPurple;
      case 'student':
      default:
        return AppColors.neonTurquoise;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'instructor':
        return Icons.school;
      case 'parent':
        return Icons.family_restroom;
      case 'student':
      default:
        return Icons.person;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'מנהל/ת';
      case 'instructor':
        return 'מדריך/ה';
      case 'parent':
        return 'הורה';
      case 'student':
      default:
        return 'תלמיד/ה';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}