import 'package:education_app/pages/teachers/class_page.dart';
import 'package:education_app/utils/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:education_app/components/home_cards.dart';

class TeacherHomePage extends StatelessWidget {
  TeacherHomePage({super.key});

  final AuthController authController = Get.find<AuthController>();

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
    } else {
      Get.snackbar('Error', result, snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.blue,

        title: Text("Home"),
        actions: [
          //logout button
          IconButton(onPressed: logout, icon: Icon(Icons.logout)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "Welcome back ${authController.currentUser.value?.firstName}!",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          // Cards
          Expanded(
            child: Row(
              children: [
                // CLASSES - 2/3 width
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: HomeCard(
                      title: "Classes",
                      icon: Icons.groups,
                      onTap: () {
                        Get.to(() => ClassPage());
                      },
                      color: Colors.green.shade300,
                    ),
                  ),
                ),

                // STUDENTS - 1/3 width
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: HomeCard(
                      title: "Students",
                      icon: Icons.people,
                      onTap: () {
                        Get.to(() => TeacherHomePage());
                      },
                      color: Colors.green.shade300,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
