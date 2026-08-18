import 'dart:math';

import 'package:education_app/components/multipleChoice.dart';
import 'package:education_app/pages/students/games/painter/circularBraceletPainter.dart';
import 'package:education_app/components/my_bottom_nav.dart';
import 'package:education_app/pages/students/games/painter/lineBraceletPainter.dart';
import 'package:education_app/utils/game_audio.dart';
import 'package:education_app/utils/int_to_colour.dart';
import 'package:education_app/utils/skill_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///Class for the Bracelet Game
///The class is stateful as it changes depending on difficulty or change of problem
class BraceletGamePage extends StatefulWidget {
  const BraceletGamePage({super.key});

  @override
  State<StatefulWidget> createState() => BraceletGamePageState();
}

class BraceletGamePageState extends State<BraceletGamePage> {
  //skill controller for any information needed from the API
  final SkillController skillController = Get.find<SkillController>();

  //Parameter for the question
  late List<int> beadColors;

  //List of options and correct position for the multiple choice selection
  late List<List<int>> options;
  late int correctPosition;

  //Initialisation of variables needed for documentation
  int attemptCount = 0;
  late DateTime questionStartTime;
  late bool firstAttempt;

  //Variables needed for loading and question generation
  bool isLoading = true;
  int questionNumber = 0; //question doesnt reload without this paramater

  //Initial state override -> loads question
  @override
  void initState() {
    super.initState();
    loadAndGenerate();
  }

  //Widget for displaying the bracelets in the multipled choice boxes
  Widget displayOptions(int index) {
    return SizedBox(
      height: 36,
      width: 200,
      child: CustomPaint(
        painter: LineBraceletPainter(beadColors: options[index]),
      ),
    );
  }

  //Method for question generation and loading
  Future<void> loadAndGenerate() async {
    //Fetch users p_know/difficuly for game
    await skillController.fetchSkills();

    generateQuestion();

    setState(() {
      isLoading = false; // done loading
      attemptCount = 1; //for stats
      questionStartTime = DateTime.now();
      firstAttempt = true;
    });
  }

  //Method for generation of question, creates answer, creates fake answers and array of options for choice later
  void generateQuestion() {
    setState(() {
      questionNumber++;
      beadColors = [];
      double p = skillController.braceletPknow.value;

      beadColors = generateAnswer(p); //creates answer

      List<List<int>> wrongAnswers = createWrongAnswers(
        beadColors,
        p,
      ); //creates wrong answers

      //shuffle answers and remember what the correct answer is
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

  ///Method for generating bracelet for question
  ///Takes parameter p for difficulty level
  List<int> generateAnswer(double p) {
    List<int> result = [];
    final rng = Random();

    //set length of bracelet based off difficulty
    int beadLength = 5;
    for (int i = 6; i > 0; i--) {
      if (p > i / 10) {
        beadLength = i + 4;
        break;
      }
    }

    //set number of colours usable based off difficulty
    int numberOfColors = 7;
    for (int i = 9; i > 4; i--) {
      if (p > i / 10) {
        numberOfColors = 11 - i;
        break;
      }
    }

    //Add beads to the bracelet randomly based off the above parameters
    for (int i = 0; i < beadLength; i++) {
      result.add(rng.nextInt(numberOfColors) + 1);
    }

    return result;
  }

  ///Method for post result of game, takes parameter correct, whether the user got the problem correct
  void onResult(bool correct) {
    if (correct) {
      GameAudio.correct();
    } else {
      GameAudio.incorrect();
    }
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
                await skillController.updateSkill(
                  'bracelet',
                  correct,
                ); //Only update p_know once per game
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
                loadAndGenerate(); // load next question
              });
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  //Method for building the page
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/clouds1.jpg'),
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bracelet Game'),
          backgroundColor: Colors.amber.shade400,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: 'How to Play',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('How to Play'),
                      content: const Text(
                        'Compare the circular bracelet above '
                        'with the four bracelets below. '
                        'Select the bracelet that has the '
                        'same colour pattern.',
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
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Question bracelet
                SizedBox(height: 25),
                Container(
                  width: 320,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 8,
                        offset: Offset(0, 4),
                        color: Colors.black12,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Which bracelet is the same?',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 19),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: 180,
                        height: 180,
                        child: CustomPaint(
                          painter: CircularBraceletPainter(
                            beadColors: beadColors,
                            randomNo: Random().nextInt(beadColors.length),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
