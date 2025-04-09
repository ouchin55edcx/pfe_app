import 'package:flutter/material.dart';
import '../models/proprietaire.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ProprietaireProfilePage extends StatefulWidget {
  @override
  _ProprietaireProfilePageState createState() => _ProprietaireProfilePageState();
}

class _ProprietaireProfilePageState extends State<ProprietaireProfilePage> {
  bool _isLoading = true;
  String _errorMessage = '';
  Proprietaire? _proprietaire;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = AuthService.to.currentUser;
      if (user == null) {
        throw Exception('No user found');
      }

      print('Loading profile...'); // Debug log

      final proprietaire = await ApiService.getProprietaireProfile();
      setState(() {
        _proprietaire = proprietaire;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profile: $e'); // Debug log
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
          'Mon Profil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _proprietaire == null
                  ? Center(child: Text('No profile data found'))
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[300],
                              child: Text(
                                '${_proprietaire!.firstName[0]}${_proprietaire!.lastName[0]}',
                                style: TextStyle(
                                  fontSize: 32,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          _buildInfoCard(
                            title: 'Informations Personnelles',
                            children: [
                              _buildInfoRow('Nom', '${_proprietaire!.firstName} ${_proprietaire!.lastName}'),
                              _buildInfoRow('Email', _proprietaire!.email),
                              _buildInfoRow('Téléphone', _proprietaire!.phoneNumber),
                              _buildInfoRow('Rôle', _proprietaire!.role),
                            ],
                          ),
                          SizedBox(height: 16),
                          _buildInfoCard(
                            title: 'Informations Appartement',
                            children: [
                              _buildInfoRow('Numéro d\'appartement', _proprietaire!.apartmentNumber),
                              _buildInfoRow('Date de propriété', _proprietaire!.ownershipDate),
                              if (_proprietaire!.buildingId != null)
                                _buildInfoRow('ID Bâtiment', _proprietaire!.buildingId!),
                            ],
                          ),
                          SizedBox(height: 16),
                          _buildInfoCard(
                            title: 'Informations Système',
                            children: [
                              _buildInfoRow('Créé le', _proprietaire!.createdAt),
                              _buildInfoRow('Dernière mise à jour', _proprietaire!.updatedAt),
                            ],
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
