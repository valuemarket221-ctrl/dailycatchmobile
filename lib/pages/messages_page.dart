import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/services/message_api_service.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final MessageApiService _messageApiService = MessageApiService();
  var _isLoading = true;
  String? _loadError;
  List<_ConversationListItem> _items = const [
    _ConversationListItem(
      title: 'Poissonnerie Yoff',
      message: 'Votre commande est prête !',
      timeLabel: '16:30',
      imageAsset: 'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
      unread: true,
      currentUserId: 'dev-client',
    ),
    _ConversationListItem(
      title: 'Mareyeur Soumbédioune',
      message: 'Merci pour votre réservation.',
      timeLabel: 'Hier',
      imageAsset: 'assets/images/ChatGPT Image 12 août 2026, 16_32_59.png',
      currentUserId: 'dev-client',
    ),
    _ConversationListItem(
      title: 'Support DailyCatch',
      message: 'Comment pouvons-nous vous aider ?',
      timeLabel: '2 mai',
      imageAsset: 'assets/icon/icon.png',
      currentUserId: 'dev-client',
    ),
    _ConversationListItem(
      title: 'Blue Sea Seafood',
      message: 'Nouvelles offres disponibles !',
      timeLabel: '1 mai',
      imageAsset: 'assets/images/ChatGPT Image 12 août 2026, 16_27_47.png',
      currentUserId: 'dev-client',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final conversations = await _messageApiService.getConversations();
      if (!mounted) return;

      setState(() {
        _items =
            conversations
                .map(_ConversationListItem.fromBackend)
                .where((item) => item.conversationId != null)
                .toList();
        _isLoading = false;
      });
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

  void _openConversation(_ConversationListItem item) {
    context.push(
      '/chat-detail',
      extra: {
        'conversationId': item.conversationId,
        'chatName': item.title,
        'currentUserId': item.currentUserId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 26, 26, 0),
          child: Column(
            children: [
              Center(child: Text('MESSAGES', style: _title)),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child:
                    _isLoading
                        ? const _MessagesLoading(key: ValueKey('loading'))
                        : _loadError == null
                        ? const SizedBox.shrink(key: ValueKey('ready'))
                        : _MessagesNotice(
                          key: const ValueKey('notice'),
                          onRetry: _loadConversations,
                        ),
              ),
              SizedBox(height: _loadError == null ? 12 : 18),
              Expanded(
                child:
                    _items.isEmpty
                        ? const _MessagesEmpty()
                        : RefreshIndicator(
                          color: AppColors.blueBic,
                          onRefresh: _loadConversations,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 18),
                            itemCount: _items.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return _MessageTile(
                                item: item,
                                onTap: () => _openConversation(item),
                              );
                            },
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.item, required this.onTap});

  final _ConversationListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                item.imageAsset,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => const ColoredBox(
                      color: Color(0xFFEAF4F2),
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: Icon(
                          Icons.storefront_outlined,
                          color: AppColors.blueBic,
                        ),
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: _name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: _message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item.timeLabel, style: _time),
                if (item.unread) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: 9.5,
                    height: 9.5,
                    decoration: const BoxDecoration(
                      color: AppColors.blueBic,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesLoading extends StatelessWidget {
  const _MessagesLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 3,
      child: LinearProgressIndicator(
        minHeight: 3,
        color: AppColors.blueBic,
        backgroundColor: Color(0xFFE9F2F0),
      ),
    );
  }
}

class _MessagesNotice extends StatelessWidget {
  const _MessagesNotice({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            size: 18,
            color: AppColors.blueBic,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Messages hors ligne pour le moment.', style: _notice),
          ),
          TextButton(onPressed: onRetry, child: Text('Réessayer', style: _link)),
        ],
      ),
    );
  }
}

class _MessagesEmpty extends StatelessWidget {
  const _MessagesEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.forum_outlined,
            size: 46,
            color: Color(0xFF8AA0A3),
          ),
          const SizedBox(height: 12),
          Text('Aucune conversation', style: _emptyTitle),
          const SizedBox(height: 6),
          Text(
            'Vos échanges avec les commerces apparaîtront ici.',
            textAlign: TextAlign.center,
            style: _notice,
          ),
        ],
      ),
    );
  }
}

class _ConversationListItem {
  const _ConversationListItem({
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.imageAsset,
    required this.currentUserId,
    this.conversationId,
    this.unread = false,
  });

  factory _ConversationListItem.fromBackend(Map<String, dynamic> conversation) {
    final storeId = conversation['storeId']?.toString();
    final partnerUserId = conversation['partnerUserId']?.toString();
    final clientUserId = conversation['clientUserId']?.toString();
    final title = _readableTitle(storeId ?? partnerUserId ?? 'DailyCatch');

    return _ConversationListItem(
      conversationId: conversation['id']?.toString(),
      title: title,
      message:
          conversation['lastMessage']?.toString().trim().isNotEmpty == true
              ? conversation['lastMessage'].toString()
              : 'Conversation ouverte',
      timeLabel: _formatConversationTime(
        conversation['lastMessageAt']?.toString() ??
            conversation['createdAt']?.toString(),
      ),
      imageAsset: _imageForTitle(title),
      currentUserId: clientUserId ?? 'dev-client',
    );
  }

  final String? conversationId;
  final String title;
  final String message;
  final String timeLabel;
  final String imageAsset;
  final bool unread;
  final String currentUserId;
}

String _readableTitle(String value) {
  final cleaned = value
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (cleaned.isEmpty) return 'DailyCatch';

  return cleaned
      .split(' ')
      .map((word) {
        if (word.length <= 2) return word.toUpperCase();
        return '${word[0].toUpperCase()}${word.substring(1)}';
      })
      .join(' ');
}

String _imageForTitle(String title) {
  final normalized = title.toLowerCase();
  if (normalized.contains('mareyeur')) {
    return 'assets/images/ChatGPT Image 12 août 2026, 16_32_59.png';
  }
  if (normalized.contains('blue')) {
    return 'assets/images/ChatGPT Image 12 août 2026, 16_27_47.png';
  }
  if (normalized.contains('support')) return 'assets/icon/icon.png';
  return 'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png';
}

String _formatConversationTime(String? value) {
  if (value == null || value.isEmpty) return '';

  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;

  final local = parsed.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final messageDay = DateTime(local.year, local.month, local.day);

  if (messageDay == today) {
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
  if (messageDay == today.subtract(const Duration(days: 1))) return 'Hier';

  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}';
}

final _title = GoogleFonts.poppins(
  fontSize: 17,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _name = GoogleFonts.poppins(
  fontSize: 12.5,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _message = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: const Color(0xFF526669),
);
final _time = GoogleFonts.poppins(
  fontSize: 10.5,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF7C8A8D),
);
final _notice = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: const Color(0xFF526669),
);
final _link = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: AppColors.blueBic,
);
final _emptyTitle = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
