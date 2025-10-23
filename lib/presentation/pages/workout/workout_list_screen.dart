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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Өнөөдрийн дасгал',
          style: TextStyle(
            fontFamily: 'Rubik',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded),
            tooltip: 'Шинээр эхлүүлэх',
            splashRadius: 24,
            onPressed: () {
              HapticFeedback.lightImpact();
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.orange.shade400, Colors.orange.shade600],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Дасгалыг дахин эхлүүлэх',
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Өнөөдрийн бүх ахиц дэвшлийг арилгаж дахин эхлүүлэх үү?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.grey.shade700,
                                  side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  'Цуцлах',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.orange.shade400, Colors.orange.shade600],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _resetDailyData();
                                    _progressAnimationController.reset();
                                    _progressAnimationController.forward();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    'Дахин эхлүүлэх',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.timer_outlined),
            tooltip: 'Дасгалын цаг хэмжигч',
            splashRadius: 24,
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkoutTimerScreen(),
                ),
              );
            },
          ),
          SizedBox(width: 8),
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
            // Enhanced hero section with modern design
            Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting and date
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _getFormattedDate(),
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Progress ring
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: CircularProgressIndicator(
                                value: _getOverallProgress(),
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getProgressColor(),
                                ),
                                strokeWidth: 6,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Text(
                              '${(_getOverallProgress() * 100).toInt()}%',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _getProgressColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Stats cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernStatCard(
                          Icons.check_circle_rounded,
                          '${_getCompletedCount()}/${exercises.length}',
                          'Дүүрсэн',
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModernStatCard(
                          Icons.timer_outlined,
                          '${_getRemainingTime().inMinutes}м',
                          'Үлдсэн',
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModernStatCard(
                          Icons.local_fire_department_rounded,
                          '${_getCompletedCount() * 10}',
                          'Оноо',
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Filter chips with modern design
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildModernFilterChip('Бүгд', _selectedFilter == 'Бүгд'),
                        SizedBox(width: 8),
                        _buildModernFilterChip(
                          'Хүч чадал',
                          _selectedFilter == 'Хүч чадал',
                        ),
                        SizedBox(width: 8),
                        _buildModernFilterChip('Хөл', _selectedFilter == 'Хөл'),
                        SizedBox(width: 8),
                        _buildModernFilterChip(
                          'Гэдэс сүмян',
                          _selectedFilter == 'Гэдэс сүмян',
                        ),
                        SizedBox(width: 8),
                        _buildModernFilterChip('Кардио', _selectedFilter == 'Кардио'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Өглөөний мэнд';
    if (hour < 18) return 'Өдрийн мэнд';
    return 'Оройн мэнд';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Даваа', 'Мягмар', 'Лхагва', 'Пүрэв', 'Баасан', 'Бямба', 'Ням'];
    final months = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]}-р сарын ${now.day}';
  }

  Color _getProgressColor() {
    final progress = _getOverallProgress();
    if (progress < 0.33) return Colors.red.shade400;
    if (progress < 0.66) return Colors.orange.shade400;
    return Colors.green.shade400;
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

  Widget _buildModernStatCard(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
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

  Widget _buildModernFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.grey.shade900 : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != 'Бүгд') ...[
              Icon(
                _getCategoryIcon(label),
                size: 16,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
              SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Rubik',
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: exercise.isCompleted ? Colors.green.shade300 : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
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
                      Text(
                        exercise.name,
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          decoration: exercise.isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: Colors.grey.shade400,
                          color: exercise.isCompleted ? Colors.grey.shade500 : Colors.grey.shade900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Sets badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.fitness_center, size: 12, color: Colors.grey.shade700),
                                SizedBox(width: 4),
                                Text(
                                  exercise.sets,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 6),
                          // Time badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.timer_outlined, size: 12, color: Colors.grey.shade700),
                                SizedBox(width: 4),
                                Text(
                                  '${exercise.estimatedTime.inMinutes}м',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 6),
                          // Difficulty badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: exercise.difficultyColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  exercise.difficulty == 1
                                      ? Icons.trending_down
                                      : exercise.difficulty == 2
                                          ? Icons.trending_flat
                                          : Icons.trending_up,
                                  size: 12,
                                  color: exercise.difficultyColor,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  exercise.difficultyText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: exercise.difficultyColor,
                                    fontWeight: FontWeight.w600,
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
                if (exercise.isCompleted)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green.shade600,
                      size: 28,
                    ),
                  )
                else
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutTimerScreen(
                                exerciseName: exercise.name,
                              ),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            // Minimalist progress section
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
                            '${exercise.currentSet}/${exercise.totalSets} багц',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(exercise.progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 13,
                              color: exercise.isCompleted ? Colors.green.shade600 : Colors.grey.shade800,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Rubik',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: exercise.progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            exercise.isCompleted ? Colors.green.shade500 : Colors.grey.shade900,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!exercise.isCompleted) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  // Info button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onShowInstructions();
                        },
                        child: Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Add set button
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: exercise.progress < 1.0 ? Colors.grey.shade900 : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: exercise.progress >= 1.0
                              ? null
                              : () {
                                  HapticFeedback.lightImpact();
                                  double increment = 1.0 / exercise.totalSets;
                                  double newProgress = (exercise.progress + increment).clamp(0.0, 1.0);
                                  onProgressUpdate(newProgress);
                                },
                          child: Center(
                            child: Text(
                              '+1 багц',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: exercise.progress < 1.0 ? Colors.grey.shade900 : Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Complete button
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: exercise.progress >= 1.0 ? Colors.green.shade600 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: exercise.progress >= 1.0
                            ? [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: exercise.progress >= 1.0 ? onComplete : null,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  exercise.progress >= 1.0 ? Icons.check_circle_rounded : Icons.lock_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Дуусгах',
                                  style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    );
  }
}
