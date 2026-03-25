import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/statistics/presentation/bloc/statistics_bloc.dart';
import '../../../features/statistics/presentation/bloc/statistics_event.dart';
import 'workout_timer_screen.dart';

class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressAnimationController;
  String _selectedCategory = 'Бүгд';
  int _selectedDifficulty = 0; // 0 = all, 1 = easy, 2 = medium, 3 = hard

  final List<String> _categories = [
    'Бүгд',
    'Хүч чадал',
    'Хөл',
    'Гэдэс',
    'Кардио',
    'Сунгалт',
  ];

  List<WorkoutExercise> exercises = [
    WorkoutExercise(
      name: 'Лангуу',
      englishName: 'Push-ups',
      description: 'Цээжний булчин, гурвалжин булчинг хөгжүүлнэ',
      sets: 3,
      reps: 15,
      restSeconds: 60,
      progress: 0.0,
      isCompleted: false,
      category: 'Хүч чадал',
      difficulty: 2,
      estimatedMinutes: 8,
      caloriesPerSet: 8,
      muscleGroups: ['Цээж', 'Мөр', 'Гурвалжин'],
      instructions: [
        'Хэвтээ байрлалд гараа мөрний өргөнтэй тэнцүү зайд тавь',
        'Биеэ шулуун байлгаж, аажмаар доош бууруул',
        'Гараа шахаж биеэ дээш түлх',
      ],
    ),
    WorkoutExercise(
      name: 'Сквот',
      englishName: 'Squats',
      description: 'Хөл, өгзөгний булчинг хөгжүүлнэ',
      sets: 3,
      reps: 20,
      restSeconds: 90,
      progress: 0.0,
      isCompleted: false,
      category: 'Хөл',
      difficulty: 2,
      estimatedMinutes: 10,
      caloriesPerSet: 12,
      muscleGroups: ['Өвдөг', 'Өгзөг', 'Гуя'],
      instructions: [
        'Хөлийг мөрний өргөнтэй тэнцүү нээж зогс',
        '90 градус хүртэл аажмаар суу',
        'Өсгий хөлөөр түлж эхний байрлалд бос',
      ],
    ),
    WorkoutExercise(
      name: 'Планк',
      englishName: 'Plank',
      description: 'Гэдэсний булчин, нурууг бэхжүүлнэ',
      sets: 3,
      reps: 30,
      restSeconds: 45,
      progress: 0.0,
      isCompleted: false,
      category: 'Гэдэс',
      difficulty: 1,
      estimatedMinutes: 5,
      caloriesPerSet: 5,
      muscleGroups: ['Гэдэс', 'Нуруу', 'Мөр'],
      isTimeBased: true,
      instructions: [
        'Тохойн дээр тулж хэвтээ байрлал',
        'Биеэ шулуун байлга',
        'Гэдэсний булчинг чангалж байрлалыг хадгал',
      ],
    ),
    WorkoutExercise(
      name: 'Урагш алхам',
      englishName: 'Lunges',
      description: 'Хөлний булчинг тэнцвэртэй хөгжүүлнэ',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      progress: 0.0,
      isCompleted: false,
      category: 'Хөл',
      difficulty: 2,
      estimatedMinutes: 7,
      caloriesPerSet: 10,
      muscleGroups: ['Өвдөг', 'Өгзөг', 'Тэнцвэр'],
      instructions: [
        'Шулуун зогсоод нэг хөлөөр урагш алхам хий',
        'Урд хөлийн өвдгийг 90 градус хүртэл бүк',
        'Хөлийг солих замаар давт',
      ],
    ),
    WorkoutExercise(
      name: 'Бурпи',
      englishName: 'Burpees',
      description: 'Бүх биеийн өндөр эрчимтэй дасгал',
      sets: 3,
      reps: 10,
      restSeconds: 90,
      progress: 0.0,
      isCompleted: false,
      category: 'Кардио',
      difficulty: 3,
      estimatedMinutes: 12,
      caloriesPerSet: 15,
      muscleGroups: ['Бүх бие', 'Зүрх судас', 'Тэсвэр'],
      instructions: [
        'Зогсоод сквот байрлалд суу',
        'Гараа газарт тулж хөлөө хойш татан лангуу хий',
        'Хөлийг буцааж үсрэлт хий',
      ],
    ),
    WorkoutExercise(
      name: 'Маунтэйн Клаймбер',
      englishName: 'Mountain Climbers',
      description: 'Кардио болон гэдэсний дасгал',
      sets: 3,
      reps: 20,
      restSeconds: 45,
      progress: 0.0,
      isCompleted: false,
      category: 'Кардио',
      difficulty: 2,
      estimatedMinutes: 6,
      caloriesPerSet: 12,
      muscleGroups: ['Гэдэс', 'Хөл', 'Мөр'],
      instructions: [
        'Лангуу байрлалд бэлтгэ',
        'Өвдгийг ээлжлэн цээж рүү тат',
        'Хурдан хөдөлгөөнөөр давт',
      ],
    ),
    WorkoutExercise(
      name: 'Сунгалт',
      englishName: 'Stretching',
      description: 'Биеийн уян хатан чанарыг сайжруулна',
      sets: 1,
      reps: 60,
      restSeconds: 0,
      progress: 0.0,
      isCompleted: false,
      category: 'Сунгалт',
      difficulty: 1,
      estimatedMinutes: 10,
      caloriesPerSet: 3,
      muscleGroups: ['Бүх бие'],
      isTimeBased: true,
      instructions: [
        'Хамстринг сунгалт - 30 секунд',
        'Мөр сунгалт - 20 секунд тал бүр',
        'Нуруу эргүүлэлт - 10 удаа',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadWorkoutData();
    _progressAnimationController.forward();
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    super.dispose();
  }

  List<WorkoutExercise> get _filteredExercises {
    var filtered = exercises;

    if (_selectedCategory != 'Бүгд') {
      filtered = filtered.where((e) => e.category == _selectedCategory).toList();
    }

    if (_selectedDifficulty > 0) {
      filtered = filtered.where((e) => e.difficulty == _selectedDifficulty).toList();
    }

    return filtered;
  }

  double get _overallProgress {
    if (exercises.isEmpty) return 0.0;
    return exercises.where((e) => e.isCompleted).length / exercises.length;
  }

  int get _completedCount => exercises.where((e) => e.isCompleted).length;

  int get _totalCalories {
    return exercises
        .where((e) => e.isCompleted)
        .fold(0, (sum, e) => sum + (e.caloriesPerSet * e.sets));
  }

  int get _remainingMinutes {
    return exercises
        .where((e) => !e.isCompleted)
        .fold(0, (sum, e) => sum + e.estimatedMinutes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),

            // Progress Card
            SliverToBoxAdapter(
              child: _buildProgressCard(),
            ),

            // Category Filter
            SliverToBoxAdapter(
              child: _buildCategoryFilter(),
            ),

            // Difficulty Filter
            SliverToBoxAdapter(
              child: _buildDifficultyFilter(),
            ),

            // Exercise List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final exercise = _filteredExercises[index];
                    return _buildExerciseCard(exercise, index);
                  },
                  childCount: _filteredExercises.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Өнөөдрийн дасгал',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showResetDialog,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6C5CE7),
              const Color(0xFF6C5CE7).withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Progress circle
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: _overallProgress,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                          strokeWidth: 8,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text(
                        '${(_overallProgress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_completedCount / ${exercises.length} дасгал',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _completedCount == exercises.length
                            ? 'Бүгд дууссан! 🎉'
                            : 'Үргэлжлүүлээрэй!',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildProgressStat(
                  Icons.local_fire_department_rounded,
                  '$_totalCalories',
                  'kcal',
                ),
                const SizedBox(width: 16),
                _buildProgressStat(
                  Icons.timer_rounded,
                  '$_remainingMinutes',
                  'мин үлдсэн',
                ),
                const SizedBox(width: 16),
                _buildProgressStat(
                  Icons.star_rounded,
                  '${_completedCount * 10}',
                  'XP',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStat(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ангилал',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: EdgeInsets.only(right: index < _categories.length - 1 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategory = category);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.grey.shade900 : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyFilter() {
    final difficulties = [
      {'label': 'Бүгд', 'value': 0},
      {'label': 'Амархан', 'value': 1, 'color': Colors.green},
      {'label': 'Дундаж', 'value': 2, 'color': Colors.orange},
      {'label': 'Хүнд', 'value': 3, 'color': Colors.red},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: difficulties.map((d) {
          final isSelected = _selectedDifficulty == d['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedDifficulty = d['value'] as int);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (d['color'] as Color?)?.withValues(alpha: 0.15) ?? Colors.grey.shade200
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? (d['color'] as Color?) ?? Colors.grey.shade400
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  d['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? (d['color'] as Color?) ?? Colors.grey.shade700
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExerciseCard(WorkoutExercise exercise, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _showExerciseDetail(exercise),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: exercise.isCompleted
                ? Colors.green.shade50
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: exercise.isCompleted
                  ? Colors.green.shade300
                  : Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Exercise icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: exercise.isCompleted
                            ? [Colors.green, Colors.green.shade400]
                            : [_getCategoryColor(exercise.category), _getCategoryColor(exercise.category).withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      exercise.isCompleted
                          ? Icons.check_rounded
                          : _getCategoryIcon(exercise.category),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Exercise info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                exercise.name,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: exercise.isCompleted
                                      ? Colors.grey.shade500
                                      : Colors.grey.shade900,
                                  decoration: exercise.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(exercise.difficulty).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getDifficultyText(exercise.difficulty),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _getDifficultyColor(exercise.difficulty),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          exercise.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        // Tags
                        Row(
                          children: [
                            _buildTag(Icons.fitness_center, exercise.isTimeBased
                                ? '${exercise.sets}x${exercise.reps}с'
                                : '${exercise.sets}x${exercise.reps}'),
                            const SizedBox(width: 8),
                            _buildTag(Icons.timer_outlined, '${exercise.estimatedMinutes}м'),
                            const SizedBox(width: 8),
                            _buildTag(Icons.local_fire_department, '${exercise.caloriesPerSet * exercise.sets}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Progress bar & actions
              if (!exercise.isCompleted) ...[
                const SizedBox(height: 14),
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
                                '${exercise.currentSet}/${exercise.sets} багц',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${(exercise.progress * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: exercise.progress,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation(
                                _getCategoryColor(exercise.category),
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Start button
                    GestureDetector(
                      onTap: () => _startExercise(exercise),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getCategoryColor(exercise.category),
                              _getCategoryColor(exercise.category).withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _getCategoryColor(exercise.category).withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _startExercise(WorkoutExercise exercise) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutTimerScreen(
          exerciseName: exercise.name,
          targetSets: exercise.sets,
          targetReps: exercise.reps,
          restSeconds: exercise.restSeconds,
        ),
      ),
    ).then((_) {
      // Exercise completed - update progress
      final index = exercises.indexOf(exercise);
      if (index != -1) {
        setState(() {
          exercises[index] = exercise.copyWith(
            isCompleted: true,
            progress: 1.0,
            currentSet: exercise.sets,
          );
        });
        _saveWorkoutData();

        // Record workout in StatisticsBloc
        final calories = exercise.caloriesPerSet * exercise.sets;
        final duration = Duration(minutes: exercise.estimatedMinutes);
        if (mounted) {
          context.read<StatisticsBloc>().add(RecordWorkout(
            exerciseName: exercise.name,
            calories: calories.toDouble(),
            duration: duration,
          ));

          // Show completion feedback
          _showCompletionFeedback(exercise);
        }
      }
    });
  }

  void _showCompletionFeedback(WorkoutExercise exercise) {
    final calories = exercise.caloriesPerSet * exercise.sets;
    final xpEarned = 10;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${exercise.name} дууслаа!',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  Text(
                    '$calories kcal  •  +$xpEarned XP',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showExerciseDetail(WorkoutExercise exercise) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ExerciseDetailSheet(
        exercise: exercise,
        onStart: () {
          Navigator.pop(context);
          _startExercise(exercise);
        },
      ),
    );
  }

  void _showResetDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Дахин эхлүүлэх'),
        content: const Text('Өнөөдрийн бүх ахиц дэвшлийг арилгах уу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Цуцлах'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetDailyData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Арилгах', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Өглөөний мэнд ☀️';
    if (hour < 18) return 'Өдрийн мэнд 💪';
    return 'Оройн мэнд 🌙';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Хүч чадал':
        return const Color(0xFFF72928);
      case 'Хөл':
        return const Color(0xFF9B59B6);
      case 'Гэдэс':
        return const Color(0xFF3498DB);
      case 'Кардио':
        return const Color(0xFFE74C3C);
      case 'Сунгалт':
        return const Color(0xFF1ABC9C);
      default:
        return const Color(0xFF6C5CE7);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Хүч чадал':
        return Icons.fitness_center_rounded;
      case 'Хөл':
        return Icons.directions_run_rounded;
      case 'Гэдэс':
        return Icons.self_improvement_rounded;
      case 'Кардио':
        return Icons.favorite_rounded;
      case 'Сунгалт':
        return Icons.accessibility_new_rounded;
      default:
        return Icons.sports_gymnastics_rounded;
    }
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Амархан';
      case 2:
        return 'Дундаж';
      case 3:
        return 'Хүнд';
      default:
        return '';
    }
  }

  Future<void> _loadWorkoutData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? workoutDataJson = prefs.getString('workout_data');
      final String? lastSaveDate = prefs.getString('last_save_date');

      final today = DateTime.now().toIso8601String().split('T')[0];
      if (lastSaveDate != today) {
        await _resetDailyData();
        return;
      }

      if (workoutDataJson != null) {
        final List<dynamic> workoutList = json.decode(workoutDataJson);
        setState(() {
          for (int i = 0; i < workoutList.length && i < exercises.length; i++) {
            final data = workoutList[i];
            exercises[i] = exercises[i].copyWith(
              progress: (data['progress'] ?? 0.0).toDouble(),
              isCompleted: data['isCompleted'] ?? false,
              currentSet: data['currentSet'] ?? 0,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading workout data: $e');
    }
  }

  Future<void> _saveWorkoutData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutData = exercises.map((exercise) => {
        'progress': exercise.progress,
        'isCompleted': exercise.isCompleted,
        'currentSet': exercise.currentSet,
      }).toList();

      await prefs.setString('workout_data', json.encode(workoutData));
      await prefs.setString(
        'last_save_date',
        DateTime.now().toIso8601String().split('T')[0],
      );
    } catch (e) {
      debugPrint('Error saving workout data: $e');
    }
  }

  Future<void> _resetDailyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('workout_data');
      await prefs.setString(
        'last_save_date',
        DateTime.now().toIso8601String().split('T')[0],
      );

      setState(() {
        for (int i = 0; i < exercises.length; i++) {
          exercises[i] = exercises[i].copyWith(
            progress: 0.0,
            isCompleted: false,
            currentSet: 0,
          );
        }
      });
    } catch (e) {
      debugPrint('Error resetting daily data: $e');
    }
  }
}

class WorkoutExercise {
  final String name;
  final String englishName;
  final String description;
  final int sets;
  final int reps;
  final int restSeconds;
  final double progress;
  final bool isCompleted;
  final String category;
  final int difficulty;
  final int estimatedMinutes;
  final int caloriesPerSet;
  final List<String> muscleGroups;
  final List<String> instructions;
  final bool isTimeBased;
  final int currentSet;

  const WorkoutExercise({
    required this.name,
    required this.englishName,
    required this.description,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.progress,
    required this.isCompleted,
    required this.category,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.caloriesPerSet,
    required this.muscleGroups,
    required this.instructions,
    this.isTimeBased = false,
    this.currentSet = 0,
  });

  WorkoutExercise copyWith({
    String? name,
    String? englishName,
    String? description,
    int? sets,
    int? reps,
    int? restSeconds,
    double? progress,
    bool? isCompleted,
    String? category,
    int? difficulty,
    int? estimatedMinutes,
    int? caloriesPerSet,
    List<String>? muscleGroups,
    List<String>? instructions,
    bool? isTimeBased,
    int? currentSet,
  }) {
    return WorkoutExercise(
      name: name ?? this.name,
      englishName: englishName ?? this.englishName,
      description: description ?? this.description,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      caloriesPerSet: caloriesPerSet ?? this.caloriesPerSet,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      instructions: instructions ?? this.instructions,
      isTimeBased: isTimeBased ?? this.isTimeBased,
      currentSet: currentSet ?? this.currentSet,
    );
  }
}

class _ExerciseDetailSheet extends StatelessWidget {
  final WorkoutExercise exercise;
  final VoidCallback onStart;

  const _ExerciseDetailSheet({
    required this.exercise,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF72928), Color(0xFFFF9149)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              exercise.englishName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    children: [
                      _buildStatCard(
                        Icons.fitness_center,
                        exercise.isTimeBased
                            ? '${exercise.sets}x${exercise.reps}с'
                            : '${exercise.sets}x${exercise.reps}',
                        'Багц x Давталт',
                        Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        Icons.timer,
                        '${exercise.estimatedMinutes}м',
                        'Хугацаа',
                        Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        Icons.local_fire_department,
                        '${exercise.caloriesPerSet * exercise.sets}',
                        'Калори',
                        Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Muscle groups
                  const Text(
                    'Булчингууд',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: exercise.muscleGroups.map((muscle) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        muscle,
                        style: const TextStyle(
                          color: Color(0xFF6C5CE7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Instructions
                  const Text(
                    'Заавар',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...exercise.instructions.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF72928),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),

                  // Start button
                  GestureDetector(
                    onTap: onStart,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF72928), Color(0xFFFF9149)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF72928).withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                          SizedBox(width: 10),
                          Text(
                            'Дасгал эхлүүлэх',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
