import 'package:education_app/pages/students/home_page.dart';
import 'package:education_app/pages/login_page.dart';
import 'package:education_app/pages/teachers/teacher_home_page.dart';
import 'package:education_app/utils/dependencies.dart';
import 'package:education_app/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthPage extends StatelessWidget{
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Obx((){
      if(authController.isSignedIn.value){
        if(authController.currentUser.value is Teacher){
          return TeacherHomePage();
        }else{
          return HomePage();
        }
      } else {
        return LoginPage();
      }
    });
  }
}