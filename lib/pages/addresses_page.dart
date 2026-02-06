import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

/// Page des adresses
class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  // Adresses fictives
  final List<Address> _addresses = [
    Address(
      id: '1',
      name: 'Domicile',
      address: '123 Rue de la Paix, Dakar',
      city: 'Dakar',
      isDefault: true,
    ),
    Address(
      id: '2',
      name: 'Bureau',
      address: '456 Avenue Leopold Sedar Senghor, Dakar',
      city: 'Dakar',
      isDefault: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mes adresses',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppColors.blueBic,
        foregroundColor: Colors.white,
      ),
      body: _addresses.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                return _buildAddressCard(_addresses[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAddress,
        icon: const Icon(Icons.add),
        label: Text(
          'Ajouter',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppColors.blueBic,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildAddressCard(Address address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      address.name == 'Domicile' ? Icons.home : Icons.business,
                      color: AppColors.blueBic,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      address.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.blueBic.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Par défaut',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.blueBic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit') _editAddress(address);
                    else if (value == 'delete') _deleteAddress(address);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 20),
                          const SizedBox(width: 8),
                          Text('Modifier', style: GoogleFonts.poppins()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 20, color: Colors.red),
                          const SizedBox(width: 8),
                          Text('Supprimer',
                              style: GoogleFonts.poppins(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              address.address,
              style: GoogleFonts.poppins(),
            ),
            Text(
              address.city,
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!address.isDefault)
                  TextButton(
                    onPressed: () => _setDefault(address),
                    child: Text(
                      'Définir par défaut',
                      style: GoogleFonts.poppins(
                        color: AppColors.blueBic,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune adresse',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez une adresse pour la livraison',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _addAddress() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildAddressForm(),
    );
  }

  void _editAddress(Address address) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildAddressForm(address: address),
    );
  }

  void _deleteAddress(Address address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Voulez-vous vraiment supprimer "${address.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Adresse supprimée',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _setDefault(Address address) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${address.name} est maintenant l\'adresse par défaut',
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  Widget _buildAddressForm({Address? address}) {
    final nameController =
        TextEditingController(text: address?.name ?? '');
    final addressController =
        TextEditingController(text: address?.address ?? '');
    final cityController =
        TextEditingController(text: address?.city ?? '');

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address == null ? 'Nouvelle adresse' : 'Modifier l\'adresse',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Nom (Domicile, Bureau...)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: addressController,
            decoration: InputDecoration(
              labelText: 'Adresse',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: cityController,
            decoration: InputDecoration(
              labelText: 'Ville',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      address == null
                          ? 'Adresse ajoutée'
                          : 'Adresse mise à jour',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueBic,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Enregistrer',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modèle d'adresse
class Address {
  final String id;
  final String name;
  final String address;
  final String city;
  final bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.isDefault,
  });
}
