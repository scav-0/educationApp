import 'dart:math';

import 'package:education_app/components/multipleChoice.dart';
import 'package:education_app/pages/games/painter/circularBraceletPainter.dart';
import 'package:education_app/components/my_bottom_nav.dart';
import 'package:education_app/utils/int_to_colour.dart';
import 'package:flutter/material.dart';

class BraceletGamePage extends StatefulWidget {

  const BraceletGamePage({super.key});

  //DIFFICULTY WILL BE THE LENGTH OF THE BRACELET/ maybe less colours too?

  @override
  State<StatefulWidget> createState() => BraceletGamePageState();
}

class BraceletGamePageState extends State<BraceletGamePage> {
  final List<int> beadColors = [1, 2, 3, 4, 5, 6];

  late List<List<int>> options;
  late int correctPosition;

  @override
  void initState() {
    super.initState();
    generateQuestion();
  }

  void generateQuestion() {
    List<List<int>> wrongAnswers = createWrongAnswers(beadColors);

    List<int> positions = [0, 1, 2, 3];
    positions.shuffle();
    correctPosition = positions[0];

    options = [[], [], [], []];
    options[positions[0]] = beadColors;
    options[positions[1]] = wrongAnswers[0];
    options[positions[2]] = wrongAnswers[1];
    options[positions[3]] = wrongAnswers[2];
  }

  void onResult(bool correct) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(correct ? 'Correct!' : 'Wrong!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                generateQuestion(); // load next question
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
    return Scaffold(
      bottomNavigationBar: const MyBottomNavBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Question bracelet
            SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: CircularBraceletPainter(
                  beadColors: beadColors,
                  randomNo: Random().nextInt(beadColors.length))
                ),
              ),
            

            const SizedBox(height: 24),

            // Multiple choice options
            MultipleChoice(
              options: options,
              onResult: onResult, correctPostion: correctPosition,
            ),
          ],
        ),
      ),
    );
  }
}
