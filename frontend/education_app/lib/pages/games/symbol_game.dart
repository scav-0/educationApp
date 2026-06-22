// ignore_for_file: no_logic_in_create_state

import 'dart:math';

import 'package:education_app/components/multipleChoice.dart';
import 'package:education_app/components/my_bottom_nav.dart';
import 'package:education_app/pages/games/painter/toSymbols.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class SymbolGamePage extends StatefulWidget {
  const SymbolGamePage({super.key});

  @override
  State<StatefulWidget> createState() => SymbolGamePageState();
}

class SymbolGamePageState extends State<SymbolGamePage> {
  late String answer;

  late List<String> options;
  late int correctPosition;
  //This one is going to work like pattern array, create 3 "wrong answers" i.e different patterns, map to icons, same multiple choice questions
  @override
  void initState() {
    super.initState();
    generateQuestion();
  }

  Widget displayOptions(int index) {
    return Text(
      options[index],
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24,
        
        letterSpacing: 4, 
      ),
    );
  }

  int questionNumber = 0;

  void generateQuestion() {
    setState(() {
      questionNumber++;
      answer = "";
      final rng = Random();
      final wordsItCouldBe = ["TOOT", "WORD", "BRRR", "PINACOLADA"];
      // //Create random bead Colors array -> to be replaced
      // for (int i = 0; i < rng.nextInt(7) + 5; i++) {
      //   beadColors.add(rng.nextInt(7) + 1);
      // }
      answer = wordsItCouldBe[rng.nextInt(3)];

      List<String> wrongAnswers = createWrongAnswers(answer);

      List<int> positions = [0, 1, 2, 3];
      positions.shuffle();
      correctPosition = positions[0];

      options = ["", "", "", ""];
      options[positions[0]] = answer;
      options[positions[1]] = wrongAnswers[0];
      options[positions[2]] = wrongAnswers[1];
      options[positions[3]] = wrongAnswers[2];
    });
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
                generateQuestion(); // should load next question....
              });
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  /**
   * Fuction to return the input String to a symbol in the form ABBA or ABAA for example from TOOT or TOTT
   */
  String getPattern(String input) {
    Map<String, String> symbols = {};
    String pattern = "";
    int nextSymbol = 65; //65=A

    for (int i = 0; i < input.length; i++) {
      if (!symbols.containsKey(input[i])) {
        symbols[input[i]] = String.fromCharCode(nextSymbol);
        nextSymbol++;
      }
      pattern += symbols[input[i]]!;
    }
    return pattern;
  }

  List<String> createWrongAnswers(String input) {
    String correctPattern = getPattern(input);
    Random rng = Random();
    List<String> wrongAnswers = [];
    List<String> patterns = [correctPattern];
    //One where a new symbol is added
    do {
      List<String> chars = input.split("");

      chars[rng.nextInt(input.length)] = String.fromCharCode(
        rng.nextInt(25) + 65,
      );
      String potential = chars.join();
      String popattern = getPattern(potential);
      if (!patterns.contains(popattern)) {
        wrongAnswers.add(potential);
        patterns.add(popattern);
      }
    } while (wrongAnswers.isEmpty);

    //two where the existing ones are jumbled
    int attempts = 0;
    do {
      List<String> chars = input.split("");
      int b;
      int a = rng.nextInt(chars.length);
      do {
        b = rng.nextInt(chars.length);
      } while (a == b);
      String temp = chars[b];
      chars[b] = chars[a];
      chars[a] = temp;

      String potential = chars.join();
      String popattern = getPattern(potential);
      if (!patterns.contains(popattern)) {
        wrongAnswers.add(potential);
        patterns.add(popattern);
      }
      attempts++;
    } while (wrongAnswers.length < 3 && attempts < 20);

    while (wrongAnswers.length < 3) {
      List<String> chars = input.split("");
      for (int i = 0; i < chars.length; i++) {
        chars[i] = String.fromCharCode(rng.nextInt(26) + 65);
      }
      String potential = chars.join();
      String popattern = getPattern(potential);
      if (!patterns.contains(popattern)) {
        wrongAnswers.add(potential);
        patterns.add(popattern);
      }
    }

    return wrongAnswers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const MyBottomNavBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Question bracelet
              SizedBox(height: 25, child: Text("Question goes here?!")),
              SizedBox(
                
                height: 180,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: buildSymbolRow(answer),
                ),
              ),

              Text("What is the password?"),
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
    );
  }
}
