import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/dashboard_stats_model.dart';

class PieChartWidget extends StatelessWidget {
  final Financial? financial;

  const PieChartWidget({this.financial});

  @override
  Widget build(BuildContext context) {
    // If no data is provided, show a loading indicator
    if (financial == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Calculate the total and paid values
    final int unpaid = financial!.unpaidCharges;
    final int paid = financial!.totalPaymentsAmount;
    final double total = (unpaid + paid).toDouble();

    // If there's no data, show a message
    if (total <= 0) {
      return const Center(
        child: Text('Aucune donnée disponible'),
      );
    }

    // Calculate percentages for the chart
    final double unpaidPercentage = unpaid / total * 100;
    final double paidPercentage = paid / total * 100;

    return Container(
      height: 200,
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: unpaidPercentage,
                    color: const Color.fromARGB(255, 87, 172, 215),
                    title: 'Impayés',
                    radius: 60,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: paidPercentage,
                    color: const Color.fromARGB(255, 75, 160, 173),
                    title: 'Payé',
                    radius: 60,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Impayés: ${unpaid} MAD', const Color.fromARGB(255, 87, 172, 215)),
              const SizedBox(width: 20),
              _buildLegendItem('Payé: ${paid} MAD', const Color.fromARGB(255, 75, 160, 173)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
