import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/data/rescued_product_repository.dart';
import 'package:myapp/models/rescued_product.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/utils/api_error_messages.dart';
import 'package:myapp/widgets/app_remote_image.dart';

class ListeProduitsPage extends StatefulWidget {
  const ListeProduitsPage({super.key, this.initialCategory = 'Tous'});
  final String initialCategory;

  @override
  State<ListeProduitsPage> createState() => _ListeProduitsPageState();
}

class _ListeProduitsPageState extends State<ListeProduitsPage> {
  final _repository = RescuedProductRepository();
  final _searchController = TextEditingController();
  var _selectedCategory = 'Tous';
  var _products = <RescuedProduct>[];
  var _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final products = await _repository.getAvailableProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = ApiErrorMessages.fromObject(error);
        _isLoading = false;
      });
    }
  }

  List<String> get _categories {
    final values = _products
        .map((product) => product.category.trim())
        .where((category) => category.isNotEmpty);
    final sorted = {...values}.toList()..sort();
    return [
      'Tous',
      ...{if (_selectedCategory != 'Tous') _selectedCategory, ...sorted},
    ];
  }

  List<RescuedProduct> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    return _products.where((product) {
      final matchesCategory =
          _selectedCategory == 'Tous' || product.category == _selectedCategory;
      final matchesSearch =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.partnerName.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mutedSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.blueBic,
        title: Text(
          'Paniers disponibles',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w800,
            color: AppColors.blueBic,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _loadError != null
                    ? _StateMessage(
                      icon: Icons.cloud_off_outlined,
                      title: 'Paniers indisponibles',
                      message: _loadError!,
                      actionLabel: 'Réessayer',
                      onAction: _loadProducts,
                    )
                    : _filteredProducts.isEmpty
                    ? const _StateMessage(
                      icon: Icons.search_off_outlined,
                      title: 'Aucun panier',
                      message:
                          'Aucun panier ne correspond à votre recherche pour le moment.',
                    )
                    : RefreshIndicator(
                      onRefresh: _loadProducts,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          return _ProductCard(
                            product: _filteredProducts[index],
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Rechercher un panier...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppTheme.mutedSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.softBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.softBorder),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: AppColors.greenTGTG,
                        backgroundColor: Colors.white,
                        labelStyle: GoogleFonts.poppins(
                          color: isSelected ? Colors.white : AppColors.blueBic,
                          fontWeight: FontWeight.w700,
                        ),
                        side: const BorderSide(color: AppTheme.softBorder),
                        onSelected:
                            (_) => setState(() => _selectedCategory = category),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final RescuedProduct product;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/detail', extra: product.toMap()),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.softBorder),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: AppRemoteImage(
                path: product.imageUrl,
                width: 110,
                height: 116,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.blueBic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.partnerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${product.discountedPrice.toStringAsFixed(0)} FCFA',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.blueBic,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${product.remainingQuantity} panier(s) • ${product.category}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.greenTGTG,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: AppColors.blueBic),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: AppColors.blueBic,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
