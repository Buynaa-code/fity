import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'workout_timer_screen.dart';
import '../../../core/services/user_data_service.dart';

class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressAnimationController;
  late AnimationController _completionAnimationController;
  String _selectedFilter = 'Бүгд';

  List<WorkoutExercise> exercises = [
    WorkoutExercise(
      name: 'Лангуу (Push-ups)',
      sets: '3 багц х 15 удаа',
      progress: 0.3,
      isCompleted: false,
      category: 'Хүч чадал',
      difficulty: 2,
      estimatedTime: const Duration(minutes: 8),
      currentSet: 1,
      totalSets: 3,
      instructions: [
        '1. Хэвтээ байрлал: Газарт хэвтээд, гараа мөрний өргөнтэй тэнцүү зайлан байрлуул',
        '2. Доош явах: Биеэ шулуун байлгаж, хүчээр биеэ доош аадай бууруул',
        '3. Деэш явах: Гараа шахаж биеэ эхний байрлалд буцаа',
      ],
    ),
    WorkoutExercise(
      name: 'Сквот (Squats)',
      sets: '3 багц х 20 удаа',
      progress: 0.0,
      isCompleted: false,
      category: 'Хөл',
      difficulty: 2,
      estimatedTime: const Duration(minutes: 10),
      currentSet: 0,
      totalSets: 3,
      instructions: [
        '1. Эхлэл: Хөлийг мөрний өргөнтэй тэнцүү нээж, сулгаа шулуун байлга',
        '2. Суух: Өндөгний булчинг ашиглж 90 градус хүртэл суу',
        '3. Босох: Өсөг хөлөөрөө түлж зогсоолтгүй эхний байрлалдаа бос',
      ],
    ),
    WorkoutExercise(
      name: 'Планк (Plank)',
      sets: '3 багц х 30 секунд',
      progress: 0.0,
      isCompleted: false,
      category: 'Гэдэс сүмян',
      difficulty: 1,
      estimatedTime: const Duration(minutes: 5),
      currentSet: 0,
      totalSets: 3,
      instructions: [
        'Тохойн дээр тулж хэвтээ байрлах',
        'Биеэ толгойноос өсөг хүртэл шулуун байлга',
        'Гэдэсний булчинг чангалж, байрлалыг хадгал',
      ],
    ),
    WorkoutExercise(
      name: 'Урагш алхам (Lunges)',
      sets: '3 багц х 12 удаа',
      progress: 0.0,
      isCompleted: false,
      category: 'Хөл',
      difficulty: 2,
      estimatedTime: const Duration(minutes: 7),
      currentSet: 0,
      totalSets: 3,
      instructions: [
        '1. Алхам: Нэг хөлөөр хүндрэл алхам урагш дэвшээ',
        '2. Ондоо: Урд хөлийн өндөгийг 90 градус хүртэл бүк',
        '3. Буцах: Хөлийг солж явцыг авдуртан давта',
      ],
    ),
    WorkoutExercise(
      name: 'Бурпи (Burpees)',
      sets: '3 багц х 10 удаа',
      progress: 0.0,
      isCompleted: false,
      category: 'Кардио',
      difficulty: 3,
      estimatedTime: const Duration(minutes: 12),
      currentSet: 0,
      totalSets: 3,
      instructions: [
        '1. Сквот: Зогсоод сквот байрлал хийж суу',
        '2. Лангуу: Гараа газарт тулж, хөлийг хойн талаа татан лангуу явц',
        '3. Үсрэх: Лангуу хийгээд хөлийг сквотт ороолго сүүлдээ үсэр',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Өнөөдрийн дасгал'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Шинээр эхлүүлэх',
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Дасгалыг дахин эхлүүлэх'),
                      content: const Text(
                        'Өнөөдрийн бүх ахиц дэвшлийг арилгаж дахин эхлүүлэх үү?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Цуцлах'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _resetDailyData();
                            _progressAnimationController.reset();
                            _progressAnimationController.forward();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Шинээр эхлүүлэх'),
                        ),
                      ],
                    ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.timer),
            tooltip: 'Дасгалын цаг хэмжигч',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkoutTimerScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          setState(() {
            // Refresh data if needed
          });
        },
        child: Column(
          children: [
            // Enhanced header with statistics
            Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Main progress card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Өнөөдрийн ахиц дэвшил',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${(_getOverallProgress() * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AnimatedBuilder(
                            animation: _progressAnimationController,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                value:
                                    _getOverallProgress() *
                                    _progressAnimationController.value,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.3,
                                ),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                minHeight: 8,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                Icons.check_circle_rounded,
                                '${_getCompletedCount()}/${exercises.length}',
                                'Дүүрсэн дасгал',
                                Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                Icons.timer_outlined,
                                '${_getRemainingTime().inMinutes} минут',
                                'Үлдэгдсэн хугацаа',
                                Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Filter chips
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip('Бүгд', _selectedFilter == 'Бүгд'),
                        _buildFilterChip(
                          'Хүч чадал',
                          _selectedFilter == 'Хүч чадал',
                        ),
                        _buildFilterChip('Хөл', _selectedFilter == 'Хөл'),
                        _buildFilterChip(
                          'Гэдэс сүмян',
                          _selectedFilter == 'Гэдэс сүмян',
                        ),
                        _buildFilterChip('Кардио', _selectedFilter == 'Кардио'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredExercises.length,
                itemBuilder: (context, index) {
                  final exercise = _filteredExercises[index];
                  final originalIndex = exercises.indexOf(exercise);

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    curve: Curves.easeOutBack,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0.3, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _progressAnimationController,
                          curve: Interval(
                            index * 0.1,
                            1.0,
                            curve: Curves.easeOutQuart,
                          ),
                        ),
                      ),
                      child: FadeTransition(
                        opacity: Tween(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _progressAnimationController,
                            curve: Interval(
                              index * 0.1,
                              1.0,
                              curve: Curves.easeOut,
                            ),
                          ),
                        ),
                        child: WorkoutCard(
                          exercise: exercise,
                          onProgressUpdate: (progress) {
                            HapticFeedback.lightImpact();
                            setState(() {
                              int newCurrentSet =
                                  (progress * exercise.totalSets).round();
                              exercises[originalIndex] = exercise.copyWith(
                                progress: progress,
                                currentSet: newCurrentSet,
                              );
                            });
                            _saveWorkoutData();
                          },
                          onComplete: () async {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              exercises[originalIndex] = exercise.copyWith(
                                isCompleted: true,
                                progress: 1.0,
                                completedAt: DateTime.now(),
                                currentSet: exercise.totalSets,
                              );
                            });

                            _saveWorkoutData();
                            
                            // Update unified data service
                            await UserDataService.instance.updateWorkoutCompletion(exercise.name);

                            // Trigger completion animation
                            _completionAnimationController.forward().then((_) {
                              _completionAnimationController.reset();
                            });

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.celebration,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${exercise.name} амжилттай дүүрслээ! +10 оноо',
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                duration: const Duration(seconds: 3),
                                action: SnackBarAction(
                                  label: 'Дараах дасгал',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    int nextIndex = exercises.indexWhere(
                                      (e) => !e.isCompleted,
                                    );
                                    if (nextIndex != -1) {
                                      _showExerciseInstructions(
                                        exercises[nextIndex],
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                          onShowInstructions:
                              () => _showExerciseInstructions(exercise),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _completionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _loadWorkoutData();
    // Start progress animation
    _progressAnimationController.forward();
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _completionAnimationController.dispose();
    super.dispose();
  }

  List<WorkoutExercise> get _filteredExercises {
    if (_selectedFilter == 'Бүгд') return exercises;
    return exercises.where((e) => e.category == _selectedFilter).toList();
  }

  double _getOverallProgress() {
    if (exercises.isEmpty) return 0.0;
    double totalProgress = exercises
        .map((e) => e.progress)
        .reduce((a, b) => a + b);
    return totalProgress / exercises.length;
  }

  int _getCompletedCount() {
    return exercises.where((e) => e.isCompleted).length;
  }

  Duration _getRemainingTime() {
    return exercises
        .where((e) => !e.isCompleted)
        .fold(Duration.zero, (prev, exercise) => prev + exercise.estimatedTime);
  }

  Future<void> _loadWorkoutData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? workoutDataJson = prefs.getString('workout_data');
      final String? lastSaveDate = prefs.getString('last_save_date');

      // Reset data if it's a new day
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
              completedAt:
                  data['completedAt'] != null
                      ? DateTime.parse(data['completedAt'])
                      : null,
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
      final workoutData =
          exercises
              .map(
                (exercise) => {
                  'progress': exercise.progress,
                  'isCompleted': exercise.isCompleted,
                  'currentSet': exercise.currentSet,
                  'completedAt': exercise.completedAt?.toIso8601String(),
                },
              )
              .toList();

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
            completedAt: null,
          );
        }
      });
    } catch (e) {
      debugPrint('Error resetting daily data: $e');
    }
  }

  void _showExerciseInstructions(WorkoutExercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                exercise.name,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: exercise.difficultyColor.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: exercise.difficultyColor,
                                ),
                              ),
                              child: Text(
                                exercise.difficultyText,
                                style: TextStyle(
                                  color: exercise.difficultyColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoCard(
                                    Icons.fitness_center,
                                    'Багц',
                                    exercise.sets,
                                    Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoCard(
                                    Icons.timer,
                                    'Цаг',
                                    '${exercise.estimatedTime.inMinutes} минут',
                                    Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Дасгалын заавар',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...exercise.instructions.asMap().entries.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${entry.key + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => WorkoutTimerScreen(
                                          exerciseName: exercise.name,
                                        ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Дасгал эхлэх'),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
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
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label, style: TextStyle(color: textColor, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Хүч чадал':
        return Icons.fitness_center_rounded;
      case 'Хөл':
        return Icons.directions_run_rounded;
      case 'Гэдэс сүмян':
        return Icons.self_improvement_rounded;
      case 'Кардио':
        return Icons.favorite_rounded;
      default:
        return Icons.sports_gymnastics_rounded;
    }
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
            borderRadius: BorderRadius.circular(20),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (label != 'Бүгд') ...[
                  Icon(
                    _getCategoryIcon(label),
                    size: 16,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = label;
              });
              HapticFeedback.selectionClick();
            },
            backgroundColor: Colors.grey.shade100,
            selectedColor: Colors.transparent,
            checkmarkColor: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? Colors.transparent : Colors.grey.shade300,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ),
    );
  }
}

class WorkoutExercise {
  final String name;
  final String sets;
  final double progress;
  final bool isCompleted;
  final String category;
  final int difficulty;
  final Duration estimatedTime;
  final String? imageUrl;
  final List<String> instructions;
  final DateTime? completedAt;
  final int currentSet;
  final int totalSets;

  WorkoutExercise({
    required this.name,
    required this.sets,
    required this.progress,
    required this.isCompleted,
    this.category = 'General',
    this.difficulty = 1,
    this.estimatedTime = const Duration(minutes: 5),
    this.imageUrl,
    this.instructions = const [],
    this.completedAt,
    this.currentSet = 0,
    this.totalSets = 3,
  });

  WorkoutExercise copyWith({
    String? name,
    String? sets,
    double? progress,
    bool? isCompleted,
    String? category,
    int? difficulty,
    Duration? estimatedTime,
    String? imageUrl,
    List<String>? instructions,
    DateTime? completedAt,
    int? currentSet,
    int? totalSets,
  }) {
    return WorkoutExercise(
      name: name ?? this.name,
      sets: sets ?? this.sets,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      imageUrl: imageUrl ?? this.imageUrl,
      instructions: instructions ?? this.instructions,
      completedAt: completedAt ?? this.completedAt,
      currentSet: currentSet ?? this.currentSet,
      totalSets: totalSets ?? this.totalSets,
    );
  }

  String get difficultyText {
    switch (difficulty) {
      case 1:
        return 'Амархан';
      case 2:
        return 'Дундаж';
      case 3:
        return 'Хүнд';
      default:
        return 'Дундаж';
    }
  }

  Color get difficultyColor {
    switch (difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}

class WorkoutCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final Function(double) onProgressUpdate;
  final VoidCallback onComplete;
  final VoidCallback onShowInstructions;

  const WorkoutCard({
    super.key,
    required this.exercise,
    required this.onProgressUpdate,
    required this.onComplete,
    required this.onShowInstructions,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Хүч чадал':
        return Icons.fitness_center_rounded;
      case 'Хөл':
        return Icons.directions_run_rounded;
      case 'Гэдэс сүмян':
        return Icons.self_improvement_rounded;
      case 'Кардио':
        return Icons.favorite_rounded;
      default:
        return Icons.sports_gymnastics_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: exercise.isCompleted ? 2 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side:
            exercise.isCompleted
                ? const BorderSide(color: Colors.green, width: 1)
                : BorderSide.none,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient:
              exercise.isCompleted
                  ? LinearGradient(
                    colors: [
                      Colors.green.withValues(alpha: 0.15),
                      Colors.green.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : LinearGradient(
                    colors: [Colors.white, Colors.grey.withValues(alpha: 0.02)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          boxShadow: [
            BoxShadow(
              color:
                  exercise.isCompleted
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  decoration:
                                      exercise.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                  color:
                                      exercise.isCompleted
                                          ? Colors.grey[600]
                                          : null,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    exercise.difficultyColor.withValues(
                                      alpha: 0.2,
                                    ),
                                    exercise.difficultyColor.withValues(
                                      alpha: 0.1,
                                    ),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: exercise.difficultyColor.withValues(
                                    alpha: 0.4,
                                  ),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: exercise.difficultyColor.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    exercise.difficulty == 1
                                        ? Icons.sentiment_very_satisfied
                                        : exercise.difficulty == 2
                                        ? Icons.sentiment_neutral
                                        : Icons.sentiment_very_dissatisfied,
                                    size: 12,
                                    color: exercise.difficultyColor,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    exercise.difficultyText,
                                    style: TextStyle(
                                      color: exercise.difficultyColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.fitness_center,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  exercise.sets,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${exercise.estimatedTime.inMinutes} минут',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.withValues(alpha: 0.15),
                                    Colors.blue.withValues(alpha: 0.08),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getCategoryIcon(exercise.category),
                                    size: 12,
                                    color: Colors.blue.shade600,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    exercise.category,
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      if (exercise.isCompleted)
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade400,
                                Colors.green.shade600,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        )
                      else
                        Row(
                          children: [
                            IconButton(
                              onPressed: onShowInstructions,
                              icon: const Icon(Icons.info_outline),
                              iconSize: 24,
                              color: Colors.blue,
                              tooltip: 'Дасгалын заавар',
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.blue.shade600,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => WorkoutTimerScreen(
                                              exerciseName: exercise.name,
                                            ),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress section
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: exercise.progress,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                exercise.isCompleted
                                    ? Colors.green.shade500
                                    : Colors.blue.shade500,
                              ),
                              minHeight: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:
                                exercise.isCompleted
                                    ? [
                                      Colors.green.withValues(alpha: 0.2),
                                      Colors.green.withValues(alpha: 0.1),
                                    ]
                                    : [
                                      Colors.blue.withValues(alpha: 0.2),
                                      Colors.blue.withValues(alpha: 0.1),
                                    ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (exercise.isCompleted
                                    ? Colors.green
                                    : Colors.blue)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              exercise.isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.donut_small_rounded,
                              size: 14,
                              color:
                                  exercise.isCompleted
                                      ? Colors.green
                                      : Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(exercise.progress * 100).toInt()}%',
                              style: TextStyle(
                                color:
                                    exercise.isCompleted
                                        ? Colors.green.shade700
                                        : Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!exercise.isCompleted) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${exercise.currentSet}/${exercise.totalSets} багц',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (exercise.completedAt != null)
                          Flexible(
                            child: Text(
                              '✓ Дүүрсэн: ${exercise.completedAt!.hour}:${exercise.completedAt!.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: Colors.green[600],
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
              if (!exercise.isCompleted) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow:
                              exercise.progress < 1.0
                                  ? [
                                    BoxShadow(
                                      color: Colors.blue.withValues(alpha: 0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: OutlinedButton.icon(
                          onPressed:
                              exercise.progress >= 1.0
                                  ? null
                                  : () {
                                    double increment = 1.0 / exercise.totalSets;
                                    double newProgress = (exercise.progress +
                                            increment)
                                        .clamp(0.0, 1.0);
                                    onProgressUpdate(newProgress);
                                  },
                          icon: const Icon(Icons.add_circle_rounded, size: 18),
                          label: const Text('+1 багц'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                exercise.progress < 1.0
                                    ? Colors.blue.shade600
                                    : Colors.grey.shade400,
                            side: BorderSide(
                              color:
                                  exercise.progress < 1.0
                                      ? Colors.blue.shade400
                                      : Colors.grey.shade300,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient:
                              exercise.progress >= 1.0
                                  ? LinearGradient(
                                    colors: [
                                      Colors.green.shade400,
                                      Colors.green.shade600,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                  : null,
                          boxShadow:
                              exercise.progress >= 1.0
                                  ? [
                                    BoxShadow(
                                      color: Colors.green.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: ElevatedButton.icon(
                          onPressed:
                              exercise.progress >= 1.0 ? onComplete : null,
                          icon: Icon(
                            exercise.progress >= 1.0
                                ? Icons.check_circle_rounded
                                : Icons.lock_rounded,
                            size: 18,
                          ),
                          label: const Text('Бүрэн дуусгах'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                exercise.progress >= 1.0
                                    ? Colors.transparent
                                    : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            elevation: 0,
                          ),
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
}
