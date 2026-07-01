import 'package:education_app/pages/auth_page.dart';
import 'package:education_app/utils/dependencies.dart';
import 'package:education_app/utils/skill_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  Get.put(AuthController());
  Get.put(SkillController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.amber[100],
        
      ),
    );
  }
}