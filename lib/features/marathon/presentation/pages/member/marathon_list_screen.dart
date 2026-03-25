import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/branding/brand_config.dart';
import '../../../../user/presentation/bloc/user_bloc.dart';
import '../../../domain/entities/marathon_class.dart';
import '../../bloc/marathon_bloc.dart';
import '../../bloc/marathon_event.dart';
import '../../bloc/marathon_state.dart';
import 'class_detail_screen.dart';

class MarathonListScreen extends StatefulWidget {
  const MarathonListScreen({super.key});

  @override
  State<MarathonListScreen> createState() => _MarathonListScreenState();
}

class _MarathonListScreenState extends State<MarathonListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    final userState = context.read<UserBloc>().state;
    final userId = userState.userId ?? 'dev_user';
    context.read<MarathonBloc>().add(const LoadClasses());
    context.read<MarathonBloc>().add(LoadMyClasses(userId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllClassesList(),
                  _buildMyClassesList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: BrandGradients.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.directions_run_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Марафон бэлтгэл',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: BrandColors.textPrimary,
                  ),
                ),
                Text(
                  'Багштай хамт бэлтгэл хий',
                  style: TextStyle(
                    fontSize: 14,
                    color: BrandColors.textSecondary,
                  ),
                ),
              ],
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
          color: BrandColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: BrandColors.textSecondary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        dividerHeight: 0,
        tabs: const [
          Tab(text: 'Бүх ангиуд'),
          Tab(text: 'Миний ангиуд'),
        ],
      ),
    );
  }

  Widget _buildAllClassesList() {
    return BlocBuilder<MarathonBloc, MarathonState>(
      builder: (context, state) {
        if (state.status == MarathonStatus.loading && state.classes.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: BrandColors.primary),
          );
        }

        if (state.classes.isEmpty) {
          return _buildEmptyState(
            icon: Icons.school_outlined,
            title: 'Одоогоор анги байхгүй байна',
            subtitle: 'Удахгүй шинэ ангиуд нээгдэнэ',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _loadData();
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: BrandColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: state.classes.length,
            itemBuilder: (context, index) {
              return _buildClassCard(state.classes[index], isMyClass: false);
            },
          ),
        );
      },
    );
  }

  Widget _buildMyClassesList() {
    return BlocBuilder<MarathonBloc, MarathonState>(
      builder: (context, state) {
        if (state.status == MarathonStatus.loading && state.myClasses.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: BrandColors.primary),
          );
        }

        if (state.myClasses.isEmpty) {
          return _buildEmptyState(
            icon: Icons.person_add_outlined,
            title: 'Та ямар нэгэн анги руу элсээгүй байна',
            subtitle: 'Ангид элсэхийн тулд "Бүх ангиуд" хэсгээс сонгоно уу',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _loadData();
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: BrandColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: state.myClasses.length,
            itemBuilder: (context, index) {
              return _buildClassCard(state.myClasses[index], isMyClass: true);
            },
          ),
        );
      },
    );
  }

  Widget _buildClassCard(MarathonClass marathonClass, {required bool isMyClass}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClassDetailScreen(marathonClass: marathonClass),
          ),
        );
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
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isMyClass ? BrandGradients.secondary : BrandGradients.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    backgroundImage: marathonClass.coachPhotoUrl != null
                        ? NetworkImage(marathonClass.coachPhotoUrl!)
                        : null,
                    child: marathonClass.coachPhotoUrl == null
                        ? Text(
                            marathonClass.coachName.isNotEmpty
                                ? marathonClass.coachName[0].toUpperCase()
                                : 'C',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
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
                          marathonClass.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Багш: ${marathonClass.coachName}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isMyClass)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Элссэн',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.access_time_rounded,
                        label: marathonClass.timeDisplay,
                        color: BrandColors.primary,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        icon: Icons.calendar_today_rounded,
                        label: marathonClass.weekdaysDisplay,
                        color: BrandColors.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.people_rounded,
                        label: '${marathonClass.currentParticipants}/${marathonClass.maxParticipants} хүн',
                        color: marathonClass.hasAvailableSpots
                            ? BrandColors.success
                            : BrandColors.error,
                      ),
                      const Spacer(),
                      if (!isMyClass && marathonClass.hasAvailableSpots)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: BrandColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 16,
                                color: BrandColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${marathonClass.availableSpots} орон сул',
                                style: TextStyle(
                                  color: BrandColors.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (!marathonClass.hasAvailableSpots)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: BrandColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Дүүрсэн',
                            style: TextStyle(
                              color: BrandColors.error,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: BrandColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: BrandColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
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
}
