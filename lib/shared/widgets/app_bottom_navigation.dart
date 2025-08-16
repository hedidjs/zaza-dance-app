import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../features/gallery/presentation/pages/gallery_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/tutorials/presentation/pages/tutorials_page.dart';
import '../../features/updates/presentation/pages/updates_page.dart';

enum NavigationPage { home, tutorials, gallery, updates }

class AppBottomNavigation extends StatelessWidget {
  final NavigationPage currentPage;

  const AppBottomNavigation({
    super.key,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.backgroundGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.neonPink.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonPink.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: _getCurrentIndex(),
        selectedItemColor: AppColors.neonPink,
        unselectedItemColor: AppColors.secondaryText,
        selectedLabelStyle: GoogleFonts.assistant(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.assistant(
          fontSize: 11,
        ),
        onTap: (index) => _onTap(context, index),
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.home, NavigationPage.home),
            label: 'בית',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.video_library, NavigationPage.tutorials),
            label: 'מדריכים',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.photo_library, NavigationPage.gallery),
            label: 'גלריה',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.announcement, NavigationPage.updates),
            label: 'עדכונים',
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData iconData, NavigationPage page) {
    final isSelected = currentPage == page;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.neonPink.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Icon(
        iconData,
        size: 24,
        shadows: isSelected
            ? [
                Shadow(
                  color: AppColors.neonPink,
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
    );
  }

  int _getCurrentIndex() {
    switch (currentPage) {
      case NavigationPage.home:
        return 0;
      case NavigationPage.tutorials:
        return 1;
      case NavigationPage.gallery:
        return 2;
      case NavigationPage.updates:
        return 3;
    }
  }

  void _onTap(BuildContext context, int index) {
    final targetPage = NavigationPage.values[index];
    
    if (targetPage == currentPage) return; // Already on this page

    Widget page;
    switch (targetPage) {
      case NavigationPage.home:
        page = const HomePage();
        break;
      case NavigationPage.tutorials:
        page = const TutorialsPage();
        break;
      case NavigationPage.gallery:
        page = const GalleryPage();
        break;
      case NavigationPage.updates:
        page = const UpdatesPage();
        break;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}