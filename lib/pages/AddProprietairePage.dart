import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class AddProprietairePage extends StatefulWidget {
  @override
  _AddProprietairePageState createState() => _AddProprietairePageState();
}

class _AddProprietairePageState extends State<AddProprietairePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ownershipDateController = TextEditingController();

  String? _selectedApartmentId;
  List<Map<String, dynamic>> _apartments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadApartments();
  }

  Future<void> _loadApartments() async {
    try {
      setState(() => _isLoading = true);
      final apartments = await ApiService.getAvailableApartments();
      setState(() {
        _apartments = apartments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedApartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
      
      await ApiService.createProprietaire({
        'email': _emailController.text,
        'password': _passwordController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'phoneNumber': _phoneController.text,
        'appartementId': _selectedApartmentId,
        'ownershipDate': _ownershipDateController.text,
      });

      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Proprietaire'),
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
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                    ),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(labelText: 'First Name'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                    ),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(labelText: 'Last Name'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedApartmentId,
                      decoration: InputDecoration(labelText: 'Apartment'),
                      items: _apartments.map<DropdownMenuItem<String>>((apartment) {
                        return DropdownMenuItem<String>(
                          value: apartment['id'].toString(),
                          child: Text('Apartment ${apartment['numero']} - Floor ${apartment['etage']}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedApartmentId = value);
                      },
                      validator: (value) =>
                          value == null ? 'Please select an apartment' : null,
                    ),
                    TextFormField(
                      controller: _ownershipDateController,
                      decoration: InputDecoration(
                        labelText: 'Ownership Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() {
                            _ownershipDateController.text =
                                date.toIso8601String();
                          });
                        }
                      },
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Add Proprietaire'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
