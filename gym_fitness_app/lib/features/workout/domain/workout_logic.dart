// lib/features/workouts/domain/workout_logic.dart
import 'workout_model.dart';
import 'workout_data.dart';

List<Exercise> generateWorkoutPlaylist(String category, int difficultyIndex) {
  final baseList = baseExercises[category] ?? [];
  List<Exercise> playlist = [];

  // Target minutes: 0: 15, 1: 30, 2: 45, 3: 60
  int targetSeconds = (difficultyIndex + 1) * 15 * 60;
  int currentSeconds = 0;
  int restSeconds = calculateRest(difficultyIndex);

  // Keep adding exercises until we fill the time
  while (currentSeconds < targetSeconds) {
    for (var ex in baseList) {
      if (currentSeconds >= targetSeconds) break;
      playlist.add(ex);
      currentSeconds += ex.durationSeconds + restSeconds;
    }
  }
  return playlist;
}