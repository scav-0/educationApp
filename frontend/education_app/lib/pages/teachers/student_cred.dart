import 'package:education_app/components/app_bar.dart';
import 'package:education_app/utils/teacher_colours.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class StudentCredentialsPage extends StatelessWidget {

  final String className;
  final List<Map<String, dynamic>> students;

  const StudentCredentialsPage({
    super.key,
    required this.className,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: MyAppBar(
        title: 'Student Accounts',
        isStudent: false,
      ),
      backgroundColor: TeacherColours.backgroundColor,
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              className,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Text(
            'Student Login Details',
            style: TextStyle(
              fontSize: 20,
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: students.length,
              itemBuilder: (context, index) {

                final student = students[index];

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 15,
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(20),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          '${student['first_name']} '
                          '${student['last_name']}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Username: ${student['username']}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),

                        Text(
                          'Password: ${student['password']}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),

            child: SizedBox(
              width: double.infinity,
              height: 60,

              child: ElevatedButton(
                onPressed: () {
                  Get.until(
                    (route) => route.isFirst,
                  );
                },

                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}