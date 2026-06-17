import 'package:education_app/pages/games/bracelet_game.dart';
import 'package:education_app/components/my_bottom_nav.dart';
import 'package:education_app/utils/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final AuthController authController = Get.find<AuthController>();

  void braceletGame() {
      Get.to(() => BraceletGamePage());
  }

  void logout() async {
    final result = await authController.signOut();

    if (result == 'success') {
      authController.isSignedIn.value = false;//Why doesnt it work without this?
      Get.snackbar('Signed Out Successfully!', "", snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Error', result, snackPosition: SnackPosition.BOTTOM);
    }
  } //To create sign out

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        
        title: Text("Home"),
        actions: [
          //logout button
          IconButton(onPressed: logout, icon: Icon(Icons.logout)),
        ],
      ),
      body: Column(
        children: [
          Center(child: Text("Logged In!\nWelcome back ${authController.signedInFirstName}!")),
          const SizedBox(height: 50),
          Center(child: IconButton(onPressed: braceletGame, icon: Icon(Icons.rocket_launch )))
        ],
      ),
      bottomNavigationBar: MyBottomNavBar(),
    );
  }
}
