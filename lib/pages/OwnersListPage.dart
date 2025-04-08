import 'package:flutter/material.dart';
import 'Owner.dart';
import 'OwnerFormPage.dart';
import 'notifications_page.dart';
import '../widgets/NotificationBell.dart';
import '../widgets/user_avatar.dart';
import 'UserProfilePage.dart';
import 'OwnerDetailPage.dart';

class OwnersListPage extends StatefulWidget {
  @override
  _OwnersListPageState createState() => _OwnersListPageState();
}

class _OwnersListPageState extends State<OwnersListPage> {
  List<Owner> owners = [];
  List<Owner> filteredOwners = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredOwners = owners;
    searchController.addListener(_filterOwners);
  }

  void _filterOwners() {
    setState(() {
      filteredOwners = owners
          .where((owner) => owner.name.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _addOrUpdateOwner(Owner owner) {
    setState(() {
      int index = owners.indexWhere((o) => o.id == owner.id);
      if (index >= 0) {
        owners[index] = owner;
      } else {
        owners.add(owner);
      }
      _filterOwners();
    });
  }

  void _editOwner(Owner owner) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OwnerFormPage(
          owner: owner,
          onSave: _addOrUpdateOwner,
        ),
      ),
    );
  }

  void _deleteOwner(Owner owner) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmer la suppression"),
          content: Text("Voulez-vous vraiment supprimer ${owner.name} ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  owners.removeWhere((o) => o.id == owner.id);
                  _filterOwners();
                });
                Navigator.pop(context);
              },
              child: Text("Supprimer", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _addOwner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OwnerFormPage(
          onSave: _addOrUpdateOwner,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 64, 66, 69),
        elevation: 0,
        title: Row(
          children: [
            Text(
              "Liste Des Propriétaires",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              ),
              child: NotificationBell(),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfilePage()),
              ),
              child: UserAvatar(),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Rechercher un propriétaire",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredOwners.isEmpty
                ? Center(
                    child: Text(
                      "Aucun propriétaire trouvé.",
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredOwners.length,
                    itemBuilder: (context, index) {
                      final owner = filteredOwners[index];
                      return Card(
                        color: Colors.blue.withOpacity(0.6),
                        margin: EdgeInsets.all(8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                                                      onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OwnerDetailPage(owner: owner),
                                ),
                              );
                            },
                          title: Text(
                            owner.name,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Immeuble ${owner.numImm}, Appartement ${owner.numApp}\nMontant à payer: ${owner.amount.toStringAsFixed(2)} MAD",
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.white),
                                onPressed: () => _editOwner(owner),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteOwner(owner),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addOwner,
        backgroundColor: const Color.fromARGB(255, 75, 160, 173),
        child: Icon(Icons.add,color: Colors.white,),
      ),
    );
  }
}
