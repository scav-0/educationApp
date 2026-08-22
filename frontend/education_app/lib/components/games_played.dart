import 'package:education_app/utils/stats_controller.dart';
import 'package:education_app/utils/teacher_colours.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


StatsController statsController = Get.find<StatsController>();
Widget gamesPlayedChart() {

  if (statsController.gamesPerDay.isEmpty) {
    return const Center(
      child: Text('No game activity yet'),
    );
  }

  final maxGames = statsController.gamesPerDay
      .map((e) => e.games)
      .reduce((a, b) => a > b ? a : b);

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),

    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          blurRadius: 8,
          offset: Offset(0, 4),
          color: Colors.black12,
        ),
      ],
    ),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        const Text(
          'Games Played',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Games completed over the last 7 days',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 25),

        SizedBox(
          height: 350,

          child: BarChart(
            BarChartData(

              maxY: maxGames == 0
                  ? 5
                  : maxGames.toDouble() + 1,

              alignment:
                  BarChartAlignment.spaceAround,

              gridData: FlGridData(
                show: true,
              ),

              borderData: FlBorderData(
                show: true,
              ),

              titlesData: FlTitlesData(

                topTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),

                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),

                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    interval: 5,
                  ),
                ),

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,

                    getTitlesWidget:
                        (value, meta) {

                      final index =
                          value.toInt();

                      if (index < 0 ||
                          index >=
                              statsController
                                  .gamesPerDay
                                  .length) {
                        return const SizedBox();
                      }

                      final date =
                          statsController
                              .gamesPerDay[index]
                              .date;

                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          top: 8,
                        ),

                        child: Text(
                          DateFormat('EEE')
                              .format(date),
                          style:
                              const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              barGroups: List.generate(
                statsController.gamesPerDay.length,
                (index) {

                  final games =
                      statsController
                          .gamesPerDay[index]
                          .games;

                  return BarChartGroupData(
                    x: index,

                    barRods: [
                      BarChartRodData(
                        toY: games.toDouble(),
                        width: 50,
                        color: TeacherColours.primaryColor,
                        borderRadius:
                            BorderRadius.circular(5),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    ),
  );
}