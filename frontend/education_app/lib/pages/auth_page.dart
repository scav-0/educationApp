import 'package:education_app/pages/home_page.dart';
import 'package:education_app/pages/login_page.dart';
import 'package:education_app/utils/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthPage extends StatelessWidget{
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Obx((){
      if(authController.isSignedIn.value){
        return HomePage();
      } else {
        return LoginPage();
      }
    });
  }
}