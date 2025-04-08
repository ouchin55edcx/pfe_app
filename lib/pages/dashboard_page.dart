import 'package:flutter/material.dart';
import '../models/dashboard_stats_model.dart';
import '../services/api_service.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/stats_summary_widget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = true;
  String _errorMessage = '';
  DashboardStats? _dashboardStats;

  @override
  void initState() {
    super.initState();
    _fetchDashboardStats();
  }

  Future<void> _fetchDashboardStats() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final response = await ApiService.getDashboardStats();

      if (response['success'] == true) {
        setState(() {
          _dashboardStats = DashboardStats.fromJson(response['stats']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Erreur lors de la récupération des statistiques';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double horizontalPadding = screenSize.width * 0.04;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        elevation: 0,
        title: const Text(
          "Tableau de bord",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchDashboardStats,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: screenSize.height * 0.02,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCard(
                                'Aperçu général',
                                StatsSummaryWidget(overview: _dashboardStats?.overview),
                                constraints,
                              ),
                              SizedBox(height: screenSize.height * 0.025),
                              _buildCard(
                                'Montant total des impayés',
                                PieChartWidget(financial: _dashboardStats?.financial),
                                constraints,
                              ),
                              SizedBox(height: screenSize.height * 0.025),
                              _buildCard(
                                'Prochaines assemblées',
                                CalendarWidget(),
                                constraints,
                              ),
                              SizedBox(height: screenSize.height * 0.02),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, Widget child, BoxConstraints constraints) {
    final double borderRadius = constraints.maxWidth < 400 ? 12.0 : 15.0;
    final double padding = constraints.maxWidth < 400 ? 12.0 : 16.0;
    final double titleSize = constraints.maxWidth < 400 ? 16.0 : 18.0;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 46, 45, 45),
            ),
          ),
          SizedBox(height: padding * 0.6),
          child,
        ],
      ),
    );
  }
}
