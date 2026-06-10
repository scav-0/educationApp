import 'package:education_app/components/button.dart';
import 'package:education_app/components/text_field.dart';
import 'package:education_app/pages/home_page.dart';
import 'package:education_app/utils/dependencies.dart';
import 'package:education_app/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  //sign user in method
  void signUserIn() async {
    final result = await authController.signIn(
    usernameController.text.trim(),
    passwordController.text.trim(),
  );

    print(result); // ← check what's coming back

    if (result == 'success') {
    authController.isSignedIn.value = true; // ← this triggers AuthPage to switch to HomePage
    } else {
      Get.snackbar('Error', result, snackPosition: SnackPosition.BOTTOM,);
    
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                        padding:  EdgeInsets.symmetric(horizontal: screenWidth(context)*0.05),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.black),
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

              //potentially register now?
            ],
          ),
        ),
      ),
    );
  }
}
