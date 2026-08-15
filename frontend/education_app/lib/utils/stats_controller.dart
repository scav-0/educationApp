import 'package:education_app/models/skill_point.dart';
import 'package:education_app/pages/teachers/student_cred.dart';
import 'package:education_app/models/class.dart';
import 'package:education_app/utils/dependencies.dart';
import 'package:education_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'base_url.dart';

class StatsController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  final classesUrl = Uri.parse('$baseUrl/api/teachers/get-classes');

  final RxList<SchoolClass> classes = <SchoolClass>[].obs;

  final RxList<Student> students = <Student>[].obs;

  final RxList<SkillPoint> skillHistory =
    <SkillPoint>[].obs;

  //For getting all students assigned to one teacher
  Future<void> getStudents() async {
    try {
      students.clear();
      final token = await authController.storage.read(key: 'token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/teachers/students'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        students.value = data.map((json) => Student.fromJson(json)).toList();
      } else {
        print(
          'Failed to get students: '
          '${response.statusCode}',
        );

        students.clear();
      }
    } catch (e) {
      print('Error getting students: $e');

      students.clear();
    }
  }

  Future<void> getStudentsFromClass(int classId) async {
    try {
      students.clear();

      final token = await authController.storage.read(key: 'token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/teachers/$classId/students'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        students.value = data.map((json) => Student.fromJson(json)).toList();
      } else {
        print(
          'Failed to get class students: '
          '${response.statusCode}',
        );

        students.clear();
      }
    } catch (e) {
      print('Error getting class students: $e');

      students.clear();
    }
  }

  Future<void> getClasses() async {
    try {
      final response = await http.get(
        classesUrl,
        headers: {
          'Authorization':
              'Bearer ${await authController.storage.read(key: 'token')}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        classes.value = data.map((json) => SchoolClass.fromJson(json)).toList();
      } else {
        print('Failed to get classes: ${response.body}');
      }
    } catch (e) {
      print('Error getting classes: $e');
    }
  }

  Future<bool> deleteClass(int classId) async {
    try {
      final token = await authController.storage.read(key: 'token');

      final response = await http.delete(
        Uri.parse('$baseUrl/api/teachers/$classId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete class status: ${response.statusCode}');
      print('Delete class body: ${response.body}');

      if (response.statusCode == 200) {
        // Remove it from the local class list
        classes.removeWhere((schoolClass) => schoolClass.id == classId);

        return true;
      }

      return false;
    } catch (e) {
      print('Error deleting class: $e');

      return false;
    }
  }

  Future<void> createClass(
    String className,
    List<Map<String, String>> students,
  ) async {
    try {
      final authController = Get.find<AuthController>();

      final token = await authController.storage.read(key: 'token');

      final response = await http.post(
        Uri.parse('$baseUrl/api/teachers/create-classes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': className, 'students': students}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Refresh classes
        await getClasses();

        // Show credentials
        Get.to(
          () => StudentCredentialsPage(
            className: data['class']['name'],
            students: List<Map<String, dynamic>>.from(data['students']),
          ),
        );
      } else {
        final data = jsonDecode(response.body);

        Get.snackbar('Error', data['message'] ?? 'Failed to create class');
      }
    } catch (e) {
      print('Error creating class: $e');

      Get.snackbar('Error', 'Something went wrong while creating the class');
    }
  }

  Future<bool> changeStudentPassword(int studentId, String password) async {
    try {

    final token =
        await authController.storage.read(
      key: 'token',
    );

    final response = await http.post(
      Uri.parse(
        '$baseUrl/api/students/$studentId/password',
      ),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },

      body: jsonEncode({
        'password': password,
      }),
    );

    print(
      'Change password status: '
      '${response.statusCode}',
    );

    print(
      'Change password body: '
      '${response.body}',
    );

    return response.statusCode == 200;

  } catch (e) {

    print(
      'Error changing student password: $e',
    );

    return false;
  }
  }

  Future<bool> changeStudentClass(
  int studentId,
  int classId,
) async {

  try {

    final token =
        await authController.storage.read(
      key: 'token',
    );

    final response = await http.post(
      Uri.parse(
        '$baseUrl/api/students/$studentId/class',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'classId': classId,
      }),
    );

    print('Change class status: ${response.statusCode}');
    print('Body: ${response.body}');

    return response.statusCode == 200;

  } catch (e) {

    print('Error changing student class: $e');

    return false;
  }
}

Future<void> getStudentStats(
  int studentId,
  String game,
) async {

  try {
    skillHistory.clear();
    final token =
        await authController.storage.read(
      key: 'token',
    );

    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/students/$studentId/stats/$game',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // print(
    //   'Stats status: ${response.statusCode}',
    // );

    // print(
    //   'Stats body: ${response.body}',
    // );

    if (response.statusCode == 200) {

      final List data =
          jsonDecode(response.body);

      skillHistory.value = data
          .map(
            (json) => SkillPoint.fromJson(json),
          )
          .toList();
    }

  } catch (e) {

    print(
      'Error getting student stats: $e',
    );
  }
}


Future<bool> deleteStudent(int studentId) async {

  try {

    final token =
        await authController.storage.read(
      key: 'token',
    );

    final response = await http.post(
      Uri.parse(
        '$baseUrl/api/students/$studentId/delete',
      ),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print(
      'Delete student status: '
      '${response.statusCode}',
    );

    print(
      'Delete student body: '
      '${response.body}',
    );

    return response.statusCode == 200;

  } catch (e) {

    print(
      'Error deleting student: $e',
    );

    return false;
  }
}
}
