import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/services/message_api_service.dart';

class ClientChatPage extends StatefulWidget {
  const ClientChatPage({
    super.key,
    this.conversationId,
    this.chatName = 'Poissonnerie Chez Moussa',
    this.currentUserId = 'dev-client',
    this.messageApiService,
  });

  final String? conversationId;
  final String chatName;
  final String currentUserId;
  final MessageApiService? messageApiService;

  @override
  State<ClientChatPage> createState() => _ClientChatPageState();
}

class _ClientChatPageState extends State<ClientChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  late final MessageApiService _messageApiService;
  var _isLoading = false;
  var _isSending = false;
  String? _loadError;
  List<_ChatMessage> _messages = const [
    _ChatMessage(
      text: 'Bonjour ! Votre panier\nest prêt à être retiré.',
      sentByMe: false,
      timeLabel: '16:30',
    ),
    _ChatMessage(
      text: 'Merci ! J’arrive dans\n10 minutes.',
      sentByMe: true,
      timeLabel: '16:31',
    ),
    _ChatMessage(
      text: 'Parfait, on vous attend !',
      sentByMe: false,
      timeLabel: '16:32',
    ),
    _ChatMessage(text: 'Merci beaucoup.', sentByMe: true, timeLabel: '16:33'),
  ];

  @override
  void initState() {
    super.initState();
    _messageApiService = widget.messageApiService ?? MessageApiService();
    if (widget.conversationId != null && widget.conversationId!.isNotEmpty) {
      _loadMessages();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final conversationId = widget.conversationId!;
      final messages = await _messageApiService.getMessages(conversationId);
      await _messageApiService.markConversationAsRead(conversationId);
      if (!mounted) return;

      setState(() {
        _messages =
            messages
                .map(
                  (message) => _ChatMessage.fromBackend(
                    message,
                    currentUserId: widget.currentUserId,
                  ),
                )
                .toList();
        _isLoading = false;
      });
      _scrollToBottom();
    } on MessageApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'messages_unavailable';
        _isLoading = false;
      });
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    _controller.clear();
    final optimisticMessage = _ChatMessage(
      text: text,
      sentByMe: true,
      timeLabel: 'Maintenant',
      pending: widget.conversationId != null,
    );

    setState(() {
      _isSending = widget.conversationId != null;
      _messages = [..._messages, optimisticMessage];
    });
    _scrollToBottom();

    if (widget.conversationId == null || widget.conversationId!.isEmpty) {
      return;
    }

    try {
      await _messageApiService.sendMessage(
        conversationId: widget.conversationId!,
        body: text,
      );
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _messages = [
          for (final message in _messages)
            identical(message, optimisticMessage)
                ? message.copyWith(pending: false)
                : message,
        ];
      });
    } on MessageApiException catch (error) {
      _handleSendFailure(optimisticMessage, error.message);
    } catch (_) {
      _handleSendFailure(optimisticMessage, 'message_send_failed');
    }
  }

  void _handleSendFailure(_ChatMessage failedMessage, String reason) {
    if (!mounted) return;
    setState(() {
      _isSending = false;
      _messages = [
        for (final message in _messages)
          identical(message, failedMessage)
              ? message.copyWith(pending: false, failed: true)
              : message,
      ];
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Message non envoyé ($reason).')));
  }

  void _showActionFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.blueBic,
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.blueBic),
                ),
                const CircleAvatar(
                  radius: 21,
                  backgroundImage: AssetImage('assets/icon/icon.png'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.chatName,
                        style: _chatTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _loadError == null ? 'En ligne' : 'Connexion limitée',
                        style: _online,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed:
                      () => _showActionFeedback(
                        'Appel client-commerçant prêt à raccorder.',
                      ),
                  icon: const Icon(Icons.phone, color: AppColors.blueBic),
                ),
                IconButton(
                  onPressed:
                      () => _showActionFeedback(
                        'Envoi de photo prêt à raccorder.',
                      ),
                  icon: const Icon(
                    Icons.photo_camera_outlined,
                    color: AppColors.blueBic,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE8EEEE)),
          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              color: AppColors.blueBic,
              backgroundColor: Color(0xFFE9F2F0),
            ),
          if (_loadError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: _ChatNotice(onRetry: _loadMessages),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment:
                      message.sentByMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    constraints: const BoxConstraints(maxWidth: 224),
                    decoration: BoxDecoration(
                      color:
                          message.sentByMe
                              ? const Color(0xFFE0F3F3)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow:
                          message.sentByMe
                              ? null
                              : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .04),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(message.text, style: _bubble),
                        const SizedBox(height: 4),
                        Text(
                          message.statusLabel,
                          style: _bubbleTime.copyWith(
                            color:
                                message.failed ? const Color(0xFFE45353) : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE1E8E6)),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.camera_alt_outlined,
                          size: 18,
                          color: Color(0xFF718487),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Écrire un message...',
                              hintStyle: _hint,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: FilledButton(
                    onPressed: _isSending ? null : _send,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppColors.blueBic,
                      shape: const CircleBorder(),
                    ),
                    child:
                        _isSending
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(Icons.send, size: 19),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ChatNotice extends StatelessWidget {
  const _ChatNotice({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAF9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1ECEA)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: AppColors.blueBic,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Impossible de synchroniser cette conversation.',
              style: _muted.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Réessayer',
              style: _muted.copyWith(
                color: AppColors.blueBic,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.sentByMe,
    required this.timeLabel,
    this.pending = false,
    this.failed = false,
  });

  factory _ChatMessage.fromBackend(
    Map<String, dynamic> message, {
    required String currentUserId,
  }) {
    return _ChatMessage(
      text: message['body']?.toString() ?? '',
      sentByMe: message['senderUserId']?.toString() == currentUserId,
      timeLabel: _formatChatTime(message['createdAt']?.toString()),
    );
  }

  final String text;
  final bool sentByMe;
  final String timeLabel;
  final bool pending;
  final bool failed;

  String get statusLabel {
    if (failed) return 'Non envoyé';
    if (pending) return 'Envoi...';
    return timeLabel;
  }

  _ChatMessage copyWith({bool? pending, bool? failed}) {
    return _ChatMessage(
      text: text,
      sentByMe: sentByMe,
      timeLabel: timeLabel,
      pending: pending ?? this.pending,
      failed: failed ?? this.failed,
    );
  }
}

String _formatChatTime(String? value) {
  if (value == null || value.isEmpty) return '';

  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;

  final local = parsed.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

class NotificationDetailPage extends StatelessWidget {
  const NotificationDetailPage({
    super.key,
    this.title = 'Votre commande est prête !',
    this.body = 'Votre panier est prêt à être retiré.',
    this.orderId,
  });

  final String title;
  final String body;
  final String? orderId;

  @override
  Widget build(BuildContext context) => _Shell(
    title: 'Notification',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SmallOrder(orderId: orderId),
        const SizedBox(height: 18),
        Text(title, style: _big),
        const SizedBox(height: 8),
        Text(body, style: _body),
        const SizedBox(height: 26),
        Center(
          child: Image.asset(
            'assets/images/ChatGPT Image 13 août 2026, 00_45_21.png',
            width: 190,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
        const Spacer(),
        _Button(
          label: 'Voir la commande',
          onPressed: () => context.go('/order-detail'),
        ),
      ],
    ),
  );
}

class ClientReviewPage extends StatefulWidget {
  const ClientReviewPage({super.key});

  @override
  State<ClientReviewPage> createState() => _ClientReviewPageState();
}

class _ClientReviewPageState extends State<ClientReviewPage> {
  int _rating = 5;

  @override
  Widget build(BuildContext context) => _Shell(
    title: 'Avis / Notation',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Donnez votre avis', style: _headline),
        const SizedBox(height: 8),
        Text('Votre avis compte beaucoup\npour nous !', style: _body),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'assets/images/ChatGPT Image 12 août 2026, 16_27_47.png',
            height: 122,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) => IconButton(
              onPressed: () => setState(() => _rating = index + 1),
              icon: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: AppColors.blueBic,
                size: 34,
              ),
            ),
          ),
        ),
        Text('Excellent !', style: _label),
        const SizedBox(height: 12),
        Text('Votre commentaire (optionnel)', style: _label),
        const _Box('Produits frais et accueil au top !'),
        const Spacer(),
        _Button(label: 'Envoyer', onPressed: () => context.go('/home')),
      ],
    ),
  );
}

class CancelOrderPage extends StatefulWidget {
  const CancelOrderPage({super.key});

  @override
  State<CancelOrderPage> createState() => _CancelOrderPageState();
}

class _CancelOrderPageState extends State<CancelOrderPage> {
  int _selected = 4;
  static const _reasons = [
    'Changement de programme',
    'Trouvé moins cher ailleurs',
    'Délai trop court',
    'Problème de transport',
    'Autre motif',
  ];

  @override
  Widget build(BuildContext context) => _Shell(
    title: 'Annuler la commande',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SmallOrder(),
        const SizedBox(height: 20),
        Text('Pourquoi annulez-vous ?', style: _label),
        const SizedBox(height: 10),
        ..._reasons.asMap().entries.map(
          (entry) => InkWell(
            onTap: () => setState(() => _selected = entry.key),
            child: SizedBox(
              height: 34,
              child: Row(
                children: [
                  Icon(
                    _selected == entry.key
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 18,
                    color:
                        _selected == entry.key
                            ? AppColors.blueBic
                            : const Color(0xFF8BA0A3),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(entry.value, style: _row)),
                ],
              ),
            ),
          ),
        ),
        const _Box('Précisez votre motif...'),
        const Spacer(),
        _Button(
          label: 'Confirmer l’annulation',
          onPressed: () => context.go('/orders'),
        ),
      ],
    ),
  );
}

class RefundRequestPage extends StatelessWidget {
  const RefundRequestPage({super.key});

  @override
  Widget build(BuildContext context) => _Shell(
    title: 'Problème avec\nvotre commande',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SmallOrder(),
        const SizedBox(height: 22),
        Text('Décrivez ensuite, vous ?', style: _label),
        const SizedBox(height: 10),
        const _Box(
          'Le produit ne correspondait\npas à ma commande.',
          height: 82,
        ),
        const SizedBox(height: 20),
        Text('Ajouter une photo (optionnel)', style: _label),
        const SizedBox(height: 10),
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/ChatGPT Image 12 août 2026, 16_32_59.png',
                width: 76,
                height: 76,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE1E8E6)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.camera_alt_outlined),
            ),
          ],
        ),
        const Spacer(),
        _Button(
          label: 'Demander un\nremboursement',
          onPressed: () => context.go('/orders'),
        ),
      ],
    ),
  );
}

class NewAddressPage extends StatelessWidget {
  const NewAddressPage({super.key});

  @override
  Widget build(BuildContext context) => _Shell(
    title: 'Nouvelle adresse',
    child: Column(
      children: [
        const _Input('Nom du lieu', 'Maison'),
        const _Input('Nom complet', 'Ibrahima Kane'),
        const _Input('Téléphone', '+221 77 123 45 67'),
        const _Input('Adresse', 'Almadies, Dakar'),
        const _Input('Complément (optionnel)', 'Villa n°5'),
        const _Input('Pays', 'Sénégal'),
        const Spacer(),
        _Button(label: 'Enregistrer', onPressed: () => context.pop()),
      ],
    ),
  );
}

class AddPaymentPage extends StatelessWidget {
  const AddPaymentPage({super.key});

  @override
  Widget build(BuildContext context) => _Shell(
    title: 'Ajouter un moyen\nde paiement',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Carte bancaire', style: _tabActive),
            const SizedBox(width: 26),
            Text('Mobile Money', style: _tab),
          ],
        ),
        const Divider(height: 26, color: Color(0xFFE1E8E6)),
        const _Input('Numéro de carte', '•••• •••• •••• 4322     VISA'),
        const _Input('Titulaire de la carte', 'Ibrahima Kane'),
        Row(
          children: const [
            Expanded(child: _Input('Date d’expiration', '04/27')),
            SizedBox(width: 14),
            Expanded(child: _Input('CVV', '•••')),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                'Enregistrer pour mes prochains\npaiements',
                style: _label,
              ),
            ),
            Switch(
              value: true,
              activeThumbColor: AppColors.blueBic,
              onChanged: (_) {},
            ),
          ],
        ),
        const Spacer(),
        _Button(label: 'Ajouter la carte', onPressed: () => context.pop()),
      ],
    ),
  );
}

class SearchEmptyPage extends StatelessWidget {
  const SearchEmptyPage({super.key});

  @override
  Widget build(BuildContext context) => _Shell(
    title: 'Recherche',
    child: Column(
      children: [
        const _SearchBarText('Recherche'),
        const Spacer(),
        const Icon(Icons.search, size: 92, color: AppColors.blueBic),
        const SizedBox(height: 34),
        Text('Aucun résultat', style: _headline),
        const SizedBox(height: 10),
        Text(
          'Aucun résultat pour “Saumon”.\nEssayez un autre mot-clé.',
          textAlign: TextAlign.center,
          style: _body,
        ),
        const Spacer(),
        _Button(label: 'Réinitialiser', onPressed: () => context.go('/search')),
      ],
    ),
  );
}

class CartEmptyPage extends StatelessWidget {
  const CartEmptyPage({super.key});

  @override
  Widget build(BuildContext context) => _Shell(
    title: 'Mon panier',
    child: Column(
      children: [
        const _SearchBarText('Saumon'),
        const Spacer(),
        Image.asset(
          'assets/images/ChatGPT Image 13 août 2026, 00_45_21.png',
          width: 160,
          height: 130,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 28),
        Text('Votre panier est vide', style: _headline),
        const SizedBox(height: 12),
        Text(
          'Parcourez nos paniers et\nfaites de bonnes affaires\nsur des produits frais !',
          textAlign: TextAlign.center,
          style: _body,
        ),
        const Spacer(),
        _Button(
          label: 'Découvrir les paniers',
          onPressed: () => context.go('/home'),
        ),
      ],
    ),
  );
}

class _Shell extends StatelessWidget {
  const _Shell({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.blueBic),
                ),
                const Spacer(),
                Text(title, textAlign: TextAlign.center, style: _header),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: child),
          ],
        ),
      ),
    ),
  );
}

class _SmallOrder extends StatelessWidget {
  const _SmallOrder({this.orderId});

  final String? orderId;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
          width: 58,
          height: 58,
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Commande ${orderId ?? '#DC-1364'}', style: _label),
            Text('Poissonnerie Chez Moussa', style: _muted),
          ],
        ),
      ),
    ],
  );
}

class _Input extends StatelessWidget {
  const _Input(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _label),
        const SizedBox(height: 7),
        _Box(value, height: 46),
      ],
    ),
  );
}

class _Box extends StatelessWidget {
  const _Box(this.text, {this.height = 58});
  final String text;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFE1E8E6)),
      borderRadius: BorderRadius.circular(10),
    ),
    alignment: Alignment.centerLeft,
    child: Text(text, style: _row),
  );
}

class _SearchBarText extends StatelessWidget {
  const _SearchBarText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFE1E8E6)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        const Icon(Icons.search, color: Color(0xFF718487), size: 18),
        const SizedBox(width: 10),
        Text(text, style: _row),
      ],
    ),
  );
}

class _Button extends StatelessWidget {
  const _Button({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 48,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.blueBic,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, textAlign: TextAlign.center, style: _button),
    ),
  );
}

final _header = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _chatTitle = GoogleFonts.poppins(
  fontSize: 15,
  height: 1.1,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _online = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: AppColors.blueBic,
);
final _big = GoogleFonts.poppins(
  fontSize: 18,
  height: 1.35,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _headline = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _body = GoogleFonts.poppins(
  fontSize: 12,
  height: 1.7,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF526669),
);
final _label = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF263B3E),
);
final _row = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF526669),
);
final _muted = GoogleFonts.poppins(
  fontSize: 10,
  fontWeight: FontWeight.w600,
  color: const Color(0xFF718487),
);
final _hint = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: const Color(0xFF9AA8AA),
);
final _bubble = GoogleFonts.poppins(
  fontSize: 13,
  height: 1.45,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF263B3E),
);
final _bubbleTime = GoogleFonts.poppins(
  fontSize: 9,
  fontWeight: FontWeight.w600,
  color: const Color(0xFF9AA8AA),
);
final _button = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
final _tabActive = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);
final _tab = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF526669),
);
