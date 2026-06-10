import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<double> dailyExpenses;
  final List<String> weekDays;

  const WeeklyBarChart({
    Key? key,
    required this.dailyExpenses,
    required this.weekDays,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey,
            tooltipRoundedRadius: 8,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < weekDays.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      weekDays[index],
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value / 1000).toStringAsFixed(0)}K',
                  style: const TextStyle(color: Colors.black54, fontSize: 10),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barGroups: _buildBarGroups(),
      ),
    );
  }

  double _getMaxY() {
    if (dailyExpenses.isEmpty) return 100000;
    final max = dailyExpenses.reduce((a, b) => a > b ? a : b);
    return max * 1.2;
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(
      dailyExpenses.length,
      (index) => BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: dailyExpenses[index],
            color: Colors.green.shade400,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryData;
  final Map<String, Color> categoryColors;

  const CategoryPieChart({
    Key? key,
    required this.categoryData,
    required this.categoryColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (categoryData.isEmpty) {
      return const Center(
        child: Text('Tidak ada data', style: TextStyle(color: Colors.black54)),
      );
    }

    return PieChart(
      PieChartData(
        sections: _buildSections(),
        centerSpaceRadius: 40,
        sectionsSpace: 0,
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final total = categoryData.values.fold(0.0, (sum, val) => sum + val);
    int colorIndex = 0;

    return categoryData.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final colors = [
        Colors.orange,
        Colors.blue,
        Colors.purple,
        Colors.green,
        Colors.red
      ];
      final color =
          categoryColors[entry.key] ?? colors[colorIndex % colors.length];

      colorIndex++;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

class ExpenseLineChart extends StatelessWidget {
  final List<double> dailyExpenses;
  final List<String> dates;

  const ExpenseLineChart({
    Key? key,
    required this.dailyExpenses,
    required this.dates,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < dates.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      dates[index],
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value / 1000).toStringAsFixed(0)}K',
                  style: const TextStyle(color: Colors.black54, fontSize: 10),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              dailyExpenses.length,
              (index) => FlSpot(index.toDouble(), dailyExpenses[index]),
            ),
            isCurved: true,
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
            ),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade400.withValues(alpha: 0.3),
                  Colors.green.shade600.withValues(alpha: 0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
