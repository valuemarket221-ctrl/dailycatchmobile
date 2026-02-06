import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

/// Page historique des commandes
class OrdersHistoryPage extends StatefulWidget {
  const OrdersHistoryPage({super.key});

  @override
  State<OrdersHistoryPage> createState() => _OrdersHistoryPageState();
}

class _OrdersHistoryPageState extends State<OrdersHistoryPage> {
  int _selectedFilter = 0; // 0: Tout, 1: En cours, 2: Livré

  // Données fictives des commandes
  final List<Order> _orders = [
    Order(
      id: 'CMD-001',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: OrderStatus.delivered,
      total: 45.50,
      items: [
        OrderItem(name: 'Saumon frais', quantity: 2, price: 25.99),
        OrderItem(name: 'Crevettes', quantity: 1, price: 15.50),
      ],
    ),
    Order(
      id: 'CMD-002',
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: OrderStatus.delivered,
      total: 32.00,
      items: [OrderItem(name: 'Huîtres', quantity: 4, price: 9.99)],
    ),
    Order(
      id: 'CMD-003',
      date: DateTime.now().subtract(const Duration(days: 5)),
      status: OrderStatus.processing,
      total: 28.50,
      items: [
        OrderItem(name: 'Thon rouge', quantity: 1, price: 18.00),
        OrderItem(name: 'Maquereau', quantity: 2, price: 9.00),
      ],
    ),
  ];

  List<Order> get _filteredOrders {
    if (_selectedFilter == 0) return _orders;
    if (_selectedFilter == 1) {
      return _orders.where((o) => o.status == OrderStatus.processing).toList();
    }
    return _orders.where((o) => o.status == OrderStatus.delivered).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des commandes', style: GoogleFonts.poppins()),
        backgroundColor: AppColors.blueBic,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip('Tout', 0),
                const SizedBox(width: 8),
                _buildFilterChip('En cours', 1),
                const SizedBox(width: 8),
                _buildFilterChip('Livré', 2),
              ],
            ),
          ),

          // Liste des commandes
          Expanded(
            child:
                _filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(_filteredOrders[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilter == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? index : 0;
        });
      },
      selectedColor: AppColors.blueBic,
      labelStyle: GoogleFonts.poppins(
        color: isSelected ? Colors.white : Colors.grey[700],
      ),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              order.id,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color:
                    order.status == OrderStatus.delivered
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                order.status == OrderStatus.delivered ? 'Livré' : 'En cours',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                      order.status == OrderStatus.delivered
                          ? Colors.green
                          : Colors.orange,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          _formatDate(order.date),
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...order.items.map((item) => _buildOrderItem(item)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${order.total.toStringAsFixed(2)}€',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.blueBic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.blueBic,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Voir les détails',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${item.quantity}x ${item.name}', style: GoogleFonts.poppins()),
          Text(
            '${item.price.toStringAsFixed(2)}€',
            style: GoogleFonts.poppins(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aucune commande',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Modèle de commande
class Order {
  final String id;
  final DateTime date;
  final OrderStatus status;
  final double total;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.date,
    required this.status,
    required this.total,
    required this.items,
  });
}

/// Élément de commande
class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({required this.name, required this.quantity, required this.price});
}

/// Statut de commande
enum OrderStatus { pending, processing, delivered, cancelled }
