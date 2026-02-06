import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatName;
  final Color avatarColor;

  const ChatDetailPage({
    super.key,
    required this.chatName,
    required this.avatarColor,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Charger des messages fictifs
    _messages.addAll([
      {
        'texte': 'Bonjour! Comment puis-je vous aider?',
        'envoyeParMoi': false,
        'heure': '10:00',
      },
      {
        'texte': 'Je voudrais commander du saumon frais',
        'envoyeParMoi': true,
        'heure': '10:05',
      },
      {
        'texte': 'Bien sûr! Nous avons du saumon frais disponible.',
        'envoyeParMoi': false,
        'heure': '10:06',
      },
      {
        'texte': 'Super! Quel est le prix?',
        'envoyeParMoi': true,
        'heure': '10:07',
      },
      {
        'texte': 'Le saumon frais est à 25€/kg',
        'envoyeParMoi': false,
        'heure': '10:08',
      },
    ]);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final now = TimeOfDay.now();
    final heure = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add({
        'texte': _messageController.text.trim(),
        'envoyeParMoi': true,
        'heure': heure,
      });
    });

    _messageController.clear();

    // Scroll vers le bas
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    // Réponse automatique après un délai
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final now = TimeOfDay.now();
        final heure = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        setState(() {
          _messages.add({
            'texte': 'Merci pour votre message! Nous vous répondrons sous peu.',
            'envoyeParMoi': false,
            'heure': heure,
          });
        });

        // Scroll vers le bas après la réponse
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && _scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: widget.avatarColor,
              child: Text(
                widget.chatName[0],
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.chatName,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blueBic),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone, color: AppColors.blueBic),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appel vocal soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: AppColors.blueBic),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appel vidéo soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.blueBic),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Plus d'options soon")),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          // Zone de saisie
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: AppColors.blueBic),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pièce jointe soon')),
                    );
                  },
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Écrivez un message...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.blueBic,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final estEnvoyeParMoi = message['envoyeParMoi'] as bool;
    return Align(
      alignment: estEnvoyeParMoi
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: estEnvoyeParMoi ? AppColors.blueBic : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: estEnvoyeParMoi ? const Radius.circular(20) : Radius.zero,
            bottomRight: estEnvoyeParMoi ? Radius.zero : const Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: estEnvoyeParMoi
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message['texte'] as String,
              style: GoogleFonts.poppins(
                color: estEnvoyeParMoi ? Colors.white : Colors.black,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message['heure'] as String,
              style: GoogleFonts.poppins(
                color: estEnvoyeParMoi
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
