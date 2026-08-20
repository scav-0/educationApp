import 'package:education_app/components/app_bar.dart';
import 'package:education_app/pages/teachers/class_page.dart';
import 'package:education_app/pages/teachers/view_students_page.dart';
import 'package:education_app/utils/dependencies.dart';
import 'package:education_app/utils/teacher_colours.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:education_app/components/home_cards.dart';

class TeacherHomePage extends StatelessWidget {
  TeacherHomePage({super.key});

  final AuthController authController = Get.find<AuthController>();

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TeacherColours.backgroundColor,
      appBar: MyAppBar(
        isStudent: false,

        title: "Home",
        
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "Welcome back ${authController.currentUser.value?.firstName}!",
              style: const TextStyle(fontSize: 20,),
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
                      color: TeacherColours.primaryColor
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
                        Get.to(() => StudentsPage());
                      },
                      color: TeacherColours.primaryColor
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
