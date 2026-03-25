import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;

  final List<Marathon> _marathons = [
    Marathon(
      id: '1',
      title: '30 Хоногийн Хувьсал',
      subtitle: 'Биеийн өөрчлөлтийн аялал',
      description: '30 хоногийн турш өдөр бүр дасгал хийж, биеийн хувьсалд хүр',
      type: MarathonType.transformation,
      totalDays: 30,
      currentDay: 12,
      participants: 2456,
      prize: '500,000₮ + Premium эрх',
      color: const Color(0xFFF72928),
      gradientColors: [const Color(0xFFF72928), const Color(0xFFFF6B35)],
      isJoined: true,
      milestones: [
        Milestone(day: 7, title: '1 долоо хоног', reward: 100, isCompleted: true),
        Milestone(day: 14, title: '2 долоо хоног', reward: 200, isCompleted: false),
        Milestone(day: 21, title: '3 долоо хоног', reward: 300, isCompleted: false),
        Milestone(day: 30, title: 'Амжилт!', reward: 500, isCompleted: false),
      ],
      dailyTasks: [
        DailyTask(title: '20 минут дасгал', isCompleted: true),
        DailyTask(title: '2L ус уух', isCompleted: true),
        DailyTask(title: '7 цаг унтах', isCompleted: false),
      ],
    ),
    Marathon(
      id: '2',
      title: '100км Алхалт',
      subtitle: 'Алхамын тэмцээн',
      description: 'Сард 100км алхаж, эрүүл амьдралын зуршил бий болго',
      type: MarathonType.steps,
      totalDays: 30,
      currentDay: 18,
      participants: 5234,
      prize: '300,000₮',
      color: const Color(0xFF1ABC9C),
      gradientColors: [const Color(0xFF1ABC9C), const Color(0xFF16A085)],
      isJoined: true,
      totalSteps: 100000,
      currentSteps: 67500,
      milestones: [
        Milestone(day: 25000, title: '25км', reward: 50, isCompleted: true),
        Milestone(day: 50000, title: '50км', reward: 100, isCompleted: true),
        Milestone(day: 75000, title: '75км', reward: 150, isCompleted: false),
        Milestone(day: 100000, title: '100км!', reward: 300, isCompleted: false),
      ],
    ),
    Marathon(
      id: '3',
      title: 'Булчин Бүтээгч',
      subtitle: 'Хүч чадлын марафон',
      description: '8 долоо хоногийн турш булчингаа хөгжүүлж, хүч чадлаа нэм',
      type: MarathonType.strength,
      totalDays: 56,
      currentDay: 0,
      participants: 1823,
      prize: '1,000,000₮ + Тэжээл',
      color: const Color(0xFF9B59B6),
      gradientColors: [const Color(0xFF9B59B6), const Color(0xFF8E44AD)],
      isJoined: false,
      startDate: DateTime.now().add(const Duration(days: 3)),
      milestones: [
        Milestone(day: 14, title: '2 долоо хоног', reward: 200, isCompleted: false),
        Milestone(day: 28, title: '4 долоо хоног', reward: 400, isCompleted: false),
        Milestone(day: 42, title: '6 долоо хоног', reward: 600, isCompleted: false),
        Milestone(day: 56, title: 'Чемпион!', reward: 1000, isCompleted: false),
      ],
    ),
    Marathon(
      id: '4',
      title: 'Эрт босогч клуб',
      subtitle: 'Өглөөний дадал',
      description: '21 хоног дараалан өглөөний 6 цагт босож, дасгал хий',
      type: MarathonType.habit,
      totalDays: 21,
      currentDay: 0,
      participants: 892,
      prize: '200,000₮',
      color: const Color(0xFFF39C12),
      gradientColors: [const Color(0xFFF39C12), const Color(0xFFE67E22)],
      isJoined: false,
      milestones: [
        Milestone(day: 7, title: '1 долоо хоног', reward: 50, isCompleted: false),
        Milestone(day: 14, title: '2 долоо хоног', reward: 100, isCompleted: false),
        Milestone(day: 21, title: 'Дадал бий боллоо!', reward: 200, isCompleted: false),
      ],
    ),
  ];

  final List<LeaderboardEntry> _leaderboard = [
    LeaderboardEntry(rank: 1, name: 'Болд', avatar: '🏆', points: 2850, streak: 45),
    LeaderboardEntry(rank: 2, name: 'Сараа', avatar: '🥈', points: 2720, streak: 38),
    LeaderboardEntry(rank: 3, name: 'Батаа', avatar: '🥉', points: 2650, streak: 32),
    LeaderboardEntry(rank: 4, name: 'Оюука', avatar: '💪', points: 2580, streak: 28),
    LeaderboardEntry(rank: 5, name: 'Түмэн', avatar: '🔥', points: 2490, streak: 25),
    LeaderboardEntry(rank: 6, name: 'Нараа', avatar: '⭐', points: 2350, streak: 22),
    LeaderboardEntry(rank: 7, name: 'Ганаа', avatar: '💎', points: 2280, streak: 20),
    LeaderboardEntry(rank: 8, name: 'Зулаа', avatar: '🎯', points: 2150, streak: 18),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMarathonsTab(),
                  _buildLeaderboardTab(),
                  _buildAchievementsTab(),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Марафон',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Урт хугацааны зорилгод хүрээрэй',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // User rank badge
          GestureDetector(
            onTap: () => _tabController.animateTo(1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🏅', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    '#12',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
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
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF72928), Color(0xFFFF9149)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Марафон'),
          Tab(text: 'Тэргүүлэгчид'),
          Tab(text: 'Амжилт'),
        ],
      ),
    );
  }

  Widget _buildMarathonsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active marathon highlight
          if (_marathons.any((m) => m.isJoined)) ...[
            _buildActiveMarathonCard(_marathons.firstWhere((m) => m.isJoined)),
            const SizedBox(height: 24),
          ],

          // All marathons
          const Text(
            'Бүх марафон',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          ..._marathons.map((marathon) => _buildMarathonCard(marathon)),
        ],
      ),
    );
  }

  Widget _buildActiveMarathonCard(Marathon marathon) {
    final progress = marathon.currentDay / marathon.totalDays;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: marathon.gradientColors,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: marathon.color.withValues(alpha: 0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Идэвхтэй',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${marathon.currentDay}/${marathon.totalDays} хоног',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            marathon.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            marathon.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 20),

          // Progress bar
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Daily tasks
          if (marathon.dailyTasks != null) ...[
            const Text(
              'Өнөөдрийн даалгавар',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            ...marathon.dailyTasks!.map((task) => _buildDailyTaskItem(task)),
          ],

          const SizedBox(height: 16),

          // Milestones preview
          Row(
            children: marathon.milestones.map((milestone) {
              final isNext = !milestone.isCompleted &&
                  marathon.milestones.where((m) => !m.isCompleted).first == milestone;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: milestone.isCompleted
                        ? Colors.white.withValues(alpha: 0.3)
                        : isNext
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: isNext
                        ? Border.all(color: Colors.white.withValues(alpha: 0.5))
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        milestone.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                        color: Colors.white.withValues(alpha: milestone.isCompleted ? 1 : 0.6),
                        size: 18,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        milestone.title,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTaskItem(DailyTask task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: task.isCompleted
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: task.isCompleted
                ? const Icon(Icons.check, color: Color(0xFFF72928), size: 16)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            task.title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: task.isCompleted ? 0.7 : 1),
              fontSize: 14,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarathonCard(Marathon marathon) {
    final isUpcoming = marathon.startDate?.isAfter(DateTime.now()) ?? false;

    return GestureDetector(
      onTap: () => _showMarathonDetail(marathon),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: marathon.isJoined
              ? Border.all(color: marathon.color.withValues(alpha: 0.5), width: 2)
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: marathon.gradientColors),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getMarathonIcon(marathon.type),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              marathon.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (isUpcoming)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Удахгүй',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        marathon.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Stats row
            Row(
              children: [
                _buildMarathonStat(Icons.calendar_today, '${marathon.totalDays} хоног'),
                const SizedBox(width: 20),
                _buildMarathonStat(Icons.people, '${marathon.participants}'),
                const SizedBox(width: 20),
                _buildMarathonStat(Icons.emoji_events, marathon.prize),
              ],
            ),

            const SizedBox(height: 16),

            // Action button
            if (!marathon.isJoined)
              GestureDetector(
                onTap: () => _joinMarathon(marathon),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: marathon.gradientColors),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'Нэгдэх',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Явц',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${((marathon.currentDay / marathon.totalDays) * 100).toInt()}%',
                              style: TextStyle(
                                color: marathon.color,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: marathon.currentDay / marathon.totalDays,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation(marathon.color),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: marathon.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: marathon.color,
                      size: 20,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarathonStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.5), size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Top 3 podium
          _buildPodium(),
          const SizedBox(height: 24),

          // Rest of leaderboard
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: _leaderboard.skip(3).map((entry) => _buildLeaderboardRow(entry)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd place
        Expanded(child: _buildPodiumItem(_leaderboard[1], 100, const Color(0xFFC0C0C0))),
        // 1st place
        Expanded(child: _buildPodiumItem(_leaderboard[0], 130, const Color(0xFFFFD700))),
        // 3rd place
        Expanded(child: _buildPodiumItem(_leaderboard[2], 80, const Color(0xFFCD7F32))),
      ],
    );
  }

  Widget _buildPodiumItem(LeaderboardEntry entry, double height, Color color) {
    return Column(
      children: [
        Text(
          entry.avatar,
          style: const TextStyle(fontSize: 40),
        ),
        const SizedBox(height: 8),
        Text(
          entry.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        Text(
          '${entry.points} XP',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.4)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Center(
            child: Text(
              '#${entry.rank}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow(LeaderboardEntry entry) {
    final isCurrentUser = entry.rank == 12;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isCurrentUser ? const Color(0xFFF72928).withValues(alpha: 0.1) : null,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(entry.avatar, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.streak} хоног',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${entry.points}',
            style: const TextStyle(
              color: Color(0xFFF72928),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'XP',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    final achievements = [
      Achievement(
        icon: '🔥',
        title: '7 хоногийн streak',
        description: '7 хоног дараалан дасгал хийсэн',
        isUnlocked: true,
        xp: 100,
      ),
      Achievement(
        icon: '💪',
        title: 'Анхны марафон',
        description: 'Марафонд анх удаа нэгдсэн',
        isUnlocked: true,
        xp: 50,
      ),
      Achievement(
        icon: '🏃',
        title: '10км алхагч',
        description: 'Нэг өдөрт 10км алхсан',
        isUnlocked: true,
        xp: 75,
      ),
      Achievement(
        icon: '🏆',
        title: 'Марафон дүүргэгч',
        description: 'Марафон бүрэн дуусгасан',
        isUnlocked: false,
        xp: 500,
      ),
      Achievement(
        icon: '⭐',
        title: 'Топ 10',
        description: 'Leaderboard топ 10-д орсон',
        isUnlocked: false,
        xp: 200,
      ),
      Achievement(
        icon: '🎯',
        title: '30 хоногийн мастер',
        description: '30 хоног дараалан идэвхтэй',
        isUnlocked: false,
        xp: 300,
      ),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) => _buildAchievementCard(achievements[index]),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? const Color(0xFF1A1A1A)
            : const Color(0xFF1A1A1A).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: achievement.isUnlocked
            ? Border.all(color: const Color(0xFFF72928).withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            achievement.icon,
            style: TextStyle(
              fontSize: 40,
              color: achievement.isUnlocked ? null : Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            achievement.title,
            style: TextStyle(
              color: achievement.isUnlocked ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            achievement.description,
            style: TextStyle(
              color: achievement.isUnlocked
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.grey.withValues(alpha: 0.5),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? const Color(0xFFF72928).withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+${achievement.xp} XP',
              style: TextStyle(
                color: achievement.isUnlocked ? const Color(0xFFF72928) : Colors.grey,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMarathonIcon(MarathonType type) {
    switch (type) {
      case MarathonType.transformation:
        return Icons.auto_awesome;
      case MarathonType.steps:
        return Icons.directions_walk;
      case MarathonType.strength:
        return Icons.fitness_center;
      case MarathonType.habit:
        return Icons.wb_sunny;
    }
  }

  void _joinMarathon(Marathon marathon) {
    HapticFeedback.heavyImpact();
    setState(() {
      final index = _marathons.indexWhere((m) => m.id == marathon.id);
      if (index != -1) {
        _marathons[index] = Marathon(
          id: marathon.id,
          title: marathon.title,
          subtitle: marathon.subtitle,
          description: marathon.description,
          type: marathon.type,
          totalDays: marathon.totalDays,
          currentDay: 0,
          participants: marathon.participants + 1,
          prize: marathon.prize,
          color: marathon.color,
          gradientColors: marathon.gradientColors,
          isJoined: true,
          milestones: marathon.milestones,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('${marathon.title} марафонд нэгдлээ!'),
          ],
        ),
        backgroundColor: const Color(0xFF1ABC9C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _showMarathonDetail(Marathon marathon) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to marathon detail screen
  }
}

// Data Models
enum MarathonType { transformation, steps, strength, habit }

class Marathon {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final MarathonType type;
  final int totalDays;
  final int currentDay;
  final int participants;
  final String prize;
  final Color color;
  final List<Color> gradientColors;
  final bool isJoined;
  final DateTime? startDate;
  final List<Milestone> milestones;
  final int? totalSteps;
  final int? currentSteps;
  final List<DailyTask>? dailyTasks;

  Marathon({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.type,
    required this.totalDays,
    required this.currentDay,
    required this.participants,
    required this.prize,
    required this.color,
    required this.gradientColors,
    required this.isJoined,
    this.startDate,
    required this.milestones,
    this.totalSteps,
    this.currentSteps,
    this.dailyTasks,
  });
}

class Milestone {
  final int day;
  final String title;
  final int reward;
  final bool isCompleted;

  Milestone({
    required this.day,
    required this.title,
    required this.reward,
    required this.isCompleted,
  });
}

class DailyTask {
  final String title;
  final bool isCompleted;

  DailyTask({required this.title, required this.isCompleted});
}

class LeaderboardEntry {
  final int rank;
  final String name;
  final String avatar;
  final int points;
  final int streak;

  LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.avatar,
    required this.points,
    required this.streak,
  });
}

class Achievement {
  final String icon;
  final String title;
  final String description;
  final bool isUnlocked;
  final int xp;

  Achievement({
    required this.icon,
    required this.title,
    required this.description,
    required this.isUnlocked,
    required this.xp,
  });
}
