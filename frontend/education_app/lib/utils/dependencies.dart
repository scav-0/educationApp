import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'base_url.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthController extends GetxController {
  final storage = FlutterSecureStorage();
  final signInUrl = Uri.parse('$baseUrl/api/users/sign-in');
  final signOutUrl = Uri.parse('$baseUrl/api/users/sign-out');

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    
    final savedToken = await storage.read(
      key: 'token',
    ); 
    if (savedToken != null) {
      token.value = savedToken;
      isSignedIn.value = true;
    }
  }

  RxBool isSignedIn = false.obs;
  RxString token = ''.obs;
  RxString signedInUsername = ''.obs;
  RxString signedInFirstName= ''.obs;
  RxString signedInLastName = ''.obs;

  Future<String> signIn(String username, String password) async {
    try {
      var signInData = await http.post(
        signInUrl,
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
        signedInUsername.value = jsonSignInData['username'];
        signedInFirstName.value = jsonSignInData['first_name'];
        signedInLastName.value = jsonSignInData['last_name'];
        await storage.write(key: 'token', value: jsonSignInData['token']); //save the token in flutter for saving state
        return 'success';
      } else {
        return jsonDecode(signInData.body)['message'].toString();
      }
    } catch (error) {
      return '$error';
    }
  }

  Future<String> signOut() async {
    try{
        isSignedIn.value = false;
        token.value = '';
        signedInUsername.value = '';
        await storage.deleteAll();
        return 'success';
      
    }catch(error){
      return '$error';
    }
  }
}
