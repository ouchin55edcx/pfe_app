import 'package:flutter/material.dart';
import '../models/proprietaire.dart';
import '../services/api_service.dart';
import './AddProprietairePage.dart';
import './EditProprietairePage.dart';

class OwnersListPage extends StatefulWidget {
  @override
  _OwnersListPageState createState() => _OwnersListPageState();
}

class _OwnersListPageState extends State<OwnersListPage> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<Proprietaire> _proprietaires = [];

  @override
  void initState() {
    super.initState();
    _fetchProprietaires();
  }

  Future<void> _fetchProprietaires() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final proprietaires = await ApiService.getAllProprietaires();
      setState(() {
        _proprietaires = proprietaires;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProprietaire(String proprietaireId) async {
    try {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete this proprietaire?'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  Navigator.of(context).pop();
                  setState(() => _isLoading = true);
                  try {
                    await ApiService.deleteProprietaire(proprietaireId);
                    await _fetchProprietaires(); // Refresh the list
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Proprietaire deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      ),
                    );
                    setState(() => _isLoading = false);
                  }
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editProprietaire(Proprietaire proprietaire) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProprietairePage(proprietaire: proprietaire),
      ),
    );

    if (result != null && result is Proprietaire) {
      await _fetchProprietaires(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Proprietaire updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Liste des Propriétaires',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProprietaires,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : ListView.builder(
                    itemCount: _proprietaires.length,
                    itemBuilder: (context, index) {
                      final proprietaire = _proprietaires[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              proprietaire.firstName[0].toUpperCase(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            '${proprietaire.firstName} ${proprietaire.lastName}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email: ${proprietaire.email}'),
                              Text('Phone: ${proprietaire.phoneNumber}'),
                              Text('Apartment: ${proprietaire.apartmentNumber}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editProprietaire(proprietaire),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteProprietaire(proprietaire.id),
                              ),
                            ],
                          ),
                          onTap: () {
                            // TODO: Navigate to proprietaire details page
                          },
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProprietairePage()),
          );
          if (result == true) {
            _fetchProprietaires(); // Refresh the list
          }
        },
        child: Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
      ),
    );
  }
}
