import 'package:flutter/material.dart';
import '../models/reunion.dart';
import '../services/api_service.dart';
import '../widgets/NotificationBell.dart';
import 'UserProfilePage.dart';
import '../widgets/user_avatar.dart';
import 'notifications_page.dart';
import 'package:intl/intl.dart';
import 'AddReunionPage.dart';


import 'ReunionDetailsPage.dart';
import 'InviteProprietairesPage.dart';
class MeetingListPage extends StatefulWidget {
  const MeetingListPage({super.key});

  @override
  State<MeetingListPage> createState() => _MeetingListPageState();
}

class _MeetingListPageState extends State<MeetingListPage> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<Reunion> _reunions = [];

  @override
  void initState() {
    super.initState();
    _fetchReunions();
  }

  Future<void> _fetchReunions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final reunions = await ApiService.getMyReunions();
      setState(() {
        _reunions = reunions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'scheduled':
        backgroundColor = Colors.blue;
        displayText = 'Programmée';
        break;
      case 'completed':
        backgroundColor = Colors.green;
        displayText = 'Terminée';
        break;
      case 'cancelled':
        backgroundColor = Colors.red;
        displayText = 'Annulée';
        break;
      default:
        backgroundColor = Colors.grey;
        displayText = status;
    }

    return Chip(
      label: Text(
        displayText,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Réunions",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
            child: NotificationBell(),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfilePage()),
              );
            },
            child: UserAvatar(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchReunions,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : _reunions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              "Aucune réunion enregistrée",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _reunions.length,
                        itemBuilder: (context, index) {
                          final reunion = _reunions[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          reunion.title,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      _buildStatusChip(reunion.status),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                      SizedBox(width: 8),
                                      Text(_formatDate(reunion.date)),
                                      SizedBox(width: 16),
                                      Icon(Icons.access_time, size: 16, color: Colors.grey),
                                      SizedBox(width: 8),
                                      Text('${reunion.startTime} - ${reunion.endTime}'),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                                      SizedBox(width: 8),
                                      Text(reunion.location),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    reunion.description,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ReunionDetailsPage(reunion: reunion),
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.visibility),
                                        label: Text('Voir détails'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(255, 64, 66, 69),
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => InviteProprietairesPage(reunionId: reunion.id),
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.person_add),
                                        label: Text('Inviter'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(255, 75, 160, 173),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddReunionPage()),
          );
          if (result == true) {
            _fetchReunions(); // Refresh the list after adding a new reunion
          }
        },
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
