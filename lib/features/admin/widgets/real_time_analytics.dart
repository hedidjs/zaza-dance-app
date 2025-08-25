import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/neon_text.dart';
import '../../../shared/widgets/enhanced_neon_effects.dart';
import '../models/admin_stats_model.dart';
import '../services/admin_analytics_service.dart';

/// ווידג'ט אנליטיקה בזמן אמת עם תרשימים ונתונים חיים
/// Real-time analytics widget with charts and live data
class RealTimeAnalytics extends ConsumerStatefulWidget {
  /// האם להציג בפריסה קומפקטית
  /// Whether to show in compact layout
  final bool isCompact;
  
  /// זמן רענון הנתונים בשניות
  /// Data refresh interval in seconds
  final int refreshInterval;
  
  /// רשימת מטריקות להצגה
  /// List of metrics to display
  final List<String>? selectedMetrics;
  
  /// פונקציית callback עבור שגיאות
  /// Callback function for errors
  final Function(String error)? onError;
  
  /// פונקציית callback עבור ייצוא נתונים
  /// Callback function for data export
  final Function()? onExport;

  const RealTimeAnalytics({
    super.key,
    this.isCompact = false,
    this.refreshInterval = 30,
    this.selectedMetrics,
    this.onError,
    this.onExport,
  });

  @override
  ConsumerState<RealTimeAnalytics> createState() => _RealTimeAnalyticsState();
}

class _RealTimeAnalyticsState extends ConsumerState<RealTimeAnalytics>
    with TickerProviderStateMixin {
  
  // Controllers and timers
  Timer? _refreshTimer;
  late AnimationController _pulseController;
  late AnimationController _chartController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _chartAnimation;
  
  // Data state
  AdminStatsModel? _currentStats;
  Map<String, dynamic>? _realtimeData;
  final List<Map<String, dynamic>> _chartData = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  DateTime _lastUpdate = DateTime.now();
  
  // Chart data storage
  final List<FlSpot> _userGrowthData = [];
  final List<FlSpot> _viewsData = [];
  final List<FlSpot> _engagementData = [];
  Map<String, double> _pieChartData = {};
  
  // Animation values
  double _animatedUserCount = 0;
  double _animatedViewCount = 0;
  double _animatedEngagementRate = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadInitialData();
    _startRealTimeUpdates();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pulseController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _loadInitialData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      
      final stats = await AdminAnalyticsService.getDashboardStats();
      final realtimeData = await AdminAnalyticsService.getRealtimeStats();
      
      if (mounted) {
        setState(() {
          _currentStats = stats;
          _realtimeData = realtimeData;
          _isLoading = false;
          _lastUpdate = DateTime.now();
        });
        
        _updateChartData();
        _animateCounters();
        _chartController.forward();
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
      widget.onError?.call(e.toString());
    }
  }

  void _startRealTimeUpdates() {
    _refreshTimer = Timer.periodic(
      Duration(seconds: widget.refreshInterval),
      (_) => _updateData(),
    );
  }

  void _updateData() async {
    if (!mounted) return;
    
    try {
      final realtimeData = await AdminAnalyticsService.getRealtimeStats();
      
      if (mounted) {
        setState(() {
          _realtimeData = realtimeData;
          _lastUpdate = DateTime.now();
          _hasError = false;
        });
        
        _updateChartData();
        _animateCounters();
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _updateChartData() {
    if (_currentStats == null) return;
    
    // Update line chart data (simulated real-time data)
    final now = DateTime.now();
    final random = Random();
    
    // User growth data
    _userGrowthData.add(FlSpot(
      now.millisecondsSinceEpoch.toDouble(),
      _currentStats!.totalUsers.toDouble() + random.nextInt(10),
    ));
    if (_userGrowthData.length > 20) {
      _userGrowthData.removeAt(0);
    }
    
    // Views data
    _viewsData.add(FlSpot(
      now.millisecondsSinceEpoch.toDouble(),
      _currentStats!.tutorialViews.toDouble() + random.nextInt(50),
    ));
    if (_viewsData.length > 20) {
      _viewsData.removeAt(0);
    }
    
    // Engagement data
    _engagementData.add(FlSpot(
      now.millisecondsSinceEpoch.toDouble(),
      _currentStats!.completionRate + (random.nextDouble() - 0.5) * 0.1,
    ));
    if (_engagementData.length > 20) {
      _engagementData.removeAt(0);
    }
    
    // Pie chart data (user distribution by role)
    _pieChartData = Map<String, double>.from(_currentStats!.usersByRole.map(
      (key, value) => MapEntry(key, value.toDouble()),
    ));
  }

  void _animateCounters() {
    if (_currentStats == null || _realtimeData == null) return;
    
    final targetUsers = _realtimeData!['active_users'] ?? _currentStats!.activeUsers;
    final targetViews = _currentStats!.tutorialViews;
    final targetEngagement = _currentStats!.completionRate;
    
    // Animate counters with Tween
    final userTween = Tween<double>(
      begin: _animatedUserCount,
      end: targetUsers.toDouble(),
    );
    final viewTween = Tween<double>(
      begin: _animatedViewCount,
      end: targetViews.toDouble(),
    );
    final engagementTween = Tween<double>(
      begin: _animatedEngagementRate,
      end: targetEngagement,
    );
    
    final animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    final animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
    );
    
    animation.addListener(() {
      if (mounted) {
        setState(() {
          _animatedUserCount = userTween.evaluate(animation);
          _animatedViewCount = viewTween.evaluate(animation);
          _animatedEngagementRate = engagementTween.evaluate(animation);
        });
      }
    });
    
    animationController.forward().then((_) => animationController.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: widget.isCompact ? _buildCompactView() : _buildFullView(),
    );
  }

  Widget _buildCompactView() {
    return NeonGlowContainer(
      glowColor: AppColors.neonTurquoise,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
            _buildHeader(isCompact: true),
            const SizedBox(height: 16),
            if (_isLoading)
              _buildLoadingIndicator()
            else if (_hasError)
              _buildErrorState()
            else
              _buildCompactStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildFullView() {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        if (_isLoading)
          _buildLoadingIndicator()
        else if (_hasError)
          _buildErrorState()
        else
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildStatsCards(),
                  const SizedBox(height: 20),
                  _buildChartsSection(),
                  const SizedBox(height: 20),
                  _buildActivityFeed(),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader({bool isCompact = false}) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: NeonGlowContainer(
                glowColor: AppColors.neonTurquoise,
                animate: true,
                child: CircleAvatar(
                  radius: isCompact ? 20 : 25,
                  backgroundColor: AppColors.darkSurface,
                  child: Icon(
                    Icons.analytics_rounded,
                    color: AppColors.neonTurquoise,
                    size: isCompact ? 20 : 25,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeonText(
                text: 'אנליטיקה בזמן אמת',
                fontSize: isCompact ? 18 : 22,
                glowColor: AppColors.neonTurquoise,
                fontWeight: FontWeight.bold,
              ),
              if (!isCompact) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: AppColors.secondaryText,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'עודכן לאחרונה: ${_formatTime(_lastUpdate)}',
                      style: GoogleFonts.assistant(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (!isCompact) ...[
          _buildRefreshButton(),
          const SizedBox(width: 8),
          if (widget.onExport != null) _buildExportButton(),
        ],
      ],
    );
  }

  Widget _buildRefreshButton() {
    return GestureDetector(
      onTap: _loadInitialData,
      child: NeonGlowContainer(
        glowColor: AppColors.neonTurquoise,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.neonTurquoise.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            Icons.refresh_rounded,
            color: AppColors.neonTurquoise,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    return GestureDetector(
      onTap: widget.onExport,
      child: NeonGlowContainer(
        glowColor: AppColors.neonPink,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.neonPink.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            Icons.download_rounded,
            color: AppColors.neonPink,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NeonGlowContainer(
              glowColor: AppColors.neonTurquoise,
              animate: true,
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(AppColors.neonTurquoise),
                ),
              ),
            ),
            const SizedBox(height: 16),
            NeonText(
              text: 'טוען נתונים...',
              fontSize: 16,
              glowColor: AppColors.neonTurquoise,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            NeonText(
              text: 'שגיאה בטעינת נתונים',
              fontSize: 18,
              glowColor: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'שגיאה לא ידועה',
              style: GoogleFonts.assistant(
                color: AppColors.secondaryText,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            NeonButton(
              text: 'נסה שוב',
              onPressed: _loadInitialData,
              glowColor: AppColors.neonTurquoise,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'משתמשים פעילים',
            _animatedUserCount.round().toString(),
            Icons.people_rounded,
            AppColors.neonTurquoise,
            isCompact: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'צפיות',
            _animatedViewCount.round().toString(),
            Icons.visibility_rounded,
            AppColors.neonPink,
            isCompact: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard(
          'משתמשים פעילים',
          _animatedUserCount.round().toString(),
          Icons.people_rounded,
          AppColors.neonTurquoise,
        ),
        _buildStatCard(
          'צפיות היום',
          _animatedViewCount.round().toString(),
          Icons.visibility_rounded,
          AppColors.neonPink,
        ),
        _buildStatCard(
          'שיעור השלמה',
          '${_animatedEngagementRate.toStringAsFixed(1)}%',
          Icons.trending_up_rounded,
          AppColors.neonPurple,
        ),
        _buildStatCard(
          'הרשמות חדשות',
          _currentStats?.newSignups.toString() ?? '0',
          Icons.person_add_rounded,
          AppColors.neonGreen,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isCompact = false,
  }) {
    return NeonGlowContainer(
      glowColor: color,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(isCompact ? 12 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: isCompact ? 20 : 24,
                ),
                const Spacer(),
                if (!isCompact)
                  Icon(
                    Icons.trending_up_rounded,
                    color: color.withValues(alpha: 0.5),
                    size: 16,
                  ),
              ],
            ),
            SizedBox(height: isCompact ? 8 : 12),
            NeonText(
              text: value,
              fontSize: isCompact ? 20 : 28,
              glowColor: color,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: isCompact ? 4 : 8),
            Text(
              title,
              style: GoogleFonts.assistant(
                color: AppColors.secondaryText,
                fontSize: isCompact ? 12 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildLineChart(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPieChart(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    return NeonGlowContainer(
      glowColor: AppColors.neonTurquoise,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 300,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NeonText(
              text: 'פעילות בזמן אמת',
              fontSize: 18,
              glowColor: AppColors.neonTurquoise,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedBuilder(
                animation: _chartAnimation,
                builder: (context, child) {
                  return LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 1,
                        verticalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppColors.darkBorder.withValues(alpha: 0.3),
                            strokeWidth: 1,
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: AppColors.darkBorder.withValues(alpha: 0.3),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${DateTime.fromMillisecondsSinceEpoch(value.toInt()).hour}:${DateTime.fromMillisecondsSinceEpoch(value.toInt()).minute.toString().padLeft(2, '0')}',
                                style: GoogleFonts.assistant(
                                  color: AppColors.secondaryText,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: GoogleFonts.assistant(
                                  color: AppColors.secondaryText,
                                  fontSize: 10,
                                ),
                              );
                            },
                            reservedSize: 42,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: AppColors.darkBorder.withValues(alpha: 0.3),
                        ),
                      ),
                      minX: _userGrowthData.isNotEmpty 
                          ? _userGrowthData.first.x 
                          : 0,
                      maxX: _userGrowthData.isNotEmpty 
                          ? _userGrowthData.last.x 
                          : 100,
                      minY: 0,
                      maxY: _userGrowthData.isNotEmpty 
                          ? _userGrowthData.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 10
                          : 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: _userGrowthData.map((spot) => FlSpot(
                            spot.x,
                            spot.y * _chartAnimation.value,
                          )).toList(),
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.neonTurquoise,
                              AppColors.neonTurquoise.withValues(alpha: 0.5),
                            ],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.neonTurquoise.withValues(alpha: 0.3),
                                AppColors.neonTurquoise.withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return NeonGlowContainer(
      glowColor: AppColors.neonPink,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.cardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.neonPink.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NeonText(
              text: 'פילוח משתמשים',
              fontSize: 18,
              glowColor: AppColors.neonPink,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedBuilder(
                animation: _chartAnimation,
                builder: (context, child) {
                  return PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          // Handle touch events
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _buildPieChartSections(),
                    ),
                  );
                },
              ),
            ),
            _buildPieChartLegend(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final colors = [
      AppColors.neonPink,
      AppColors.neonTurquoise,
      AppColors.neonPurple,
      AppColors.neonGreen,
    ];
    
    final total = _pieChartData.values.fold<double>(0, (sum, value) => sum + value);
    
    return _pieChartData.entries.map((entry) {
      final index = _pieChartData.keys.toList().indexOf(entry.key);
      final percentage = total > 0 ? (entry.value / total) * 100 : 0;
      
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value * _chartAnimation.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: GoogleFonts.assistant(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
      );
    }).toList();
  }

  Widget _buildPieChartLegend() {
    final colors = [
      AppColors.neonPink,
      AppColors.neonTurquoise,
      AppColors.neonPurple,
      AppColors.neonGreen,
    ];
    
    final roleNames = {
      'admin': 'מנהלים',
      'instructor': 'מדריכים',
      'parent': 'הורים',
      'student': 'תלמידים',
    };
    
    return Column(
      children: _pieChartData.entries.map((entry) {
        final index = _pieChartData.keys.toList().indexOf(entry.key);
        final color = colors[index % colors.length];
        final name = roleNames[entry.key] ?? entry.key;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: GoogleFonts.assistant(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                entry.value.round().toString(),
                style: GoogleFonts.assistant(
                  color: AppColors.primaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityFeed() {
    return NeonGlowContainer(
      glowColor: AppColors.neonPurple,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.cardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.neonPurple.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                NeonText(
                  text: 'פעילות אחרונה',
                  fontSize: 18,
                  glowColor: AppColors.neonPurple,
                  fontWeight: FontWeight.bold,
                ),
                const Spacer(),
                Icon(
                  Icons.fiber_manual_record_rounded,
                  color: AppColors.success,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  'חי',
                  style: GoogleFonts.assistant(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._buildActivityItems(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActivityItems() {
    final activities = [
      {'type': 'login', 'user': 'מיכל כהן', 'time': '2 דקות', 'icon': Icons.login_rounded},
      {'type': 'tutorial', 'user': 'דני לוי', 'time': '5 דקות', 'icon': Icons.play_circle_rounded},
      {'type': 'upload', 'user': 'שרה אברהם', 'time': '8 דקות', 'icon': Icons.cloud_upload_rounded},
      {'type': 'signup', 'user': 'אלון ישראל', 'time': '12 דקות', 'icon': Icons.person_add_rounded},
    ];
    
    return activities.map((activity) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.neonPurple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                activity['icon'] as IconData,
                color: AppColors.neonPurple,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['user'] as String,
                    style: GoogleFonts.assistant(
                      color: AppColors.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getActivityDescription(activity['type'] as String),
                    style: GoogleFonts.assistant(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'לפני ${activity['time']}',
              style: GoogleFonts.assistant(
                color: AppColors.disabledText,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _getActivityDescription(String type) {
    switch (type) {
      case 'login':
        return 'התחבר למערכת';
      case 'tutorial':
        return 'צפה במדריך';
      case 'upload':
        return 'העלה תוכן חדש';
      case 'signup':
        return 'הרשם למערכת';
      default:
        return 'פעילות';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'כרגע';
    } else if (difference.inMinutes < 60) {
      return 'לפני ${difference.inMinutes} דקות';
    } else if (difference.inHours < 24) {
      return 'לפני ${difference.inHours} שעות';
    } else {
      return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}