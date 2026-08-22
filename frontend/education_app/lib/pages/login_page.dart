import 'package:education_app/components/button.dart';
import 'package:education_app/components/text_field.dart';
import 'package:education_app/pages/students/auth_page.dart';
import 'package:education_app/pages/teachers/teacher_login_page.dart';
import 'package:education_app/utils/dependencies.dart';
import 'package:education_app/utils/screen_size.dart';
import 'package:education_app/utils/teacher_colours.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  //sign user in method
  void signStudentIn() async {
    final result = await authController.signIn(
      usernameController.text.trim(),
      passwordController.text.trim(),
    );

    if (result == 'success') {
      authController.isSignedIn.value = true;
      Get.to(() => AuthPage());
    } else {
      Get.snackbar('Error', result, snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TeacherColours.backgroundColor,
      body: SafeArea(
        
        child: Center(
          
          child: Column(
            children: [
              const SizedBox(height: 100),
              //logo
              const Icon(Icons.lock, size: 100, color: Colors.amber),

              const SizedBox(height: 50),

              //Welcome back...
              Text(
                'Welcome Back Student!',textAlign: TextAlign.center ,
                style: TextStyle(color: Colors.grey[700], fontSize: 16,),
              ),

              const SizedBox(height: 25),

              //username textfield
              Center(
                child: Container(
                  height: 250,
                  width: screenWidth(context) * 0.6,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 50),
                      MyTextField(
                        controller: usernameController,
                        hintText: "Username",
                        obscureText: false,
                      ),

                      const SizedBox(height: 15),

                      MyTextField(
                        controller: passwordController,
                        hintText: "Password",
                        obscureText: true,
                      ),
                      //forgot password?
                      const SizedBox(height: 15),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth(context) * 0.05,
                        ),

                        
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                          onTap: () => Get.to(() => TeacherLoginPage()),
                          child: const Text(
                            'Teacher Login',
                            style: TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),
              //sign in button
              myButton(onTap: signStudentIn, color: Colors.green, text: "Sign In"),

              //potentially register now?
            ],
          ),
        ),
      ),
    );
  }
}
