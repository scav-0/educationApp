import 'package:education_app/models/user.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'base_url.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthController extends GetxController {
  final storage = FlutterSecureStorage();
  final studentSignInUrl = Uri.parse('$baseUrl/api/students/sign-in');
  final teacherSignInUrl = Uri.parse('$baseUrl/api/teachers/sign-in');

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final savedToken = await storage.read(key: 'token');
    if (savedToken != null) {
      token.value = savedToken;
      isSignedIn.value = true;

      final role = await storage.read(key: 'role');

      if (role == 'student') {
        currentUser.value = Student(
          id: int.parse(await storage.read(key: 'id') ?? '0'),
          firstName: await storage.read(key: 'first_name') ?? '',
          lastName: await storage.read(key: 'last_name') ?? '',
          username: await storage.read(key: 'username') ?? '',
        );
      } else if (role == 'teacher') {
        currentUser.value = Teacher(
          id: int.parse(await storage.read(key: 'id') ?? '0'),
          firstName: await storage.read(key: 'first_name') ?? '',
          lastName: await storage.read(key: 'last_name') ?? '',
          email: await storage.read(key: 'email') ?? '',
        );
      }

      // final idString = await storage.read(key: 'id') ?? '0';//needs to be parsed since it returns a string!
      // signedInId.value = int.parse(idString);
      // signedInUsername.value = await storage.read(key: 'username') ?? '';
      // signedInFirstName.value = await storage.read(key: 'first_name') ?? '';
      // signedInLastName.value = await storage.read(key: 'last_name') ?? '';
    } else {
      isSignedIn.value = false;
    }
  }

  RxBool isSignedIn = false.obs;
  RxString token = ''.obs;
  // RxString signedInUsername = ''.obs;
  // RxString signedInFirstName = ''.obs;
  // RxString signedInLastName = ''.obs;
  // RxInt signedInId = 0.obs;

  Rxn<User> currentUser = Rxn<User>();

  Future<String> teacherSignIn(String email, String password) async {
    try {
      var signInData = await http.post(
        teacherSignInUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'password': password.trim()}),
      );
      if (signInData.statusCode == 200) {
        final jsonSignInData = jsonDecode(signInData.body);

        isSignedIn.value = true;
        token.value = jsonSignInData['token'];

        currentUser.value = Teacher.fromJson(jsonSignInData);

        await storage.write(key: 'token', value: jsonSignInData['token']);

        await storage.write(key: 'role', value: 'teacher');
        await storage.write(key: 'id', value: jsonSignInData['id'].toString());
        await storage.write(key: 'email', value: jsonSignInData['email']);
        await storage.write(
          key: 'first_name',
          value: jsonSignInData['first_name'],
        );
        await storage.write(
          key: 'last_name',
          value: jsonSignInData['last_name'],
        );
        return 'success';
      } else {
        return jsonDecode(signInData.body)['message'].toString();
      }
    } catch (error) {
      return '$error';
    }
  }

  Future<String> signIn(String username, String password) async {
    try {
      var signInData = await http.post(
        studentSignInUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username.trim(),
          'password': password.trim(),
        }),
      );
      //when api responds -> if succesfull sends status code of 200
      if (signInData.statusCode == 200) {
        final jsonSignInData = jsonDecode(signInData.body);

        isSignedIn.value = true;
        token.value = jsonSignInData['token'];

        currentUser.value = Student.fromJson(jsonSignInData);
        // signedInId.value = jsonSignInData['id'];
        // signedInUsername.value = jsonSignInData['username'];
        // signedInFirstName.value = jsonSignInData['first_name'];
        // signedInLastName.value = jsonSignInData['last_name'];

        await storage.write(key: 'token', value: jsonSignInData['token']);

        await storage.write(key: 'role', value: 'student');
        await storage.write(key: 'id', value: jsonSignInData['id'].toString());
        await storage.write(key: 'username', value: jsonSignInData['username']);
        await storage.write(
          key: 'first_name',
          value: jsonSignInData['first_name'],
        );
        await storage.write(
          key: 'last_name',
          value: jsonSignInData['last_name'],
        );
        return 'success';
      } else {
        return jsonDecode(signInData.body)['message'].toString();
      }
    } catch (error) {
      return '$error';
    }
  }

  Future<String> createStudent(
  String firstName,
  String lastName,
  String password,
  int? classId,
) async {
  try {
    final token = await storage.read(key: 'token');

    final response = await http.post(
      Uri.parse('$baseUrl/api/students/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'password': password,
        'class_id': classId,
      }),
    );

    if (response.statusCode == 201) {
      return 'success';
    }

    final data = jsonDecode(response.body);
    print(data['message']);
    return data['message'] ?? 'Failed to create student';

  } catch (e, stackTrace) {
    print('Error creating student: $e');
  print(stackTrace);

  return 'Unable to connect to server';
  }
}

  Future<String> signOut() async {
    try {
      isSignedIn.value = false;
      token.value = '';
      currentUser.value = null;
      await storage.deleteAll();
      return 'success';
    } catch (error) {
      return '$error';
    }
  }

  Future<String> createTeacherAccount(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/teachers/register'),

        headers: {'Content-Type': 'application/json'},

        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        return "success";
      }

      final data = jsonDecode(response.body);

      return data['message'] ?? 'Failed to create account';
    } catch (e) {
      print('Error creating teacher account: $e');

      return 'Unable to connect to the server';
    }
  }
}
