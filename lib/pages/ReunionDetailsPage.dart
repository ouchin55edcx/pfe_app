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
  bool _isUpdating = false;
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

  Future<void> _updateAttendance(String proprietaireId, String newAttendance) async {
    try {
      setState(() => _isUpdating = true);
      await ApiService.updateAttendance(widget.reunion.id, proprietaireId, newAttendance);
      await _loadInvitedProprietaires(); // Reload the list after update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Présence mise à jour avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Widget _buildAttendanceControls(InvitedProprietaire invitee) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.check_circle,
            color: invitee.attendance == 'present' ? Colors.green : Colors.grey,
          ),
          onPressed: _isUpdating
              ? null
              : () => _updateAttendance(invitee.proprietaireId, 'present'),
          tooltip: 'Présent',
        ),
        IconButton(
          icon: Icon(
            Icons.cancel,
            color: invitee.attendance == 'absent' ? Colors.red : Colors.grey,
          ),
          onPressed: _isUpdating
              ? null
              : () => _updateAttendance(invitee.proprietaireId, 'absent'),
          tooltip: 'Absent',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la Réunion'),
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
      ),
      body: Stack(
        children: [
          _isLoading
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
                                  title: Text(
                                    '${invitee.firstName} ${invitee.lastName}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Appt: ${invitee.apartmentNumber}'),
                                      Text('Status: ${invitee.status}'),
                                      Row(
                                        children: [
                                          Text('Présence: '),
                                          Text(
                                            invitee.attendance == 'present'
                                                ? 'Présent'
                                                : invitee.attendance == 'absent'
                                                    ? 'Absent'
                                                    : 'En attente',
                                            style: TextStyle(
                                              color: invitee.attendance == 'present'
                                                  ? Colors.green
                                                  : invitee.attendance == 'absent'
                                                      ? Colors.red
                                                      : Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildAttendanceControls(invitee),
                                      Icon(
                                        invitee.notificationSent
                                            ? Icons.mark_email_read
                                            : Icons.mark_email_unread,
                                        color: invitee.notificationSent
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
          if (_isUpdating)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isUpdating
            ? null
            : () async {
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
        backgroundColor: _isUpdating
            ? Colors.grey
            : const Color.fromARGB(255, 64, 66, 69),
        child: Icon(Icons.person_add),
      ),
    );
  }
}
