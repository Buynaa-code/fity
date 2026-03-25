import 'package:flutter/material.dart' hide Badge;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/badge.dart';
import '../../domain/entities/badge_definitions.dart';
import '../bloc/badge_bloc.dart';
import '../bloc/badge_event.dart';
import '../bloc/badge_state.dart';
import '../widgets/badge_card.dart';
import '../widgets/badge_unlock_animation.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showEarnedOnly = false;

  final List<BadgeCategory?> _categories = [
    null, // All
    BadgeCategory.streak,
    BadgeCategory.workout,
    BadgeCategory.challenge,
    BadgeCategory.water,
    BadgeCategory.milestone,
    BadgeCategory.social,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    context.read<BadgeBloc>().add(const LoadBadges());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BadgeBloc, BadgeState>(
      listener: (context, state) {
        // Show unlock animation for newly awarded badges
        if (state.newlyAwardedBadges.isNotEmpty) {
          for (final userBadge in state.newlyAwardedBadges) {
            BadgeUnlockAnimation.show(context, userBadge);
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: CustomScrollView(
            slivers: [
              // App Bar
              _buildAppBar(state),

              // Stats Header
              SliverToBoxAdapter(
                child: _buildStatsHeader(state),
              ),

              // Filter toggle
              SliverToBoxAdapter(
                child: _buildFilterToggle(),
              ),

              // Category Tabs
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  tabBar: _buildTabBar(),
                ),
              ),

              // Badge Grid
              _buildBadgeGrid(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BadgeState state) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFFF72928),
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Шагнал & Амжилт',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF72928), Color(0xFFFF9149)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      actions: [
        if (state.newBadgeCount > 0)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.new_releases_rounded, size: 16, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  '${state.newBadgeCount} шинэ',
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
    );
  }

  Widget _buildStatsHeader(BadgeState state) {
    final totalBadges = BadgeDefinitions.allBadges.length;
    final earnedCount = state.earnedBadges.length;
    final percent = totalBadges > 0 ? (earnedCount / totalBadges) : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade600, Colors.purple.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Progress ring
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: percent,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(percent * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Таны цуглуулга',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$earnedCount / $totalBadges',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          color: Colors.amber[400],
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${state.totalXp} XP',
                          style: TextStyle(
                            color: Colors.amber[400],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Rarity breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: BadgeRarity.values.map((rarity) {
              final earnedOfRarity = state.earnedBadges.where((ub) {
                final badge = BadgeDefinitions.getBadgeById(ub.badgeId);
                return badge?.rarity == rarity;
              }).length;

              final totalOfRarity = BadgeDefinitions.getBadgesByRarity(rarity).length;

              return _buildRarityItem(rarity, earnedOfRarity, totalOfRarity);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRarityItem(BadgeRarity rarity, int earned, int total) {
    final colors = _getRarityColors(rarity);
    final name = _getRarityShortName(rarity);

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$earned',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  List<Color> _getRarityColors(BadgeRarity rarity) {
    switch (rarity) {
      case BadgeRarity.common:
        return [Colors.grey.shade400, Colors.grey.shade600];
      case BadgeRarity.uncommon:
        return [Colors.green.shade400, Colors.green.shade700];
      case BadgeRarity.rare:
        return [Colors.blue.shade400, Colors.blue.shade700];
      case BadgeRarity.epic:
        return [Colors.purple.shade400, Colors.purple.shade700];
      case BadgeRarity.legendary:
        return [Colors.orange.shade400, Colors.amber.shade700];
    }
  }

  String _getRarityShortName(BadgeRarity rarity) {
    switch (rarity) {
      case BadgeRarity.common:
        return 'Энгийн';
      case BadgeRarity.uncommon:
        return 'Ховор биш';
      case BadgeRarity.rare:
        return 'Ховор';
      case BadgeRarity.epic:
        return 'Эпик';
      case BadgeRarity.legendary:
        return 'Домог';
    }
  }

  Widget _buildFilterToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text(
            'Зөвхөн авсан',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Switch(
            value: _showEarnedOnly,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() {
                _showEarnedOnly = value;
              });
            },
            activeThumbColor: const Color(0xFFF72928),
          ),
        ],
      ),
    );
  }

  TabBar _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: const Color(0xFFF72928),
      unselectedLabelColor: Colors.grey,
      indicatorColor: const Color(0xFFF72928),
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      tabs: _categories.map((category) {
        return Tab(text: _getCategoryName(category));
      }).toList(),
    );
  }

  String _getCategoryName(BadgeCategory? category) {
    if (category == null) return 'Бүгд';
    switch (category) {
      case BadgeCategory.streak:
        return 'Тогтмол';
      case BadgeCategory.workout:
        return 'Дасгал';
      case BadgeCategory.challenge:
        return 'Сорилцоон';
      case BadgeCategory.water:
        return 'Ус';
      case BadgeCategory.milestone:
        return 'Чухал үе';
      case BadgeCategory.social:
        return 'Нийгэм';
      case BadgeCategory.seasonal:
        return 'Улирал';
    }
  }

  Widget _buildBadgeGrid(BadgeState state) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          final selectedCategory = _categories[_tabController.index];
          final badges = _getFilteredBadges(selectedCategory, state);

          if (badges.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _showEarnedOnly
                          ? 'Энэ ангилалд шагнал аваагүй байна'
                          : 'Шагнал олдсонгүй',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final badgeData = badges[index];
                final badge = badgeData['badge'] as Badge;
                final userBadge = badgeData['userBadge'] as UserBadge?;
                final progress = badgeData['progress'] as BadgeProgress?;

                return BadgeCard(
                  badge: badge,
                  userBadge: userBadge,
                  progress: progress,
                  onTap: () {
                    if (userBadge?.isNew == true) {
                      context.read<BadgeBloc>().add(MarkBadgeSeen(userBadge!.id));
                    }
                  },
                );
              },
              childCount: badges.length,
            ),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredBadges(
    BadgeCategory? category,
    BadgeState state,
  ) {
    final earnedIds = state.earnedBadges.map((b) => b.badgeId).toSet();
    final progressMap = {
      for (var p in state.badgeProgress) p.badgeId: p,
    };
    final userBadgeMap = {
      for (var ub in state.earnedBadges) ub.badgeId: ub,
    };

    var badges = BadgeDefinitions.visibleBadges;

    // Filter by category
    if (category != null) {
      badges = badges.where((b) => b.category == category).toList();
    }

    // Filter by earned status
    if (_showEarnedOnly) {
      badges = badges.where((b) => earnedIds.contains(b.id)).toList();
    }

    // Sort: earned first, then by progress
    badges.sort((a, b) {
      final aEarned = earnedIds.contains(a.id);
      final bEarned = earnedIds.contains(b.id);

      if (aEarned && !bEarned) return -1;
      if (!aEarned && bEarned) return 1;

      if (!aEarned && !bEarned) {
        final aProgress = progressMap[a.id]?.progressPercent ?? 0;
        final bProgress = progressMap[b.id]?.progressPercent ?? 0;
        return bProgress.compareTo(aProgress);
      }

      return 0;
    });

    return badges.map((badge) {
      return {
        'badge': badge,
        'userBadge': userBadgeMap[badge.id],
        'progress': progressMap[badge.id],
      };
    }).toList();
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate({required this.tabBar});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
