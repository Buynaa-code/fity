import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/branding/brand_config.dart';
import '../../../../user/presentation/bloc/user_bloc.dart';
import '../../../../user/presentation/bloc/user_state.dart';
import '../../../domain/entities/marathon_class.dart';
import '../../bloc/marathon_bloc.dart';
import '../../bloc/marathon_event.dart';
import '../../bloc/marathon_state.dart';
import '../../widgets/weekly_attendance_dots.dart';
import '../../widgets/marathon_stats_card.dart';
import '../../widgets/milestones_progress.dart';
import '../../widgets/attendance_history_list.dart';

class ClassDetailScreen extends StatefulWidget {
  final MarathonClass marathonClass;

  const ClassDetailScreen({
    super.key,
    required this.marathonClass,
  });

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final userId = context.read<UserBloc>().state.userId ?? 'dev_user';
    context.read<MarathonBloc>().add(LoadClassDetail(
      classId: widget.marathonClass.id,
      currentUserId: userId,
    ));
    // Load user progress
    context.read<MarathonBloc>().add(LoadUserProgress(
      userId: userId,
      classId: widget.marathonClass.id,
    ));
    // Load attendance history
    context.read<MarathonBloc>().add(LoadAttendanceHistory(
      userId: userId,
      classId: widget.marathonClass.id,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserBloc>().state.userId ?? 'dev_user';

    return BlocConsumer<MarathonBloc, MarathonState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.successMessage!)),
                ],
              ),
              backgroundColor: BrandColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.errorMessage!)),
                ],
              ),
              backgroundColor: BrandColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        // Show milestone celebration dialog
        if (state.newlyUnlockedMilestones.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => MilestoneCelebrationDialog(
                milestones: state.newlyUnlockedMilestones,
                onDismiss: () {
                  Navigator.of(context).pop();
                  context.read<MarathonBloc>().add(const ClearMilestoneCelebration());
                },
              ),
            );
          });
        }
      },
      builder: (context, state) {
        final marathonClass = state.selectedClass ?? widget.marathonClass;
        final isEnrolled = marathonClass.isUserEnrolled(userId);

        return Scaffold(
          backgroundColor: BrandColors.background,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(marathonClass),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCards(marathonClass),
                      const SizedBox(height: 24),
                      // Weekly attendance dots for enrolled users
                      if (isEnrolled && state.userProgress != null)
                        _buildWeeklySection(state.userProgress!),
                      if (isEnrolled && state.userProgress != null)
                        const SizedBox(height: 24),
                      // Stats card for enrolled users
                      if (isEnrolled && state.userProgress != null)
                        MarathonStatsCard(progress: state.userProgress!),
                      if (isEnrolled && state.userProgress != null)
                        const SizedBox(height: 24),
                      _buildDescription(marathonClass),
                      const SizedBox(height: 24),
                      _buildCoachSection(marathonClass),
                      const SizedBox(height: 24),
                      // Milestones for enrolled users
                      if (isEnrolled && state.userProgress != null && state.userProgress!.milestones.isNotEmpty)
                        MilestonesProgress(milestones: state.userProgress!.milestones),
                      if (isEnrolled && state.userProgress != null && state.userProgress!.milestones.isNotEmpty)
                        const SizedBox(height: 24),
                      _buildParticipantsSection(state),
                      const SizedBox(height: 24),
                      // Attendance history for enrolled users
                      if (isEnrolled && state.attendanceHistory.isNotEmpty)
                        AttendanceHistoryList(
                          history: state.attendanceHistory,
                          hasMore: state.attendanceHistory.length >= 30,
                          onLoadMore: () {
                            context.read<MarathonBloc>().add(LoadAttendanceHistory(
                              userId: userId,
                              classId: marathonClass.id,
                              offset: state.attendanceHistory.length,
                            ));
                          },
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context, state, marathonClass),
        );
      },
    );
  }

  Widget _buildWeeklySection(UserProgress progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: BrandShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: BrandGradients.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_view_week_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '7 хоногийн ирц',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: BrandColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (progress.currentStreak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: BrandGradients.streak,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${progress.currentStreak} хоног',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          WeeklyAttendanceDots(weeklyAttendance: progress.weeklyAttendance),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Ирсэн', BrandColors.success),
              const SizedBox(width: 16),
              _buildLegendItem('Алдсан', BrandColors.error),
              const SizedBox(width: 16),
              _buildLegendItem('Ирээдүй', BrandColors.disabled.withValues(alpha: 0.3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: BrandColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(MarathonClass marathonClass) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: BrandColors.primary,
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
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: BrandGradients.primary,
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_run_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    marathonClass.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCards(MarathonClass marathonClass) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.access_time_rounded,
            title: 'Цагийн хуваарь',
            value: marathonClass.timeDisplay,
            color: BrandColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.people_rounded,
            title: 'Оролцогчид',
            value: '${marathonClass.currentParticipants}/${marathonClass.maxParticipants}',
            color: BrandColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: BrandShadows.small,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: BrandColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: BrandColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(MarathonClass marathonClass) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(Icons.info_outline_rounded, color: BrandColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Ангийн мэдээлэл',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: BrandColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (marathonClass.description != null)
            Text(
              marathonClass.description!,
              style: TextStyle(
                color: BrandColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                size: 16,
                color: BrandColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Өдрүүд: ${marathonClass.weekdaysDisplay}',
                style: TextStyle(
                  color: BrandColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoachSection(MarathonClass marathonClass) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: BrandShadows.small,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: BrandColors.secondary.withValues(alpha: 0.1),
            backgroundImage: marathonClass.coachPhotoUrl != null
                ? NetworkImage(marathonClass.coachPhotoUrl!)
                : null,
            child: marathonClass.coachPhotoUrl == null
                ? Text(
                    marathonClass.coachName.isNotEmpty
                        ? marathonClass.coachName[0].toUpperCase()
                        : 'C',
                    style: TextStyle(
                      color: BrandColors.secondary,
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
                const Text(
                  'Багш',
                  style: TextStyle(
                    color: BrandColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  marathonClass.coachName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BrandColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: BrandColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_rounded,
                  size: 16,
                  color: BrandColors.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Баталгаажсан',
                  style: TextStyle(
                    color: BrandColors.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection(MarathonState state) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(Icons.groups_rounded, color: BrandColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Оролцогчид',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: BrandColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${state.enrollments.length} хүн',
                style: TextStyle(
                  color: BrandColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.enrollments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Одоогоор оролцогч байхгүй',
                  style: TextStyle(
                    color: BrandColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.enrollments.map((enrollment) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: BrandColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: BrandColors.primary.withValues(alpha: 0.2),
                        backgroundImage: enrollment.userPhotoUrl != null
                            ? NetworkImage(enrollment.userPhotoUrl!)
                            : null,
                        child: enrollment.userPhotoUrl == null
                            ? Text(
                                enrollment.userName.isNotEmpty
                                    ? enrollment.userName[0].toUpperCase()
                                    : 'U',
                                style: TextStyle(
                                  color: BrandColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        enrollment.userName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, MarathonState state, MarathonClass marathonClass) {
    final userState = context.read<UserBloc>().state;
    final userId = userState.userId ?? 'dev_user';
    final userName = userState.userName.isNotEmpty ? userState.userName : 'Хэрэглэгч';
    final isEnrolled = marathonClass.isUserEnrolled(userId);
    final isLoading = state.status == MarathonStatus.loading;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (isEnrolled) ...[
              // Check-in button
              Expanded(
                child: _buildActionButton(
                  label: state.hasCheckedInToday ? 'Ирц бүртгэгдсэн' : 'Ирц бүртгүүлэх',
                  icon: state.hasCheckedInToday
                      ? Icons.check_circle_rounded
                      : Icons.how_to_reg_rounded,
                  color: state.hasCheckedInToday
                      ? BrandColors.success
                      : BrandColors.primary,
                  isLoading: isLoading,
                  isDisabled: state.hasCheckedInToday,
                  onTap: state.hasCheckedInToday
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          context.read<MarathonBloc>().add(CheckIn(
                            classId: marathonClass.id,
                            userId: userId,
                            userName: userName,
                            userPhotoUrl: userState.photoUrl,
                          ));
                        },
                ),
              ),
              const SizedBox(width: 12),
              // Leave button
              _buildIconButton(
                icon: Icons.exit_to_app_rounded,
                color: BrandColors.error,
                onTap: () => _showLeaveDialog(context, userState, marathonClass),
              ),
            ] else ...[
              // Join button
              Expanded(
                child: _buildActionButton(
                  label: marathonClass.hasAvailableSpots ? 'Элсэх' : 'Дүүрсэн',
                  icon: Icons.person_add_rounded,
                  color: BrandColors.primary,
                  isLoading: isLoading,
                  isDisabled: !marathonClass.hasAvailableSpots,
                  onTap: marathonClass.hasAvailableSpots
                      ? () {
                          HapticFeedback.mediumImpact();
                          context.read<MarathonBloc>().add(JoinClass(
                            classId: marathonClass.id,
                            userId: userId,
                            userName: userName,
                            userPhotoUrl: userState.photoUrl,
                          ));
                        }
                      : null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required bool isDisabled,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: isDisabled || isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDisabled ? BrandColors.disabled : color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDisabled ? null : [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            else ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }

  void _showLeaveDialog(BuildContext context, UserState userState, MarathonClass marathonClass) {
    final userId = userState.userId ?? 'dev_user';
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ангиас гарах'),
        content: const Text('Та энэ ангиас гарахдаа итгэлтэй байна уу?'),
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
              context.read<MarathonBloc>().add(LeaveClass(
                classId: marathonClass.id,
                userId: userId,
              ));
              Navigator.pop(context);
            },
            child: Text(
              'Тийм',
              style: TextStyle(color: BrandColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
