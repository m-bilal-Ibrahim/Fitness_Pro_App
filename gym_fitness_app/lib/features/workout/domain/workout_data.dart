// lib/features/workouts/domain/workout_data.dart
import 'workout_model.dart';

final Map<String, List<Exercise>> baseExercises = {
  'ABS': [
    Exercise(name: "Crunches", instruction: "Lie on your back, lift upper body using core muscles.", animationUrl: "", durationSeconds: 45),
    Exercise(name: "Plank", instruction: "Keep body straight, support weight on forearms and toes.", animationUrl: "", durationSeconds: 60),
    Exercise(name: "Leg Raises", instruction: "Lie flat, lift legs to 90 degrees without bending knees.", animationUrl: "", durationSeconds: 45),
    Exercise(name: "Russian Twists", instruction: "Sit with knees bent, rotate torso from side to side.", animationUrl: "", durationSeconds: 40),
    Exercise(name: "Bicycle Crunches", instruction: "Alternate elbow to opposite knee in a cycling motion.", animationUrl: "", durationSeconds: 45),
    Exercise(name: "Mountain Climbers", instruction: "In plank position, alternate bringing knees to chest.", animationUrl: "", durationSeconds: 40),
  ],
  'CHEST': [
    Exercise(name: "Standard Push-ups", instruction: "Lower chest to floor, keep back straight.", animationUrl: "", durationSeconds: 45),
    Exercise(name: "Wide Push-ups", instruction: "Hands wider than shoulders to target outer chest.", animationUrl: "", durationSeconds: 45),
    Exercise(name: "Diamond Push-ups", instruction: "Form a diamond with hands to target triceps and inner chest.", animationUrl: "", durationSeconds: 30),
    Exercise(name: "Incline Push-ups", instruction: "Place hands on an elevated surface.", animationUrl: "", durationSeconds: 45),
    Exercise(name: "Decline Push-ups", instruction: "Place feet on an elevated surface.", animationUrl: "", durationSeconds: 40),
    Exercise(name: "Cobra Stretch", instruction: "Lie face down, lift chest up while keeping hips on floor.", animationUrl: "", durationSeconds: 30),
  ],
  'BACK': [
    Exercise(name: "Superman", instruction: "Lie face down, lift arms and legs simultaneously.", animationUrl: "", durationSeconds: 45),
    Exercise(name: "Cat-Cow", instruction: "Alternate arching and rounding back on all fours.", animationUrl: "", durationSeconds: 60),
    Exercise(name: "Bird-Dog", instruction: "Extend opposite arm and leg while on all fours.", animationUrl: "", durationSeconds: 45),
    Exercise(name: "Prone Y-Raise", instruction: "Lie face down, lift arms in a 'Y' shape.", animationUrl: "", durationSeconds: 40),
    Exercise(name: "Swimmers", instruction: "Alternate lifting opposite arm/leg fast while face down.", animationUrl: "", durationSeconds: 45),
  ],
  'LEGS': [
    Exercise(name: "Basic Squats", instruction: "Sit back into hips, keep chest up and heels down.", animationUrl: "", durationSeconds: 50),
    Exercise(name: "Forward Lunges", instruction: "Step forward, lowering hips until both knees are at 90 degrees.", animationUrl: "", durationSeconds: 45),
    Exercise(name: "Glute Bridges", instruction: "Lie on back, lift hips toward the ceiling.", animationUrl: "", durationSeconds: 50),
    Exercise(name: "Sumo Squats", instruction: "Wide stance, toes pointed out, lower hips deep.", animationUrl: "", durationSeconds: 45),
    Exercise(name: "Calf Raises", instruction: "Rise onto the balls of your feet, hold, and lower.", animationUrl: "", durationSeconds: 40),
    Exercise(name: "Wall Sit", instruction: "Lean against wall in a squat position and hold.", animationUrl: "", durationSeconds: 60),
  ],
  'ARMS': [
    Exercise(name: "Tricep Dips", instruction: "Use a sturdy chair or bench, lower body by bending elbows.", animationUrl: "", durationSeconds: 45),
    Exercise(name: "Push-ups", instruction: "Classic push-up focusing on triceps and chest.", animationUrl: "", durationSeconds: 45),
    Exercise(name: "Arm Circles", instruction: "Extend arms to the side and make small circular motions.", animationUrl: "", durationSeconds: 60),
    Exercise(name: "Diamond Push-ups", instruction: "Hands close together forming a diamond shape.", animationUrl: "", durationSeconds: 30),
    Exercise(name: "Side Plank", instruction: "Balance on one forearm and side of foot to engage arms and core.", animationUrl: "", durationSeconds: 45),
    Exercise(name: "Punching", instruction: "Throw alternating punches in the air with force.", animationUrl: "", durationSeconds: 60),
  ],
};