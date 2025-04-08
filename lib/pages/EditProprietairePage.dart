import 'package:flutter/material.dart';
import '../models/proprietaire.dart';
import '../services/api_service.dart';

class EditProprietairePage extends StatefulWidget {
  final Proprietaire proprietaire;

  EditProprietairePage({required this.proprietaire});

  @override
  _EditProprietairePageState createState() => _EditProprietairePageState();
}

class _EditProprietairePageState extends State<EditProprietairePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.proprietaire.firstName);
    _lastNameController = TextEditingController(text: widget.proprietaire.lastName);
    _phoneController = TextEditingController(text: widget.proprietaire.phoneNumber);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() => _isLoading = true);

      final updateData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'phoneNumber': _phoneController.text,
      };

      final updatedProprietaire = await ApiService.updateProprietaire(
        widget.proprietaire.id,
        updateData,
      );

      Navigator.pop(context, updatedProprietaire);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Proprietaire'),
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(labelText: 'First Name'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(labelText: 'Last Name'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}