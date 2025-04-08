import 'package:flutter/material.dart';
import '../models/proprietaire.dart';
import '../services/api_service.dart';

class InviteProprietairesPage extends StatefulWidget {
  final String reunionId;

  const InviteProprietairesPage({Key? key, required this.reunionId}) : super(key: key);

  @override
  _InviteProprietairesPageState createState() => _InviteProprietairesPageState();
}

class _InviteProprietairesPageState extends State<InviteProprietairesPage> {
  bool _isLoading = true;
  List<Proprietaire> _proprietaires = [];
  Set<String> _selectedProprietaires = {};
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProprietaires();
  }

  Future<void> _loadProprietaires() async {
    try {
      setState(() => _isLoading = true);
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

  Future<void> _inviteSelected() async {
    if (_selectedProprietaires.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner au moins un propriétaire')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
      await ApiService.inviteToReunion(
        widget.reunionId,
        _selectedProprietaires.toList(),
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inviter des Propriétaires',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _proprietaires.length,
                        itemBuilder: (context, index) {
                          final proprietaire = _proprietaires[index];
                          return CheckboxListTile(
                            title: Text('${proprietaire.firstName} ${proprietaire.lastName}'),
                            subtitle: Text(proprietaire.email),
                            value: _selectedProprietaires.contains(proprietaire.id),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedProprietaires.add(proprietaire.id);
                                } else {
                                  _selectedProprietaires.remove(proprietaire.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _inviteSelected,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 64, 66, 69),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text(
                          'Inviter les propriétaires sélectionnés',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}