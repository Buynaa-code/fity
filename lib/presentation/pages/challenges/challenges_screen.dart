import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/user_data_service.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  String selectedCategory = 'Бүгд';

  final List<Challenge> challenges = [
    Challenge(
      id: '1',
      title: '30 хоногийн лангуу',
      description: '30 хоногийн турш өдөр бүр лангуу дасгал хийх',
      category: 'Хүч чадал',
      difficulty: ChallengeLevel.medium,
      duration: const Duration(days: 30),
      currentProgress: 12,
      totalSteps: 30,
      reward: 500,
      participants: 1245,
      isJoined: true,
      startDate: DateTime.now().subtract(const Duration(days: 12)),
      endDate: DateTime.now().add(const Duration(days: 18)),
      icon: Icons.fitness_center_rounded,
      color: Colors.orange,
      dailyTarget: 'Өдөрт 20 лангуу',
    ),
    Challenge(
      id: '2',
      title: '10000 алхам',
      description: 'Өдөр бүр 10000 алхам алхах',
      category: 'Кардио',
      difficulty: ChallengeLevel.easy,
      duration: const Duration(days: 7),
      currentProgress: 5,
      totalSteps: 7,
      reward: 200,
      participants: 3892,
      isJoined: true,
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 2)),
      icon: Icons.directions_walk_rounded,
      color: Colors.green,
      dailyTarget: '10000 алхам',
    ),
    Challenge(
      id: '3',
      title: 'Планк хүчирхэг',
      description: '60 секундийн планк дасгалыг хийх чадвар эзэмших',
      category: 'Гэдэс сүмян',
      difficulty: ChallengeLevel.hard,
      duration: const Duration(days: 21),
      currentProgress: 0,
      totalSteps: 21,
      reward: 800,
      participants: 567,
      isJoined: false,
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 22)),
      icon: Icons.self_improvement_rounded,
      color: Colors.purple,
      dailyTarget: 'Планк хугацааг нэмэгдүүлэх',
    ),
    Challenge(
      id: '4',
      title: 'Усны хэмжээ',
      description: 'Өдөрт 2.5 литр ус уух',
      category: 'Эрүүл мэнд',
      difficulty: ChallengeLevel.easy,
      duration: const Duration(days: 14),
      currentProgress: 0,
      totalSteps: 14,
      reward: 300,
      participants: 2156,
      isJoined: false,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 14)),
      icon: Icons.water_drop_rounded,
      color: Colors.blue,
      dailyTarget: '2.5 литр ус',
    ),
    Challenge(
      id: '5',
      title: 'Кардио магистр',
      description: 'Долоо хоног бүр 3 удаа кардио дасгал',
      category: 'Кардио',
      difficulty: ChallengeLevel.hard,
      duration: const Duration(days: 28),
      currentProgress: 0,
      totalSteps: 12, // 4 weeks * 3 times per week
      reward: 1000,
      participants: 389,
      isJoined: false,
      startDate: DateTime.now().add(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 31)),
      icon: Icons.favorite_rounded,
      color: Colors.red,
      dailyTarget: 'Долоо хоногт 3 удаа',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Challenge> get filteredChallenges {
    if (selectedCategory == 'Бүгд') return challenges;
    return challenges.where((c) => c.category == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Сорилцоон'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard_rounded),
            tooltip: 'Үр дүнгийн самбар',
            onPressed: () {
              // Navigate to leaderboard
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Шинэ сорилцоон',
            onPressed: () {
              // Create new challenge
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          setState(() {});
        },
        child: Column(
          children: [
            // Header with statistics
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Таны сорилцоон',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          Icons.emoji_events_rounded,
                          '${challenges.where((c) => c.isJoined).length}',
                          'Идэвхитэй',
                          Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          Icons.stars_rounded,
                          '${challenges.where((c) => c.isJoined && c.isCompleted).length}',
                          'Дууссан',
                          Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          Icons.local_fire_department_rounded,
                          '${challenges.fold<int>(0, (sum, c) => sum + (c.isJoined ? c.reward : 0))}',
                          'Нийт оноо',
                          Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Category filters
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip('Бүгд', selectedCategory == 'Бүгд'),
                  _buildCategoryChip(
                    'Хүч чадал',
                    selectedCategory == 'Хүч чадал',
                  ),
                  _buildCategoryChip('Кардио', selectedCategory == 'Кардио'),
                  _buildCategoryChip(
                    'Гэдэс сүмян',
                    selectedCategory == 'Гэдэс сүмян',
                  ),
                  _buildCategoryChip(
                    'Эрүүл мэнд',
                    selectedCategory == 'Эрүүл мэнд',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Challenges list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredChallenges.length,
                itemBuilder: (context, index) {
                  final challenge = filteredChallenges[index];
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final animation = Tween(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            index * 0.1,
                            1.0,
                            curve: Curves.easeOutQuart,
                          ),
                        ),
                      );

                      return SlideTransition(
                        position: animation,
                        child: FadeTransition(
                          opacity: _animationController,
                          child: ChallengeCard(
                            challenge: challenge,
                            onJoin: () => _joinChallenge(challenge),
                            onLeave: () => _leaveChallenge(challenge),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String value,
    String label,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: textColor, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              selectedCategory = label;
            });
            HapticFeedback.selectionClick();
          },
          backgroundColor: Colors.white,
          selectedColor: Colors.blue.withValues(alpha: 0.2),
          checkmarkColor: Colors.blue,
          labelStyle: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
          elevation: isSelected ? 4 : 1,
          shadowColor: Colors.blue.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
            ),
          ),
        ),
      ),
    );
  }

  void _joinChallenge(Challenge challenge) async {
    HapticFeedback.mediumImpact();

    // Update local state
    setState(() {
      final index = challenges.indexWhere((c) => c.id == challenge.id);
      if (index != -1) {
        challenges[index] = challenge.copyWith(isJoined: true);
      }
    });

    // Save to persistent storage
    await UserDataService.instance.joinChallenge(challenge.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${challenge.title} сорилцоонд амжилттай нэгдлээ!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _leaveChallenge(Challenge challenge) async {
    HapticFeedback.lightImpact();

    // Update local state
    setState(() {
      final index = challenges.indexWhere((c) => c.id == challenge.id);
      if (index != -1) {
        challenges[index] = challenge.copyWith(isJoined: false);
      }
    });

    // Save to persistent storage
    await UserDataService.instance.leaveChallenge(challenge.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${challenge.title} сорилцооноос гарлаа'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onJoin,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final isStartingSoon = challenge.startDate.isAfter(DateTime.now());
    final isActive = !isStartingSoon && !challenge.isCompleted;
    final progressPercent = challenge.currentProgress / challenge.totalSteps;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: challenge.isJoined ? 6 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side:
              challenge.isJoined
                  ? BorderSide(color: challenge.color, width: 2)
                  : BorderSide.none,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient:
                challenge.isJoined
                    ? LinearGradient(
                      colors: [
                        challenge.color.withValues(alpha: 0.1),
                        challenge.color.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            challenge.color,
                            challenge.color.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: challenge.color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        challenge.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildDifficultyBadge(),
                              const SizedBox(width: 8),
                              _buildStatusBadge(isStartingSoon, isActive),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                        Text(
                          '${challenge.reward}',
                          style: TextStyle(
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  challenge.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 12),

                // Daily target
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: challenge.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: challenge.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.track_changes_rounded,
                        size: 16,
                        color: challenge.color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        challenge.dailyTarget,
                        style: TextStyle(
                          color: challenge.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Progress (if joined)
                if (challenge.isJoined) ...[
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
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  '${challenge.currentProgress}/${challenge.totalSteps}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: challenge.color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progressPercent,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    challenge.color,
                                  ),
                                  minHeight: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${(progressPercent * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: challenge.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Footer with participants and action
                Row(
                  children: [
                    Icon(
                      Icons.group_rounded,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${challenge.participants} хүн оролцож байна',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const Spacer(),
                    _buildActionButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge() {
    final difficultyData = _getDifficultyData(challenge.difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: difficultyData['color'].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: difficultyData['color'].withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            difficultyData['icon'],
            size: 12,
            color: difficultyData['color'],
          ),
          const SizedBox(width: 4),
          Text(
            difficultyData['text'],
            style: TextStyle(
              color: difficultyData['color'],
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isStartingSoon, bool isActive) {
    String text;
    Color color;
    IconData icon;

    if (challenge.isCompleted) {
      text = 'Дууссан';
      color = Colors.green;
      icon = Icons.check_circle_rounded;
    } else if (isStartingSoon) {
      text = 'Удахгүй';
      color = Colors.orange;
      icon = Icons.schedule_rounded;
    } else if (isActive) {
      text = 'Идэвхитэй';
      color = Colors.blue;
      icon = Icons.play_circle_rounded;
    } else {
      text = 'Дууссан';
      color = Colors.grey;
      icon = Icons.stop_circle_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (challenge.isJoined) {
      return TextButton.icon(
        onPressed: onLeave,
        icon: const Icon(Icons.exit_to_app_rounded, size: 16),
        label: const Text('Гарах'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: onJoin,
        icon: const Icon(Icons.add_rounded, size: 16),
        label: const Text('Нэгдэх'),
        style: ElevatedButton.styleFrom(
          backgroundColor: challenge.color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 2,
        ),
      );
    }
  }

  Map<String, dynamic> _getDifficultyData(ChallengeLevel level) {
    switch (level) {
      case ChallengeLevel.easy:
        return {
          'text': 'Амархан',
          'color': Colors.green,
          'icon': Icons.sentiment_very_satisfied_rounded,
        };
      case ChallengeLevel.medium:
        return {
          'text': 'Дундаж',
          'color': Colors.orange,
          'icon': Icons.sentiment_neutral_rounded,
        };
      case ChallengeLevel.hard:
        return {
          'text': 'Хүнд',
          'color': Colors.red,
          'icon': Icons.sentiment_very_dissatisfied_rounded,
        };
    }
  }
}

// Data Models
enum ChallengeLevel { easy, medium, hard }

class Challenge {
  final String id;
  final String title;
  final String description;
  final String category;
  final ChallengeLevel difficulty;
  final Duration duration;
  final int currentProgress;
  final int totalSteps;
  final int reward;
  final int participants;
  final bool isJoined;
  final DateTime startDate;
  final DateTime endDate;
  final IconData icon;
  final Color color;
  final String dailyTarget;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.duration,
    required this.currentProgress,
    required this.totalSteps,
    required this.reward,
    required this.participants,
    required this.isJoined,
    required this.startDate,
    required this.endDate,
    required this.icon,
    required this.color,
    required this.dailyTarget,
  });

  bool get isCompleted => currentProgress >= totalSteps;

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    ChallengeLevel? difficulty,
    Duration? duration,
    int? currentProgress,
    int? totalSteps,
    int? reward,
    int? participants,
    bool? isJoined,
    DateTime? startDate,
    DateTime? endDate,
    IconData? icon,
    Color? color,
    String? dailyTarget,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      currentProgress: currentProgress ?? this.currentProgress,
      totalSteps: totalSteps ?? this.totalSteps,
      reward: reward ?? this.reward,
      participants: participants ?? this.participants,
      isJoined: isJoined ?? this.isJoined,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      dailyTarget: dailyTarget ?? this.dailyTarget,
    );
  }
}
