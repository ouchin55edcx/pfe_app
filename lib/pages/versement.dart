import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'add_charge_page.dart';

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

class Payment {
  final String id;
  final double montant;
  final String datePayment;
  final String methodePaiement;
  final String reference;
  final String chargeId;
  final String proprietaireId;
  final String syndicId;
  final String statut;
  final bool isPartial;
  final double remainingAmount;
  final String notes;

  Payment({
    required this.id,
    required this.montant,
    required this.datePayment,
    required this.methodePaiement,
    required this.reference,
    required this.chargeId,
    required this.proprietaireId,
    required this.syndicId,
    required this.statut,
    required this.isPartial,
    required this.remainingAmount,
    required this.notes,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      montant: json['montant'].toDouble(),
      datePayment: json['datePayment'],
      methodePaiement: json['methodePaiement'],
      reference: json['reference'],
      chargeId: json['chargeId'],
      proprietaireId: json['proprietaireId'],
      syndicId: json['syndicId'],
      statut: json['statut'],
      isPartial: json['isPartial'],
      remainingAmount: json['remainingAmount'].toDouble(),
      notes: json['notes'] ?? '',
    );
  }
}

class VersementScreen extends StatefulWidget {
  @override
  _VersementScreenState createState() => _VersementScreenState();
}

class _VersementScreenState extends State<VersementScreen> with SingleTickerProviderStateMixin {
  List<Charge> charges = [];
  List<Payment> payments = [];
  bool isLoading = true;
  String errorMessage = '';
  TabController? _tabController; // Make it nullable

  @override
  void initState() {
    super.initState();
    // Initialize the TabController here
    _tabController = TabController(length: 2, vsync: this);
    _fetchCharges();
    _fetchPayments();
  }

  @override
  void dispose() {
    // Dispose the controller
    _tabController?.dispose();
    super.dispose();
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

  Future<void> _fetchPayments() async {
    try {
      final response = await ApiService.get('/payments');
      
      if (response['success'] == true) {
        final paymentsList = (response['payments'] as List)
            .map((payment) => Payment.fromJson(payment))
            .toList();
        setState(() {
          payments = paymentsList;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load payments';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
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

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmé':
        return Colors.green;
      case 'en attente':
        return Colors.orange;
      case 'refusé':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if controller is initialized
    if (_tabController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gestion Financière",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController!, // Use ! operator since we checked it's not null
          tabs: const [
            Tab(text: 'Charges'),
            Tab(text: 'Paiements'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
      ),
      body: TabBarView(
        controller: _tabController!, // Use ! operator since we checked it's not null
        children: [
          _buildChargesTab(),
          _buildPaymentsTab(),
        ],
      ),
    );
  }

  Widget _buildPaymentsTab() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : payments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.payment, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('Aucun paiement trouvé'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: payments.length,
                            itemBuilder: (context, index) {
                              final payment = payments[index];
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Montant: ${payment.montant} MAD',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getPaymentStatusColor(payment.statut),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              payment.statut,
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text('Date: ${payment.datePayment}'),
                                      Text('Méthode: ${payment.methodePaiement}'),
                                      Text('Référence: ${payment.reference}'),
                                      if (payment.isPartial)
                                        Text('Montant restant: ${payment.remainingAmount} MAD'),
                                      if (payment.notes.isNotEmpty)
                                        Text('Notes: ${payment.notes}'),
                                      if (payment.statut.toLowerCase() == 'en attente')
                                        Padding(
                                          padding: EdgeInsets.only(top: 12),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () async {
                                                  try {
                                                    await ApiService.confirmPayment(payment.id);
                                                    // Refresh the payments list
                                                    await _fetchPayments();
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Paiement confirmé avec succès'),
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
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: Text('Confirmer'),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargesTab() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : charges.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "Aucune charge trouvée",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: charges.length,
                            itemBuilder: (context, index) {
                              final charge = charges[index];
                              return Card(
                                elevation: 3,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16),
                                  title: Text(
                                    charge.titre,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 8),
                                      Text(
                                        charge.description,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                          SizedBox(width: 4),
                                          Text(
                                            "Échéance: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(charge.dateEcheance))}",
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Montant: ${charge.montant} DH",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blue[700],
                                            ),
                                          ),
                                          Text(
                                            "Restant: ${charge.montantRestant} DH",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(charge.statut),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      charge.statut,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddChargePage(),
                ),
              );
              if (result == true) {
                _fetchCharges();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 64, 66, 69),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Create New Charge",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
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
