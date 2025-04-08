import 'package:flutter/material.dart';
import '../models/dashboard_stats_model.dart';

class StatsSummaryWidget extends StatelessWidget {
  final Overview? overview;

  const StatsSummaryWidget({this.overview});

  @override
  Widget build(BuildContext context) {
    if (overview == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Propriétaires',
                  overview!.totalProprietaires.toString(),
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12), // Add spacing between cards
              Expanded(
                child: _buildStatCard(
                  context,
                  'Appartements',
                  overview!.totalAppartements.toString(),
                  Icons.apartment,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Charges',
                  overview!.totalCharges.toString(),
                  Icons.receipt_long,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12), // Add spacing between cards
              Expanded(
                child: _buildStatCard(
                  context,
                  'Paiements',
                  overview!.totalPayments.toString(),
                  Icons.payment,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
