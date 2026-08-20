import 'package:education_app/utils/stats_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildPKnowGraph() {
  StatsController statsController = Get.find<StatsController>();

  return Obx(() {
    final points = statsController.skillHistory;

    if (points.isEmpty) {
      return const Center(child: Text('No data available for this game.'));
    }

    return LineChart(
      LineChartData(

        backgroundColor: Colors.grey[200],
        minY: 0,
        maxY: 1,

        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final game = spot.x.toInt();
                final pKnow = spot.y;

                return LineTooltipItem(
                  'Game $game\n'
                  'P(known): ${pKnow.toStringAsFixed(2)}',
                  const TextStyle(fontSize: 14),
                );
              }).toList();
            },
          ),
        ),

        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: const Text('P(known)'),
            axisNameSize: 30,

            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,

              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),

          // Don't show labels on the top
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          // Don't show labels on the right
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          bottomTitles: AxisTitles(
            axisNameWidget: const Text('Attempt'),
            axisNameSize: 30,

            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,

              interval: 1,

              getTitlesWidget: (value, meta) {
                final attempt = value.toInt();

                if (attempt < 1 || attempt > points.length) {
                  return const SizedBox();
                }

                return Text('$attempt', style: const TextStyle(fontSize: 12));
              },
            ),
          ),
        ),

        lineBarsData: [
          LineChartBarData(
            spots: List.generate(points.length, (index) {
              return FlSpot(
                (index + 1).toDouble(), // Attempt number: 1, 2, 3...
                points[index].pKnow, // P(know)
              );
            }),

            isCurved: true,

            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  });
}
