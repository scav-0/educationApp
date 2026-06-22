import 'package:education_app/pages/games/bracelet_game.dart';
import 'package:education_app/components/my_bottom_nav.dart';
import 'package:education_app/pages/games/symbol_game.dart';
import 'package:education_app/utils/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final AuthController authController = Get.find<AuthController>();

  void braceletGame() {
    Get.to(() => BraceletGamePage());
  }

  void symbolGame() {
    Get.to(()=> SymbolGamePage());
  }

  void game3() {}

  void game4() {}

  void logout() async {
    final result = await authController.signOut();

    if (result == 'success') {
      authController.isSignedIn.value =
          false; //Why doesnt it work without this?
      Get.snackbar(
        'Signed Out Successfully!',
        "",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar('Error', result, snackPosition: SnackPosition.BOTTOM);
    }
  }

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "Welcome back ${authController.signedInFirstName}!",
              
            ),
          ),
          const SizedBox(height: 50),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: braceletGame,
                icon: Icon(Icons.rocket_launch),
                iconSize: 100,
                color: Colors.green,
              ),
              IconButton(
                onPressed: game3,
                 icon: Icon(Icons.hexagon_outlined),
                 iconSize: 100,
                 color: Colors.purple,
                 ),
            ],
          ),
          const SizedBox(height: 50,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: symbolGame,
                icon: Icon(Icons.abc_outlined),
                color: Colors.pink,
                iconSize: 100,
              ),
              IconButton(
                onPressed: game4,
                 icon: Icon(Icons.accessible_rounded),
                 iconSize: 100,
                 color: Colors.blue,
                 ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: MyBottomNavBar(),
    );
  }
}
