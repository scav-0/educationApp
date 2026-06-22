import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

List<Color> toBeadColours(List<int> colours){
    return colours.map((c) {
      switch (c) {
        case 1: return Colors.red;
        case 2: return Colors.orange;
        case 3: return Colors.yellow;
        case 4: return Colors.green;
        case 5: return Colors.blue;
        case 6: return Colors.pink;
        default: return Colors.purple;
      }
    }).toList();
  }

  final double beadRadius = 16;

  List<List<int>> createWrongAnswers(List<int> colours){
    List<List<int>> list = [] ;
    
    while(list.length<3){
      List<int> scrambled= List.from(colours);

      //do whatever scrambling needed 
      //SIMPLE 2 BEAD SWAP FOR NOW, COME BACK ONCE DIFFICULTY IS IMPLEMENTED
      final rng = Random();
      int a = rng.nextInt(colours.length);
      int b;
      do{
        b = rng.nextInt(colours.length);
      }while(a==b);
      
      scrambled[a]=colours[b];
      scrambled[b]=colours[a];

      //check not equal or in list
      //add to list if not
      if (!isSameCircularSequence(scrambled, colours) && 
      !list.any((existing) => isSameCircularSequence(existing, scrambled))) {
      list.add(scrambled);
      }
    }

    return list;
  }

  bool isSameCircularSequence(List<int> a, List<int> b) {
  if (a.length != b.length) return false;

  for (int i = 0; i < a.length; i++) {
    List<int> rotated = [...a.sublist(i), ...a.sublist(0, i)];//... = spreads a list out into its components
    if (listEquals(rotated, b)) return true;
  }
  return false;
}