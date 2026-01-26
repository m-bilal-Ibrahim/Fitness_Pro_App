import 'package:flutter/material.dart';

import 'workout_player_screen.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme Match: Dark card color to stand out against black background

    final Color baseCardColor = Colors.grey.shade900;

    final List<Map<String, String>> categories = [
      {
        'title': 'ABS',

        'image':
            'https://www.shutterstock.com/image-photo/closeup-photo-athlete-perfect-abs-260nw-252795634.jpg',
      },

      {
        'title': 'CHEST',

        'image':
            'https://www.shutterstock.com/shutterstock/videos/6029219/thumb/1.jpg?ip=x480',
      },

      {
        'title': 'BACK',

        'image':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQu065JvfsfrxuBF8ScJa-ylko5Bsu0RH6A4A&s',
      },

      {
        'title': 'LEGS',

        'image':
            'https://thumbs.dreamstime.com/b/detail-male-bodybuilder-front-leg-muscles-black-background-quadriceps-tibialis-anterior-detail-male-bodybuilder-front-113884353.jpg',
      },

      {
        'title': 'ARMS',

        'image':
        'https://media.istockphoto.com/id/474844156/photo/close-up-of-athletic-muscular-hand.jpg?s=612x612&w=0&k=20&c=WXzcWR49eYerIQEdG2FUN9EU979KMDA2wRsDrPKBpAw=',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black, // Dark Theme Background

      appBar: AppBar(
        title: const Text(
          "WORKOUTS",

          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ), // White Text

        backgroundColor: Colors.transparent,

        elevation: 0,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),

        itemCount: categories.length,

        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),

            child: GestureDetector(
              onTap: () =>
                  _showDifficultyPicker(context, categories[index]['title']!),

              child: Container(
                height: 110,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),

                  gradient: LinearGradient(
                    begin: Alignment.centerRight,

                    end: Alignment.centerLeft,

                    colors: [
                      baseCardColor,
                      Colors.black,
                    ], // Gradient fades into background
                  ),

                  border: Border.all(
                    color: Colors.white10,
                  ), // Subtle border for definition
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24.0),

                        child: Text(
                          categories[index]['title']!,

                          style: const TextStyle(
                            color: Colors.white,

                            fontSize: 26,

                            fontWeight: FontWeight.w900,

                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),

                    // Image Section on Right using NetworkImage
                    Container(
                      width: 130,

                      height: double.infinity,

                      decoration: BoxDecoration(
                        color: Colors.grey[800],

                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),

                          bottomRight: Radius.circular(20),
                        ),

                        image: DecorationImage(
                          image: NetworkImage(categories[index]['image']!),

                          fit: BoxFit.cover,

                          onError: (e, s) => {}, // Prevents crash if URL fails
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDifficultyPicker(BuildContext context, String category) {
    final levels = [
      {'name': 'Beginner', 'time': '15 min'},

      {'name': 'Average', 'time': '30 min'},

      {'name': 'Pro', 'time': '45 min'},

      {'name': 'Extreme', 'time': '1 hour'},
    ];

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.grey[900], // Theme Match

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),

      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),

        child: SingleChildScrollView(
          // Fixes Bottom Overflow on Modal
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Text(
                "Select $category Intensity",

                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              ...List.generate(
                levels.length,
                (i) => ListTile(
                  title: Text(
                    levels[i]['name']!,

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD0FD3E),
                    ),
                  ), // Neon Green Accent

                  subtitle: Text(
                    levels[i]['time']!,
                    style: const TextStyle(color: Colors.white70),
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white,
                  ),

                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkoutPlayerScreen(
                          category: category,
                          difficultyIndex: i,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
