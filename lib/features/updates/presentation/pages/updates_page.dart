import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/data_providers.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/neon_text.dart';
import '../../../../shared/models/update_model.dart';

class UpdatesPage extends ConsumerStatefulWidget {
  const UpdatesPage({super.key});

  @override
  ConsumerState<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends ConsumerState<UpdatesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<String> get categories => [
    'הכל',
    'הודעות',
    'הישגי תלמידים', 
    'טיפים ממדריכים',
    'אירועים',
  ];
  
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

  List<UpdateModel> _getFilteredUpdates(List<UpdateModel> allUpdates, int categoryIndex) {
    List<UpdateModel> filtered = List.from(allUpdates);
    
    // Filter by category
    switch (categoryIndex) {
      case 0: // הכל
        break;
      case 1: // הודעות
        filtered = filtered.where((u) => u.updateType == UpdateType.announcement).toList();
        break;
      case 2: // הישגי תלמידים
        filtered = filtered.where((u) => u.updateType == UpdateType.achievement).toList();
        break;
      case 3: // טיפים ממדריכים
        filtered = filtered.where((u) => u.updateType == UpdateType.tip).toList();
        break;
      case 4: // אירועים
        filtered = filtered.where((u) => u.updateType == UpdateType.event).toList();
        break;
    }
    
    // Sort by pinned first, then by date
    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.publishDate.compareTo(a.publishDate);
    });
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final updatesAsync = ref.watch(updatesProvider);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: NeonText(
          text: 'עדכונים חמים',
          fontSize: 24,
          glowColor: AppColors.neonTurquoise,
        ),
        actions: [
          IconButton(
            icon: GlowIcon(
              Icons.notifications,
              color: AppColors.primaryText,
              glowColor: AppColors.neonPink,
            ),
            onPressed: () {
              _showNotificationSettings();
            },
          ),
        ],
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
          child: updatesAsync.when(
            data: (updates) => TabBarView(
              controller: _tabController,
              children: categories.asMap().entries.map((entry) {
                final categoryIndex = entry.key;
                return _buildUpdatesFeed(updates, categoryIndex);
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
                    text: 'שגיאה בטעינת העדכונים',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _refreshUpdates();
        },
        backgroundColor: AppColors.neonPink,
        child: GlowIcon(
          Icons.refresh,
          color: AppColors.primaryText,
          glowColor: AppColors.neonPink,
        ),
      ),
    );
  }

  Widget _buildUpdatesFeed(List<UpdateModel> allUpdates, int categoryIndex) {
    final updates = _getFilteredUpdates(allUpdates, categoryIndex);
    
    if (updates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.announcement_outlined,
              size: 80,
              color: AppColors.secondaryText,
            ),
            const SizedBox(height: 20),
            NeonText(
              text: 'אין עדכונים בקטגוריה זו',
              fontSize: 18,
              glowColor: AppColors.neonTurquoise,
            ),
            const SizedBox(height: 10),
            Text(
              'עדכונים חדשים יתווספו בקרוב',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshUpdates,
      color: AppColors.neonTurquoise,
      backgroundColor: AppColors.darkCard,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomScrollView(
          slivers: [
            // Pinned updates section
            if (categoryIndex == 0) ..._buildPinnedSection(updates),
            
            // Regular updates
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final update = updates[index];
                  final isPinnedSection = categoryIndex == 0 && 
                      updates.where((u) => u.isPinned).isNotEmpty;
                  final adjustedIndex = isPinnedSection && update.isPinned ? index : index;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildUpdateCard(update, adjustedIndex),
                  );
                },
                childCount: updates.length,
              ),
            ),
            
            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 80), // Extra space for FAB
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPinnedSection(List<UpdateModel> updates) {
    final pinnedUpdates = updates.where((u) => u.isPinned).toList();
    
    if (pinnedUpdates.isEmpty) return [];
    
    return [
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GlowIcon(
                  Icons.push_pin,
                  color: AppColors.neonPink,
                  glowColor: AppColors.neonPink,
                  size: 20,
                ),
                const SizedBox(width: 8),
                NeonText(
                  text: 'הודעות נעוצות',
                  fontSize: 18,
                  glowColor: AppColors.neonPink,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...pinnedUpdates.asMap().entries.map((entry) {
              final index = entry.key;
              final update = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPinnedCard(update, index),
              );
            }),
            const SizedBox(height: 20),
            NeonText(
              text: 'עדכונים אחרונים',
              fontSize: 18,
              glowColor: AppColors.neonTurquoise,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ];
  }

  Widget _buildPinnedCard(UpdateModel update, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: AppColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.neonPink.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonPink.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: _buildUpdateContent(update, index, isPinned: true),
    ).animate().fadeIn(duration: 600.ms, delay: (index * 100).ms).slideX(begin: 0.3);
  }

  Widget _buildUpdateCard(UpdateModel update, int index) {
    if (update.isPinned) return const SizedBox.shrink(); // Skip pinned in regular list
    
    return GestureDetector(
      onTap: () => _openUpdateDetails(update),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: AppColors.cardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.neonTurquoise.withValues(alpha: 0.3),
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
        child: _buildUpdateContent(update, index),
      ).animate().fadeIn(duration: 500.ms, delay: (index * 50).ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildUpdateContent(UpdateModel update, int index, {bool isPinned = false}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with type badge and timestamp
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getUpdateTypeColor(update.updateType).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getUpdateTypeColor(update.updateType).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getUpdateTypeIcon(update.updateType),
                      color: _getUpdateTypeColor(update.updateType),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getUpdateTypeText(update.updateType),
                      style: TextStyle(
                        color: _getUpdateTypeColor(update.updateType),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (DateTime.now().difference(update.publishDate).inDays < 3)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.neonPink.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.neonPink.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'חדש',
                    style: TextStyle(
                      color: AppColors.neonPink,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Text(
                _formatTimeAgo(update.publishDate),
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Title
          Text(
            update.titleHe,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: isPinned ? 18 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Content
          Text(
            update.contentHe,
            style: TextStyle(
              color: AppColors.primaryText.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.4,
            ),
            maxLines: isPinned ? null : 3,
            overflow: isPinned ? null : TextOverflow.ellipsis,
          ),
          
          // Image if available
          if (update.imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: update.imageUrl!,
                height: isPinned ? 200 : 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: isPinned ? 200 : 150,
                  color: AppColors.darkCard,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.neonTurquoise,
                    ),
                  ),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Footer with author and engagement
          Row(
            children: [
              Text(
                'מאת: ${update.authorName ?? 'לא ידוע'}',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _toggleLike(update),
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: AppColors.neonPink,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          update.likesCount.toString(),
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.comment,
                        color: AppColors.neonTurquoise,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        update.commentsCount.toString(),
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getUpdateTypeColor(UpdateType type) {
    switch (type) {
      case UpdateType.announcement:
        return AppColors.neonPink;
      case UpdateType.achievement:
        return AppColors.neonTurquoise;
      case UpdateType.tip:
        return AppColors.neonPurple;
      case UpdateType.event:
        return AppColors.neonBlue;
      case UpdateType.news:
        return AppColors.neonTurquoise;
    }
  }

  IconData _getUpdateTypeIcon(UpdateType type) {
    switch (type) {
      case UpdateType.announcement:
        return Icons.campaign;
      case UpdateType.achievement:
        return Icons.star;
      case UpdateType.tip:
        return Icons.lightbulb;
      case UpdateType.event:
        return Icons.event;
      case UpdateType.news:
        return Icons.newspaper;
    }
  }

  String _getUpdateTypeText(UpdateType type) {
    switch (type) {
      case UpdateType.announcement:
        return 'הודעה';
      case UpdateType.achievement:
        return 'הישג תלמיד';
      case UpdateType.tip:
        return 'טיפ מדריך';
      case UpdateType.event:
        return 'אירוע';
      case UpdateType.news:
        return 'חדשות';
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return 'לפני ${difference.inDays} ימים';
    } else if (difference.inHours > 0) {
      return 'לפני ${difference.inHours} שעות';
    } else if (difference.inMinutes > 0) {
      return 'לפני ${difference.inMinutes} דקות';
    } else {
      return 'עכשיו';
    }
  }

  void _toggleLike(UpdateModel update) {
    setState(() {
      // Toggle like logic would go here
      // In real app, this would call Supabase API
    });
  }

  void _openUpdateDetails(UpdateModel update) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UpdateDetailsPage(update: update),
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: NeonText(
          text: 'הגדרות התראות',
          fontSize: 18,
          glowColor: AppColors.neonPink,
        ),
        content: Text(
          'בעתיד ניתן יהיה להגדיר התראות לעדכונים חדשים',
          style: TextStyle(color: AppColors.primaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'סגור',
              style: TextStyle(color: AppColors.neonTurquoise),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshUpdates() async {
    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // In real app, this would fetch latest updates from Supabase
    });
  }
}

// Update Details Page (placeholder for now)
class UpdateDetailsPage extends StatelessWidget {
  final UpdateModel update;

  const UpdateDetailsPage({
    super.key,
    required this.update,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'פרטי העדכון',
          style: TextStyle(color: AppColors.primaryText),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedGradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeonText(
                text: update.titleHe,
                fontSize: 24,
                glowColor: AppColors.neonPink,
              ),
              const SizedBox(height: 20),
              if (update.imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: update.imageUrl!,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Text(
                update.contentHe,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.cardGradient),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.neonTurquoise.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'פרטי העדכון',
                      style: TextStyle(
                        color: AppColors.neonTurquoise,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'מאת: ${update.authorName ?? 'לא ידוע'}',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'תאריך: ${update.publishDate.day}/${update.publishDate.month}/${update.publishDate.year}',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'קטגוריה: ${_getUpdateTypeText(update.updateType)}',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getUpdateTypeText(UpdateType type) {
    switch (type) {
      case UpdateType.announcement:
        return 'הודעה';
      case UpdateType.achievement:
        return 'הישג תלמיד';
      case UpdateType.tip:
        return 'טיפ מדריך';
      case UpdateType.event:
        return 'אירוע';
      case UpdateType.news:
        return 'חדשות';
    }
  }
}