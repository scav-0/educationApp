import 'package:education_app/components/app_bar.dart';
import 'package:education_app/pages/students/games/bracelet_game.dart';
import 'package:education_app/components/my_bottom_nav.dart';
import 'package:education_app/pages/students/games/hex_game.dart';
import 'package:education_app/pages/students/games/symbol_game.dart';
import 'package:education_app/utils/dependencies.dart';
import 'package:education_app/components/game_cards.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final AuthController authController = Get.find<AuthController>();

  void braceletGame() {
    Get.to(() => BraceletGamePage());
  }

  void symbolGame() {
    Get.to(() => SymbolGamePage());
  }

  void hexGame() {
    Get.to(() => HexGamePage());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/clouds1.jpg'),
          repeat: ImageRepeat.repeat,
        ),
      ),


      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: MyAppBar(title: "Home", isStudent: true),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const SizedBox(height: 50),

            Center(
              child: Text(
                "Welcome back ${authController.currentUser.value?.firstName}!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),

            const SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                gameCard(
                  title: "Bracelet",
                  icon: Container(
                    height: 80,
                    child: Image.asset('icons/beads.png', color: Colors.white),
                  ),
                  color: Colors.green,
                  onTap: braceletGame,
                ),

                const SizedBox(width: 50),

                gameCard(
                  title: "Honeycomb",
                  icon: Icon(
                    Icons.hexagon_outlined,
                    size: 80,
                    color: Colors.white,
                  ),
                  color: Colors.yellow.shade800,
                  onTap: hexGame,
                ),

              ],
            ),

            const SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                gameCard(
                  title: "Password",
                  icon: Icon(Icons.abc_outlined, size: 80, color: Colors.white),
                  color: Colors.red,
                  onTap: symbolGame,
                ),

              ],
            ),
          ],
        ),
        bottomNavigationBar: MyBottomNavBar(),
      ),
    );
  }
}
