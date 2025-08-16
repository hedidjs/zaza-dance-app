import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';

/// עמוד ניהול תוכן עבור מנהלי זזה דאנס
class ContentManagementPage extends ConsumerStatefulWidget {
  const ContentManagementPage({super.key});

  @override
  ConsumerState<ContentManagementPage> createState() => _ContentManagementPageState();
}

class _ContentManagementPageState extends ConsumerState<ContentManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            text: 'ניהול תוכן',
            fontSize: 24,
            glowColor: AppColors.neonPink,
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.primaryText,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.neonPink,
            labelColor: AppColors.primaryText,
            unselectedLabelColor: AppColors.secondaryText,
            tabs: const [
              Tab(text: 'מדריכי וידאו'),
              Tab(text: 'גלריה'),
              Tab(text: 'עדכונים'),
            ],
          ),
        ),
        body: AnimatedGradientBackground(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTutorialManagement(),
              _buildGalleryManagement(),
              _buildUpdatesManagement(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialManagement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // כפתור הוספת מדריך
          SizedBox(
            width: double.infinity,
            child: NeonButton(
              text: 'הוסף מדריך חדש',
              onPressed: _showAddTutorialDialog,
              glowColor: AppColors.neonPink,
              icon: Icons.video_call,
            ),
          ),
          
          const SizedBox(height: 30),
          
          // סטטיסטיקות מדריכים
          _buildTutorialStats(),
          
          const SizedBox(height: 30),
          
          // רשימת מדריכים אחרונים
          _buildRecentTutorials(),
        ],
      ),
    );
  }

  Widget _buildGalleryManagement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // כפתורי הוספה
          Row(
            children: [
              Expanded(
                child: NeonButton(
                  text: 'הוסף תמונות',
                  onPressed: _showAddImagesDialog,
                  glowColor: AppColors.neonTurquoise,
                  icon: Icons.photo_camera,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeonButton(
                  text: 'הוסף וידאו',
                  onPressed: _showAddVideoDialog,
                  glowColor: AppColors.neonBlue,
                  icon: Icons.videocam,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // סטטיסטיקות גלריה
          _buildGalleryStats(),
          
          const SizedBox(height: 30),
          
          // תמונות ווידאו אחרונים
          _buildRecentGalleryItems(),
        ],
      ),
    );
  }

  Widget _buildUpdatesManagement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // כפתור יצירת עדכון
          SizedBox(
            width: double.infinity,
            child: NeonButton(
              text: 'צור עדכון חדש',
              onPressed: _showCreateUpdateDialog,
              glowColor: AppColors.neonGreen,
              icon: Icons.announcement,
            ),
          ),
          
          const SizedBox(height: 30),
          
          // סטטיסטיקות עדכונים
          _buildUpdatesStats(),
          
          const SizedBox(height: 30),
          
          // עדכונים אחרונים
          _buildRecentUpdates(),
        ],
      ),
    );
  }

  Widget _buildTutorialStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonPink.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeonText(
            text: 'סטטיסטיקות מדריכים',
            fontSize: 18,
            glowColor: AppColors.neonPink,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('סך הכל', '58', AppColors.neonPink),
              _buildStatItem('השבוע', '+3', AppColors.neonGreen),
              _buildStatItem('צפיות', '12.4K', AppColors.neonTurquoise),
              _buildStatItem('אהבו', '2.1K', AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonTurquoise.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeonText(
            text: 'סטטיסטיקות גלריה',
            fontSize: 18,
            glowColor: AppColors.neonTurquoise,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('תמונות', '892', AppColors.neonTurquoise),
              _buildStatItem('וידאו', '47', AppColors.neonBlue),
              _buildStatItem('היום', '+15', AppColors.neonGreen),
              _buildStatItem('נפח', '2.3GB', AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatesStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeonText(
            text: 'סטטיסטיקות עדכונים',
            fontSize: 18,
            glowColor: AppColors.neonGreen,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('סך הכל', '23', AppColors.neonGreen),
              _buildStatItem('פעילים', '12', AppColors.info),
              _buildStatItem('השבוע', '+2', AppColors.success),
              _buildStatItem('צפיות', '1.8K', AppColors.neonPink),
            ],
          ),
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

  Widget _buildRecentTutorials() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: NeonText(
                text: 'מדריכים אחרונים',
                fontSize: 18,
                glowColor: AppColors.neonPink,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToAllTutorials(),
              child: Text(
                'הצג הכל',
                style: GoogleFonts.assistant(
                  color: AppColors.neonPink,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildContentList([
          {
            'title': 'ברייקדאנס למתחילים - פרק 3',
            'subtitle': 'מדריך: דני כהן',
            'status': 'פורסם',
            'date': 'היום',
            'icon': Icons.play_circle,
            'color': AppColors.neonPink,
          },
          {
            'title': 'פופינג מתקדם - טכניקות חדשות',
            'subtitle': 'מדריך: שרה לוי',
            'status': 'בעריכה',
            'date': 'אתמול',
            'icon': Icons.edit,
            'color': AppColors.warning,
          },
          {
            'title': 'כוריאוגרפיה לילדים',
            'subtitle': 'מדריך: מיכל דוד',
            'status': 'ממתין לאישור',
            'date': 'לפני יומיים',
            'icon': Icons.pending,
            'color': AppColors.info,
          },
        ]),
      ],
    );
  }

  Widget _buildRecentGalleryItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: NeonText(
                text: 'גלריה אחרונה',
                fontSize: 18,
                glowColor: AppColors.neonTurquoise,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToAllGallery(),
              child: Text(
                'הצג הכל',
                style: GoogleFonts.assistant(
                  color: AppColors.neonTurquoise,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildContentList([
          {
            'title': 'הופעת סיום - תמונות',
            'subtitle': '15 תמונות',
            'status': 'פורסם',
            'date': 'היום',
            'icon': Icons.photo_library,
            'color': AppColors.neonTurquoise,
          },
          {
            'title': 'שיעור ברייקדאנס - וידאו',
            'subtitle': '3:47 דקות',
            'status': 'פורסם',
            'date': 'אתמול',
            'icon': Icons.videocam,
            'color': AppColors.neonBlue,
          },
          {
            'title': 'אחורי הקלעים',
            'subtitle': '8 תמונות',
            'status': 'בעריכה',
            'date': 'לפני יומיים',
            'icon': Icons.edit,
            'color': AppColors.warning,
          },
        ]),
      ],
    );
  }

  Widget _buildRecentUpdates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: NeonText(
                text: 'עדכונים אחרונים',
                fontSize: 18,
                glowColor: AppColors.neonGreen,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToAllUpdates(),
              child: Text(
                'הצג הכל',
                style: GoogleFonts.assistant(
                  color: AppColors.neonGreen,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildContentList([
          {
            'title': 'שיעורים מיוחדים לחופש הגדול',
            'subtitle': 'הודעה כללית',
            'status': 'פעיל',
            'date': 'היום',
            'icon': Icons.announcement,
            'color': AppColors.neonGreen,
          },
          {
            'title': 'תחרות ריקוד שנתית',
            'subtitle': 'אירוע מיוחד',
            'status': 'פעיל',
            'date': 'השבוע',
            'icon': Icons.event,
            'color': AppColors.neonPink,
          },
          {
            'title': 'שינוי בלוחות זמנים',
            'subtitle': 'עדכון חשוב',
            'status': 'הסתיים',
            'date': 'השבוע שעבר',
            'icon': Icons.schedule,
            'color': AppColors.secondaryText,
          },
        ]),
      ],
    );
  }

  Widget _buildContentList(List<Map<String, dynamic>> items) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: index < items.length - 1
                  ? Border(bottom: BorderSide(color: AppColors.darkBorder))
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item['color'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item['icon'],
                    color: item['color'],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: GoogleFonts.assistant(
                          color: AppColors.primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['subtitle'],
                        style: GoogleFonts.assistant(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: item['color'].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: item['color'].withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        item['status'],
                        style: GoogleFonts.assistant(
                          color: item['color'],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['date'],
                      style: GoogleFonts.assistant(
                        color: AppColors.secondaryText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
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

  void _showAddTutorialDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildUploadDialog(
        title: 'הוסף מדריך חדש',
        icon: Icons.video_call,
        glowColor: AppColors.neonPink,
        onUpload: _uploadTutorial,
        acceptedTypes: 'MP4, MOV, AVI',
        fileType: 'video',
      ),
    );
  }

  void _showAddImagesDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildUploadDialog(
        title: 'הוסף תמונות לגלריה',
        icon: Icons.photo_camera,
        glowColor: AppColors.neonTurquoise,
        onUpload: _uploadImages,
        acceptedTypes: 'JPG, PNG, GIF',
        fileType: 'image',
      ),
    );
  }

  void _showAddVideoDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildUploadDialog(
        title: 'הוסף וידאו לגלריה',
        icon: Icons.videocam,
        glowColor: AppColors.neonBlue,
        onUpload: _uploadGalleryVideo,
        acceptedTypes: 'MP4, MOV, AVI',
        fileType: 'video',
      ),
    );
  }

  void _showCreateUpdateDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String updateType = 'general';
    
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppColors.neonGreen.withOpacity(0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.announcement, color: AppColors.neonGreen),
              const SizedBox(width: 8),
              NeonText(
                text: 'צור עדכון חדש',
                fontSize: 18,
                glowColor: AppColors.neonGreen,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: GoogleFonts.assistant(color: AppColors.primaryText),
                  decoration: InputDecoration(
                    labelText: 'כותרת העדכון',
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
                      borderSide: BorderSide(color: AppColors.neonGreen, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.darkCard,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  style: GoogleFonts.assistant(color: AppColors.primaryText),
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'תוכן העדכון',
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
                      borderSide: BorderSide(color: AppColors.neonGreen, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.darkCard,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: updateType,
                  style: GoogleFonts.assistant(color: AppColors.primaryText),
                  dropdownColor: AppColors.darkSurface,
                  decoration: InputDecoration(
                    labelText: 'סוג העדכון',
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
                      borderSide: BorderSide(color: AppColors.neonGreen, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.darkCard,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'general', child: Text('הודעה כללית')),
                    DropdownMenuItem(value: 'event', child: Text('אירוע מיוחד')),
                    DropdownMenuItem(value: 'important', child: Text('עדכון חשוב')),
                    DropdownMenuItem(value: 'schedule', child: Text('שינוי בלוח זמנים')),
                  ],
                  onChanged: (value) => updateType = value ?? 'general',
                ),
              ],
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
              text: 'פרסם',
              onPressed: () {
                Navigator.of(context).pop();
                _createUpdate(titleController.text, contentController.text, updateType);
              },
              glowColor: AppColors.neonGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadDialog({
    required String title,
    required IconData icon,
    required Color glowColor,
    required VoidCallback onUpload,
    required String acceptedTypes,
    required String fileType,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: glowColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            Icon(icon, color: glowColor),
            const SizedBox(width: 8),
            NeonText(
              text: title,
              fontSize: 18,
              glowColor: glowColor,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                border: Border.all(
                  color: glowColor.withOpacity(0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 60,
                    color: glowColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'גרור קבצים לכאן או לחץ לבחירה',
                    style: GoogleFonts.assistant(
                      color: AppColors.primaryText,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'קבצים נתמכים: $acceptedTypes',
                    style: GoogleFonts.assistant(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
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
            text: 'בחר קבצים',
            onPressed: () {
              Navigator.of(context).pop();
              onUpload();
            },
            glowColor: glowColor,
          ),
        ],
      ),
    );
  }

  Future<void> _uploadTutorial() async {
    // TODO: Implement tutorial upload
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('העלאת מדריך בפיתוח'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  Future<void> _uploadImages() async {
    // TODO: Implement images upload
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('העלאת תמונות בפיתוח'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  Future<void> _uploadGalleryVideo() async {
    // TODO: Implement gallery video upload
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('העלאת וידאו לגלריה בפיתוח'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _createUpdate(String title, String content, String type) {
    // TODO: Implement update creation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('העדכון "$title" נוצר בהצלחה'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _navigateToAllTutorials() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ניהול מדריכים מלא בפיתוח'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _navigateToAllGallery() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ניהול גלריה מלא בפיתוח'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _navigateToAllUpdates() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ניהול עדכונים מלא בפיתוח'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}