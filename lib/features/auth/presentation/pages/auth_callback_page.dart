import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/neon_text.dart';

/// עמוד לטיפול ב-Authentication callbacks מ-Supabase
class AuthCallbackPage extends ConsumerStatefulWidget {
  const AuthCallbackPage({super.key});

  @override
  ConsumerState<AuthCallbackPage> createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends ConsumerState<AuthCallbackPage> {
  bool _isProcessing = true;
  String _status = 'מעבד אותנטיקציה...';
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _processAuthCallback();
  }

  Future<void> _processAuthCallback() async {
    try {
      setState(() {
        _status = 'מעבד אותנטיקציה...';
        _isProcessing = true;
      });

      // בדיקה אם יש session פעיל
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session != null) {
        setState(() {
          _status = 'האותנטיקציה הושלמה בהצלחה!';
          _isSuccess = true;
          _isProcessing = false;
        });
        
        // המתנה קצרה לפני ניווט
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          context.go('/home');
        }
      } else {
        setState(() {
          _status = 'שגיאה באותנטיקציה';
          _isSuccess = false;
          _isProcessing = false;
        });
        
        // המתנה לפני ניווט לעמוד התחברות
        await Future.delayed(const Duration(seconds: 3));
        
        if (mounted) {
          context.go('/auth/login');
        }
      }
    } catch (e) {
      debugPrint('Auth callback error: $e');
      
      setState(() {
        _status = 'שגיאה באותנטיקציה: ${e.toString()}';
        _isSuccess = false;
        _isProcessing = false;
      });
      
      // המתנה לפני ניווט לעמוד התחברות
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted) {
        context.go('/auth/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AnimatedGradientBackground(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // לוגו
                    NeonText(
                      text: 'זזה דאנס',
                      fontSize: 48,
                      glowColor: AppColors.neonPink,
                      fontWeight: FontWeight.bold,
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // אייקון סטטוס
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _isSuccess 
                              ? [AppColors.success, AppColors.success.withValues(alpha: 0.7)]
                              : [AppColors.neonTurquoise, AppColors.neonTurquoise.withValues(alpha: 0.7)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isSuccess ? AppColors.success : AppColors.neonTurquoise).withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isProcessing
                            ? CircularProgressIndicator(
                                color: AppColors.primaryText,
                                strokeWidth: 3,
                              )
                            : Icon(
                                _isSuccess ? Icons.check : Icons.error,
                                size: 50,
                                color: AppColors.primaryText,
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // הודעת סטטוס
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.cardGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.neonTurquoise.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          NeonText(
                            text: _status,
                            fontSize: 18,
                            glowColor: _isSuccess ? AppColors.success : AppColors.neonTurquoise,
                            textAlign: TextAlign.center,
                          ),
                          
                          if (!_isProcessing && !_isSuccess) ...[
                            const SizedBox(height: 20),
                            
                            ElevatedButton(
                              onPressed: () {
                                context.go('/auth/login');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.neonPink,
                                foregroundColor: AppColors.primaryText,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'חזור להתחברות',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // הסבר נוסף
                    if (_isProcessing)
                      Text(
                        'אנא המתינו בזמן שאנחנו מעבדים את הבקשה שלכם...',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}