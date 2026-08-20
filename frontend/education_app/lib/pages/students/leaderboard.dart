import 'package:education_app/components/app_bar.dart';
import 'package:education_app/components/my_bottom_nav.dart';
import 'package:education_app/utils/stats_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final StatsController statsController = Get.find<StatsController>();

  @override
  void initState() {
    super.initState();

    statsController.getLeaderboard();
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
        bottomNavigationBar: const MyBottomNavBar(),
        appBar: MyAppBar(title: "Leaderboard", isStudent: true),

        body: Obx(() {
          if (statsController.leaderboard.isEmpty) {
            return const Center(
              child: Text('No students found', style: TextStyle(fontSize: 20)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),

            itemCount: statsController.leaderboard.length,

            itemBuilder: (context, index) {
              final student = statsController.leaderboard[index];

              final firstName = student['first_name'];

              final lastName = student['last_name'];

              final games = int.parse(student['games_played'].toString());

              return Card(
                margin: const EdgeInsets.only(bottom: 12),

                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),

                  leading: _getPositionIcon(
                    index,
                    games,
                  ),

                  title: Text(
                    '$firstName $lastName',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  trailing: Text(
                    '$games games',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _getPositionIcon(int index, int games) {
  final position = statsController.leaderboard
          .where(
            (student) =>
                int.parse(
                  student['games_played'].toString(),
                ) >
                games,
          )
          .length +
      1;

  switch (position) {
    case 1:
      return const Icon(
        Icons.emoji_events,
        color: Colors.amber,
        size: 35,
      );

    case 2:
      return const Icon(
        Icons.emoji_events,
        color: Colors.grey,
        size: 32,
      );

    case 3:
      return const Icon(
        Icons.emoji_events,
        color: Colors.brown,
        size: 30,
      );

    default:
      return CircleAvatar(
        child: Text('$position'),
      );
  }
}
}
