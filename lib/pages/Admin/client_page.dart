import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

class Client {
  final String name;
  final String email;
  final String phone;
  bool isActive;

  Client({
    required this.name,
    required this.email,
    required this.phone,
    this.isActive = true,
  });
}

class ClientsPage extends StatefulWidget {
  @override
  _ClientsPageState createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final List<Client> clients = List.generate(
    25,
    (index) => Client(
      name: 'Client $index',
      email: 'client$index@example.com',
      phone: '77${index}00123${index}',
    ),
  );

  List<Client> filteredClients = [];
  int currentPage = 0;
  final int itemsPerPage = 10;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredClients = clients;
  }

  void filterClients(String query) {
    setState(() {
      currentPage = 0;
      if (query.isEmpty) {
        filteredClients = clients;
      } else {
        filteredClients = clients.where((client) =>
            client.name.toLowerCase().contains(query.toLowerCase()) ||
            client.email.toLowerCase().contains(query.toLowerCase()) ||
            client.phone.contains(query)).toList();
      }
    });
  }

  List<Client> getPaginatedClients() {
    final start = currentPage * itemsPerPage;
    final end = (start + itemsPerPage) > filteredClients.length
        ? filteredClients.length
        : start + itemsPerPage;
    return filteredClients.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final paginatedClients = getPaginatedClients();
    final totalPages = (filteredClients.length / itemsPerPage).ceil();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Liste des Clients',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.blueBic,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Champ de recherche intégré
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: filterClients,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Rechercher un client...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Tableau
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DataTable(
                        columnSpacing: 24,
                        headingTextStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.blueBic,
                        ),
                        columns: [
                          DataColumn(label: Text('Nom')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Téléphone')),
                          DataColumn(label: Text('Actif')),
                        ],
                        rows: paginatedClients.map((client) {
                          return DataRow(cells: [
                            DataCell(Text(client.name)),
                            DataCell(Text(client.email)),
                            DataCell(Text(client.phone)),
                            DataCell(Row(
                              children: [
                                Checkbox(
                                  value: client.isActive,
                                  onChanged: (value) {
                                    setState(() => client.isActive = value!);
                                  },
                                  activeColor: AppColors.blueBic,
                                ),
                                Text(
                                  client.isActive ? 'Actif' : 'Désactivé',
                                  style: TextStyle(
                                    color: client.isActive ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Pagination
            const SizedBox(height: 16),
            if (totalPages > 1)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: currentPage > 0
                        ? () => setState(() => currentPage--)
                        : null,
                  ),
                  ...List.generate(totalPages, (index) {
                    return InkWell(
                      onTap: () => setState(() => currentPage = index),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: currentPage == index
                              ? AppColors.blueBic
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: currentPage == index
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: currentPage < totalPages - 1
                        ? () => setState(() => currentPage++)
                        : null,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
