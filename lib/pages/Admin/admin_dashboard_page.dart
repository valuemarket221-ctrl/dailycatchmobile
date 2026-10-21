import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/services/admin_api_service.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/utils/api_environment.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AdminApiService _adminApiService = AdminApiService();
  AdminMetrics? _metrics;
  List<Map<String, dynamic>> _supportTickets = [];
  List<Map<String, dynamic>> _fraudEvents = [];
  List<Map<String, dynamic>> _notificationFailures = [];
  List<Map<String, dynamic>> _auditEvents = [];
  bool _isLoading = true;
  bool _isProcessingNotifications = false;
  String? _refundingOrderId;
  String? _updatingTicketId;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    try {
      final results = await Future.wait([
        _adminApiService.getMetrics(),
        _adminApiService.getSupportTickets(),
        _adminApiService.getFraudEvents(),
        _adminApiService.getNotificationFailures(),
        _adminApiService.getAuditEvents(),
      ]);
      if (!mounted) return;
      setState(() {
        _metrics = results[0] as AdminMetrics;
        _supportTickets =
            (results[1] as List<Map<String, dynamic>>).take(5).toList();
        _fraudEvents =
            (results[2] as List<Map<String, dynamic>>).take(3).toList();
        _notificationFailures =
            (results[3] as List<Map<String, dynamic>>).take(3).toList();
        _auditEvents =
            (results[4] as List<Map<String, dynamic>>).take(3).toList();
        _loadError = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _metrics =
            ApiEnvironment.isDemoFallbackAllowed
                ? const AdminMetrics(
                  activeOffers: 24,
                  lowStockOffers: 8,
                  paidOrders: 156,
                  pickedUpOrders: 1247,
                  refundPendingOrders: 2,
                  openSupportTickets: 6,
                  highRiskEvents: 3,
                  grossRevenue: 4589050,
                  queuedNotifications: 4,
                  failedNotifications: 1,
                  sentNotificationsToday: 18,
                )
                : null;
        _notificationFailures =
            ApiEnvironment.isDemoFallbackAllowed
                ? [
                  {
                    'title': 'Rappel retrait',
                    'failureReason': 'no_active_push_token',
                    'deliveryAttempts': 1,
                  },
                ]
                : [];
        _auditEvents =
            ApiEnvironment.isDemoFallbackAllowed
                ? [
                  {
                    'action': 'partner_application_approved',
                    'targetType': 'partner_application',
                    'targetId': 'demo_partner',
                    'actorUserId': 'admin_demo',
                  },
                ]
                : [];
        _loadError =
            ApiEnvironment.isDemoFallbackAllowed
                ? 'Backend indisponible: données de démonstration affichées'
                : 'Données admin indisponibles.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _metrics;

    return Scaffold(
      backgroundColor: AppTheme.mutedSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.blueBic),
        title: Text(
          'DailyCatch Admin',
          style: GoogleFonts.poppins(
            color: AppColors.blueBic,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.blueBic,
            ),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAdminHero(),
            if (_loadError != null) ...[
              const SizedBox(height: 12),
              _buildWarningBanner(_loadError!),
            ],
            const SizedBox(height: 24),
            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    title: 'Paniers sauvés',
                    value:
                        _isLoading
                            ? '...'
                            : (metrics?.pickedUpOrders ?? 0).toString(),
                    icon: Icons.shopping_bag,
                    color: AppColors.blueBic,
                    onTap: () => context.go('/admin/orders'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    title: 'Paniers actifs',
                    value:
                        _isLoading
                            ? '...'
                            : (metrics?.activeOffers ?? 0).toString(),
                    icon: Icons.store,
                    color: AppColors.greenTGTG,
                    onTap: () => context.go('/admin/partners'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    title: 'Support ouvert',
                    value:
                        _isLoading
                            ? '...'
                            : (metrics?.openSupportTickets ?? 0).toString(),
                    icon: Icons.support_agent,
                    color: AppTheme.warningColor,
                    onTap: () => context.go('/admin/clients'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context: context,
                    title: 'Presque épuisés',
                    value:
                        _isLoading
                            ? '...'
                            : (metrics?.lowStockOffers ?? 0).toString(),
                    icon: Icons.timelapse,
                    color: const Color(0xFF6A4C93),
                    onTap: () => context.go('/admin/products'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Quick Actions
            Text(
              'Actions rapides',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    context: context,
                    icon: Icons.person_add,
                    label: 'Nouveau partenaire',
                    onTap: () => context.go('/admin/partners/new'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    context: context,
                    icon: Icons.verified_user_outlined,
                    label: 'Valider partenaires',
                    onTap: () => context.go('/admin/partners/pending'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildOperationsPanel(),
            const SizedBox(height: 24),
            // Recent Activity
            Text(
              'Activité récente',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildRecentActivityTile(
              icon: Icons.warning_amber,
              title: 'Risque fraude',
              subtitle:
                  '${metrics?.highRiskEvents ?? 0} événement(s) à vérifier cette semaine',
              time: 'Il y a 5 min',
              color: Colors.orange,
            ),
            _buildRecentActivityTile(
              icon: Icons.shopping_bag,
              title: 'Réservations payées',
              subtitle: '${metrics?.paidOrders ?? 0} panier(s) à retirer',
              time: 'Il y a 12 min',
              color: AppColors.blueBic,
            ),
            _buildRecentActivityTile(
              icon: Icons.replay_circle_filled,
              title: 'Remboursements',
              subtitle:
                  '${metrics?.refundPendingOrders ?? 0} remboursement(s) en attente',
              time: 'Il y a 25 min',
              color: AppTheme.warningColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.softBorder),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.blueBic.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.set_meal,
              color: AppColors.blueBic,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilotage DailyCatch',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blueBic,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Validez les partenaires, surveillez la qualité, le support et les alertes. Les paniers sont publiés par les vendeurs.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.warningColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(onPressed: _loadMetrics, child: const Text('Réessayer')),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.blueBic,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationsPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.softBorder),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.health_and_safety, color: AppColors.blueBic),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Centre opérationnel',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blueBic,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Rafraîchir',
                onPressed: _isLoading ? null : _loadMetrics,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildNotificationQueueAction(),
          const SizedBox(height: 12),
          _buildNotificationMetricsRow(),
          const SizedBox(height: 16),
          _buildPanelSectionTitle('Échecs notifications'),
          if (_notificationFailures.isEmpty)
            _buildEmptyOperationLine('Aucun échec push récent.')
          else
            ..._notificationFailures.map(_buildNotificationFailureTile),
          const SizedBox(height: 16),
          _buildPanelSectionTitle('Tickets support à traiter'),
          if (_supportTickets.isEmpty)
            _buildEmptyOperationLine('Aucun ticket ouvert à afficher.')
          else
            ..._supportTickets.map(_buildSupportTicketTile),
          const SizedBox(height: 16),
          _buildPanelSectionTitle('Alertes fraude récentes'),
          if (_fraudEvents.isEmpty)
            _buildEmptyOperationLine('Aucune alerte fraude récente.')
          else
            ..._fraudEvents.map(_buildFraudEventTile),
          const SizedBox(height: 16),
          _buildPanelSectionTitle('Audit back-office'),
          if (_auditEvents.isEmpty)
            _buildEmptyOperationLine('Aucune action admin récente.')
          else
            ..._auditEvents.map(_buildAuditEventTile),
        ],
      ),
    );
  }

  Widget _buildNotificationQueueAction() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blueBic.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blueBic.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign_outlined, color: AppColors.blueBic),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'File notifications',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blueBic,
                      ),
                    ),
                    Text(
                      'Traiter les notifications en attente vers les tokens actifs.',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed:
                    _isProcessingNotifications
                        ? null
                        : () => _processNotificationQueue(),
                icon:
                    _isProcessingNotifications
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.send_outlined, size: 18),
                label: Text(
                  _isProcessingNotifications ? 'Envoi...' : 'Envoyer',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.blueBic,
                  side: const BorderSide(color: AppColors.blueBic),
                ),
              ),
              OutlinedButton.icon(
                onPressed:
                    _isProcessingNotifications
                        ? null
                        : () => _processNotificationQueue(includeFailed: true),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Réessayer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.warningColor,
                  side: const BorderSide(color: AppTheme.warningColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationMetricsRow() {
    final metrics = _metrics;

    return Row(
      children: [
        Expanded(
          child: _buildOperationMetric(
            label: 'En attente',
            value:
                _isLoading
                    ? '...'
                    : (metrics?.queuedNotifications ?? 0).toString(),
            color: AppTheme.warningColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildOperationMetric(
            label: 'Échouées',
            value:
                _isLoading
                    ? '...'
                    : (metrics?.failedNotifications ?? 0).toString(),
            color: Colors.red.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildOperationMetric(
            label: 'Envoyées 24h',
            value:
                _isLoading
                    ? '...'
                    : (metrics?.sentNotificationsToday ?? 0).toString(),
            color: AppColors.greenTGTG,
          ),
        ),
      ],
    );
  }

  Widget _buildOperationMetric({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationFailureTile(Map<String, dynamic> failure) {
    final reason = failure['failureReason']?.toString() ?? 'unknown';
    final attempts = failure['deliveryAttempts'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          const Icon(Icons.sms_failed_outlined, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  failure['title']?.toString() ?? 'Notification échouée',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_formatNotificationFailureReason(reason)} · $attempts tentative(s)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNotificationFailureReason(String reason) {
    return switch (reason) {
      'no_active_push_token' => 'Aucun token actif',
      'push_provider_unconfigured' => 'FCM non configuré',
      'push_provider_delivery_failed' => 'Échec FCM',
      'suppressed_by_user_preferences' => 'Filtrée par préférences',
      _ => 'Erreur inconnue',
    };
  }

  Widget _buildPanelSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.grey[850],
        ),
      ),
    );
  }

  Widget _buildEmptyOperationLine(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildSupportTicketTile(Map<String, dynamic> ticket) {
    final ticketId = ticket['id']?.toString() ?? '';
    final orderId = ticket['order_id']?.toString();
    final status = ticket['status']?.toString() ?? 'open';
    final canRefund = orderId != null && orderId.isNotEmpty;
    final isRefunding = _refundingOrderId == orderId;
    final isUpdating = _updatingTicketId == ticketId;
    final isClosed = status == 'resolved' || status == 'closed';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.mutedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.greenTGTG.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  ticket['category']?.toString() ?? 'support',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greenTGTG,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildTicketStatusBadge(status),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ticket['subject']?.toString() ?? 'Ticket support',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            orderId == null ? 'Sans réservation liée' : 'Réservation $orderId',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
          ),
          if (!isClosed) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed:
                      isUpdating
                          ? null
                          : () => _updateTicketStatus(ticketId, 'in_progress'),
                  icon:
                      isUpdating
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.pending_actions, size: 18),
                  label: const Text('En cours'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      isUpdating
                          ? null
                          : () => _updateTicketStatus(ticketId, 'resolved'),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Résolu'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.greenTGTG,
                    side: const BorderSide(color: AppColors.greenTGTG),
                  ),
                ),
              ],
            ),
          ],
          if (canRefund) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: isRefunding ? null : () => _refundOrder(orderId),
                icon:
                    isRefunding
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.replay_circle_filled, size: 18),
                label: Text(isRefunding ? 'Traitement...' : 'Rembourser'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.warningColor,
                  side: const BorderSide(color: AppTheme.warningColor),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTicketStatusBadge(String status) {
    final color = switch (status) {
      'resolved' || 'closed' => AppColors.greenTGTG,
      'in_progress' => AppColors.blueBic,
      'waiting_user' => AppTheme.warningColor,
      _ => Colors.grey.shade700,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _formatTicketStatus(status),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  String _formatTicketStatus(String status) {
    return switch (status) {
      'in_progress' => 'en cours',
      'waiting_user' => 'attente client',
      'resolved' => 'résolu',
      'closed' => 'clos',
      _ => 'ouvert',
    };
  }

  Widget _buildFraudEventTile(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['event_type']?.toString() ?? 'Alerte fraude',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Score ${event['risk_score'] ?? '-'}'
                  '${event['order_id'] == null ? '' : ' · ${event['order_id']}'}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditEventTile(Map<String, dynamic> event) {
    final action = event['action']?.toString() ?? 'admin_action';
    final targetType = event['targetType']?.toString() ?? 'ressource';
    final targetId = event['targetId']?.toString() ?? '-';
    final actorUserId = event['actorUserId']?.toString() ?? 'admin';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blueBic.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blueBic.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          const Icon(Icons.manage_history, color: AppColors.blueBic),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatAuditAction(action),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$targetType $targetId · $actorUserId',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAuditAction(String action) {
    return switch (action) {
      'support_ticket_status_updated' => 'Ticket support mis à jour',
      'partner_application_approved' => 'Vendeur approuvé',
      'partner_application_rejected' => 'Vendeur rejeté',
      _ => action.replaceAll('_', ' '),
    };
  }

  Future<void> _refundOrder(String orderId) async {
    setState(() => _refundingOrderId = orderId);
    try {
      await _adminApiService.refundOrder(orderId);
      if (!mounted) return;
      _showAdminMessage('Remboursement lancé pour $orderId');
      await _loadMetrics();
    } catch (error) {
      if (!mounted) return;
      _showAdminMessage(
        'Remboursement impossible: vérifiez Stripe et le statut de la réservation.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _refundingOrderId = null);
      }
    }
  }

  Future<void> _updateTicketStatus(String ticketId, String status) async {
    if (ticketId.isEmpty) return;

    setState(() => _updatingTicketId = ticketId);
    try {
      await _adminApiService.updateSupportTicketStatus(
        ticketId: ticketId,
        status: status,
      );
      if (!mounted) return;
      _showAdminMessage('Ticket mis à jour');
      await _loadMetrics();
    } catch (_) {
      if (!mounted) return;
      _showAdminMessage(
        'Impossible de mettre à jour ce ticket.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _updatingTicketId = null);
      }
    }
  }

  Future<void> _processNotificationQueue({bool includeFailed = false}) async {
    setState(() => _isProcessingNotifications = true);
    try {
      final result = await _adminApiService.processNotificationQueue(
        includeFailed: includeFailed,
      );
      if (!mounted) return;
      _showAdminMessage(
        'Notifications: ${result['processed']} traitées, '
        '${result['sent']} envoyées, ${result['failed']} échouées, '
        '${result['skipped'] ?? 0} en attente, '
        '${result['suppressed'] ?? 0} filtrées.',
      );
    } catch (_) {
      if (!mounted) return;
      _showAdminMessage(
        'Impossible de traiter la file notifications.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessingNotifications = false);
      }
    }
  }

  void _showAdminMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : AppColors.greenTGTG,
      ),
    );
  }

  Widget _buildRecentActivityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppColors.blueBic),
            accountName: Text(
              'Administrateur',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text('admin@dailycatch.com'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings, color: AppColors.blueBic),
            ),
          ),
          _buildDrawerSection('Gestion Utilisateurs'),
          _buildDrawerItem(
            Icons.people,
            'Clients',
            () => context.go('/admin/clients'),
          ),
          _buildDrawerItem(
            Icons.store,
            'Partenaires',
            () => context.go('/admin/partners'),
          ),
          _buildDrawerItem(
            Icons.verified_user,
            'Validation partenaires',
            () => context.go('/admin/partners/pending'),
          ),
          const Divider(),
          _buildDrawerSection('Gestion Paniers'),
          _buildDrawerItem(
            Icons.inventory_2,
            'Paniers',
            () => context.go('/admin/products'),
          ),
          _buildDrawerItem(
            Icons.add_box,
            'Ajouter panier',
            () => context.go('/admin/products/new'),
          ),
          const Divider(),
          _buildDrawerSection('Réservations'),
          _buildDrawerItem(
            Icons.shopping_bag,
            'Toutes les réservations',
            () => context.go('/admin/orders'),
          ),
          _buildDrawerItem(
            Icons.qr_code_scanner,
            'Suivi retraits',
            () => context.go('/admin/deliveries'),
          ),
          const Divider(),
          _buildDrawerSection('Paiements'),
          _buildDrawerItem(
            Icons.euro,
            'Revenus',
            () => context.go('/admin/revenue'),
          ),
          _buildDrawerItem(
            Icons.payments,
            'Paiements partenaires',
            () => context.go('/admin/partner-payments'),
          ),
          const Divider(),
          _buildDrawerSection('Paramètres'),
          _buildDrawerItem(
            Icons.settings,
            'Paramètres',
            () => context.go('/admin/settings'),
          ),
          _buildDrawerItem(
            Icons.logout,
            'Déconnexion',
            () => context.go('/login'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.blueBic),
      title: Text(title, style: GoogleFonts.poppins()),
      onTap: onTap,
    );
  }
}
