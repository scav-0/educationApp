import 'package:education_app/utils/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'base_url.dart';

class SkillController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  RxDouble braceletPknow = 0.0.obs;
  RxDouble symbolPknow = 0.0.obs;
  RxDouble honeycombPknow = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    fetchSkills();
  }

  Future<void> fetchSkills() async {
    try {
      // print("Fetching Skills");
      if (authController.token.value.isEmpty) {
        await authController.checkAuthStatus();
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/skills/${authController.currentUser.value?.id}'),
        headers: {
          'Authorization':
              'Bearer ${await authController.storage.read(key: 'token') ?? ''}',
        }, //needs american spelling
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        braceletPknow.value = data['bracelet'];
        symbolPknow.value = data['symbol'];
        honeycombPknow.value = data['honeycomb'];
      }else{
        // print(response.statusCode);
      }
    } catch (e) {
      print('Error fetching skills: $e');
    }
  }

  Future<void> updateSkill(String game, bool correct) async {
    //Need to send game, and if its is correct or not alongside student id, (maybe current pknow also)
    try {
      // print("Updating skills");
      final response = await http.post(
        Uri.parse('$baseUrl/api/skills/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${await authController.storage.read(key: 'token') ?? ''}',
        },
        body: jsonEncode({'game': game, 'correct': correct}),
      );

      if (response.statusCode == 200) {
        // print("Success!");
        final data = jsonDecode(response.body);

        //Then receive back the new pknow
        switch (game) {
          case 'bracelet':
            braceletPknow.value = data['p_know'];
            break;
          case 'symbol':
            symbolPknow.value = data['p_know'];
            break;
          case 'honeycomb':
            honeycombPknow.value = data['p_know'];
            break;
          //UPDATE WHEN A NEW GAME IS ADDED
        }
      }else{
          // print(response.statusCode);
        }
    } catch (e) {
      print('Error updating skill: $e');
    }
  }

  Future<void> saveStats(String game, bool correct, int attempts, int timeTaken, double pKnow) async {
  try {
    await http.post(
      Uri.parse('$baseUrl/api/skills/stats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authController.token.value}',
      },
      body: jsonEncode({
        'game': game,
        'correct': correct,
        'attempts': attempts,
        'time_taken': timeTaken,
        'p_know': pKnow,
      }),
    );
  } catch (e) {
    print('Error saving stats: $e');
  }
}
}
