import 'dart:math';

import 'package:education_app/components/multipleChoice.dart';
import 'package:education_app/pages/games/painter/circularBraceletPainter.dart';
import 'package:education_app/components/my_bottom_nav.dart';
import 'package:education_app/pages/games/painter/lineBraceletPainter.dart';
import 'package:education_app/utils/int_to_colour.dart';
import 'package:education_app/utils/skill_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BraceletGamePage extends StatefulWidget {
  const BraceletGamePage({super.key});

  //DIFFICULTY WILL BE THE LENGTH OF THE BRACELET/ maybe less colours too?

  @override
  State<StatefulWidget> createState() => BraceletGamePageState();
}

class BraceletGamePageState extends State<BraceletGamePage> {
  late List<int> beadColors;
  final SkillController skillController = Get.find<SkillController>();

  late List<List<int>> options;
  late int correctPosition;

  int attemptCount = 0;
  late DateTime questionStartTime;
  late bool firstAttempt;
  @override
  void initState() {
    super.initState();
    loadAndGenerate();
  }

  Widget displayOptions(int index) {
    return CustomPaint(
      painter: LineBraceletPainter(beadColors: options[index]),
    );
  }

  bool isLoading = true;

  int questionNumber = 0;

  Future<void> loadAndGenerate() async {
    await skillController.fetchSkills();
    generateQuestion();
    setState(() {
      isLoading = false; // done loading
      attemptCount = 1;
      questionStartTime = DateTime.now();
      firstAttempt = true;
    });
  }

  void generateQuestion() {
    setState(() {
      questionNumber++;
      beadColors = [];

      //Create random bead Colors array -> to be replaced
      double p = skillController.braceletPknow.value;
      beadColors = generateAnswer(p);

      List<List<int>> wrongAnswers = createWrongAnswers(beadColors, p);

      List<int> positions = [0, 1, 2, 3];
      positions.shuffle();
      correctPosition = positions[0];

      options = [[], [], [], []];
      options[positions[0]] = beadColors;
      options[positions[1]] = wrongAnswers[0];
      options[positions[2]] = wrongAnswers[1];
      options[positions[3]] = wrongAnswers[2];
    });
  }

  List<int> generateAnswer(double p) {
    List<int> result = [];
    final rng = Random();
    int beadLength = 5;

    for (int i = 6; i > 0; i--) {
      if (p > i / 10) {
        beadLength = i + 4;
        break;
      }
    }

    int numberOfColors = 7;
    for (int i = 9; i > 4; i--) {
      if (p > i / 10) {
        numberOfColors = 11 - i;
        break;
      }
    }

    for (int i = 0; i < beadLength; i++) {
      result.add(rng.nextInt(numberOfColors) + 1);
    }

    return result;
  }

  void onResult(bool correct) {
    attemptCount++;
    final timeTaken = DateTime.now().difference(questionStartTime).inSeconds;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(correct ? 'Correct!' : 'Not quite there...'),
        actions: [
          if (!correct)
            TextButton(
              onPressed: () {
                attemptCount++;
                Navigator.pop(context);
                //Retry question,
              },
              child: const Text('Try Again'),
            ),
          TextButton(
            onPressed: () async {
              final pKnow = skillController.braceletPknow.value;

              if (firstAttempt) {
                firstAttempt = false;
                await skillController.updateSkill('bracelet', correct);
              }

              await skillController.saveStats(
                'bracelet',
                correct,
                attemptCount,
                timeTaken,
                pKnow,
              );

              Navigator.pop(context);
              setState(() {
                loadAndGenerate(); // should load next question....
              });
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/clouds1.jpg'),
          repeat: ImageRepeat.repeat, // tiles in both directions
          // repeat: ImageRepeat.repeatX, // tiles horizontally only
          // repeat: ImageRepeat.repeatY, // tiles vertically only
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: const MyBottomNavBar(),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Question bracelet
                SizedBox(height: 25),
                Container(
                  
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  child: CustomPaint(
                    painter: CircularBraceletPainter(
                      beadColors: beadColors,
                      randomNo: Random().nextInt(beadColors.length),
                    ),
                  ),
                ),

                Text("Which Bracelet is the same?"),
                const SizedBox(height: 24),

                // Multiple choice options
                MultipleChoice(
                  key: ValueKey(questionNumber),
                  displayOptions: displayOptions,
                  onResult: onResult,
                  correctPostion: correctPosition,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
