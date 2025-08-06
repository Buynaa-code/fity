import 'package:flutter/material.dart';
import 'workout_timer_screen.dart';

class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  final List<WorkoutExercise> exercises = [
    WorkoutExercise(
      name: 'Push-ups',
      sets: '3 sets of 15 reps',
      progress: 0.3,
      isCompleted: false,
    ),
    WorkoutExercise(
      name: 'Squats',
      sets: '3 sets of 20 reps',
      progress: 0.0,
      isCompleted: false,
    ),
    WorkoutExercise(
      name: 'Plank',
      sets: '3 sets of 30 sec',
      progress: 0.0,
      isCompleted: false,
    ),
    WorkoutExercise(
      name: 'Lunges',
      sets: '3 sets of 12 reps',
      progress: 0.0,
      isCompleted: false,
    ),
    WorkoutExercise(
      name: 'Burpees',
      sets: '3 sets of 10 reps',
      progress: 0.0,
      isCompleted: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Өнөөдрийн төлөвлөгөө'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.timer),
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
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Өнөөдрийн дүүргэлт',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _getOverallProgress(),
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${(_getOverallProgress() * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return WorkoutCard(
                  exercise: exercise,
                  onProgressUpdate: (progress) {
                    setState(() {
                      exercises[index] = exercise.copyWith(progress: progress);
                    });
                  },
                  onComplete: () {
                    setState(() {
                      exercises[index] = exercise.copyWith(
                        isCompleted: true,
                        progress: 1.0,
                      );
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${exercise.name} дуусгалаа! +10 points'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _getOverallProgress() {
    if (exercises.isEmpty) return 0.0;
    double totalProgress = exercises.map((e) => e.progress).reduce((a, b) => a + b);
    return totalProgress / exercises.length;
  }
}

class WorkoutExercise {
  final String name;
  final String sets;
  final double progress;
  final bool isCompleted;

  WorkoutExercise({
    required this.name,
    required this.sets,
    required this.progress,
    required this.isCompleted,
  });

  WorkoutExercise copyWith({
    String? name,
    String? sets,
    double? progress,
    bool? isCompleted,
  }) {
    return WorkoutExercise(
      name: name ?? this.name,
      sets: sets ?? this.sets,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class WorkoutCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final Function(double) onProgressUpdate;
  final VoidCallback onComplete;

  const WorkoutCard({
    super.key,
    required this.exercise,
    required this.onProgressUpdate,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: exercise.isCompleted 
                            ? TextDecoration.lineThrough 
                            : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.sets,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (exercise.isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 32,
                  )
                else
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkoutTimerScreen(
                            exerciseName: exercise.name,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_circle_outline),
                    iconSize: 32,
                    color: Colors.blue,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: exercise.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      exercise.isCompleted ? Colors.green : Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${(exercise.progress * 100).toInt()}%'),
              ],
            ),
            if (!exercise.isCompleted) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        double newProgress = (exercise.progress + 0.33).clamp(0.0, 1.0);
                        onProgressUpdate(newProgress);
                      },
                      child: const Text('Set дуусгах'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: exercise.progress >= 1.0 ? onComplete : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Дуусгах'),
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