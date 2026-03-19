import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/trainer_repository.dart';
import '../bloc/trainer_list/trainer_list_bloc.dart';
import '../widgets/trainer_card.dart';
import '../widgets/specialty_chip.dart';
import 'trainer_detail_screen.dart';
import 'booking_history_screen.dart';

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

class _TrainerListView extends StatelessWidget {
  const _TrainerListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Дасгалжуулагч',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookingHistoryScreen(),
                ),
              );
            },
            tooltip: 'Захиалгын түүх',
          ),
        ],
      ),
      body: BlocBuilder<TrainerListBloc, TrainerListState>(
        builder: (context, state) {
          if (state is TrainerListLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFE7409)),
            );
          }

          if (state is TrainerListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Алдаа гарлаа',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TrainerListBloc>().add(LoadTrainers());
                    },
                    child: const Text('Дахин оролдох'),
                  ),
                ],
              ),
            );
          }

          if (state is TrainerListLoaded) {
            return Column(
              children: [
                // Search Bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: TextField(
                    onChanged: (value) {
                      context.read<TrainerListBloc>().add(SearchTrainers(value));
                    },
                    decoration: InputDecoration(
                      hintText: 'Дасгалжуулагч хайх...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                // Specialty Filter
                Container(
                  color: Colors.white,
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: SpecialtyChip(
                          label: 'Бүгд',
                          isSelected: state.selectedSpecialty == null,
                          onTap: () {
                            context
                                .read<TrainerListBloc>()
                                .add(const FilterTrainersBySpecialty(null));
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
                              context
                                  .read<TrainerListBloc>()
                                  .add(FilterTrainersBySpecialty(specialty));
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Trainer List
                Expanded(
                  child: state.filteredTrainers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_search_rounded,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Дасгалжуулагч олдсонгүй',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.filteredTrainers.length,
                          itemBuilder: (context, index) {
                            final trainer = state.filteredTrainers[index];
                            return TrainerCard(
                              trainer: trainer,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TrainerDetailScreen(
                                      trainerId: trainer.id,
                                    ),
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

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
