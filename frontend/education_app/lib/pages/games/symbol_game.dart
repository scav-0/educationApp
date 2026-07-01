// ignore_for_file: no_logic_in_create_state

import 'dart:math';

import 'package:education_app/components/multipleChoice.dart';
import 'package:education_app/components/my_bottom_nav.dart';
import 'package:education_app/pages/games/painter/toSymbols.dart';
import 'package:education_app/utils/skill_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class SymbolGamePage extends StatefulWidget {
  const SymbolGamePage({super.key});

  @override
  State<StatefulWidget> createState() => SymbolGamePageState();
}

class SymbolGamePageState extends State<SymbolGamePage> {
  //DIFFICULTY EFFECTS WRONG ANSWER GENERATION (MORE RANDOM LETTERS)
  //ALSO EFFECTS LENGTH OF WORD
  
  final SkillController skillController = Get.find<SkillController>();
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
      style: const TextStyle(fontSize: 24, letterSpacing: 4),
    );
  }

  int questionNumber = 0;

  void generateQuestion() {
    setState(() {
      questionNumber++;

      double pKnown = skillController.symbolPknow.value;

      print(pKnown);
      print("New Game \n");
      answer = wordGenerator(pKnown);

      List<String> wrongAnswers = createWrongAnswers(answer, pKnown);

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

  //p <1 -> can be changed later assuming Bayesian Knowledge Tracing
  String wordGenerator(double p) {
    final rng = Random();

    String word = "";

    int wordLength = 4;

    //loop -> if (p>i/10) -> wordLength = i+1 where i--, i starts at 9 -> ends on 1 so if p>0.9 -> word length=10, >0.8 =9, etc etc.

    for (int i = 9; i > 0; i--) {
      if (p > i / 10) {
        wordLength = i + 4;
        break;
      }
    }

    while (word.length != wordLength) {
      if (word.isNotEmpty && rng.nextDouble() < 0.4) {
        word +=
            word[rng.nextInt(word.length)]; //40% chance of a repeast
      } else {
        word += String.fromCharCode(65 + rng.nextInt(26));
      }
    }

    //add a check for swear words as it is a kids game

    return word;
  }

  void  onResult(bool correct) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(correct ? 'Correct!' : 'Wrong!'),
        actions: [
          TextButton(
            onPressed: () async {
              await skillController.updateSkill('symbol', correct);
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

  List<String> createWrongAnswers(String input, double p) {
    String correctPattern = getPattern(input);
    Random rng = Random();
    List<String> wrongAnswers = [];
    List<String> patterns = [correctPattern];
    //One where a new symbol is added

    bool breakCon;

    int randoms = 1;

    //change this such that once length is upped, you get some with more -> less


    if (p%0.1 <0.025) {
      randoms = 4;
    } else if (p%0.1 <0.05) {
      randoms = 3;
    } else if (p%0.1 <0.075) {
      randoms = 2;
    }

    randoms = randoms.clamp(1, input.length);

    do {
      List<String> chars = input.split("");
      List<int> changed = [];
      for (int i = 0; i < randoms; i++) {
        int index;
        do {
          index = rng.nextInt(input.length);
        } while (changed.contains(index));
        changed.add(index);
        chars[index] = String.fromCharCode(rng.nextInt(25) + 65);
      }

      String potential = chars.join();
      String popattern = getPattern(potential);
      if (!patterns.contains(popattern)) {
        wrongAnswers.add(potential);
        patterns.add(popattern);
      }

      if (p < 0.5) {
        breakCon = wrongAnswers.length < 2;
      } else {
        breakCon = wrongAnswers.isEmpty;
      }
    } while (breakCon);

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
