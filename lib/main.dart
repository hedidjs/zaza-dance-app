import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import 'core/config/supabase_config.dart';
import 'core/providers/auth_provider.dart';
import 'core/services/deep_link_service.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/auth_callback_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/tutorials/presentation/pages/tutorials_page.dart';
import 'features/gallery/presentation/pages/gallery_page.dart';
import 'features/updates/presentation/pages/updates_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/profile/presentation/pages/edit_profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  runApp(const ProviderScope(child: ZazaDanceApp()));
}

class ZazaDanceApp extends ConsumerStatefulWidget {
  const ZazaDanceApp({super.key});

  @override
  ConsumerState<ZazaDanceApp> createState() => _ZazaDanceAppState();
}

class _ZazaDanceAppState extends ConsumerState<ZazaDanceApp> {
  late final GoRouter _router;
  final DeepLinkService _deepLinkService = DeepLinkService();

  @override
  void initState() {
    super.initState();
    _setupRouter();
  }

  void _setupRouter() {
    _router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final user = ref.read(currentUserProvider).valueOrNull;
        final isLoggedIn = user != null;
        final isAuthRoute = state.fullPath?.startsWith('/auth') ?? false;
        
        // אם המשתמש לא מחובר ולא בדף אותנטיקציה, הפנה להתחברות
        if (!isLoggedIn && !isAuthRoute && state.fullPath != '/') {
          return '/auth/login';
        }
        
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const AuthWrapper(),
        ),
        GoRoute(
          path: '/auth/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/auth/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/auth/callback',
          builder: (context, state) => const AuthCallbackPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/tutorials',
          builder: (context, state) => const TutorialsPage(),
        ),
        GoRoute(
          path: '/gallery',
          builder: (context, state) => const GalleryPage(),
        ),
        GoRoute(
          path: '/updates',
          builder: (context, state) => const UpdatesPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/profile/edit',
          builder: (context, state) => const EditProfilePage(),
        ),
      ],
    );
    
    // אתחול Deep Link Service
    _deepLinkService.initialize(_router);
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'זזה דאנס - Zaza Dance',
      theme: _buildTheme(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF00FF), // Fuchsia
        secondary: Color(0xFF40E0D0), // Turquoise
        background: Color(0xFF0A0A0A),
        surface: Color(0xFF1A1A1A),
      ),
      textTheme: GoogleFonts.assistantTextTheme().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    
    return currentUser.when(
      data: (user) {
        if (user != null) {
          return const HomePage();
        } else {
          return const LandingPage();
        }
      },
      loading: () => const LoadingPage(),
      error: (error, stack) => const LoginPage(),
    );
  }
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFFFF00FF),
            ),
            const SizedBox(height: 20),
            Text(
              'זזה דאנס',
              style: GoogleFonts.assistant(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Main fade animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Subtle pulse animation for glow effects
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Slide animation for sections
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _animationController.forward();
    _pulseController.repeat(reverse: true);
    
    // Delayed slide animation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.3, 0.7, 1.0],
              colors: [
                Color(0xFF0F0F23), // Deep navy with subtle purple hint
                Color(0xFF1A1A2E), // Darker navy
                Color(0xFF16213E), // Even darker with blue tint
                Color(0xFF0F0F23), // Back to deep navy
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroSection(),
                  const SizedBox(height: 80),
                  _buildAboutSection(),
                  const SizedBox(height: 80),
                  _buildFeaturesSection(),
                  const SizedBox(height: 80),
                  _buildContactSection(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Main logo with subtle glow
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return _buildEnhancedNeonText(
                  'זזה דאנס',
                  fontSize: 64,
                  color: const Color(0xFFE91E63), // Softer pink instead of pure fuchsia
                  glowIntensity: _pulseAnimation.value,
                );
              },
            ),
            const SizedBox(height: 16),
            
            // English subtitle with different color
            _buildEnhancedNeonText(
              'ZAZA DANCE',
              fontSize: 28,
              color: const Color(0xFF26C6DA), // Softer cyan instead of pure turquoise
              glowIntensity: 0.4,
            ),
            
            const SizedBox(height: 50),
            
            // Tagline with elegant typography
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Text(
                      'בית דיגיטלי לקהילת ההיפ הופ',
                      style: GoogleFonts.assistant(
                        fontSize: 22,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'כאן הקצב מתחיל והחלומות מתגשמים',
                      style: GoogleFonts.assistant(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w300,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 70),
            
            // Enhanced CTA button
            SlideTransition(
              position: _slideAnimation,
              child: _buildEnhancedCtaButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedNeonText(String text, {
    required double fontSize, 
    required Color color, 
    double glowIntensity = 0.5
  }) {
    return Container(
      child: Text(
        text,
        style: GoogleFonts.assistant(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: color,
          shadows: [
            // Main subtle glow
            Shadow(
              color: color.withOpacity(0.3 * glowIntensity),
              blurRadius: 8,
              offset: const Offset(0, 0),
            ),
            // Secondary soft glow
            Shadow(
              color: color.withOpacity(0.2 * glowIntensity),
              blurRadius: 16,
              offset: const Offset(0, 0),
            ),
            // Minimal outer glow
            Shadow(
              color: color.withOpacity(0.1 * glowIntensity),
              blurRadius: 24,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNeonText(String text, {required double fontSize, required Color color}) {
    return _buildEnhancedNeonText(
      text, 
      fontSize: fontSize, 
      color: color, 
      glowIntensity: 0.4
    );
  }

  Widget _buildEnhancedCtaButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE91E63).withOpacity(0.8), // Softer pink
            const Color(0xFF26C6DA).withOpacity(0.8), // Softer cyan
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'גלה את הקסם',
                  style: GoogleFonts.assistant(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCtaButton() {
    return _buildEnhancedCtaButton();
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildNeonText(
            'על הסטודיו',
            fontSize: 36,
            color: const Color(0xFF40E0D0),
          ),
          const SizedBox(height: 30),
          Text(
            'זזה דאנס הוא מקום בו הקצב מתחיל, הריתמוס מדבר והאנרגיה של ההיפ הופ חיה.\n'
            'כאן כל תלמיד מוצא את הביטוי הייחודי שלו ובונה ביטחון דרך התנועה.',
            style: GoogleFonts.assistant(
              fontSize: 18,
              color: Colors.white70,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildNeonText(
            'מה תמצאו כאן',
            fontSize: 36,
            color: const Color(0xFFFF00FF),
          ),
          const SizedBox(height: 40),
          _buildFeatureGrid(),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      {'title': 'גלריית תמונות ווידאו', 'icon': Icons.photo_library},
      {'title': 'מדריכי ריקוד', 'icon': Icons.play_circle_outline},
      {'title': 'עדכונים חמים', 'icon': Icons.notifications_active},
      {'title': 'קהילה חמה', 'icon': Icons.people},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureCard(
          feature['title'] as String,
          feature['icon'] as IconData,
        );
      },
    );
  }

  Widget _buildFeatureCard(String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF40E0D0).withOpacity(0.3),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2A2A2A).withOpacity(0.8),
            const Color(0xFF1A1A1A).withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF40E0D0).withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: const Color(0xFF40E0D0),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: GoogleFonts.assistant(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildNeonText(
            'בואו להצטרף',
            fontSize: 36,
            color: const Color(0xFFFF00FF),
          ),
          const SizedBox(height: 30),
          Text(
            'מוכנים להרגיש את הקצב? בואו להיות חלק מהקהילה שלנו!',
            style: GoogleFonts.assistant(
              fontSize: 18,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildContactButtons(),
        ],
      ),
    );
  }

  Widget _buildContactButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildContactButton(
          'WhatsApp',
          Icons.message,
          const Color(0xFF25D366),
        ),
        _buildContactButton(
          'Instagram',
          Icons.camera_alt,
          const Color(0xFFE4405F),
        ),
        _buildContactButton(
          'טלפון',
          Icons.phone,
          const Color(0xFF40E0D0),
        ),
      ],
    );
  }

  Widget _buildContactButton(String label, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Implement contact functionality
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: color.withOpacity(0.5)),
          ),
        ),
        icon: Icon(icon, color: color, size: 20),
        label: Text(
          label,
          style: GoogleFonts.assistant(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}