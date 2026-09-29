import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/qa_coordinator_data/dashboard/dashboard_graph_model.dart';

class QaProductivityGraph extends StatelessWidget {
  final QaDashboardGraphModel dashboardData;

  const QaProductivityGraph({super.key, required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p8, vertical: AppPadding.p10),
      child: Row(
        children: [
          /// ── Weekly Chart ──
          Expanded(
            child: _ProductivityChart(
              title: 'Productivity (Weekly)',
              spots: List.generate(
                dashboardData.productivityWeekly.length,
                    (i) => FlSpot(i.toDouble(), dashboardData.productivityWeekly[i].count.toDouble()),
              ),
              xLabels: dashboardData.productivityWeekly.map((e) => e.day).toList(),
            ),
          ),

          const SizedBox(width: AppSize.s15),

          /// ── Monthly Chart ──
          Expanded(
            child: _ProductivityChart(
              title: 'Productivity (Monthly)',
              spots: List.generate(
                dashboardData.productivityMonthly.length,
                    (i) => FlSpot(i.toDouble(), dashboardData.productivityMonthly[i].count.toDouble()),
              ),
              xLabels: dashboardData.productivityMonthly.map((e) => e.month).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductivityChart extends StatelessWidget {
  final String title;
  final List<FlSpot> spots;
  final List<String> xLabels;

  const _ProductivityChart({
    required this.title,
    required this.spots,
    required this.xLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppPadding.p12, AppPadding.p14, AppPadding.p12, AppPadding.p8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: FontSize.s12,
              fontWeight: FontWeight.w700,
              color: ColorManager.textBlack,
            ),
          ),
          const SizedBox(height: AppSize.s12),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (xLabels.length - 1).toDouble(),
                minY: 0,
                maxY: 16,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.withOpacity(0.15),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 4,
                      reservedSize: 28,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10, color: Color(0xFF444444),
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (value != value.roundToDouble()) return const SizedBox.shrink();
                        if (index < 0 || index >= xLabels.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            xLabels[index],
                            style: const TextStyle(fontSize: 9,
                                color: Color(0xFF444444),
                            fontWeight: FontWeight.w700),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots.isEmpty
                        ? List.generate(xLabels.length, (i) => FlSpot(i.toDouble(), 0))
                        : spots,
                    isCurved: true,
                    curveSmoothness: 0.4,
                    color: const Color(0xFF26C6DA),
                    barWidth: 2,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: const Color(0xFF26C6DA),
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF26C6DA).withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}