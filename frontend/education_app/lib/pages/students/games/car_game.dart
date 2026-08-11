import 'package:education_app/components/my_bottom_nav.dart';
import 'package:education_app/utils/skill_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CarGamePage extends StatefulWidget {
  const CarGamePage({super.key});

  @override
  State<CarGamePage> createState() => CarGameState();
}

class CarGameState extends State<CarGamePage> {
  final SkillController skillController = Get.find<SkillController>();
  int attemptCount = 0;
  late DateTime questionStartTime;
  late bool firstAttempt;
  bool isLoading = true;

  //Answer list
  //what player sees/guess list

  @override
  void initState() {
    super.initState();
    loadAndGenerate();
  }

  Future<void> loadAndGenerate() async {
    await skillController.fetchSkills();
    generateQuestion();
    setState(() {
      isLoading=false;
      attemptCount = 1;
      questionStartTime = DateTime.now();
      firstAttempt = true;
    });
  }

  void generateQuestion(){
    //TO-DO QUESTION GENERATION
    setState(() {
      

    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/clouds1.jpg'),
          repeat: ImageRepeat.repeat, // tiles in both directions
          
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: const MyBottomNavBar(),
        body: Center(
          //Statement text
          
          //cars


          //submut button


        )
      )
    );
  
  }
}