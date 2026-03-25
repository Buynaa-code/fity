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
import 'create_class_screen.dart';
import 'coach_class_detail_screen.dart';

class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({super.key});

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final userId = context.read<UserBloc>().state.userId ?? 'dev_coach';
    context.read<MarathonBloc>().add(LoadCoachClasses(userId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MarathonBloc, MarathonState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(state.successMessage!),
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
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: BrandColors.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildStatsCards(state)),
                SliverToBoxAdapter(child: _buildSectionTitle()),
                if (state.status == MarathonStatus.loading && state.coachClasses.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: BrandColors.primary),
                    ),
                  )
                else if (state.coachClasses.isEmpty)
                  SliverFillRemaining(child: _buildEmptyState())
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildClassCard(state.coachClasses[index]),
                        );
                      },
                      childCount: state.coachClasses.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
          floatingActionButton: _buildFab(),
        );
      },
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: BrandColors.secondary.withValues(alpha: 0.1),
                backgroundImage: userState.photoUrl != null
                    ? NetworkImage(userState.photoUrl!)
                    : null,
                child: userState.photoUrl == null
                    ? Text(
                        userState.userName.isNotEmpty
                            ? userState.userName[0].toUpperCase()
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
                    Text(
                      'Сайн байна уу, ${userState.userName}!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: BrandColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: BrandColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.school_rounded,
                            size: 14,
                            color: BrandColors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Марафон багш',
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
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCards(MarathonState state) {
    final totalClasses = state.coachClasses.length;
    final totalParticipants = state.coachClasses.fold<int>(
      0,
      (sum, c) => sum + c.currentParticipants,
    );
    final activeClasses = state.coachClasses
        .where((c) => c.status == MarathonClassStatus.active)
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.class_rounded,
              label: 'Нийт анги',
              value: totalClasses.toString(),
              color: BrandColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.people_rounded,
              label: 'Оролцогчид',
              value: totalParticipants.toString(),
              color: BrandColors.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.play_circle_rounded,
              label: 'Идэвхтэй',
              value: activeClasses.toString(),
              color: BrandColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
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

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Text(
            'Миний ангиуд',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BrandColors.textPrimary,
            ),
          ),
          const Spacer(),
          BlocBuilder<MarathonBloc, MarathonState>(
            builder: (context, state) {
              return Text(
                '${state.coachClasses.length} анги',
                style: TextStyle(
                  fontSize: 14,
                  color: BrandColors.textSecondary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(MarathonClass marathonClass) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CoachClassDetailScreen(marathonClass: marathonClass),
          ),
        ).then((_) => _loadData());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: BrandShadows.small,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: BrandGradients.secondary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_run_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          marathonClass.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          marathonClass.timeDisplay,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      marathonClass.status.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildClassInfoChip(
                    icon: Icons.calendar_today_rounded,
                    label: marathonClass.weekdaysDisplay,
                  ),
                  const SizedBox(width: 12),
                  _buildClassInfoChip(
                    icon: Icons.people_rounded,
                    label: '${marathonClass.currentParticipants}/${marathonClass.maxParticipants}',
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: BrandColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: BrandColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: BrandColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: BrandColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: BrandColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_circle_outline_rounded,
                size: 48,
                color: BrandColors.secondary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Та одоогоор анги үүсгээгүй байна',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: BrandColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Доорх товчийг дарж шинэ анги үүсгэнэ үү',
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

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateClassScreen()),
        ).then((_) => _loadData());
      },
      backgroundColor: BrandColors.primary,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text(
        'Анги үүсгэх',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
