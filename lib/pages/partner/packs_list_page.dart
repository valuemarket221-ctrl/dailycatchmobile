import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/styles/text_styles.dart';
import 'package:myapp/providers/partner_provider.dart'
    show Pack, PartnerProvider;

class PacksListPage extends StatelessWidget {
  const PacksListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PartnerProvider>(
      builder: (context, provider, child) {
        return Material(
          color: AppTheme.mutedSurface,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Mes paniers',
                        style: AppTextStyles.headingM,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primaryColor,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 24),
                      _buildPacksTable(context, provider),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Paniers surprise',
            style: AppTextStyles.headingS,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () => _showAddPackDialog(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Créer un panier',
                    style: AppTextStyles.bodyM.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddPackDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final discPriceController = TextEditingController();
    final qtyController = TextEditingController();
    List<String> selectedProducts = [];

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Créer un panier'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nom du panier',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Contenu possible',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              [
                                    'Saumon frais (500g)',
                                    'Crevettes (250g)',
                                    'Homard entier (800g)',
                                    'Moules (400g)',
                                    'Huîtres (6 pièces)',
                                    'Maquereau (600g)',
                                  ]
                                  .map(
                                    (p) => FilterChip(
                                      label: Text(p),
                                      selected: selectedProducts.contains(p),
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            selectedProducts.add(p);
                                          } else {
                                            selectedProducts.remove(p);
                                          }
                                        });
                                      },
                                      selectedColor: const Color(
                                        0xFF3B82F6,
                                      ).withValues(alpha: 0.2),
                                    ),
                                  )
                                  .toList(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: priceController,
                                decoration: const InputDecoration(
                                  labelText: 'Prix (€)',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: discPriceController,
                                decoration: const InputDecoration(
                                  labelText: 'Prix réduit',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: qtyController,
                          decoration: const InputDecoration(
                            labelText: 'Quantité',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                      ),
                      onPressed: () {
                        if (nameController.text.isNotEmpty) {
                          final pack = Pack(
                            id:
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            name: nameController.text,
                            description: descController.text,
                            products: selectedProducts,
                            originalPrice:
                                double.tryParse(priceController.text) ?? 0,
                            discountedPrice:
                                double.tryParse(discPriceController.text) ?? 0,
                            quantity: int.tryParse(qtyController.text) ?? 0,
                          );
                          context.read<PartnerProvider>().addPack(pack);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Panier créé!'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        }
                      },
                      child: const Text('Créer'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showEditPackDialog(BuildContext context, Pack pack) {
    final nameController = TextEditingController(text: pack.name);
    final descController = TextEditingController(text: pack.description);
    final priceController = TextEditingController(
      text: pack.originalPrice.toString(),
    );
    final discPriceController = TextEditingController(
      text: pack.discountedPrice.toString(),
    );
    final qtyController = TextEditingController(text: pack.quantity.toString());
    String status = pack.status;
    List<String> selectedProducts = List.from(pack.products);

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Modifier le panier'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nom',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: status,
                          decoration: const InputDecoration(
                            labelText: 'Statut',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              ['Actif', 'Inactif']
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => status = v!,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: priceController,
                                decoration: const InputDecoration(
                                  labelText: 'Prix (€)',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: discPriceController,
                                decoration: const InputDecoration(
                                  labelText: 'Prix réduit',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: qtyController,
                          decoration: const InputDecoration(
                            labelText: 'Quantité',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                      ),
                      onPressed: () {
                        final updated = pack.copyWith(
                          name: nameController.text,
                          description: descController.text,
                          status: status,
                          originalPrice:
                              double.tryParse(priceController.text) ?? 0,
                          discountedPrice:
                              double.tryParse(discPriceController.text) ?? 0,
                          quantity: int.tryParse(qtyController.text) ?? 0,
                          products: selectedProducts,
                        );
                        context.read<PartnerProvider>().updatePack(updated);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Panier modifié!'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      },
                      child: const Text('Enregistrer'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _confirmDelete(BuildContext context, Pack pack) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Supprimer le panier'),
            content: Text('Voulez-vous supprimer "${pack.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                ),
                onPressed: () {
                  context.read<PartnerProvider>().deletePack(pack.id);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Panier supprimé!'),
                      backgroundColor: Color(0xFFEF4444),
                    ),
                  );
                },
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
  }

  Widget _buildPacksTable(BuildContext context, PartnerProvider provider) {
    final packs = provider.packs;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.softBorder),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.mutedSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Panier',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Contenu',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Prix',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Prix réduit',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Stock',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Statut',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Actions',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (packs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('Aucun panier'),
            )
          else
            ...packs.map((p) => _buildPackRow(context, p)),
        ],
      ),
    );
  }

  Widget _buildPackRow(BuildContext context, Pack pack) {
    final isActive = pack.status == 'Actif';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: const Border(bottom: BorderSide(color: AppTheme.softBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.card_giftcard,
                    color: Color(0xFF3B82F6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    pack.name,
                    style: AppTextStyles.bodyM,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              pack.products.join(', '),
              style: AppTextStyles.bodyS.copyWith(color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text('${pack.originalPrice}€', style: AppTextStyles.bodyM),
          ),
          Expanded(
            child: Text(
              '${pack.discountedPrice}€',
              style: AppTextStyles.bodyM.copyWith(
                color: const Color(0xFF10B981),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text('${pack.quantity}', style: AppTextStyles.bodyM)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    isActive
                        ? const Color(0xFF10B981).withValues(alpha: 0.1)
                        : Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                pack.status,
                style: AppTextStyles.bodyS.copyWith(
                  color: isActive ? const Color(0xFF10B981) : Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _showEditPackDialog(context, pack),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Color(0xFFEF4444),
                  ),
                  onPressed: () => _confirmDelete(context, pack),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
