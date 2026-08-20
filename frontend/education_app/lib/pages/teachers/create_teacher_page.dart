import 'package:education_app/components/button.dart';
import 'package:education_app/components/text_field.dart';
import 'package:education_app/utils/dependencies.dart';
import 'package:education_app/utils/screen_size.dart';
import 'package:education_app/utils/teacher_colours.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateTeacherPage extends StatefulWidget {
  CreateTeacherPage({super.key});

  @override
  State<CreateTeacherPage> createState() => CreateTeacherPageState();
}

class CreateTeacherPageState extends State<CreateTeacherPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  AuthController authController = Get.find<AuthController>();

  void createAccount() async {
    //API call to go here
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!emailController.text.contains('@')) {
      Get.snackbar('Error', 'Please enter a valid email address');
      return;
    }
    if (passwordController.text.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters');
      return;
    }

    final result = await authController.createTeacherAccount(
      firstNameController.text.trim(),
      lastNameController.text.trim(),
      emailController.text.trim(),
      passwordController.text,
    );
    if (result == 'success') {
      Get.back();
      Get.snackbar(
        'Account Created',
        'Your teacher account has been created.',
        snackPosition: SnackPosition.BOTTOM,
      );

      
    } else {
      Get.snackbar('Error', result, snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TeacherColours.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 30, bottom: 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 75),
            Icon(
              Icons.account_box_rounded,
              size: 100,
              color: TeacherColours.primaryColor,
            ),
            Container(
              width: screenWidth(context) * 0.6,
              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: TeacherColours.primaryColor,
                  width: 5,
                ),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 25),

                  MyTextField(
                    controller: firstNameController,
                    hintText: 'First Name',
                    obscureText: false,
                  ),

                  const SizedBox(height: 15),

                  MyTextField(
                    controller: lastNameController,
                    hintText: 'Last Name',
                    obscureText: false,
                  ),

                  const SizedBox(height: 15),

                  MyTextField(
                    controller: emailController,
                    hintText: 'Email Address',
                    obscureText: false,
                  ),

                  const SizedBox(height: 15),

                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),

                  const SizedBox(height: 15),

                  MyTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                  ),

                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Text(
                      'Already have an account? Log in',
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),

            const SizedBox(height: 25),

            myButton(
              onTap: createAccount,
              color: TeacherColours.primaryColor,
              text: "Create Account",
            ),
          ],
        ),
      ),
    );
  }
}
