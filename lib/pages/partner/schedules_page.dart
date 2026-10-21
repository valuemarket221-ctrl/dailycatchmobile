import 'package:flutter/material.dart';
import 'package:myapp/providers/partner_provider.dart' show StoreHours;
import 'package:myapp/services/partner_api_service.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/styles/text_styles.dart';

class PartnerSchedulesPage extends StatefulWidget {
  const PartnerSchedulesPage({super.key});

  @override
  State<PartnerSchedulesPage> createState() => _PartnerSchedulesPageState();
}

class _PartnerSchedulesPageState extends State<PartnerSchedulesPage> {
  final PartnerApiService _partnerApiService = PartnerApiService();
  final List<_SpecialDay> _specialDays = [];
  List<StoreHours> _schedule = _defaultSchedule();
  Map<String, dynamic>? _profile;
  var _isLoading = true;
  var _isSaving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final profile = await _partnerApiService.getMyProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _schedule = _scheduleFromProfile(profile);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Horaires indisponibles pour le moment.';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveHours(StoreHours updated) async {
    final previousSchedule =
        _schedule.map((hours) => hours.copyWith()).toList();
    setState(() {
      _schedule =
          _schedule
              .map((hours) => hours.day == updated.day ? updated : hours)
              .toList();
      _isSaving = true;
    });

    try {
      final profile = await _partnerApiService.saveMyProfile(
        PartnerProfileRequest(
          storeId: _readProfileString('storeId', fallback: 'store_port'),
          storeName: _readProfileString('storeName', fallback: 'Mon commerce'),
          ownerName: _readNullableProfileString('ownerName'),
          commerceType: _readProfileString(
            'commerceType',
            fallback: 'fishmonger',
          ),
          address: _readNullableProfileString('address'),
          city: _readNullableProfileString('city'),
          postalCode: _readNullableProfileString('postalCode'),
          phone: _readNullableProfileString('phone'),
          email: _readNullableProfileString('email'),
          description: _readNullableProfileString('description'),
          latitude: _readProfileDouble('latitude'),
          longitude: _readProfileDouble('longitude'),
          openingHours: _openingHoursPayload(_schedule),
        ),
      );
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Horaire enregistré.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _schedule = previousSchedule;
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enregistrement impossible pour le moment.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.mutedSurface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _loadError != null
                    ? _buildStateMessage(
                      icon: Icons.cloud_off_outlined,
                      title: 'Horaires indisponibles',
                      message: _loadError!,
                      actionLabel: 'Réessayer',
                      onAction: _loadSchedule,
                    )
                    : RefreshIndicator(
                      onRefresh: _loadSchedule,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWeeklySchedule(context),
                            const SizedBox(height: 32),
                            _buildSpecialHours(context),
                          ],
                        ),
                      ),
                    ),
          ),
        ],
      ),
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
                                keyboardType: TextInputType.datetime,
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
                                keyboardType: TextInputType.datetime,
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
                      onPressed:
                          _isSaving
                              ? null
                              : () {
                                final updated = StoreHours(
                                  day: hours.day,
                                  openTime: openController.text.trim(),
                                  closeTime: closeController.text.trim(),
                                  isOpen: isOpen,
                                );
                                Navigator.pop(ctx);
                                _saveHours(updated);
                              },
                      child: const Text('Enregistrer'),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildWeeklySchedule(BuildContext context) {
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
              Expanded(
                child: Text(
                  'Créneaux hebdomadaires',
                  style: AppTextStyles.headingS,
                ),
              ),
              if (_isSaving)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
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
                    'Synchronisé',
                    style: AppTextStyles.bodyS.copyWith(
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          ...List.generate(
            _schedule.length,
            (i) => _buildDayRow(context, _schedule[i], i),
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
                        _timePill(hours.openTime),
                        Text(
                          '-',
                          style: AppTextStyles.bodyM.copyWith(
                            color: Colors.grey[400],
                          ),
                        ),
                        _timePill(hours.closeTime),
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

  Widget _timePill(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(value, style: AppTextStyles.bodyM),
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
              Expanded(
                child: Text(
                  'Créneaux exceptionnels',
                  style: AppTextStyles.headingS,
                ),
              ),
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

  Widget _buildStateMessage({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.headingS),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyM.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ],
        ),
      ),
    );
  }

  static List<StoreHours> _defaultSchedule() => [
    StoreHours(day: 'Lundi', openTime: '08:00', closeTime: '20:00'),
    StoreHours(day: 'Mardi', openTime: '08:00', closeTime: '20:00'),
    StoreHours(day: 'Mercredi', openTime: '08:00', closeTime: '20:00'),
    StoreHours(day: 'Jeudi', openTime: '08:00', closeTime: '20:00'),
    StoreHours(day: 'Vendredi', openTime: '08:00', closeTime: '22:00'),
    StoreHours(day: 'Samedi', openTime: '08:00', closeTime: '22:00'),
    StoreHours(day: 'Dimanche', openTime: '08:00', closeTime: '18:00'),
  ];

  static List<StoreHours> _scheduleFromProfile(Map<String, dynamic>? profile) {
    final defaults = _defaultSchedule();
    final openingHours = profile?['openingHours'];
    if (openingHours is! Map || openingHours.isEmpty) return defaults;

    return defaults.map((hours) {
      final raw = openingHours[hours.day] ?? openingHours[_shortDay(hours.day)];
      if (raw == null) return hours;
      return _parseHoursValue(hours, raw.toString());
    }).toList();
  }

  static StoreHours _parseHoursValue(StoreHours fallback, String value) {
    final normalized = value.trim();
    if (normalized.isEmpty || normalized.toLowerCase() == 'fermé') {
      return fallback.copyWith(isOpen: false);
    }

    final parts =
        normalized
            .replaceAll('–', '-')
            .split('-')
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .toList();
    if (parts.length < 2) return fallback;
    return fallback.copyWith(openTime: parts[0], closeTime: parts[1]);
  }

  static String _shortDay(String day) {
    switch (day) {
      case 'Lundi':
        return 'Lun';
      case 'Mardi':
        return 'Mar';
      case 'Mercredi':
        return 'Mer';
      case 'Jeudi':
        return 'Jeu';
      case 'Vendredi':
        return 'Ven';
      case 'Samedi':
        return 'Sam';
      case 'Dimanche':
        return 'Dim';
      default:
        return day;
    }
  }

  static Map<String, String> _openingHoursPayload(List<StoreHours> schedule) {
    return {
      for (final hours in schedule)
        hours.day:
            hours.isOpen ? '${hours.openTime} - ${hours.closeTime}' : 'Fermé',
    };
  }

  String _readProfileString(String field, {required String fallback}) {
    final value = _profile?[field]?.toString().trim() ?? '';
    return value.isEmpty ? fallback : value;
  }

  String? _readNullableProfileString(String field) {
    final value = _profile?[field]?.toString().trim() ?? '';
    return value.isEmpty ? null : value;
  }

  double? _readProfileDouble(String field) {
    final value = _profile?[field];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}

class _SpecialDay {
  const _SpecialDay(this.title, this.detail);

  final String title;
  final String detail;
}
