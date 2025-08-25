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
import '../../services/category_service.dart';

/// עמוד ניהול קטגוריות עבור מנהלי זזה דאנס
class CategoryManagementPage extends ConsumerStatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  ConsumerState<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends ConsumerState<CategoryManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final CategoryService _categoryService = CategoryService();
  
  List<Map<String, dynamic>> _tutorialCategories = [];
  List<Map<String, dynamic>> _galleryCategories = [];
  List<Map<String, dynamic>> _updateCategories = [];
  
  bool _isLoading = false;
  String _errorMessage = '';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final futures = await Future.wait([
        _categoryService.getTutorialCategories(activeOnly: false),
        _categoryService.getGalleryCategories(activeOnly: false),
        _categoryService.getUpdateCategories(activeOnly: false),
      ]);

      setState(() {
        _tutorialCategories = futures[0];
        _galleryCategories = futures[1];
        _updateCategories = futures[2];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
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
            text: 'ניהול קטגוריות',
            fontSize: 24,
            glowColor: AppColors.neonPink,
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
                Icons.add,
                color: AppColors.neonGreen,
              ),
              onPressed: _showAddCategoryDialog,
              tooltip: 'הוסף קטגוריה',
            ),
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: AppColors.neonTurquoise,
              ),
              onPressed: _loadCategories,
              tooltip: 'רענן',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.neonPink,
            labelColor: AppColors.primaryText,
            unselectedLabelColor: AppColors.secondaryText,
            tabs: const [
              Tab(text: 'מדריכים'),
              Tab(text: 'גלריה'),
              Tab(text: 'עדכונים'),
            ],
          ),
        ),
        body: AnimatedGradientBackground(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.neonPink,
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCategoryTab('tutorial', _tutorialCategories, AppColors.neonPink),
                    _buildCategoryTab('gallery', _galleryCategories, AppColors.neonTurquoise),
                    _buildCategoryTab('update', _updateCategories, AppColors.neonGreen),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCategoryTab(String type, List<Map<String, dynamic>> categories, Color color) {
    if (_hasError && categories.isEmpty) {
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
              onPressed: _loadCategories,
              glowColor: color,
            ),
          ],
        ),
      );
    }

    if (categories.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 80,
              color: AppColors.secondaryText,
            ),
            const SizedBox(height: 20),
            NeonText(
              text: 'אין קטגוריות',
              fontSize: 18,
              glowColor: color,
            ),
            const SizedBox(height: 10),
            Text(
              'הוסף קטגוריות חדשות לסוג תוכן זה',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            NeonButton(
              text: 'הוסף קטגוריה',
              onPressed: () => _showAddCategoryDialog(categoryType: type),
              glowColor: color,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: categories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(category, color, type);
      },
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, Color color, String type) {
    final isActive = category['is_active'] == true;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showCategoryDetails(category),
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
              color: isActive ? color.withValues(alpha: 0.3) : AppColors.error.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // אייקון או צבע קטגוריה
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(int.parse(category['color']?.replaceAll('#', '0xFF') ?? '0xFF${color.value.toRadixString(16).substring(2)}')),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(category['icon']),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // פרטי קטגוריה
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['name_he'] ?? 'ללא שם',
                      style: GoogleFonts.assistant(
                        color: AppColors.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (category['name_en'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        category['name_en'],
                        style: GoogleFonts.assistant(
                          color: AppColors.secondaryText,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (category['description_he'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        category['description_he'],
                        style: GoogleFonts.assistant(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // סטטוס וסדר מיון
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.success.withValues(alpha: 0.2) : AppColors.error.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isActive ? AppColors.success : AppColors.error,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isActive ? 'פעיל' : 'לא פעיל',
                      style: GoogleFonts.assistant(
                        color: isActive ? AppColors.success : AppColors.error,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'סדר: ${category['sort_order'] ?? 0}',
                    style: GoogleFonts.assistant(
                      color: AppColors.secondaryText,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              
              // תפריט פעולות
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.secondaryText,
                ),
                color: AppColors.darkSurface,
                onSelected: (value) => _handleCategoryAction(value, category, type),
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
                  PopupMenuItem(
                    value: isActive ? 'deactivate' : 'activate',
                    child: Row(
                      children: [
                        Icon(
                          isActive ? Icons.visibility_off : Icons.visibility,
                          color: isActive ? AppColors.warning : AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isActive ? 'השבת' : 'הפעל',
                          style: GoogleFonts.assistant(color: AppColors.primaryText),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(Icons.copy, color: AppColors.neonBlue, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'שכפל',
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
    ).animate().fadeIn(duration: 500.ms, delay: (50).ms).slideX(begin: 0.3);
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'video_library':
        return Icons.video_library;
      case 'photo_library':
        return Icons.photo_library;
      case 'announcement':
        return Icons.announcement;
      case 'category':
        return Icons.category;
      case 'school':
        return Icons.school;
      case 'music_note':
        return Icons.music_note;
      case 'sports':
        return Icons.sports;
      default:
        return Icons.category;
    }
  }

  void _handleCategoryAction(String action, Map<String, dynamic> category, String type) {
    switch (action) {
      case 'view':
        _showCategoryDetails(category);
        break;
      case 'edit':
        _showEditCategoryDialog(category, type);
        break;
      case 'activate':
      case 'deactivate':
        _toggleCategoryStatus(category, type);
        break;
      case 'duplicate':
        _duplicateCategory(category, type);
        break;
    }
  }

  void _showCategoryDetails(Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppColors.neonPink.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(
                _getCategoryIcon(category['icon']),
                color: AppColors.neonPink,
              ),
              const SizedBox(width: 8),
              NeonText(
                text: 'פרטי קטגוריה',
                fontSize: 18,
                glowColor: AppColors.neonPink,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('שם עברית', category['name_he'] ?? 'לא הוגדר'),
                if (category['name_en'] != null)
                  _buildDetailRow('שם אנגלית', category['name_en']),
                if (category['description_he'] != null)
                  _buildDetailRow('תיאור עברית', category['description_he']),
                if (category['description_en'] != null)
                  _buildDetailRow('תיאור אנגלית', category['description_en']),
                _buildDetailRow('קוד צבע', category['color'] ?? 'לא הוגדר'),
                _buildDetailRow('אייקון', category['icon'] ?? 'ברירת מחדל'),
                _buildDetailRow('סדר מיון', category['sort_order']?.toString() ?? '0'),
                _buildDetailRow('סטטוס', (category['is_active'] == true) ? 'פעיל' : 'לא פעיל'),
                _buildDetailRow('נוצר ב', _formatDate(category['created_at'])),
                if (category['updated_at'] != null)
                  _buildDetailRow('עודכן ב', _formatDate(category['updated_at'])),
              ],
            ),
          ),
          actions: [
            NeonButton(
              text: 'סגור',
              onPressed: () => context.pop(),
              glowColor: AppColors.neonPink,
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'לא זמין';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'לא זמין';
    }
  }

  void _showAddCategoryDialog({String? categoryType}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('הוספת קטגוריה חדשה - פנייה למנהל'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showEditCategoryDialog(Map<String, dynamic> category, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('עריכת קטגוריה "${category['name_he']}" - פנייה למנהל'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _toggleCategoryStatus(Map<String, dynamic> category, String type) async {
    final isActive = category['is_active'] == true;
    try {
      await _categoryService.updateCategory(
        type,
        category['id'],
        isActive: !isActive,
      );
      _loadCategories();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isActive ? 'הקטגוריה הושבתה בהצלחה' : 'הקטגוריה הופעלה בהצלחה'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בעדכון הקטגוריה: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _duplicateCategory(Map<String, dynamic> category, String type) async {
    try {
      await _categoryService.duplicateCategory(type, category['id']);
      _loadCategories();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('הקטגוריה שוכפלה בהצלחה'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בשכפול הקטגוריה: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
}