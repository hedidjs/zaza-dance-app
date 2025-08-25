import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart' as share_plus;
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/data_providers.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_bottom_navigation.dart';
import '../../../../shared/widgets/zaza_logo.dart';
import '../../../../shared/models/gallery_model.dart';

class GalleryPage extends ConsumerStatefulWidget {
  const GalleryPage({super.key});

  @override
  ConsumerState<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends ConsumerState<GalleryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CategoryModel> _categories = [];
  List<String> _categoryTabs = ['הכל'];
  bool _isLoadingCategories = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this); // Start with 1 for 'הכל'
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ref.read(categoriesProvider.future);
      
      if (mounted) {
        setState(() {
          _categories = categories.where((cat) => cat.isActive).toList();
          _categoryTabs = ['הכל', ..._categories.map((cat) => cat.nameHe)];
          _isLoadingCategories = false;
          
          // Rebuild tab controller with correct length
          _tabController.dispose();
          _tabController = TabController(length: _categoryTabs.length, vsync: this);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<GalleryModel> _getFilteredItems(List<GalleryModel> allItems, int categoryIndex) {
    if (categoryIndex == 0) return allItems; // הכל
    
    // סינון לפי קטגוריה
    if (categoryIndex <= _categories.length) {
      final selectedCategory = _categories[categoryIndex - 1]; // -1 כי האינדקס 0 הוא 'הכל'
      return allItems.where((item) => item.categoryId == selectedCategory.id).toList();
    }
    
    return allItems;
  }

  @override
  Widget build(BuildContext context) {
    final galleryAsync = ref.watch(galleryItemsProvider);
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const ZazaLogo.appBar(),
          leading: Builder(
            builder: (context) => IconButton(
              icon: GlowIcon(
                Icons.menu,
                color: AppColors.primaryText,
                glowColor: AppColors.neonTurquoise,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          bottom: _isLoadingCategories 
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: AppColors.neonTurquoise,
                labelColor: AppColors.primaryText,
                unselectedLabelColor: AppColors.secondaryText,
                isScrollable: true,
                tabs: _categoryTabs.map((category) => Tab(text: category)).toList(),
              ),
        ),
        drawer: const AppDrawer(),
        body: AnimatedGradientBackground(
          child: SafeArea(
            child: _isLoadingCategories
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.neonTurquoise,
                  ),
                )
              : galleryAsync.when(
                  data: (items) => TabBarView(
                    controller: _tabController,
                    children: _categoryTabs.asMap().entries.map((entry) {
                      final categoryIndex = entry.key;
                      return _buildGalleryGrid(items, categoryIndex);
                    }).toList(),
                  ),
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: AppColors.neonTurquoise,
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: AppColors.secondaryText,
                    ),
                    const SizedBox(height: 20),
                    NeonText(
                      text: 'שגיאה בטעינת הגלריה',
                      fontSize: 18,
                      glowColor: AppColors.neonPink,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'אנא נסו שוב מאוחר יותר',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: const AppBottomNavigation(
          currentPage: NavigationPage.gallery,
        ),
      ),
    );
  }

  Widget _buildGalleryGrid(List<GalleryModel> allItems, int categoryIndex) {
    final items = _getFilteredItems(allItems, categoryIndex);
    
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
              text: categoryIndex == 0 
                ? 'אין תמונות בגלריה'
                : 'אין תמונות בקטגוריה זו',
              fontSize: 18,
              glowColor: AppColors.neonPink,
            ),
            const SizedBox(height: 10),
            Text(
              categoryIndex == 0
                ? 'אין תמונות או סרטונים זמינים כרגע'
                : 'אין תוכן זמין בקטגוריה זו כרגע',
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
                  _buildFeaturedCarousel(items),
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

  Widget _buildFeaturedCarousel(List<GalleryModel> items) {
    final featuredItems = items.where((item) => item.isFeatured).toList();
    
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

  Widget _buildFeaturedItem(GalleryModel item, int index) {
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
                  imageUrl: item.thumbnailUrl ?? item.mediaUrl,
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
              if (item.mediaType == MediaType.video)
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
                      text: item.titleHe,
                      fontSize: 16,
                      glowColor: AppColors.neonTurquoise,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.descriptionHe ?? '',
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

  Widget _buildGalleryItem(GalleryModel item, int index) {
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
                  imageUrl: item.thumbnailUrl ?? item.mediaUrl,
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
              if (item.mediaType == MediaType.video)
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
                      item.titleHe,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.descriptionHe != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.descriptionHe!,
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

  void _openItemDetails(GalleryModel item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildItemDetailsSheet(item),
    );
  }

  Widget _buildItemDetailsSheet(GalleryModel item) {
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
                                imageUrl: item.thumbnailUrl ?? item.mediaUrl,
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
                            if (item.mediaType == MediaType.video)
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
                    text: item.titleHe,
                    fontSize: 24,
                    glowColor: AppColors.neonPink,
                    fontWeight: FontWeight.bold,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Description
                  if (item.descriptionHe != null)
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        child: Text(
                          item.descriptionHe!,
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
                          onPressed: () async {
                            try {
                              final shareText = 'בדקו את הצילום הזה מהסטודיו של זזה דאנס! 💃\n\n'
                                  '${item.titleHe}\n\n'
                                  '${item.descriptionHe ?? ''}\n\n'
                                  'בואו להצטרף למשפחת זזה דאנס! 🎵';
                              
                              await share_plus.SharePlus.instance.share(share_plus.ShareParams(text: shareText));
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('שגיאה בשיתוף: $e'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
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
                            context.pop();
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