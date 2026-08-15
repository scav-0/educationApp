import 'package:education_app/components/p_know_graph.dart';
import 'package:education_app/utils/stats_controller.dart';
import 'package:education_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//MOST IMPORTANT PAGE
//CHANGE PASSWORDS
//VIEW STATS ON STUDENTS PERFORMANCE

class StudentStatsPage extends StatefulWidget {
  final Student student;

  const StudentStatsPage({super.key, required this.student});

  @override
  State<StudentStatsPage> createState() => StudentStatsState();
}

class StudentStatsState extends State<StudentStatsPage> {
  String selectedGame = 'Overall Stats';
  StatsController statsController = Get.find<StatsController>();

  @override
  void initState() {
    loadStats();
    statsController.skillHistory.clear();

    super.initState();
  }

  void loadStats() {
    if (selectedGame == 'Overall Stats') {
      return;
    }

    statsController.getStudentStats(
      widget.student.id,
      selectedGame.toLowerCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.student.firstName} '
          '${widget.student.lastName}',
        ),
        backgroundColor: Colors.blue,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            //Student info ...
            Text(
              '${widget.student.firstName} '
              '${widget.student.lastName}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              '@${widget.student.username}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            Text(
              'Class : ${widget.student.className ?? 'N/A'}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            const SizedBox(height: 30),

            //Stats from games
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedGame,

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Game',
              ),

              items: const [
                DropdownMenuItem(
                  value: 'Overall Stats',
                  child: Text('Overall Stats'),
                ),

                DropdownMenuItem(value: 'Bracelet', child: Text('Bracelet')),

                DropdownMenuItem(value: 'Symbol', child: Text('Symbol')),

                DropdownMenuItem(value: 'Honeycomb', child: Text('Honeycomb')),
              ],

              onChanged: (value) {
                setState(() {
                  selectedGame = value!;
                });

                loadStats();
              },
            ),

            const SizedBox(height: 25),

            //GRAPHS
            // Container(
            //   height: 300,
            //   width: double.infinity,

            //   decoration: BoxDecoration(
            //     color: Colors.grey[200],
            //     borderRadius: BorderRadius.circular(12),
            //   ),

            //   child: Center(
            //     child: Text(
            //       '$selectedGame graph goes here',
            //       style: const TextStyle(fontSize: 18),
            //     ),
            //   ),
            // ),
            SizedBox(
              height: 350,
              width: double.infinity,
              child: buildPKnowGraph(),
            ),

            const SizedBox(height: 30),

            //ACCOUNT BITS - DELETE/ CHANGE PASSWORD/ CHANGE CLASS
            const Text(
              'Account',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  showChangePasswordDialog();
                },

                child: const Text('Change Password'),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  showChangeClassDialog();
                },

                child: const Text('Change Class'),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),

                onPressed: () {
                  confirmDeleteStudent();
                },

                child: const Text('Delete Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showChangePasswordDialog() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),

          content: TextField(
            controller: passwordController,
            obscureText: true,

            decoration: const InputDecoration(
              labelText: 'New Password',
              border: OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                final password = passwordController.text.trim();

                if (password.isEmpty) {
                  Get.snackbar(
                    'Error',
                    'Password cannot be empty',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }

                if (password.length < 6) {
                  Get.snackbar(
                    'Error',
                    'Password must be at least 6 characters',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }

                final success = await statsController.changeStudentPassword(
                  widget.student.id,
                  password,
                );

                if (success) {
                  Navigator.pop(context);

                  Get.snackbar(
                    'Success',
                    'Password changed successfully',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    'Could not change password',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },

              child: const Text('Change Password'),
            ),
          ],
        );
      },
    );
  }

  void showChangeClassDialog() async {
    await statsController.getClasses();

    if (!mounted) return;

    int? selectedClassId = widget.student.classId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Change Class'),

              content: Obx(() {
                if (statsController.classes.isEmpty) {
                  return const Text('You have no classes.');
                }

                return DropdownButtonFormField<int>(
                  value: selectedClassId,

                  decoration: const InputDecoration(
                    labelText: 'Class',
                    border: OutlineInputBorder(),
                  ),

                  items: statsController.classes.map((schoolClass) {
                    return DropdownMenuItem<int>(
                      value: schoolClass.id,
                      child: Text(schoolClass.name),
                    );
                  }).toList(),

                  onChanged: (value) {
                    setDialogState(() {
                      selectedClassId = value;
                    });
                  },
                );
              }),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    if (selectedClassId == null) {
                      return;
                    }

                    final success = await statsController.changeStudentClass(
                      widget.student.id,
                      selectedClassId!,
                    );

                    if (!context.mounted) return;

                    if (success) {
                      final selectedClass = statsController.classes.firstWhere(
                        (schoolClass) => schoolClass.id == selectedClassId,
                      );

                      setState(() {
                        widget.student.classId = selectedClass.id;
                        widget.student.className = selectedClass.name;
                      });

                      Navigator.pop(context);

                      Get.snackbar(
                        'Success',
                        'Class changed successfully',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    } else {
                      Get.snackbar(
                        'Error',
                        'Could not change class',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },

                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  //here we go
  void confirmDeleteStudent() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account?'),

          content: Text(
            'Are you sure you want to delete '
            '${widget.student.firstName} '
            '${widget.student.lastName}\'s account?\n\n'
            'This cannot be undone.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text('Cancel'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),

              onPressed: () async {
                final success = await statsController.deleteStudent(
                  widget.student.id,
                );

                if (!context.mounted) return;

                if (success) {
                  // Close confirmation dialog
                  Navigator.pop(context);

                  // Return to students page
                  Navigator.pop(context);

                  Get.snackbar(
                    'Student Deleted',
                    'The student account has been deleted.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    'Could not delete student account.',
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
}
