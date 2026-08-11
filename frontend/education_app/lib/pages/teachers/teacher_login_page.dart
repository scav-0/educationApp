import 'package:education_app/components/button.dart';
import 'package:education_app/components/text_field.dart';
import 'package:education_app/pages/login_page.dart';
import 'package:education_app/pages/students/auth_page.dart';
import 'package:education_app/utils/dependencies.dart';
import 'package:education_app/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TeacherLoginPage extends StatelessWidget {
  TeacherLoginPage({super.key});

  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  //sign user in method
  void signUserIn() async {
    final result = await authController.teacherSignIn(
      // TO DO
      emailController.text.trim(),
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
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              //logo
              const Icon(Icons.lock, size: 100, color: Colors.amber),

              const SizedBox(height: 50),

              //Welcome back...
              Text(
                'Welcome back!',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),

              const SizedBox(height: 25),

              //username textfield
              Center(
                child: Container(
                  height: 250,
                  width: screenWidth(context) * 0.6,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 50),
                      MyTextField(
                        controller: emailController,
                        hintText: "Email Address",
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
                          onTap: () => Get.to(() => LoginPage()),
                          child: const Text(
                            'Student Login',
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
              myButton(onTap: signUserIn),
            ],
          ),
        ),
      ),

      //LOG IN PAGE FOR TEACHERS
    );
  }
}
