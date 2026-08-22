import 'package:education_app/components/app_bar.dart';
import 'package:education_app/components/class_button.dart';
import 'package:education_app/pages/teachers/create_student_page.dart';
import 'package:education_app/pages/teachers/view_students_page.dart';
import 'package:education_app/utils/stats_controller.dart';
import 'package:education_app/utils/teacher_colours.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

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

          const SizedBox(height: 25),

          const Text(
            'How would you like to add students?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final name =
                    classNameController.text.trim();

                if (name.isEmpty) {
                  Get.snackbar(
                    'Error',
                    'Please enter a class name.',
                  );
                  return;
                }

                Get.back();

                showStudentCountDialog(name);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Enter Students Manually'),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final name =
                    classNameController.text.trim();

                if (name.isEmpty) {
                  Get.snackbar(
                    'Error',
                    'Please enter a class name.',
                  );
                  return;
                }

                Get.back();

                uploadStudentSpreadsheet(name);
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Spreadsheet'),
            ),
          ),
        ],
      ),

      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}

void showStudentCountDialog(String className) async {
  final studentCountController =
      TextEditingController();

  Get.dialog(
    AlertDialog(
      title: const Text('Number of Students'),

      content: TextField(
        controller: studentCountController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Number of students',
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: () async {
            final count = int.tryParse(
              studentCountController.text.trim(),
            );

            if (count == null || count < 0) {
              Get.snackbar(
                'Error',
                'Please enter a valid number of students.',
              );
              return;
            }

            Get.back();
            if(count==0){
              await statsController.createClass(className, []);
            }else{
            Get.to(
              () => StudentEntryPage(
                className: className,
                studentCount: count,
              ),
            );}
          },
          child: const Text('Next'),
        ),
      ],
    ),
  );
}

Future<void> uploadStudentSpreadsheet(
  String className,
) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx'],
    withData: true,
  );

  if (result == null) {
    return;
  }

  final bytes = result.files.single.bytes;

  if (bytes == null) {
    Get.snackbar(
      'Error',
      'Could not read the spreadsheet.',
    );
    return;
  }

  try {
    final excel = Excel.decodeBytes(bytes);

    if (excel.tables.isEmpty) {
      Get.snackbar(
        'Error',
        'The spreadsheet contains no worksheets.',
      );
      return;
    }

    final sheet =
        excel.tables[excel.tables.keys.first]!;

    final students = <Map<String, String>>[];

    // Skip row 0 because it contains the headers
    for (int rowIndex = 1;
        rowIndex < sheet.maxRows;
        rowIndex++) {

      final row = sheet.row(rowIndex);

      if (row.length < 2) {
        continue;
      }

      final firstName =
          row[0]?.value?.toString().trim() ?? '';

      final lastName =
          row[1]?.value?.toString().trim() ?? '';

      // Ignore completely empty rows
      if (firstName.isEmpty &&
          lastName.isEmpty) {
        continue;
      }

      // Don't allow incomplete names
      if (firstName.isEmpty ||
          lastName.isEmpty) {
        Get.snackbar(
          'Error',
          'Row ${rowIndex + 1} is missing a first or last name.',
        );
        return;
      }

      students.add({
        'first_name': firstName,
        'last_name': lastName,
      });
    }

    if (students.isEmpty) {
      Get.snackbar(
        'Error',
        'No students were found in the spreadsheet.',
      );
      return;
    }

    // Go to the same page used for manual entry
    Get.to(
      () => StudentEntryPage(
        className: className,
        studentCount: students.length,
        importedStudents: students,
      ),
    );

  } catch (e) {
    print('Error reading spreadsheet: $e');

    Get.snackbar(
      'Error',
      'Could not read the spreadsheet.',
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Classes', isStudent: false),
      backgroundColor: TeacherColours.backgroundColor,
      body: Obx(() {
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
                        final schoolClass = statsController.classes[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: ClassButton(
                            name: schoolClass.name,
                            onTap: () {
                              Get.to(
                                () => StudentsPage(
                                  classId: schoolClass.id,
                                  className: schoolClass.name,
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
      }),
    );
  }
}
