import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/enhanced_neon_effects.dart';
import '../../providers/edit_profile_provider.dart';

class AutoSaveIndicator extends ConsumerStatefulWidget {
  final bool hasUnsavedChanges;
  final DateTime? lastSaved;
  final DateTime? lastAutoSave;
  final bool isAutoSaving;

  const AutoSaveIndicator({
    super.key,
    required this.hasUnsavedChanges,
    this.lastSaved,
    this.lastAutoSave,
    this.isAutoSaving = false,
  });

  @override
  ConsumerState<AutoSaveIndicator> createState() => _AutoSaveIndicatorState();
}

class _AutoSaveIndicatorState extends ConsumerState<AutoSaveIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startUpdateTimer();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    if (widget.hasUnsavedChanges || widget.isAutoSaving) {
      _slideController.forward();
      if (widget.isAutoSaving) {
        _pulseController.repeat(reverse: true);
      }
    }
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Trigger rebuild to update timestamps
        });
      }
    });
  }

  @override
  void didUpdateWidget(AutoSaveIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.hasUnsavedChanges != oldWidget.hasUnsavedChanges ||
        widget.isAutoSaving != oldWidget.isAutoSaving) {
      
      if (widget.hasUnsavedChanges || widget.isAutoSaving) {
        _slideController.forward();
      } else {
        _slideController.reverse();
      }
    }

    if (widget.isAutoSaving != oldWidget.isAutoSaving) {
      if (widget.isAutoSaving) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: _buildIndicatorContent(),
      ),
    );
  }

  Widget _buildIndicatorContent() {
    if (widget.isAutoSaving) {
      return _buildAutoSavingIndicator();
    } else if (widget.hasUnsavedChanges) {
      return _buildUnsavedChangesIndicator();
    } else if (widget.lastSaved != null || widget.lastAutoSave != null) {
      return _buildSavedIndicator();
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildAutoSavingIndicator() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: NeonGlowContainer(
            glowColor: AppColors.neonTurquoise,
            glowRadius: 12,
            opacity: 0.4,
            animate: true,
            isSubtle: true,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.neonTurquoise.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.neonTurquoise.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: AppColors.neonTurquoise,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'שומר אוטומטית...',
                    style: GoogleFonts.assistant(
                      color: AppColors.neonTurquoise,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnsavedChangesIndicator() {
    return NeonGlowContainer(
      glowColor: AppColors.warning,
      glowRadius: 10,
      opacity: 0.3,
      isSubtle: true,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.warning,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'יש שינויים לא שמורים',
              style: GoogleFonts.assistant(
                color: AppColors.warning,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedIndicator() {
    final lastSaveTime = widget.lastSaved ?? widget.lastAutoSave;
    if (lastSaveTime == null) return const SizedBox.shrink();

    final timeAgo = _getTimeAgoText(lastSaveTime);
    final isRecent = DateTime.now().difference(lastSaveTime).inMinutes < 1;

    return NeonGlowContainer(
      glowColor: AppColors.success,
      glowRadius: 8,
      opacity: isRecent ? 0.3 : 0.2,
      isSubtle: true,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              timeAgo,
              style: GoogleFonts.assistant(
                color: AppColors.success,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgoText(DateTime saveTime) {
    final now = DateTime.now();
    final difference = now.difference(saveTime);

    if (difference.inSeconds < 30) {
      return 'נשמר כעת';
    } else if (difference.inMinutes < 1) {
      return 'נשמר לפני ${difference.inSeconds} שניות';
    } else if (difference.inMinutes < 60) {
      return 'נשמר לפני ${difference.inMinutes} דקות';
    } else if (difference.inHours < 24) {
      return 'נשמר לפני ${difference.inHours} שעות';
    } else {
      return 'נשמר לפני ${difference.inDays} ימים';
    }
  }
}

// Main auto-save status widget that combines with provider
class AutoSaveStatus extends ConsumerWidget {
  const AutoSaveStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editState = ref.watch(editProfileProvider);
    
    return AutoSaveIndicator(
      hasUnsavedChanges: editState.hasChanges,
      lastSaved: editState.lastSaved,
      lastAutoSave: editState.lastAutoSave,
      isAutoSaving: editState.isAutoSaving,
    );
  }
}

// Unsaved changes warning dialog
class UnsavedChangesDialog extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onDiscard;
  final VoidCallback onCancel;
  final bool isSaving;

  const UnsavedChangesDialog({
    super.key,
    required this.onSave,
    required this.onDiscard,
    required this.onCancel,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: AppColors.authCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            NeonGlowContainer(
              glowColor: AppColors.warning,
              glowRadius: 8,
              opacity: 0.3,
              isSubtle: true,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.warning_amber,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'שינויים לא שמורים',
                style: GoogleFonts.assistant(
                  color: AppColors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'יש לך שינויים שלא נשמרו בפרופיל.',
              style: GoogleFonts.assistant(
                color: AppColors.secondaryText,
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'מה תרצה לעשות?',
              style: GoogleFonts.assistant(
                color: AppColors.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: isSaving ? null : onCancel,
            child: Text(
              'ביטול',
              style: GoogleFonts.assistant(
                color: isSaving ? AppColors.disabledText : AppColors.secondaryText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Discard button
          TextButton(
            onPressed: isSaving ? null : onDiscard,
            child: Text(
              'יציאה ללא שמירה',
              style: GoogleFonts.assistant(
                color: isSaving ? AppColors.disabledText : AppColors.error,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Save button
          NeonButton(
            text: isSaving ? 'שומר...' : 'שמירה ויציאה',
            onPressed: isSaving ? null : onSave,
            glowColor: AppColors.neonTurquoise,
            fontSize: 16,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            isSubtle: true,
          ),
        ],
      ),
    );
  }
}

// Helper widget for showing unsaved changes warning with proper animation
class UnsavedChangesHandler extends StatefulWidget {
  final bool hasUnsavedChanges;
  final VoidCallback onSave;
  final VoidCallback onExit;
  final Widget child;

  const UnsavedChangesHandler({
    super.key,
    required this.hasUnsavedChanges,
    required this.onSave,
    required this.onExit,
    required this.child,
  });

  @override
  State<UnsavedChangesHandler> createState() => _UnsavedChangesHandlerState();
}

class _UnsavedChangesHandlerState extends State<UnsavedChangesHandler> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.hasUnsavedChanges,
      onPopInvokedWithResult: _onPopInvoked,
      child: widget.child,
    );
  }

  void _onPopInvoked(bool didPop, dynamic result) async {
    if (widget.hasUnsavedChanges && !didPop) {
      _showUnsavedChangesDialog();
    }
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UnsavedChangesDialog(
        isSaving: _isSaving,
        onSave: () async {
          setState(() {
            _isSaving = true;
          });
          
          try {
            widget.onSave();
            if (mounted) {
              context.pop();
              widget.onExit();
            }
          } catch (e) {
            if (mounted) {
              setState(() {
                _isSaving = false;
              });
              // Error is handled by the save method
            }
          }
        },
        onDiscard: () {
          context.pop();
          widget.onExit();
        },
        onCancel: () {
          context.pop();
        },
      ),
    );
  }
}

// Auto save configuration widget
class AutoSaveConfig extends StatelessWidget {
  final Duration interval;
  final bool enabled;
  final VoidCallback? onToggle;
  final Function(Duration)? onIntervalChanged;

  const AutoSaveConfig({
    super.key,
    required this.interval,
    required this.enabled,
    this.onToggle,
    this.onIntervalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NeonGlowContainer(
      glowColor: AppColors.neonTurquoise,
      glowRadius: 10,
      opacity: 0.15,
      isSubtle: true,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.authCardBackground.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.neonTurquoise.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_fix_high,
                  color: AppColors.neonTurquoise,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'שמירה אוטומטית',
                  style: GoogleFonts.assistant(
                    color: AppColors.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: enabled,
                  onChanged: (_) => onToggle?.call(),
                  activeThumbColor: AppColors.neonTurquoise,
                  inactiveThumbColor: AppColors.secondaryText,
                  inactiveTrackColor: AppColors.darkSurface,
                ),
              ],
            ),
            if (enabled) ...[
              const SizedBox(height: 12),
              Text(
                'תדירות שמירה: ${interval.inSeconds} שניות',
                style: GoogleFonts.assistant(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}