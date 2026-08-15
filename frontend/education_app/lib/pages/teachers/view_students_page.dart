import 'package:education_app/pages/teachers/student_page.dart';

import 'package:education_app/utils/stats_controller.dart';
import 'package:education_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentsPage extends StatefulWidget {
  final int? classId;
  final String? className;

  const StudentsPage({super.key, this.classId, this.className});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final StatsController statsController = Get.find<StatsController>();

  void showDeleteClassDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Class?'),

          content: Text(
            'Are you sure you want to delete '
            '"${widget.className}"?\n\n'
            'The students will NOT be deleted. '
            'They will simply be removed from this class.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),

              onPressed: () async {
                Navigator.pop(context);

                final success = await statsController.deleteClass(
                  widget.classId!,
                );

                if (success) {
                  Get.back();

                  Get.snackbar(
                    'Class deleted',
                    '${widget.className} was deleted.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    'Could not delete the class.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },

              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.classId == null) {
      // All students for teacher
      statsController.getStudents();
    } else {
      // Students in specific class
      statsController.getStudentsFromClass(widget.classId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.className ?? 'All Students';

    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.blue),

      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (statsController.students.isEmpty) {
                return const Center(
                  child: Text(
                    'No students found',
                    style: TextStyle(fontSize: 20),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),

                itemCount: statsController.students.length,

                itemBuilder: (context, index) {
                  final student = statsController.students[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),

                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),

                      title: Text(
                        '${student.firstName} '
                        '${student.lastName}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: widget.classId == null
                          ? Text(student.className ?? '')
                          : Text(student.username),

                      onTap: () => {
                        Get.to(() => StudentStatsPage(student: student)),
                      },
                    ),
                  );
                },
              );
            }),
          ),

          if (widget.classId != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),

                  icon: const Icon(Icons.delete),

                  label: const Text('Delete Class'),

                  onPressed: () {
                    showDeleteClassDialog();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
