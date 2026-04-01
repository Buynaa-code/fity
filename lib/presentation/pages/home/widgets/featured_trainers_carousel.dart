import 'package:flutter/material.dart';
import '../../../../features/trainer_marketplace/domain/entities/trainer.dart';
import '../../../../features/trainer_marketplace/data/repositories/trainer_repository.dart';
import '../../../../features/trainer_marketplace/presentation/widgets/featured_trainer_card.dart';
import '../../../../features/trainer_marketplace/presentation/pages/trainer_detail_screen.dart';
import '../../../../features/trainer_marketplace/presentation/pages/trainer_list_screen.dart';

class FeaturedTrainersCarousel extends StatefulWidget {
  final bool isDarkMode;

  const FeaturedTrainersCarousel({
    super.key,
    required this.isDarkMode,
  });

  @override
  State<FeaturedTrainersCarousel> createState() =>
      _FeaturedTrainersCarouselState();
}

class _FeaturedTrainersCarouselState extends State<FeaturedTrainersCarousel> {
  final TrainerRepository _repository = TrainerRepository();
  List<Trainer> _featuredTrainers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeaturedTrainers();
  }

  Future<void> _loadFeaturedTrainers() async {
    try {
      final trainers = await _repository.getFeaturedTrainers(limit: 10);
      if (mounted) {
        setState(() {
          _featuredTrainers = trainers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_featuredTrainers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Онцлох дасгалжуулагч нар',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? Colors.white : Colors.grey[800],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TrainerListScreen(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'Бүгдийг харах',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFF72928),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Color(0xFFF72928),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _featuredTrainers.length,
            itemBuilder: (context, index) {
              final trainer = _featuredTrainers[index];
              return FeaturedTrainerCard(
                trainer: trainer,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrainerDetailScreen(trainerId: trainer.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: 200,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
