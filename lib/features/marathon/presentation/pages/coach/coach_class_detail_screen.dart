import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/branding/brand_config.dart';
import '../../../../user/presentation/bloc/user_bloc.dart';
import '../../../domain/entities/marathon_class.dart';
import '../../../domain/entities/marathon_enrollment.dart';
import '../../bloc/marathon_bloc.dart';
import '../../bloc/marathon_event.dart';
import '../../bloc/marathon_state.dart';
import '../../widgets/weekly_attendance_dots.dart';

class CoachClassDetailScreen extends StatefulWidget {
  final MarathonClass marathonClass;

  const CoachClassDetailScreen({
    super.key,
    required this.marathonClass,
  });

  @override
  State<CoachClassDetailScreen> createState() => _CoachClassDetailScreenState();
}

class _CoachClassDetailScreenState extends State<CoachClassDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    final userId = context.read<UserBloc>().state.userId;
    context.read<MarathonBloc>().add(LoadClassDetail(
      classId: widget.marathonClass.id,
      currentUserId: userId,
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MarathonBloc, MarathonState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: BrandColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final marathonClass = state.selectedClass ?? widget.marathonClass;

        return Scaffold(
          backgroundColor: BrandColors.background,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildAppBar(marathonClass),
                SliverToBoxAdapter(child: _buildStatsRow(marathonClass, state)),
                SliverToBoxAdapter(child: _buildTabBar()),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildEnrollmentsTab(state),
                _buildAttendanceTab(state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(MarathonClass marathonClass) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: BrandColors.secondary,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showOptionsMenu(marathonClass),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: BrandGradients.secondary,
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  marathonClass.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        marathonClass.timeDisplay,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(MarathonClass marathonClass, MarathonState state) {
    final todayRate = state.analytics?.todayAttendanceRate ?? 0;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people_rounded,
                  value: '${marathonClass.currentParticipants}',
                  label: 'Оролцогч',
                  color: BrandColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle_rounded,
                  value: '${state.todayAttendance.length}',
                  label: 'Өнөөдөр',
                  color: BrandColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.percent_rounded,
                  value: '${todayRate.round()}%',
                  label: 'Ирц',
                  color: todayRate >= 70
                      ? BrandColors.success
                      : todayRate >= 40
                          ? BrandColors.warning
                          : BrandColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Engagement breakdown
          if (state.analytics != null) _buildEngagementBreakdown(state.analytics!),
        ],
      ),
    );
  }

  Widget _buildEngagementBreakdown(ClassAnalytics analytics) {
    final breakdown = analytics.engagementBreakdown;
    final total = breakdown.values.fold<int>(0, (sum, v) => sum + v);
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: BrandShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded, size: 18, color: BrandColors.secondary),
              const SizedBox(width: 8),
              const Text(
                'Гишүүдийн оролцоо',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildEngagementItem(
                EngagementLevel.excellent,
                breakdown[EngagementLevel.excellent] ?? 0,
                total,
              ),
              _buildEngagementItem(
                EngagementLevel.active,
                breakdown[EngagementLevel.active] ?? 0,
                total,
              ),
              _buildEngagementItem(
                EngagementLevel.atRisk,
                breakdown[EngagementLevel.atRisk] ?? 0,
                total,
              ),
              _buildEngagementItem(
                EngagementLevel.inactive,
                breakdown[EngagementLevel.inactive] ?? 0,
                total,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementItem(EngagementLevel level, int count, int total) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    final color = _getEngagementColor(level);

    return Expanded(
      child: Column(
        children: [
          Text(
            level.emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 11,
              color: BrandColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getEngagementColor(EngagementLevel level) {
    switch (level) {
      case EngagementLevel.excellent:
        return BrandColors.success;
      case EngagementLevel.active:
        return BrandColors.primary;
      case EngagementLevel.atRisk:
        return BrandColors.warning;
      case EngagementLevel.inactive:
        return BrandColors.error;
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: BrandShadows.small,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: BrandColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: BrandColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: BrandColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: BrandColors.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: BrandColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        dividerHeight: 0,
        tabs: const [
          Tab(text: 'Оролцогчид'),
          Tab(text: 'Өнөөдрийн ирц'),
        ],
      ),
    );
  }

  Widget _buildEnrollmentsTab(MarathonState state) {
    if (state.enrollments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline_rounded,
        title: 'Одоогоор оролцогч байхгүй',
        subtitle: 'Гишүүд таны анги руу элсэхийг хүлээнэ үү',
      );
    }

    // Engagement түвшингээр эрэмбэлэх (at risk болон inactive-г эхэнд)
    final sortedEnrollments = List<MarathonEnrollment>.from(state.enrollments);
    sortedEnrollments.sort((a, b) {
      final aLevel = a.engagementLevel.index;
      final bLevel = b.engagementLevel.index;
      // Эрсдэлтэй гишүүдийг эхэнд харуулах
      if (aLevel > bLevel) return -1;
      if (aLevel < bLevel) return 1;
      // Нэг түвшний дотор streak-ээр эрэмбэлэх
      return b.currentStreak.compareTo(a.currentStreak);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sortedEnrollments.length,
      itemBuilder: (context, index) {
        final enrollment = sortedEnrollments[index];
        return _buildMemberCard(enrollment, state);
      },
    );
  }

  Widget _buildMemberCard(MarathonEnrollment enrollment, MarathonState state) {
    final engagementColor = _getEngagementColor(enrollment.engagementLevel);
    final hasCheckedInToday = state.todayAttendance.any(
      (a) => a.userId == enrollment.userId,
    );

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showMemberDetail(enrollment);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: BrandShadows.small,
          border: enrollment.engagementLevel == EngagementLevel.atRisk ||
                  enrollment.engagementLevel == EngagementLevel.inactive
              ? Border.all(color: engagementColor.withValues(alpha: 0.3), width: 1.5)
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar with check-in indicator
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: engagementColor.withValues(alpha: 0.1),
                      backgroundImage: enrollment.userPhotoUrl != null
                          ? NetworkImage(enrollment.userPhotoUrl!)
                          : null,
                      child: enrollment.userPhotoUrl == null
                          ? Text(
                              enrollment.userName.isNotEmpty
                                  ? enrollment.userName[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                color: engagementColor,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    if (hasCheckedInToday)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: BrandColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            enrollment.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            enrollment.engagementLevel.emoji,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        enrollment.lastAttendedDisplay,
                        style: TextStyle(
                          fontSize: 12,
                          color: BrandColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Streak badge
                if (enrollment.currentStreak > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: enrollment.currentStreak >= 5
                          ? const LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                            )
                          : null,
                      color: enrollment.currentStreak < 5
                          ? BrandColors.primary.withValues(alpha: 0.1)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          size: 14,
                          color: enrollment.currentStreak >= 5
                              ? Colors.white
                              : BrandColors.primary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${enrollment.currentStreak}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: enrollment.currentStreak >= 5
                                ? Colors.white
                                : BrandColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Stats row
            Row(
              children: [
                _buildMemberStat(
                  icon: Icons.event_available_rounded,
                  value: '${enrollment.totalAttendance}',
                  label: 'ирц',
                ),
                _buildMemberStat(
                  icon: Icons.percent_rounded,
                  value: '${enrollment.attendanceRate.round()}%',
                  label: 'хувь',
                ),
                _buildMemberStat(
                  icon: Icons.emoji_events_rounded,
                  value: '${enrollment.longestStreak}',
                  label: 'рекорд',
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: BrandColors.textSecondary,
                ),
              ],
            ),
            // 7 хоногийн ирц
            if (state.memberWeeklyAttendance[enrollment.userId] != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: WeeklyAttendanceDots(
                  weeklyAttendance: state.memberWeeklyAttendance[enrollment.userId]!,
                  compact: false,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          Icon(icon, size: 14, color: BrandColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: BrandColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showMemberDetail(MarathonEnrollment enrollment) {
    context.read<MarathonBloc>().add(LoadMemberDetail(
      userId: enrollment.userId,
      classId: widget.marathonClass.id,
    ));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _MemberDetailSheet(
        enrollment: enrollment,
        classTitle: widget.marathonClass.title,
      ),
    ).then((_) {
      context.read<MarathonBloc>().add(const ClearMemberDetail());
    });
  }

  Widget _buildAttendanceTab(MarathonState state) {
    if (state.todayAttendance.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_busy_rounded,
        title: 'Өнөөдөр ирц бүртгэгдээгүй',
        subtitle: 'Оролцогчид ирцээ бүртгүүлэхийг хүлээнэ үү',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: state.todayAttendance.length,
      itemBuilder: (context, index) {
        final attendance = state.todayAttendance[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: BrandShadows.small,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: BrandColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: BrandColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attendance.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Бүртгэгдсэн: ${attendance.timeDisplay}',
                      style: TextStyle(
                        fontSize: 13,
                        color: BrandColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: BrandColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: BrandColors.secondary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: BrandColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: BrandColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu(MarathonClass marathonClass) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: BrandColors.disabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: BrandColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.delete_rounded, color: BrandColors.error),
                ),
                title: const Text(
                  'Анги устгах',
                  style: TextStyle(
                    color: BrandColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text('Энэ үйлдлийг буцаах боломжгүй'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(marathonClass);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(MarathonClass marathonClass) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Анги устгах'),
        content: const Text(
          'Та энэ ангийг устгахдаа итгэлтэй байна уу? '
          'Бүх оролцогчид болон ирцийн мэдээлэл устах болно.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Үгүй',
              style: TextStyle(color: BrandColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<MarathonBloc>().add(DeleteClass(marathonClass.id));
              Navigator.pop(context);
            },
            child: Text(
              'Устгах',
              style: TextStyle(color: BrandColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Гишүүний дэлгэрэнгүй мэдээлэл харуулах sheet
class _MemberDetailSheet extends StatelessWidget {
  final MarathonEnrollment enrollment;
  final String classTitle;

  const _MemberDetailSheet({
    required this.enrollment,
    required this.classTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarathonBloc, MarathonState>(
      builder: (context, state) {
        final memberDetail = state.selectedMember;
        final engagementColor = _getEngagementColor(enrollment.engagementLevel);

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: BrandColors.disabled,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: engagementColor.withValues(alpha: 0.1),
                          backgroundImage: enrollment.userPhotoUrl != null
                              ? NetworkImage(enrollment.userPhotoUrl!)
                              : null,
                          child: enrollment.userPhotoUrl == null
                              ? Text(
                                  enrollment.userName.isNotEmpty
                                      ? enrollment.userName[0].toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                    color: engagementColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    enrollment.userName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    enrollment.engagementLevel.emoji,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: engagementColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  enrollment.engagementLevel.displayName,
                                  style: TextStyle(
                                    color: engagementColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Stats cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildStatCard(
                          icon: Icons.event_available_rounded,
                          value: '${enrollment.totalAttendance}',
                          label: 'Нийт ирц',
                          color: BrandColors.primary,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          icon: Icons.local_fire_department_rounded,
                          value: '${enrollment.currentStreak}',
                          label: 'Одоогийн streak',
                          color: enrollment.currentStreak >= 5
                              ? BrandColors.error
                              : BrandColors.warning,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          icon: Icons.emoji_events_rounded,
                          value: '${enrollment.longestStreak}',
                          label: 'Рекорд',
                          color: BrandColors.success,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Attendance rate
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: BrandColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Ирцийн хувь',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${enrollment.attendanceRate.round()}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: enrollment.attendanceRate >= 70
                                      ? BrandColors.success
                                      : enrollment.attendanceRate >= 40
                                          ? BrandColors.warning
                                          : BrandColors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: enrollment.attendanceRate / 100,
                              backgroundColor: Colors.white,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                enrollment.attendanceRate >= 70
                                    ? BrandColors.success
                                    : enrollment.attendanceRate >= 40
                                        ? BrandColors.warning
                                        : BrandColors.error,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Attendance history section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month_rounded,
                                size: 18,
                                color: BrandColors.secondary,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Сүүлийн 30 хоногийн ирц',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: memberDetail == null
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : memberDetail.attendanceDates.isEmpty
                                  ? Center(
                                      child: Text(
                                        'Ирцийн түүх байхгүй',
                                        style: TextStyle(
                                          color: BrandColors.textSecondary,
                                        ),
                                      ),
                                    )
                                  : _buildAttendanceCalendar(
                                      memberDetail.attendanceDates,
                                      scrollController,
                                    ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: BrandColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCalendar(
    List<DateTime> attendanceDates,
    ScrollController scrollController,
  ) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final days = <DateTime>[];

    for (int i = 0; i < 30; i++) {
      days.add(thirtyDaysAgo.add(Duration(days: i)));
    }

    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final isAttended = attendanceDates.any((d) =>
            d.year == day.year && d.month == day.month && d.day == day.day);
        final isToday = day.year == now.year &&
            day.month == now.month &&
            day.day == now.day;

        return Container(
          decoration: BoxDecoration(
            color: isAttended
                ? BrandColors.success
                : isToday
                    ? BrandColors.primary.withValues(alpha: 0.1)
                    : BrandColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: isToday
                ? Border.all(color: BrandColors.primary, width: 2)
                : null,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: TextStyle(
                    color: isAttended ? Colors.white : BrandColors.textPrimary,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
                if (isAttended)
                  const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 10,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getEngagementColor(EngagementLevel level) {
    switch (level) {
      case EngagementLevel.excellent:
        return BrandColors.success;
      case EngagementLevel.active:
        return BrandColors.primary;
      case EngagementLevel.atRisk:
        return BrandColors.warning;
      case EngagementLevel.inactive:
        return BrandColors.error;
    }
  }
}
