import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/data_providers.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../../shared/models/gallery_model.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data - בעתיד יחובר ל-Supabase
  final List<GalleryItemModel> _allItems = [
    GalleryItemModel(
      id: '1',
      title: 'שיעור היפ הופ מתקדמים',
      description: 'אימון אנרגטי עם הכוריאוגרפיה החדשה',
      mediaUrl: 'https://picsum.photos/400/600?random=1',
      mediaType: MediaType.image,
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    GalleryItemModel(
      id: '2',
      title: 'הופעה בתחרות עירונית',
      description: 'התלמידים שלנו זורחים על הבמה',
      mediaUrl: 'https://picsum.photos/400/600?random=2',
      mediaType: MediaType.video,
      thumbnailUrl: 'https://picsum.photos/400/600?random=2',
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    GalleryItemModel(
      id: '3',
      title: 'אמצע השיעור',
      description: 'תלמידים מתרגלים את הצעדים החדשים',
      mediaUrl: 'https://picsum.photos/400/600?random=3',
      mediaType: MediaType.image,
      isFeatured: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    GalleryItemModel(
      id: '4',
      title: 'הכנות לתחרות',
      description: 'שבועות של אימונים מתוקים לפני ההופעה הגדולה',
      mediaUrl: 'https://picsum.photos/400/600?random=4',
      mediaType: MediaType.video,
      thumbnailUrl: 'https://picsum.photos/400/600?random=4',
      isFeatured: false,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    GalleryItemModel(
      id: '5',
      title: 'תלמידת השנה',
      description: 'מיה זוכת התואר - גאים בך!',
      mediaUrl: 'https://picsum.photos/400/600?random=5',
      mediaType: MediaType.image,
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    GalleryItemModel(
      id: '6',
      title: 'הסטודיו החדש',
      description: 'מרחב יצירה מושלם לריקוד',
      mediaUrl: 'https://picsum.photos/400/600?random=6',
      mediaType: MediaType.image,
      isFeatured: false,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  List<String> get categories => ['הכל', 'שיעורים', 'הופעות', 'חיי הסטודיו', 'תלמידים'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<GalleryItemModel> _getFilteredItems(int categoryIndex) {
    if (categoryIndex == 0) return _allItems; // הכל
    
    // כאן נוכל להוסיף לוגיקה לסינון לפי קטגוריות
    // בינתיים מחזיר את כל הפריטים
    return _allItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: NeonText(
          text: 'גלריה',
          fontSize: 24,
          glowColor: AppColors.neonTurquoise,
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.neonTurquoise,
          labelColor: AppColors.primaryText,
          unselectedLabelColor: AppColors.secondaryText,
          isScrollable: true,
          tabs: categories.map((category) => Tab(text: category)).toList(),
        ),
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: categories.asMap().entries.map((entry) {
              final categoryIndex = entry.key;
              return _buildGalleryGrid(categoryIndex);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryGrid(int categoryIndex) {
    final items = _getFilteredItems(categoryIndex);
    
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: AppColors.secondaryText,
            ),
            const SizedBox(height: 20),
            NeonText(
              text: 'אין תמונות בקטגוריה זו',
              fontSize: 18,
              glowColor: AppColors.neonPink,
            ),
            const SizedBox(height: 10),
            Text(
              'תמונות חדשות יתווספו בקרוב',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomScrollView(
        slivers: [
          // Featured items carousel
          if (categoryIndex == 0) ...[
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NeonText(
                    text: 'מומלצים',
                    fontSize: 20,
                    glowColor: AppColors.neonPink,
                  ),
                  const SizedBox(height: 16),
                  _buildFeaturedCarousel(),
                  const SizedBox(height: 30),
                  NeonText(
                    text: 'הכל',
                    fontSize: 20,
                    glowColor: AppColors.neonTurquoise,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
          
          // Grid of all items
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildGalleryItem(items[index], index);
              },
              childCount: items.length,
            ),
          ),
          
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCarousel() {
    final featuredItems = _allItems.where((item) => item.isFeatured).toList();
    
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: featuredItems.length,
        itemBuilder: (context, index) {
          final item = featuredItems[index];
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 12),
            child: _buildFeaturedItem(item, index),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedItem(GalleryItemModel item, int index) {
    return GestureDetector(
      onTap: () => _openItemDetails(item),
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: AppColors.cardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.neonPink.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonPink.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: item.displayUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.darkCard,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.neonTurquoise,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.darkCard,
                    child: Icon(
                      Icons.error,
                      color: AppColors.error,
                      size: 40,
                    ),
                  ),
                ),
              ),
              
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Video play button
              if (item.isVideo)
                Positioned(
                  top: 16,
                  right: 16,
                  child: GlowIcon(
                    Icons.play_circle_filled,
                    color: AppColors.primaryText,
                    glowColor: AppColors.neonTurquoise,
                    size: 36,
                  ),
                ),
              
              // Content
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NeonText(
                      text: item.title,
                      fontSize: 16,
                      glowColor: AppColors.neonTurquoise,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description ?? '',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 600.ms, delay: (index * 100).ms).slideX(begin: 0.3),
    );
  }

  Widget _buildGalleryItem(GalleryItemModel item, int index) {
    return GestureDetector(
      onTap: () => _openItemDetails(item),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: AppColors.cardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.neonTurquoise.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonTurquoise.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: item.displayUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.darkCard,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.neonTurquoise,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.darkCard,
                    child: Icon(
                      Icons.broken_image,
                      color: AppColors.secondaryText,
                      size: 30,
                    ),
                  ),
                ),
              ),
              
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Video play button
              if (item.isVideo)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GlowIcon(
                    Icons.play_circle_filled,
                    color: AppColors.primaryText,
                    glowColor: AppColors.neonTurquoise,
                    size: 24,
                  ),
                ),
              
              // Content
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.description!,
                        style: TextStyle(
                          color: AppColors.primaryText.withValues(alpha: 0.8),
                          fontSize: 10,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 500.ms, delay: (index * 50).ms).scale(begin: const Offset(0.8, 0.8)),
    );
  }

  void _openItemDetails(GalleryItemModel item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildItemDetailsSheet(item),
    );
  }

  Widget _buildItemDetailsSheet(GalleryItemModel item) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.backgroundGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: AppColors.neonTurquoise.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.secondaryText,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image/Video
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.neonPink.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CachedNetworkImage(
                                imageUrl: item.displayUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.darkCard,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.neonTurquoise,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (item.isVideo)
                              Center(
                                child: GlowIcon(
                                  Icons.play_circle_filled,
                                  color: AppColors.primaryText,
                                  glowColor: AppColors.neonTurquoise,
                                  size: 80,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title
                  NeonText(
                    text: item.title,
                    fontSize: 24,
                    glowColor: AppColors.neonPink,
                    fontWeight: FontWeight.bold,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Description
                  if (item.description != null)
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        child: Text(
                          item.description!,
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: הוספת לוגיקת שיתוף
                          },
                          icon: Icon(Icons.share),
                          label: Text('שתף'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonTurquoise,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close),
                          label: Text('סגור'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkCard,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}