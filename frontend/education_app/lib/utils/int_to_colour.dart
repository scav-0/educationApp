import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

///Method to map integers (from 1-6) to unique colours
///Anything outside of that range is mapped to purple
///Returned list of type Color
List<Color> toBeadColours(List<int> colours) {
  return colours.map((c) {
    switch (c) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.green;
      case 5:
        return Colors.blue;
      case 6:
        return Colors.pink;
      default:
        return Colors.purple;
    }
  }).toList();
}

final double beadRadius = 16;

///Method for swaping elements of an array
///Element at index a will be swapped to element of index b
///returns array with swapped elements
List<int> swap(List<int> array, int a, int b) {
  int temp = array[a];
  array[a] = array[b];
  array[b] = temp;
  return array;
}


//Method for creating incorrect choices for bracelet multiple choices
List<List<int>> createWrongAnswers(List<int> colours, double p) {
  List<List<int>> list = [];
  List<int> scrambled = List.from(colours);
  final rng = Random();

  //if easier add more random colours, if harder just swap, more swaps for easier etc
  int randoms = 1;
  if (p < 0.5) {
    randoms = 2;
  }
  int swaps = 2;
  if (p < 0.75) {
    swaps = 3;
  }

  int attempts = 0;
  int innerAttempts = 0;
  do {
    scrambled = List.from(colours);
    for (int i = 0; i < swaps; i++) {
      innerAttempts++;
      HashSet<int> map = new HashSet();
      int a = rng.nextInt(colours.length);
      int b;
      do {
        b = rng.nextInt(colours.length);
      } while (a == b);
      if (!map.add(a) || !map.add(b)) {
        i--;
      } else {
        scrambled = swap(scrambled, a, b);
      }
      if (innerAttempts == 20) {
        break;
      }
    }
    if (!isSameCircularSequence(scrambled, colours) &&
        !list.any((existing) => isSameCircularSequence(existing, scrambled))) {
      list.add(scrambled);
    }

    attempts++;
  } while (attempts < 20 && list.length < 3 - randoms);

  attempts = 0;
  while (list.length < 3 || attempts > 20) {
    scrambled = List.from(colours);
    HashSet<int> map = new HashSet();
    for (int i = 0; i < 2; i++) {
      int a = rng.nextInt(colours.length);
      if (map.add(a)) {
        scrambled[a] = rng.nextInt(7);
      } else {
        i--;
      }
    }

    //check not equal or in list
    //add to list if not
    if (!isSameCircularSequence(scrambled, colours) &&
        !list.any((existing) => isSameCircularSequence(existing, scrambled))) {
      list.add(scrambled);
    }
  }

  //shouldnt reach this but jic
  while (list.length < 3) {
    List<int> random = List.generate(colours.length, (_) => rng.nextInt(7) + 1);
    if (!isSameCircularSequence(random, colours) &&
        !list.any((existing) => isSameCircularSequence(existing, random))) {
      list.add(random);
    }
  }

  return list;
}

///Method for checking is two integer lists (bracelets) are the same circular sequence
///example to make sure you dont have 1234 and 2341
bool isSameCircularSequence(List<int> a, List<int> b) {
  if (a.length != b.length) return false;

  for (int i = 0; i < a.length; i++) {
    List<int> rotated = [
      ...a.sublist(i),
      ...a.sublist(0, i),
    ]; //... = spreads a list out into its components
    if (listEquals(rotated, b)) return true;
  }
  return false;
}
