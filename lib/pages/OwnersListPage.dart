import 'package:flutter/material.dart';
import '../models/proprietaire.dart';
import '../services/api_service.dart';

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
                ? Center(
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: _proprietaires.length,
                    itemBuilder: (context, index) {
                      final proprietaire = _proprietaires[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              proprietaire.firstName[0].toUpperCase(),
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.blue,
                          ),
                          title: Text('${proprietaire.firstName} ${proprietaire.lastName}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email: ${proprietaire.email}'),
                              Text('Appartement: ${proprietaire.apartmentNumber}'),
                            ],
                          ),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            // TODO: Navigate to proprietaire details page
                          },
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add proprietaire page
        },
        child: Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
      ),
    );
  }
}
