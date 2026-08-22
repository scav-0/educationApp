import 'dart:math';

import 'package:education_app/components/app_bar.dart';
import 'package:education_app/components/my_bottom_nav.dart';
import 'package:education_app/models/user.dart';
import 'package:education_app/pages/students/games/painter/honeyComb.dart';
import 'package:education_app/utils/game_audio.dart';
import 'package:education_app/utils/skill_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HexGamePage extends StatefulWidget {
  const HexGamePage({super.key});

  @override
  State<StatefulWidget> createState() => HexGamePageState();
}

class HexGamePageState extends State<HexGamePage> {
  final SkillController skillController = Get.find<SkillController>();
  int attemptCount = 0;
  late DateTime questionStartTime;
  late bool firstAttempt;
  bool isLoading = true;

  late List<List<bool>> solution; // the correct answer
  late List<List<bool>> playerGrid; // all false initially
  late List<List<int>> numbers; // the hint numbers shown to player

  @override
  void initState() {
    super.initState();
    loadAndGenerate();
  }

  Future<void> loadAndGenerate() async {
    await skillController.fetchSkills();
    generateQuestion();
    setState(() {
      isLoading = false;
      attemptCount = 0;
      questionStartTime = DateTime.now();
      firstAttempt = true;
    });
  }

  void generateQuestion() {
    double p = skillController.honeycombPknow.value;
    int columns;
    int rows = 3;
    if (p > 0.8) {
      columns = 5;
      rows = 5;
    } else if (p > 0.6) {
      columns = 4;
      rows = 4;
    } else if (p > 0.4) {
      columns = 3;
    } else {
      columns = 2;
    }

    final random = Random();

    solution = List.generate(
      rows,
      (_) => List.generate(columns, (_) => random.nextBool()),
    );

    numbers = toNumbered(solution);

    // player starts with all false
    playerGrid = List.generate(
      solution.length,
      (_) => List.generate(solution[0].length, (_) => false),
    );
  }

  void onTap(int col, int row) {
    setState(() {
      playerGrid[row][col] = !playerGrid[row][col]; // toggle
    });
  }

  void onSubmit() {
    attemptCount++;
    bool correct = true;

    for (int row = 0; row < solution.length; row++) {
      for (int col = 0; col < solution[0].length; col++) {
        if (playerGrid[row][col] != solution[row][col]) {
          correct = false;
          break;
        }
      }
    }

    final timeTaken = DateTime.now().difference(questionStartTime).inSeconds;
    if (correct) {
      GameAudio.correct();
    } else {
      GameAudio.incorrect();
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(correct ? 'Correct!' : 'Not quite there...'),
        actions: [
          if (!correct)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // don't update BKT, just let them try again
              },
              child: const Text('Try Again'),
            ),
          TextButton(
            onPressed: () async {
              if (firstAttempt) {
                await skillController.updateSkill('honeycomb', correct);
                await skillController.saveStats(
                  'honeycomb',
                  correct,
                  attemptCount,
                  timeTaken,
                  skillController.honeycombPknow.value,
                );
                firstAttempt = false;
              }
              Navigator.pop(context);
              loadAndGenerate();
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  //Turns array of booleans into figures for the game
  List<List<int>> toNumbered(List<List<bool>> honeyed) {
    int verticalLen = honeyed.length;
    int horizontalLen = honeyed[0].length;

    List<List<int>> numbered = List.generate(
      verticalLen,
      (_) => List.generate(horizontalLen, (_) => 0),
    );

    for (int vert = 0; vert < verticalLen; vert++) {
      for (int horz = 0; horz < horizontalLen; horz++) {
        int value = 0;

        if (vert != 0) {
          if (honeyed[vert - 1][horz]) value++;
          if (horz != horizontalLen - 1 && honeyed[vert - 1][horz + 1]) value++;
        }

        if (vert != verticalLen - 1) {
          if (honeyed[vert + 1][horz]) value++;
          if (horz != 0 && honeyed[vert + 1][horz - 1]) value++;
        }

        if (horz != 0 && honeyed[vert][horz - 1]) value++;
        if (horz != horizontalLen - 1 && honeyed[vert][horz + 1]) value++;

        numbered[vert][horz] = value;
      }
    }

    return numbered;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/clouds1.jpg'),
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Scaffold(
        appBar: MyAppBar(
          title: 'Honeycomb Game',
          isStudent: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: 'How to Play',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(
                        'How to Play',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),

                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Each number tells you how many '
                              'nearby hexagons contain honey.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                            ),

                            const SizedBox(height: 15),

                            Image.asset(
                              'assets/images/HoneyCombExample.png',
                              width: 250,
                            ),

                            const SizedBox(height: 15),

                            const Text(
                              'Yellow hexagons contain honey, while grey '
                              'hexagons are empty.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                            ),

                            const SizedBox(height: 15),

                            const Text(
                              '(Hint): Start with the hexagons showing 0!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Got it'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        bottomNavigationBar: const MyBottomNavBar(),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 6,
                          offset: Offset(0, 3),
                          color: Colors.black12,
                        ),
                      ],
                    ),
                    child: const Text(
                      'Which hexagons contain honey?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                HoneycombGrid(
                  numbers: numbers,
                  playerGrid: playerGrid,
                  onTap: onTap,
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onSubmit,
                  child: const Text('Done!'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
