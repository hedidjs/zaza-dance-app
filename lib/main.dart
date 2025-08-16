import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  
  runApp(const ProviderScope(child: ZazaDanceApp()));
}

class ZazaDanceApp extends ConsumerWidget {
  const ZazaDanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'זזה דאנס - Zaza Dance',
      theme: _buildTheme(),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
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

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                Color(0xFF2A2A2A),
                Color(0xFF1A1A1A),
                Color(0xFF0A0A0A),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroSection(),
                  const SizedBox(height: 60),
                  _buildAboutSection(),
                  const SizedBox(height: 60),
                  _buildFeaturesSection(),
                  const SizedBox(height: 60),
                  _buildContactSection(),
                  const SizedBox(height: 40),
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
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNeonText(
              'זזה דאנס',
              fontSize: 72,
              color: const Color(0xFFFF00FF),
            ),
            const SizedBox(height: 20),
            _buildNeonText(
              'ZAZA DANCE',
              fontSize: 36,
              color: const Color(0xFF40E0D0),
            ),
            const SizedBox(height: 40),
            Text(
              'בית דיגיטלי לקהילת ההיפ הופ',
              style: GoogleFonts.assistant(
                fontSize: 24,
                color: Colors.white70,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            _buildCtaButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNeonText(String text, {required double fontSize, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.8),
            blurRadius: 20,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.assistant(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
          shadows: [
            Shadow(
              color: color,
              blurRadius: 10,
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCtaButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF00FF), Color(0xFF40E0D0)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF00FF).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'גלה את הקסם',
          style: GoogleFonts.assistant(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
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
        onPressed: () {},
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