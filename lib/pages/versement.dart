import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class Charge {
  final String id;
  final String titre;
  final String description;
  final double montant;
  final String dateEcheance;
  final String statut;
  final String categorie;
  final double montantPaye;
  final double montantRestant;

  Charge({
    required this.id,
    required this.titre,
    required this.description,
    required this.montant,
    required this.dateEcheance,
    required this.statut,
    required this.categorie,
    required this.montantPaye,
    required this.montantRestant,
  });

  factory Charge.fromJson(Map<String, dynamic> json) {
    return Charge(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      montant: json['montant'].toDouble(),
      dateEcheance: json['dateEcheance'],
      statut: json['statut'],
      categorie: json['categorie'],
      montantPaye: json['montantPaye'].toDouble(),
      montantRestant: json['montantRestant'].toDouble(),
    );
  }
}

class VersementScreen extends StatefulWidget {
  @override
  _VersementScreenState createState() => _VersementScreenState();
}

class _VersementScreenState extends State<VersementScreen> {
  String selectedImm = "8";
  String selectedAppt = "8";
  List<Charge> charges = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCharges();
  }

  Future<void> _fetchCharges() async {
    try {
      setState(() => isLoading = true);
      final response = await ApiService.get('/charges');
      
      if (response['success'] == true) {
        final chargesList = (response['charges'] as List)
            .map((charge) => Charge.fromJson(charge))
            .toList();
        setState(() {
          charges = chargesList;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load charges';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'payé':
        return Colors.green;
      case 'non payé':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GESTION SYNDICAT"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedImm,
                    items: ["8", "9", "10"].map((e) => DropdownMenuItem(value: e, child: Text("Immeuble $e"))).toList(),
                    onChanged: (val) => setState(() => selectedImm = val!),
                    decoration: InputDecoration(labelText: "Num_IMM", border: OutlineInputBorder()),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedAppt,
                    items: ["8", "9", "10"].map((e) => DropdownMenuItem(value: e, child: Text("Appt $e"))).toList(),
                    onChanged: (val) => setState(() => selectedAppt = val!),
                    decoration: InputDecoration(labelText: "Num_Appt", border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                      ? Center(child: Text(errorMessage))
                      : charges.isEmpty
                          ? Center(child: Text("Aucune charge trouvée"))
                          : ListView.builder(
                              itemCount: charges.length,
                              itemBuilder: (context, index) {
                                final charge = charges[index];
                                return Card(
                                  elevation: 3,
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    title: Text(
                                      charge.titre,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(charge.description),
                                        Text(
                                          "Échéance: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(charge.dateEcheance))}",
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                        Text(
                                          "Montant: ${charge.montant} DH | Restant: ${charge.montantRestant} DH",
                                          style: TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    trailing: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(charge.statut),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        charge.statut,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AjouterVersementScreen(
                      onAjout: (versement) {
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              child: Text("Effectuer un versement"),
            ),
          ],
        ),
      ),
    );
  }
}

class AjouterVersementScreen extends StatefulWidget {
  final Function(Map<String, String>) onAjout;
  AjouterVersementScreen({required this.onAjout});

  @override
  _AjouterVersementScreenState createState() => _AjouterVersementScreenState();
}

class _AjouterVersementScreenState extends State<AjouterVersementScreen> {
  final _formKey = GlobalKey<FormState>();
  String montant = "";
  String mode = "Espèce";
  String reference = "";
  String date = "";

  void _validerVersement() {
    if (_formKey.currentState!.validate()) {
      widget.onAjout({"date": date, "montant": montant, "mode": mode, "ref": reference});
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ajouter un Versement"), backgroundColor: Colors.blue.shade700),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Date", border: OutlineInputBorder()),
                onChanged: (val) => date = val,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: "Montant", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onChanged: (val) => montant = val,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: mode,
                items: ["Espèce", "Chèque", "Virement"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => mode = val!),
                decoration: InputDecoration(labelText: "Mode de paiement", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: "Référence", border: OutlineInputBorder()),
                onChanged: (val) => reference = val,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _validerVersement,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
                child: Text("Valider"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
