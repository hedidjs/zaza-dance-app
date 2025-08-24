import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'shared/widgets/zaza_logo.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/cache_service.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/auth_callback_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/tutorials/presentation/pages/tutorials_page.dart';
import 'features/gallery/presentation/pages/gallery_page.dart';
import 'features/updates/presentation/pages/updates_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/settings/presentation/pages/general_settings_page.dart';
import 'features/settings/presentation/pages/notification_settings_page.dart';
import 'features/settings/presentation/pages/profile_settings_page.dart';
import 'features/admin/presentation/pages/analytics_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/profile/presentation/pages/edit_profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  // Initialize cache service
  await CacheService().initialize();
  
  // Auto-login admin user for development
  await _autoLoginAdminForDev();
  
  runApp(const ProviderScope(child: ZazaDanceApp()));
}

/// התחברות אוטומטית למשתמש אדמין למצב פיתוח
Future<void> _autoLoginAdminForDev() async {
  try {
    final supabase = SupabaseConfig.client;
    
    // בדיקה אם כבר מחובר
    if (supabase.auth.currentUser != null) {
      print('User already logged in: ${supabase.auth.currentUser!.email}');
      return;
    }
    
    // במצב רשת, לא ננסה להתחבר אוטומטית בגלל בעיות CORS
    if (kIsWeb) {
      print('Web mode: Skipping auto-login due to CORS restrictions');
      return;
    }
    
    // התחברות עם המשתמש האדמין למצב פיתוח (רק במובייל)
    final response = await supabase.auth.signInWithPassword(
      email: 'dev@zazadance.com',
      password: 'dev123456',
    );
    
    if (response.user != null) {
      print('✅ Auto-logged in as admin: ${response.user!.email}');
    }
  } catch (e) {
    print('❌ Auto-login failed: $e');
    // לא נעצור את האפליקציה, פשוט נמשיך בלי התחברות
  }
}

class ZazaDanceApp extends ConsumerStatefulWidget {
  const ZazaDanceApp({super.key});

  @override
  ConsumerState<ZazaDanceApp> createState() => _ZazaDanceAppState();
}

class _ZazaDanceAppState extends ConsumerState<ZazaDanceApp> {
  late final GoRouter _router;
  final DeepLinkService _deepLinkService = DeepLinkService();
  final PushNotificationService _pushNotificationService = PushNotificationService();

  @override
  void initState() {
    super.initState();
    _setupRouter();
    _initializeServices();
  }

  void _initializeServices() async {
    // אתחול שירות ההתראות
    await _pushNotificationService.initialize();
  }

  void _setupRouter() {
    _router = GoRouter(
      initialLocation: '/',
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
        GoRoute(
          path: '/settings/general',
          builder: (context, state) => const GeneralSettingsPage(),
        ),
        GoRoute(
          path: '/settings/notifications',
          builder: (context, state) => const NotificationSettingsPage(),
        ),
        GoRoute(
          path: '/settings/profile',
          builder: (context, state) => const ProfileSettingsPage(),
        ),
        
        // Admin Routes
        GoRoute(
          path: '/admin/analytics',
          builder: (context, state) => const AnalyticsPage(),
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
    // העברת ה-context לשירות ההתראות לצורך ניווט
    _pushNotificationService.setContext(context);
    
    return MaterialApp.router(
      title: 'זזה דאנס - Zaza Dance',
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      // RTL Support for Hebrew
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('he', 'IL'), // Hebrew
        Locale('en', 'US'), // English
      ],
      locale: const Locale('he', 'IL'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
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
            const ZazaLogo.splash(),
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
            // Main logo - larger and clearer
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseAnimation.value * 0.05),
                  child: const ZazaLogo(
                    width: 300,
                    height: 120,
                    withGlow: false,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 40),
            
            // Welcome message
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'ברוכים הבאים לסטודיו Zaza Dance בהנהלת שרון צרפתי',
                  style: GoogleFonts.assistant(
                    fontSize: 24,
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
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
    return Text(
        text,
        style: GoogleFonts.assistant(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: color,
          shadows: [
            // Main subtle glow
            Shadow(
              color: color.withValues(alpha: 0.3 * glowIntensity),
              blurRadius: 8,
              offset: const Offset(0, 0),
            ),
            // Secondary soft glow
            Shadow(
              color: color.withValues(alpha: 0.2 * glowIntensity),
              blurRadius: 16,
              offset: const Offset(0, 0),
            ),
            // Minimal outer glow
            Shadow(
              color: color.withValues(alpha: 0.1 * glowIntensity),
              blurRadius: 24,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        textAlign: TextAlign.center,
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
            const Color(0xFFE91E63).withValues(alpha: 0.8), // Softer pink
            const Color(0xFF26C6DA).withValues(alpha: 0.8), // Softer cyan
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withValues(alpha: 0.2),
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
            context.go('/auth/login');
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


  Widget _buildAboutSection() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.05),
              Colors.white.withValues(alpha: 0.02),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF26C6DA).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            _buildNeonText(
              'על הסטודיו',
              fontSize: 32,
              color: const Color(0xFF26C6DA),
            ),
            const SizedBox(height: 25),
            Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE91E63),
                    Color(0xFF26C6DA),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'זזה דאנס הוא מקום בו הקצב מתחיל, הריתמוס מדבר והאנרגיה של ההיפ הופ חיה.',
              style: GoogleFonts.assistant(
                fontSize: 20,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.7,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'כאן כל תלמיד מוצא את הביטוי הייחודי שלו ובונה ביטחון דרך התנועה.',
              style: GoogleFonts.assistant(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.6,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _buildNeonText(
              'מה תמצאו כאן',
              fontSize: 32,
              color: const Color(0xFFE91E63),
            ),
            const SizedBox(height: 15),
            Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF26C6DA),
                    Color(0xFFE91E63),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
            _buildEnhancedFeatureGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedFeatureGrid() {
    final features = [
      {
        'title': 'גלריית תמונות ווידאו', 
        'icon': Icons.photo_library,
        'description': 'רגעים מיוחדים מהשיעורים והחזרות'
      },
      {
        'title': 'מדריכי ריקוד', 
        'icon': Icons.play_circle_outline,
        'description': 'למד צעדים חדשים בקצב שלך'
      },
      {
        'title': 'עדכונים חמים', 
        'icon': Icons.notifications_active,
        'description': 'הישאר מעודכן על אירועים ושיעורים'
      },
      {
        'title': 'קהילה חמה', 
        'icon': Icons.people,
        'description': 'התחבר לרקדנים אחרים וחלק השראה'
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildEnhancedFeatureCard(
          feature['title'] as String,
          feature['icon'] as IconData,
          feature['description'] as String,
          index,
        );
      },
    );
  }


  Widget _buildEnhancedFeatureCard(String title, IconData icon, String description, int index) {
    final colors = [
      const Color(0xFFE91E63), // Pink
      const Color(0xFF26C6DA), // Cyan
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF00BCD4), // Light cyan
    ];
    final cardColor = colors[index % colors.length];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        border: Border.all(
          color: cardColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            // Navigate to login page to access the features
            context.go('/auth/login');
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: cardColor.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: cardColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.assistant(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.assistant(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withValues(alpha: 0.6),
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildContactSection() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.05),
              Colors.white.withValues(alpha: 0.02),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFE91E63).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            _buildNeonText(
              'בואו להצטרף',
              fontSize: 32,
              color: const Color(0xFFE91E63),
            ),
            const SizedBox(height: 15),
            Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE91E63),
                    Color(0xFF26C6DA),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'מוכנים להרגיש את הקצב?',
              style: GoogleFonts.assistant(
                fontSize: 20,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'בואו להיות חלק מהקהילה שלנו!',
              style: GoogleFonts.assistant(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w300,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildEnhancedContactButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedContactButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildEnhancedContactButton(
                'WhatsApp',
                Icons.message,
                const Color(0xFF25D366),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildEnhancedContactButton(
                'Instagram',
                Icons.camera_alt,
                const Color(0xFFE4405F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildEnhancedContactButton(
          'צור קשר טלפוני',
          Icons.phone,
          const Color(0xFF26C6DA),
          isWide: true,
        ),
      ],
    );
  }


  Widget _buildEnhancedContactButton(String label, IconData icon, Color color, {bool isWide = false}) {
    return Container(
      width: isWide ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            // Show dialog with contact information
            showDialog(
              context: context,
              builder: (context) => Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  backgroundColor: const Color(0xFF1A1A2E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: Text(
                    'צור קשר',
                    style: GoogleFonts.assistant(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    'ליצירת קשר עם סטודיו זזה דאנס:\n\nטלפון: 050-123-4567\nאימייל: info@zazadance.co.il\nכתובת: רחוב הריקוד 15, תל אביב',
                    style: GoogleFonts.assistant(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'סגור',
                        style: GoogleFonts.assistant(
                          color: const Color(0xFF26C6DA),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 24 : 16, 
              vertical: 16
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: isWide ? MainAxisSize.max : MainAxisSize.min,
              children: [
                Icon(
                  icon, 
                  color: color, 
                  size: isWide ? 24 : 20
                ),
                SizedBox(width: isWide ? 12 : 8),
                Text(
                  label,
                  style: GoogleFonts.assistant(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: isWide ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}