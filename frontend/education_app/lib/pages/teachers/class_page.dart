import 'package:education_app/components/class_button.dart';
import 'package:education_app/pages/teachers/create_student_page.dart';
import 'package:education_app/utils/stats_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClassPage extends StatefulWidget {
  const ClassPage({super.key});

  @override
  State<ClassPage> createState() => ClassPageState();
}

class ClassPageState extends State<ClassPage> {
  final StatsController statsController = Get.put(StatsController());

  @override
  void initState() {
    super.initState();

    statsController.getClasses();
  }

  void createClassDialog() {
  final classNameController = TextEditingController();
  final studentCountController = TextEditingController();

  Get.dialog(
    AlertDialog(
      title: const Text('Create Class'),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: classNameController,
            decoration: const InputDecoration(
              labelText: 'Class name',
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: studentCountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Number of students',
            ),
          ),
        ],
      ),

      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: () {
            final name = classNameController.text.trim();
            final count = int.tryParse(
              studentCountController.text.trim(),
            );

            if (name.isEmpty || count == null || count <= 0) {
              Get.snackbar(
                'Error',
                'Please enter a class name and valid size.',
              );
              return;
            }

            Get.back();

            Get.to(
              () => StudentEntryPage(
                className: name,
                studentCount: count,
              ),
            );
          },
          child: const Text('Next'),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes'),
        backgroundColor: Colors.blue,
      ),

      body: Obx(
  () {
    return Column(
      children: [

        // CREATE CLASS BUTTON
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: createClassDialog,
              icon: const Icon(Icons.add),
              label: const Text(
                'Create Class',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),

        // CLASS LIST
        Expanded(
          child: statsController.classes.isEmpty
              ? const Center(
                  child: Text(
                    'No classes found',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: statsController.classes.length,
                  itemBuilder: (context, index) {
                    final schoolClass =
                        statsController.classes[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: ClassButton(
                        name: schoolClass.name,
                        onTap: () {
                          Get.to(
                            () => ClassPage(
                              // classId: schoolClass.id,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  },
),
    );
  }
}
