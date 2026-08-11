import 'package:education_app/utils/stats_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentEntryPage extends StatefulWidget {
  final String className;
  final int studentCount;

  const StudentEntryPage({
    super.key,
    required this.className,
    required this.studentCount,
  });

  @override
  State<StudentEntryPage> createState() => _StudentEntryPageState();
}

class _StudentEntryPageState extends State<StudentEntryPage> {

  late List<TextEditingController> firstNameControllers;
  late List<TextEditingController> lastNameControllers;

  @override
  void initState() {
    super.initState();

    firstNameControllers = List.generate(
      widget.studentCount,
      (_) => TextEditingController(),
    );

    lastNameControllers = List.generate(
      widget.studentCount,
      (_) => TextEditingController(),
    );
  }

  void createClass() async {

  final students = <Map<String, String>>[];

  for (int i = 0; i < widget.studentCount; i++) {

    final firstName =
        firstNameControllers[i].text.trim();

    final lastName =
        lastNameControllers[i].text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter all student names.',
      );
      return;
    }

    students.add({
      'first_name': firstName,
      'last_name': lastName,
    });
  }

  final StatsController statsController = Get.find<StatsController>();

  await statsController.createClass(
    widget.className,
    students,
  );
}

  @override
  void dispose() {
    for (final controller in firstNameControllers) {
      controller.dispose();
    }

    for (final controller in lastNameControllers) {
      controller.dispose();
    }

    super.dispose();
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.className),
        backgroundColor: Colors.blue,
      ),

      body: Column(
        children: [

          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Enter Student Names',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              itemCount: widget.studentCount,
              itemBuilder: (context, index) {

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 15,
                  ),

                  child: Row(
                    children: [

                      SizedBox(
                        width: 40,
                        child: Text(
                          '${index + 1}.',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),

                      Expanded(
                        child: TextField(
                          controller:
                              firstNameControllers[index],
                          decoration: const InputDecoration(
                            labelText: 'First name',
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: TextField(
                          controller:
                              lastNameControllers[index],
                          decoration: const InputDecoration(
                            labelText: 'Last name',
                          ),
                        ),
                      ),
                    ],
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
                onPressed: createClass,
                child: const Text(
                  'Create Class',
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
