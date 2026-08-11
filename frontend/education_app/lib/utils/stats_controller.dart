import 'package:education_app/pages/teachers/student_cred.dart';
import 'package:education_app/utils/class.dart';
import 'package:education_app/utils/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'base_url.dart';

class StatsController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  final classesUrl = Uri.parse('$baseUrl/api/teachers/get-classes');

  final RxList<SchoolClass> classes = <SchoolClass>[].obs;

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

      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

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
}
