import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:education_app/pages/home_page.dart';
import 'package:education_app/pages/more_page.dart';

class MyBottomNavBar extends StatelessWidget {
  const MyBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
      ],
      onTap: (index) {
        if (index == 0) Get.to(() => HomePage());
        if (index == 1) Get.to(() => MorePage());
      },
    );
  }
}