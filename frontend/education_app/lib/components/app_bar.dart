import 'package:education_app/pages/students/auth_page.dart';
import 'package:education_app/utils/dependencies.dart';
import 'package:education_app/utils/teacher_colours.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget{
  AuthController authController = Get.find<AuthController>();
  final List<Widget>? actions;
  final String title;
  final bool isStudent;

  MyAppBar({super.key, this.actions, required this.title, required this.isStudent});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void logout() async {
    final result = await authController.signOut();

    if (result == 'success') {
      authController.isSignedIn.value =
          false; //Why doesnt it work without this?
      Get.snackbar(
        'Signed Out Successfully!',
        "",
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.to(() => AuthPage());
    } else {
      Get.snackbar('Error', result, snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: isStudent?Colors.amber.shade400:TeacherColours.secondaryColor,

      title: Text(title),
      actions: [
        ...?actions,

        IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
      ],
    );
  }
}
