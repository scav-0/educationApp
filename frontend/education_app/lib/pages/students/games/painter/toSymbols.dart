import 'package:flutter/material.dart';
const List<IconData> symbolIcons = [
  Icons.star,
  Icons.circle,
  Icons.favorite,
  Icons.diamond,
  Icons.square,
  Icons.hexagon,
  // Icons.bolt,
  // Icons.cloud,
  // Icons.arrow_back,
  // Icons.punch_clock,
  // Icons.person,
  Icons.pentagon,
  // Icons.back_hand_rounded
];

const List<Color> symbolColors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.pink,
  Colors.teal,
  Colors.amber,
];

List<Widget> buildSymbolRow(String word) {
  Map<String, int> charToIndex = {};
  int nextIndex = 0;
  List<Widget> symbols = [];

  for (String char in word.split('')) {
    if (!charToIndex.containsKey(char)) {
      charToIndex[char] = nextIndex++;
    }
    int index = charToIndex[char]!;
    symbols.add(
      //since icons length is 7 and colours is 8 when it loops back it should be a different colour? 
      Icon(
        symbolIcons[index % symbolIcons.length],
        color: symbolColors[index % symbolColors.length],
        size: 40,
      ),
    );
  }
  return symbols;
}