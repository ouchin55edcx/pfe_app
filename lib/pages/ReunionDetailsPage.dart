import 'package:flutter/material.dart';
import '../models/reunion.dart';
import '../models/invited_proprietaire.dart';
import '../services/api_service.dart';
import 'InviteProprietairesPage.dart';

class ReunionDetailsPage extends StatefulWidget {
  final Reunion reunion;

  const ReunionDetailsPage({Key? key, required this.reunion}) : super(key: key);

  @override
  _ReunionDetailsPageState createState() => _ReunionDetailsPageState();
}

class _ReunionDetailsPageState extends State<ReunionDetailsPage> {
  bool _isLoading = true;
  List<InvitedProprietaire> _invitedProprietaires = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadInvitedProprietaires();
  }

  Future<void> _loadInvitedProprietaires() async {
    try {
      setState(() => _isLoading = true);
      final invitees = await ApiService.getReunionInvitees(widget.reunion.id);
      setState(() {
        _invitedProprietaires = invitees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la Réunion'),
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.reunion.title,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(widget.reunion.description),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 20),
                                  SizedBox(width: 8),
                                  Text(widget.reunion.location),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 20),
                                  SizedBox(width: 8),
                                  Text('${widget.reunion.date} ${widget.reunion.startTime} - ${widget.reunion.endTime}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Propriétaires Invités',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _invitedProprietaires.length,
                        itemBuilder: (context, index) {
                          final invitee = _invitedProprietaires[index];
                          return Card(
                            child: ListTile(
                              title: Text('${invitee.firstName} ${invitee.lastName}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Appt: ${invitee.apartmentNumber}'),
                                  Text('Status: ${invitee.status}'),
                                  Text('Présence: ${invitee.attendance}'),
                                ],
                              ),
                              trailing: Icon(
                                invitee.notificationSent
                                    ? Icons.mark_email_read
                                    : Icons.mark_email_unread,
                                color: invitee.notificationSent
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  InviteProprietairesPage(reunionId: widget.reunion.id),
            ),
          );
          if (result == true) {
            _loadInvitedProprietaires();
          }
        },
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        child: Icon(Icons.person_add),
      ),
    );
  }
}