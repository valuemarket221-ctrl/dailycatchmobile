import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/styles/text_styles.dart';
import 'package:myapp/providers/partner_provider.dart';

class PartnerSchedulesPage extends StatefulWidget {
  const PartnerSchedulesPage({super.key});

  @override
  State<PartnerSchedulesPage> createState() => _PartnerSchedulesPageState();
}

class _PartnerSchedulesPageState extends State<PartnerSchedulesPage> {
  final List<_SpecialDay> _specialDays = [
    const _SpecialDay('Fête nationale', '14 Juillet - Fermé'),
  ];

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
                        'Créneaux de retrait',
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
                      _buildWeeklySchedule(context, provider),
                      const SizedBox(height: 32),
                      _buildSpecialHours(context),
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

  void _showEditHoursDialog(BuildContext context, StoreHours hours) {
    final openController = TextEditingController(text: hours.openTime);
    final closeController = TextEditingController(text: hours.closeTime);
    bool isOpen = hours.isOpen;

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text('Modifier: ${hours.day}'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SwitchListTile(
                        title: const Text('Retrait disponible'),
                        value: isOpen,
                        onChanged: (v) => setState(() => isOpen = v),
                      ),
                      if (isOpen) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: openController,
                                decoration: const InputDecoration(
                                  labelText: 'Début retrait',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: closeController,
                                decoration: const InputDecoration(
                                  labelText: 'Fin retrait',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                      ),
                      onPressed: () {
                        final updated = StoreHours(
                          day: hours.day,
                          openTime: openController.text,
                          closeTime: closeController.text,
                          isOpen: isOpen,
                        );
                        context.read<PartnerProvider>().updateStoreHours(
                          updated,
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Horaire mis à jour!'),
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

  Widget _buildWeeklySchedule(BuildContext context, PartnerProvider provider) {
    final schedule = provider.storeHours;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.softBorder),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Créneaux hebdomadaires', style: AppTextStyles.headingS),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Retrait actif aujourd\'hui',
                  style: AppTextStyles.bodyS.copyWith(
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...List.generate(
            schedule.length,
            (i) => _buildDayRow(context, schedule[i], i),
          ),
        ],
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, StoreHours hours, int index) {
    final isToday = index == DateTime.now().weekday - 1;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: const Border(bottom: BorderSide(color: AppTheme.softBorder)),
        color: isToday ? const Color(0xFF10B981).withValues(alpha: 0.05) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Row(
              children: [
                if (isToday)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                Expanded(
                  child: Text(
                    hours.day,
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                hours.isOpen
                    ? Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            hours.openTime,
                            style: AppTextStyles.bodyM,
                          ),
                        ),
                        Text(
                          '-',
                          style: AppTextStyles.bodyM.copyWith(
                            color: Colors.grey[400],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            hours.closeTime,
                            style: AppTextStyles.bodyM,
                          ),
                        ),
                      ],
                    )
                    : Text(
                      'Fermé',
                      style: AppTextStyles.bodyM.copyWith(
                        color: const Color(0xFFEF4444),
                      ),
                    ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => _showEditHoursDialog(context, hours),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialHours(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.softBorder),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Créneaux exceptionnels', style: AppTextStyles.headingS),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _showAddSpecialDay(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ajouter'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_specialDays.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.mutedSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Aucun créneau exceptionnel',
                style: AppTextStyles.bodyM,
              ),
            )
          else
            ..._specialDays.asMap().entries.map(
              (entry) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.value.title,
                            style: AppTextStyles.bodyM.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            entry.value.detail,
                            style: AppTextStyles.bodyS.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFEF4444),
                      ),
                      onPressed: () => _removeSpecialDay(entry.key),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddSpecialDay(BuildContext context) {
    final nameController = TextEditingController();
    final detailController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Ajouter un créneau exceptionnel'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: detailController,
                  decoration: const InputDecoration(labelText: 'Date / état'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Fermer'),
              ),
              ElevatedButton(
                onPressed: () {
                  final title = nameController.text.trim();
                  final detail = detailController.text.trim();
                  if (title.isEmpty || detail.isEmpty) return;
                  setState(() => _specialDays.add(_SpecialDay(title, detail)));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Créneau ajouté')),
                  );
                },
                child: const Text('Ajouter'),
              ),
            ],
          ),
    );
  }

  void _removeSpecialDay(int index) {
    setState(() => _specialDays.removeAt(index));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Créneau supprimé')));
  }
}

class _SpecialDay {
  const _SpecialDay(this.title, this.detail);

  final String title;
  final String detail;
}
