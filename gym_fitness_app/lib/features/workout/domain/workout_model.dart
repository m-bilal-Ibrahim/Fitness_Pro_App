// lib/features/workouts/domain/workout_model.dart

class Exercise {
  final String name;
  final String instruction;
  final String animationUrl;
  final int durationSeconds;

  Exercise({
    required this.name,
    required this.instruction,
    required this.animationUrl,
    required this.durationSeconds,
  });
}

class WorkoutCategory {
  final String title;
  final String imagePath;
  final List<Exercise> exercises;

  WorkoutCategory({required this.title, required this.imagePath, required this.exercises});
}

int calculateRest(int difficultyIndex) {
  List<int> rests = [30, 25, 15, 10];
  return rests[difficultyIndex];
}