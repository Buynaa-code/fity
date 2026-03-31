import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/branding/brand_config.dart';
import '../../data/repositories/trainer_repository.dart';
import '../../domain/entities/trainer.dart';
import '../bloc/trainer_list/trainer_list_bloc.dart';
import '../widgets/trainer_card.dart';
import '../widgets/specialty_chip.dart';
import 'trainer_detail_screen.dart';
import 'booking_history_screen.dart';
import 'trainer_registration_screen.dart';

class TrainerListScreen extends StatelessWidget {
  const TrainerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TrainerListBloc(repository: TrainerRepository())
        ..add(LoadTrainers()),
      child: const _TrainerListView(),
    );
  }
}

class _TrainerListView extends StatefulWidget {
  const _TrainerListView();

  @override
  State<_TrainerListView> createState() => _TrainerListViewState();
}

class _TrainerListViewState extends State<_TrainerListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortBottomSheet(BuildContext context, TrainerSortOption currentSort) {
    showModalBottomSheet(
      context: context,
      backgroundColor: BrandColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _SortBottomSheet(
        currentSort: currentSort,
        onSelected: (option) {
          context.read<TrainerListBloc>().add(SortTrainers(option));
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.background,
      body: SafeArea(
        child: BlocBuilder<TrainerListBloc, TrainerListState>(
          builder: (context, state) {
            if (state is TrainerListLoading) {
              return const Center(
                child: CircularProgressIndicator(color: BrandColors.primary),
              );
            }

            if (state is TrainerListError) {
              return _buildErrorState(context);
            }

            if (state is TrainerListLoaded) {
              return CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(child: _buildHeader(context)),

                  // Search Bar
                  SliverToBoxAdapter(child: _buildSearchBar(context)),

                  // Sort and Filter Row
                  SliverToBoxAdapter(child: _buildSortFilterRow(context, state)),

                  // Specialty Filter Chips
                  SliverToBoxAdapter(child: _buildSpecialtyChips(context, state)),

                  // Featured Section (only show when no search/filter)
                  if (state.searchQuery.isEmpty &&
                      state.selectedSpecialty == null &&
                      state.featuredTrainers.isNotEmpty)
                    SliverToBoxAdapter(child: _buildFeaturedSection(context, state)),

                  // Results Header
                  SliverToBoxAdapter(child: _buildResultsHeader(state)),

                  // Trainer List
                  state.filteredTrainers.isEmpty
                      ? SliverFillRemaining(child: _buildEmptyState())
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final trainer = state.filteredTrainers[index];
                                return TrainerCard(
                                  trainer: trainer,
                                  onTap: () => _navigateToDetail(context, trainer),
                                );
                              },
                              childCount: state.filteredTrainers.length,
                            ),
                          ),
                        ),

                  // Bottom padding
                  const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BrandColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: BrandShadows.small,
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Дасгалжуулагч',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Мэргэжлийн дасгалжуулагч олоорой',
                  style: TextStyle(
                    fontSize: 13,
                    color: BrandColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Become a trainer button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrainerRegistrationScreen(
                    userId: 'current_user',
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF72928), Color(0xFFFF9149)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Бүртгүүлэх',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Booking history button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookingHistoryScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BrandColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.history_rounded,
                color: BrandColors.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: BrandColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: BrandShadows.small,
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            context.read<TrainerListBloc>().add(SearchTrainers(value));
          },
          decoration: InputDecoration(
            hintText: 'Дасгалжуулагч хайх...',
            hintStyle: TextStyle(color: BrandColors.textTertiary),
            prefixIcon: Icon(Icons.search, color: BrandColors.textTertiary),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: BrandColors.textTertiary),
                    onPressed: () {
                      _searchController.clear();
                      context.read<TrainerListBloc>().add(const SearchTrainers(''));
                    },
                  )
                : null,
            filled: true,
            fillColor: BrandColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortFilterRow(BuildContext context, TrainerListLoaded state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          // Sort button
          GestureDetector(
            onTap: () => _showSortBottomSheet(context, state.sortOption),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: BrandColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: BrandColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sort, size: 18, color: BrandColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    state.sortOption.displayName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: BrandColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, size: 18, color: BrandColors.textSecondary),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Results count
          Text(
            '${state.filteredTrainers.length} илэрц',
            style: TextStyle(
              fontSize: 13,
              color: BrandColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyChips(BuildContext context, TrainerListLoaded state) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SpecialtyChip(
              label: 'Бүгд',
              isSelected: state.selectedSpecialty == null,
              onTap: () {
                context.read<TrainerListBloc>().add(const FilterTrainersBySpecialty(null));
              },
            ),
          ),
          ...state.availableSpecialties.map((specialty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SpecialtyChip(
                label: specialty,
                isSelected: state.selectedSpecialty == specialty,
                onTap: () {
                  context.read<TrainerListBloc>().add(FilterTrainersBySpecialty(specialty));
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context, TrainerListLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: BrandColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.star_rounded, size: 18, color: BrandColors.warning),
              ),
              const SizedBox(width: 8),
              const Text(
                'Онцлох дасгалжуулагч',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.featuredTrainers.length,
            itemBuilder: (context, index) {
              final trainer = state.featuredTrainers[index];
              return _FeaturedTrainerCard(
                trainer: trainer,
                onTap: () => _navigateToDetail(context, trainer),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultsHeader(TrainerListLoaded state) {
    if (state.searchQuery.isEmpty && state.selectedSpecialty == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Row(
          children: [
            Icon(Icons.people_outline, size: 20, color: BrandColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Бүх дасгалжуулагч',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox(height: 8);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: BrandColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_search_rounded,
              size: 48,
              color: BrandColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Дасгалжуулагч олдсонгүй',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Өөр хайлт хийж үзнэ үү',
            style: TextStyle(
              fontSize: 14,
              color: BrandColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: BrandColors.errorSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: BrandColors.error,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Алдаа гарлаа',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Интернэт холболтоо шалгана уу',
            style: TextStyle(
              fontSize: 14,
              color: BrandColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<TrainerListBloc>().add(LoadTrainers());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Дахин оролдох'),
            style: ElevatedButton.styleFrom(
              backgroundColor: BrandColors.primary,
              foregroundColor: BrandColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Trainer trainer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainerDetailScreen(trainerId: trainer.id),
      ),
    );
  }
}

// Featured Trainer Card Widget
class _FeaturedTrainerCard extends StatelessWidget {
  final Trainer trainer;
  final VoidCallback onTap;

  const _FeaturedTrainerCard({
    required this.trainer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: BrandColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: BrandShadows.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    trainer.imageUrl,
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        color: BrandColors.primarySurface,
                        child: Center(
                          child: Icon(Icons.person, size: 40, color: BrandColors.primary),
                        ),
                      );
                    },
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          trainer.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Info - use Expanded to prevent overflow
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      trainer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trainer.specialties.take(2).join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: BrandColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₮${_formatPrice(trainer.hourlyRate)}/цаг',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: BrandColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return price.toStringAsFixed(0);
  }
}

// Sort Bottom Sheet
class _SortBottomSheet extends StatelessWidget {
  final TrainerSortOption currentSort;
  final Function(TrainerSortOption) onSelected;

  const _SortBottomSheet({
    required this.currentSort,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: BrandColors.disabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Эрэмбэлэх',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...TrainerSortOption.values.map((option) {
            final isSelected = option == currentSort;
            return ListTile(
              onTap: () => onSelected(option),
              leading: Icon(
                _getIconForOption(option),
                color: isSelected ? BrandColors.primary : BrandColors.textSecondary,
              ),
              title: Text(
                option.displayName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? BrandColors.primary : BrandColors.textPrimary,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: BrandColors.primary)
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: isSelected ? BrandColors.primarySurface : null,
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  IconData _getIconForOption(TrainerSortOption option) {
    switch (option) {
      case TrainerSortOption.rating:
        return Icons.star_rounded;
      case TrainerSortOption.priceHigh:
        return Icons.trending_up;
      case TrainerSortOption.priceLow:
        return Icons.trending_down;
      case TrainerSortOption.experience:
        return Icons.workspace_premium;
      case TrainerSortOption.name:
        return Icons.sort_by_alpha;
    }
  }
}
