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
import '../../services/album_service.dart';

/// עמוד ניהול אלבומי גלריה עבור מנהלי זזה דאנס
class AlbumManagementPage extends ConsumerStatefulWidget {
  const AlbumManagementPage({super.key});

  @override
  ConsumerState<AlbumManagementPage> createState() => _AlbumManagementPageState();
}

class _AlbumManagementPageState extends ConsumerState<AlbumManagementPage> {
  final AlbumService _albumService = AlbumService();
  final _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _albums = [];
  String _searchQuery = '';
  String _selectedCategory = 'all';
  bool _showFeaturedOnly = false;
  
  bool _isLoading = false;
  String _errorMessage = '';
  bool _hasError = false;
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadAlbums(isRefresh: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAlbums({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 0;
      _hasMoreData = true;
      _albums.clear();
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final albums = await _albumService.getAllAlbums(
        categoryId: _selectedCategory == 'all' ? null : _selectedCategory,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        isFeatured: _showFeaturedOnly ? true : null,
        sortBy: 'sort_order',
        ascending: true,
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      setState(() {
        if (isRefresh) {
          _albums = albums;
        } else {
          _albums.addAll(albums);
        }
        _hasMoreData = albums.length == _pageSize;
        _currentPage++;
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
            text: 'ניהול אלבומי גלריה',
            fontSize: 24,
            glowColor: AppColors.neonTurquoise,
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
                Icons.add_photo_alternate,
                color: AppColors.neonGreen,
              ),
              onPressed: _showCreateAlbumDialog,
              tooltip: 'צור אלבום חדש',
            ),
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: AppColors.neonTurquoise,
              ),
              onPressed: () => _loadAlbums(isRefresh: true),
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
                
                // סטטיסטיקות אלבומים
                _buildAlbumStats(),
                
                // רשימת אלבומים
                Expanded(
                  child: _isLoading && _albums.isEmpty
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.neonTurquoise,
                          ),
                        )
                      : _buildAlbumsList(),
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
                color: AppColors.neonTurquoise.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: AppColors.primaryText),
              decoration: InputDecoration(
                hintText: 'חפש אלבומים...',
                hintStyle: TextStyle(color: AppColors.secondaryText),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.neonTurquoise,
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
                          _loadAlbums(isRefresh: true);
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
                  'קטגוריה',
                  _selectedCategory,
                  const {
                    'all': 'הכל',
                    'dance': 'ריקודים',
                    'events': 'אירועים', 
                    'classes': 'שיעורים',
                    'performances': 'הופעות',
                  },
                  (value) {
                    setState(() => _selectedCategory = value!);
                    _loadAlbums(isRefresh: true);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() => _showFeaturedOnly = !_showFeaturedOnly);
                    _loadAlbums(isRefresh: true);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _showFeaturedOnly
                          ? AppColors.neonTurquoise.withValues(alpha: 0.2)
                          : AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _showFeaturedOnly
                            ? AppColors.neonTurquoise
                            : AppColors.neonTurquoise.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: _showFeaturedOnly
                              ? AppColors.neonTurquoise
                              : AppColors.secondaryText,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'מוצגים',
                          style: GoogleFonts.assistant(
                            color: _showFeaturedOnly
                                ? AppColors.neonTurquoise
                                : AppColors.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
          color: AppColors.neonTurquoise.withValues(alpha: 0.3),
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

  void _debounceSearch() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadAlbums(isRefresh: true);
      }
    });
  }

  Widget _buildAlbumStats() {
    final totalAlbums = _albums.length;
    final featuredAlbums = _albums.where((a) => a['is_featured'] == true).length;
    final activeAlbums = _albums.where((a) => a['is_active'] == true).length;

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
          color: AppColors.neonTurquoise.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('סך הכל', totalAlbums.toString(), AppColors.neonTurquoise),
          _buildStatItem('מוצגים', featuredAlbums.toString(), AppColors.neonPink),
          _buildStatItem('פעילים', activeAlbums.toString(), AppColors.neonGreen),
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

  Widget _buildAlbumsList() {
    if (_hasError && _albums.isEmpty) {
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
              onPressed: () => _loadAlbums(isRefresh: true),
              glowColor: AppColors.neonTurquoise,
            ),
          ],
        ),
      );
    }

    if (_albums.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_album_outlined,
              size: 80,
              color: AppColors.secondaryText,
            ),
            const SizedBox(height: 20),
            NeonText(
              text: _searchQuery.isNotEmpty 
                  ? 'לא נמצאו אלבומים'
                  : 'אין אלבומים במערכת',
              fontSize: 18,
              glowColor: AppColors.neonTurquoise,
            ),
            const SizedBox(height: 10),
            Text(
              _searchQuery.isNotEmpty 
                  ? 'נסה לשנות את החיפוש או הסינון'
                  : 'צור אלבומים חדשים לגלריה',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            NeonButton(
              text: 'צור אלבום חדש',
              onPressed: _showCreateAlbumDialog,
              glowColor: AppColors.neonGreen,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _albums.length + (_hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _albums.length) {
          // Load more indicator
          return Center(
            child: _isLoading
                ? CircularProgressIndicator(
                    color: AppColors.neonTurquoise,
                  )
                : NeonButton(
                    text: 'טען עוד',
                    onPressed: () => _loadAlbums(),
                    glowColor: AppColors.neonTurquoise,
                  ),
          );
        }
        
        final album = _albums[index];
        return _buildAlbumCard(album, index);
      },
    );
  }

  Widget _buildAlbumCard(Map<String, dynamic> album, int index) {
    final isActive = album['is_active'] == true;
    final isFeatured = album['is_featured'] == true;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showAlbumDetails(album),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.cardGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive 
                  ? AppColors.neonTurquoise.withValues(alpha: 0.3)
                  : AppColors.error.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // תמונת כריכה
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    color: AppColors.darkSurface,
                  ),
                  child: Stack(
                    children: [
                      if (album['cover_image_url'] != null)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            album['cover_image_url'],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage();
                            },
                          ),
                        )
                      else
                        _buildPlaceholderImage(),
                      
                      // Featured badge
                      if (isFeatured)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.neonPink,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      
                      // Status badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.success : AppColors.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isActive ? 'פעיל' : 'לא פעיל',
                            style: GoogleFonts.assistant(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // פרטי אלבום
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        album['name_he'] ?? 'ללא שם',
                        style: GoogleFonts.assistant(
                          color: AppColors.primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (album['description_he'] != null) ...[
                        Text(
                          album['description_he'],
                          style: GoogleFonts.assistant(
                            color: AppColors.secondaryText,
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                      ],
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.photo,
                            color: AppColors.neonTurquoise,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${album['gallery_items_count'] ?? 0} פריטים',
                            style: GoogleFonts.assistant(
                              color: AppColors.secondaryText,
                              fontSize: 10,
                            ),
                          ),
                          const Spacer(),
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert,
                              color: AppColors.secondaryText,
                              size: 16,
                            ),
                            color: AppColors.darkSurface,
                            onSelected: (value) => _handleAlbumAction(value, album),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'view',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility, color: AppColors.info, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'צפה',
                                      style: GoogleFonts.assistant(
                                        color: AppColors.primaryText,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: AppColors.neonTurquoise, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'ערוך',
                                      style: GoogleFonts.assistant(
                                        color: AppColors.primaryText,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'toggle_featured',
                                child: Row(
                                  children: [
                                    Icon(
                                      isFeatured ? Icons.star_outline : Icons.star,
                                      color: AppColors.neonPink,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isFeatured ? 'הסר מהמוצגים' : 'הוסף למוצגים',
                                      style: GoogleFonts.assistant(
                                        color: AppColors.primaryText,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'duplicate',
                                child: Row(
                                  children: [
                                    Icon(Icons.copy, color: AppColors.neonBlue, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'שכפל',
                                      style: GoogleFonts.assistant(
                                        color: AppColors.primaryText,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: (index * 100).ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.darkSurface,
      child: Icon(
        Icons.photo_album,
        color: AppColors.secondaryText,
        size: 40,
      ),
    );
  }

  void _handleAlbumAction(String action, Map<String, dynamic> album) {
    switch (action) {
      case 'view':
        _showAlbumDetails(album);
        break;
      case 'edit':
        _showEditAlbumDialog(album);
        break;
      case 'toggle_featured':
        _toggleFeaturedStatus(album);
        break;
      case 'duplicate':
        _duplicateAlbum(album);
        break;
    }
  }

  void _showAlbumDetails(Map<String, dynamic> album) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: NeonText(
          text: 'פרטי האלבום',
          fontSize: 20,
          glowColor: AppColors.neonBlue,
        ),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (album['cover_image_url'] != null)
                  Container(
                    height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(album['cover_image_url']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                
                _buildDetailRow('שם האלבום', album['name_he'] ?? 'לא זמין'),
                if (album['name_en'] != null)
                  _buildDetailRow('שם באנגלית', album['name_en']),
                if (album['description_he'] != null)
                  _buildDetailRow('תיאור', album['description_he']),
                _buildDetailRow('סטטוס', album['is_active'] == true ? 'פעיל' : 'לא פעיל'),
                _buildDetailRow('מומלץ', album['is_featured'] == true ? 'כן' : 'לא'),
                _buildDetailRow('סדר תצוגה', album['sort_order']?.toString() ?? '0'),
                _buildDetailRow('נוצר בתאריך', _formatDate(album['created_at'])),
                if (album['updated_at'] != null)
                  _buildDetailRow('עודכן בתאריך', _formatDate(album['updated_at'])),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'סגור',
              style: GoogleFonts.assistant(color: AppColors.primaryText),
            ),
          ),
          NeonButton(
            text: 'ערוך אלבום',
            onPressed: () {
              context.pop();
              _showEditAlbumDialog(album);
            },
            glowColor: AppColors.neonTurquoise,
          ),
        ],
      ),
    );
  }

  void _showCreateAlbumDialog() {
    final nameHeController = TextEditingController();
    final nameEnController = TextEditingController();
    final descriptionHeController = TextEditingController();
    final descriptionEnController = TextEditingController();
    final sortOrderController = TextEditingController(text: '0');
    bool isFeatured = false;
    bool isActive = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: NeonText(
          text: 'יצירת אלבום חדש',
          fontSize: 20,
          glowColor: AppColors.neonGreen,
        ),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Album Name Hebrew
                TextField(
                  controller: nameHeController,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.assistant(color: AppColors.primaryText),
                  decoration: InputDecoration(
                    labelText: 'שם האלבום (עברית)*',
                    labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.darkBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.neonGreen),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Album Name English
                TextField(
                  controller: nameEnController,
                  style: GoogleFonts.assistant(color: AppColors.primaryText),
                  decoration: InputDecoration(
                    labelText: 'שם האלבום (אנגלית)',
                    labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.darkBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.neonGreen),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Description Hebrew
                TextField(
                  controller: descriptionHeController,
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                  style: GoogleFonts.assistant(color: AppColors.primaryText),
                  decoration: InputDecoration(
                    labelText: 'תיאור (עברית)',
                    labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.darkBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.neonGreen),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Sort Order
                TextField(
                  controller: sortOrderController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.assistant(color: AppColors.primaryText),
                  decoration: InputDecoration(
                    labelText: 'סדר תצוגה',
                    labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.darkBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.neonGreen),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Featured and Active switches
                StatefulBuilder(
                  builder: (context, setDialogState) => Column(
                    children: [
                      SwitchListTile(
                        title: Text(
                          'אלבום מומלץ',
                          style: GoogleFonts.assistant(color: AppColors.primaryText),
                        ),
                        value: isFeatured,
                        onChanged: (value) {
                          setDialogState(() {
                            isFeatured = value;
                          });
                        },
                        activeThumbColor: AppColors.neonGreen,
                      ),
                      SwitchListTile(
                        title: Text(
                          'אלבום פעיל',
                          style: GoogleFonts.assistant(color: AppColors.primaryText),
                        ),
                        value: isActive,
                        onChanged: (value) {
                          setDialogState(() {
                            isActive = value;
                          });
                        },
                        activeThumbColor: AppColors.neonGreen,
                      ),
                    ],
                  ),
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
              style: GoogleFonts.assistant(color: AppColors.secondaryText),
            ),
          ),
          NeonButton(
            text: 'צור אלבום',
            onPressed: () async {
              if (nameHeController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('נדרש שם האלבום בעברית'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              
              try {
                await _albumService.createAlbum(
                  nameHe: nameHeController.text.trim(),
                  nameEn: nameEnController.text.trim().isEmpty ? null : nameEnController.text.trim(),
                  descriptionHe: descriptionHeController.text.trim().isEmpty ? null : descriptionHeController.text.trim(),
                  descriptionEn: descriptionEnController.text.trim().isEmpty ? null : descriptionEnController.text.trim(),
                  categoryId: '06b838e8-bc7d-467c-b84c-2db3e63de2cd', // ברירת מחדל - היפ הופ קלאסי
                  isFeatured: isFeatured,
                  isActive: isActive,
                  sortOrder: int.tryParse(sortOrderController.text) ?? 0,
                );
                
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('האלבום "${nameHeController.text}" נוצר בהצלחה'),
                    backgroundColor: AppColors.success,
                  ),
                );
                
                _loadAlbums(isRefresh: true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('שגיאה ביצירת האלבום: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            glowColor: AppColors.neonGreen,
          ),
        ],
      ),
    ).then((_) {
      // Dispose controllers
      nameHeController.dispose();
      nameEnController.dispose();
      descriptionHeController.dispose();
      descriptionEnController.dispose();
      sortOrderController.dispose();
    });
  }

  void _showEditAlbumDialog(Map<String, dynamic> album) {
    final nameHeController = TextEditingController(text: album['name_he'] ?? '');
    final nameEnController = TextEditingController(text: album['name_en'] ?? '');
    final descriptionHeController = TextEditingController(text: album['description_he'] ?? '');
    final descriptionEnController = TextEditingController(text: album['description_en'] ?? '');
    final sortOrderController = TextEditingController(text: album['sort_order']?.toString() ?? '0');
    bool isFeatured = album['is_featured'] ?? false;
    bool isActive = album['is_active'] ?? true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: NeonText(
          text: 'עריכת אלבום',
          fontSize: 20,
          glowColor: AppColors.neonTurquoise,
        ),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Album Name Hebrew
                TextField(
                  controller: nameHeController,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.assistant(color: AppColors.primaryText),
                  decoration: InputDecoration(
                    labelText: 'שם האלבום (עברית)*',
                    labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.darkBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.neonTurquoise),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Album Name English
                TextField(
                  controller: nameEnController,
                  style: GoogleFonts.assistant(color: AppColors.primaryText),
                  decoration: InputDecoration(
                    labelText: 'שם האלבום (אנגלית)',
                    labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.darkBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.neonTurquoise),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Description Hebrew
                TextField(
                  controller: descriptionHeController,
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                  style: GoogleFonts.assistant(color: AppColors.primaryText),
                  decoration: InputDecoration(
                    labelText: 'תיאור (עברית)',
                    labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.darkBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.neonTurquoise),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Sort Order
                TextField(
                  controller: sortOrderController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.assistant(color: AppColors.primaryText),
                  decoration: InputDecoration(
                    labelText: 'סדר תצוגה',
                    labelStyle: GoogleFonts.assistant(color: AppColors.secondaryText),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.darkBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.neonTurquoise),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Featured and Active switches
                StatefulBuilder(
                  builder: (context, setDialogState) => Column(
                    children: [
                      SwitchListTile(
                        title: Text(
                          'אלבום מומלץ',
                          style: GoogleFonts.assistant(color: AppColors.primaryText),
                        ),
                        value: isFeatured,
                        onChanged: (value) {
                          setDialogState(() {
                            isFeatured = value;
                          });
                        },
                        activeThumbColor: AppColors.neonTurquoise,
                      ),
                      SwitchListTile(
                        title: Text(
                          'אלבום פעיל',
                          style: GoogleFonts.assistant(color: AppColors.primaryText),
                        ),
                        value: isActive,
                        onChanged: (value) {
                          setDialogState(() {
                            isActive = value;
                          });
                        },
                        activeThumbColor: AppColors.neonTurquoise,
                      ),
                    ],
                  ),
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
              style: GoogleFonts.assistant(color: AppColors.secondaryText),
            ),
          ),
          NeonButton(
            text: 'שמור שינויים',
            onPressed: () async {
              if (nameHeController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('נדרש שם האלבום בעברית'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              
              try {
                await _albumService.updateAlbum(
                  albumId: album['id'],
                  nameHe: nameHeController.text.trim(),
                  nameEn: nameEnController.text.trim().isEmpty ? null : nameEnController.text.trim(),
                  descriptionHe: descriptionHeController.text.trim().isEmpty ? null : descriptionHeController.text.trim(),
                  descriptionEn: descriptionEnController.text.trim().isEmpty ? null : descriptionEnController.text.trim(),
                  isFeatured: isFeatured,
                  isActive: isActive,
                  sortOrder: int.tryParse(sortOrderController.text) ?? 0,
                );
                
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('האלבום "${nameHeController.text}" עודכן בהצלחה'),
                    backgroundColor: AppColors.success,
                  ),
                );
                
                _loadAlbums(isRefresh: true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('שגיאה בעדכון האלבום: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            glowColor: AppColors.neonTurquoise,
          ),
        ],
      ),
    ).then((_) {
      // Dispose controllers
      nameHeController.dispose();
      nameEnController.dispose();
      descriptionHeController.dispose();
      descriptionEnController.dispose();
      sortOrderController.dispose();
    });
  }

  void _toggleFeaturedStatus(Map<String, dynamic> album) async {
    final isFeatured = album['is_featured'] == true;
    try {
      await _albumService.updateAlbum(
        albumId: album['id'],
        isFeatured: !isFeatured,
      );
      _loadAlbums(isRefresh: true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFeatured ? 'האלבום הוסר מהמוצגים' : 'האלבום נוסף למוצגים'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בעדכון סטטוס האלבום: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _duplicateAlbum(Map<String, dynamic> album) async {
    try {
      await _albumService.duplicateAlbum(album['id'], includeItems: false);
      _loadAlbums(isRefresh: true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('האלבום שוכפל בהצלחה'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בשכפול האלבום: $e'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.assistant(
                color: AppColors.neonBlue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
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

  String _formatDate(String? dateString) {
    if (dateString == null) return 'לא זמין';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'תאריך לא תקין';
    }
  }
}