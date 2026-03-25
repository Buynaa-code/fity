import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/branding/brand_config.dart';
import '../../../../user/presentation/bloc/user_bloc.dart';
import '../../../domain/entities/marathon_class.dart';
import '../../bloc/marathon_bloc.dart';
import '../../bloc/marathon_event.dart';
import '../../bloc/marathon_state.dart';

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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
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
              icon: Icons.event_available_rounded,
              value: '${marathonClass.maxParticipants}',
              label: 'Багтаамж',
              color: BrandColors.secondary,
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
        ],
      ),
    );
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

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: state.enrollments.length,
      itemBuilder: (context, index) {
        final enrollment = state.enrollments[index];
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
              CircleAvatar(
                radius: 24,
                backgroundColor: BrandColors.primary.withValues(alpha: 0.1),
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
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enrollment.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ирсэн: ${enrollment.totalAttendance} удаа',
                      style: TextStyle(
                        fontSize: 13,
                        color: BrandColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: BrandColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  enrollment.status.displayName,
                  style: TextStyle(
                    color: BrandColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
