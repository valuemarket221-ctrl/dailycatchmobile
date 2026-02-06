import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> faqs = [
    {
      'category': 'Commandes',
      'questions': [
        {
          'question': 'Comment passer une commande ?',
          'answer':
              'Parcourez les produits disponibles près de chez vous, sélectionnez ceux que vous souhaitez acheter et validez votre commande via l\'onglet panier.',
        },
        {
          'question': 'Puis-je annuler ma commande ?',
          'answer':
              'Vous pouvez annuler votre commande jusqu\'à 1 heure avant l\'heure de retrait prévue. Au-delà, une annulation n\'est pas possible.',
        },
        {
          'question': 'Comment modifier ma commande ?',
          'answer':
              'Une fois validée, votre commande ne peut plus être modifiée. Vous pouvez ajouter de nouveaux produits en passant une nouvelle commande.',
        },
      ],
    },
    {
      'category': 'Retrait',
      'questions': [
        {
          'question': 'Où récupérer ma commande ?',
          'answer':
              'L\'adresse du commerce est indiquée dans votre confirmation de commande et sur la page de retrait. Vous pouvez également la retrouver dans l\'onglet "Mes commandes".',
        },
        {
          'question':
              'Que se passe-t-il si je ne peux pas récupérer ma commande ?',
          'answer':
              'Si vous ne pouvez pas récupérer votre commande à temps, contactez directement le commerce. Sans nouvelles de votre part, la commande sera perdue et ne sera pas remboursée.',
        },
        {
          'question': 'Dois-je montrer un code pour récupérer ma commande ?',
          'answer':
              'Oui, un code QR vous sera envoyé après votre paiement. Présentez-le au commerçant lors de votre passage.',
        },
      ],
    },
    {
      'category': 'Paiement',
      'questions': [
        {
          'question': 'Quels moyens de paiement sont acceptés ?',
          'answer':
              'Nous acceptons les cartes bancaires (Visa, Mastercard, CB), Apple Pay, Google Pay et PayPal.',
        },
        {
          'question': 'Le paiement est-il sécurisé ?',
          'answer':
              'Oui, toutes les transactions sont sécurisées via notre partenaire de paiement certifié PCI-DSS.',
        },
        {
          'question': 'Puis-je obtenir un remboursement ?',
          'answer':
              'Les remboursements sont possibles en cas de problème avec votre commande (produit non conforme, commerce fermé, etc.). Contactez notre équipe pour toute demande.',
        },
      ],
    },
    {
      'category': 'Compte',
      'questions': [
        {
          'question': 'Comment créer un compte ?',
          'answer':
              'Appuyez sur "S\'inscrire" en bas de la page de connexion et suivez les étapes pour créer votre compte.',
        },
        {
          'question': 'J\'ai oublié mon mot de passe',
          'answer':
              'Appuyez sur "Mot de passe oublié ?" sur la page de connexion et suivez les instructions pour réinitialiser votre mot de passe.',
        },
        {
          'question': 'Comment supprimer mon compte ?',
          'answer':
              'Pour supprimer votre compte, accédez à Paramètres > Mon compte > Supprimer mon compte. Cette action est irréversible.',
        },
      ],
    },
  ];

  final List<Map<String, dynamic>> contactOptions = [
    {
      'icon': Icons.chat_bubble_outline,
      'title': 'Chat en direct',
      'subtitle': ' Réponse en quelques minutes',
      'color': AppColors.greenTGTG,
    },
    {
      'icon': Icons.email_outlined,
      'title': 'Email',
      'subtitle': 'support@dailycatch.fr',
      'color': const Color(0xFF0055A4),
    },
    {
      'icon': Icons.phone_outlined,
      'title': 'Téléphone',
      'subtitle': '01 23 45 67 89',
      'color': const Color(0xFF4285F4),
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaqs =
        _searchQuery.isEmpty
            ? faqs
            : faqs
                .map((category) {
                  final filteredQuestions =
                      category['questions']
                          .where(
                            (q) =>
                                q['question'].toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ) ||
                                q['answer'].toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ),
                          )
                          .toList();
                  if (filteredQuestions.isEmpty) return null;
                  return {...category, 'questions': filteredQuestions};
                })
                .where((c) => c != null)
                .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Aide & FAQ',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Rechercher une question...',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[500]),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                });
                              },
                            )
                            : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Contact options
              Text(
                'Nous contacter',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              ...contactOptions.map((option) => _buildContactCard(option)),
              const SizedBox(height: 32),

              // FAQs
              if (filteredFaqs.isNotEmpty) ...[
                Text(
                  'Questions fréquentes',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ...filteredFaqs.map(
                  (category) =>
                      _buildFaqSection(category as Map<String, dynamic>),
                ),
              ],
              if (filteredFaqs.isEmpty && _searchQuery.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun résultat trouvé',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Essayez une autre recherche ou contactez-nous',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(Map<String, dynamic> option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (option['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              option['icon'] as IconData,
              color: option['color'] as Color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option['title'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  option['subtitle'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildFaqSection(Map<String, dynamic> category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category['category'] as String,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.greenTGTG,
          ),
        ),
        const SizedBox(height: 12),
        ...category['questions'].map<Widget>(
          (question) => _buildQuestionCard(question),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question['question'] as String,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                question['answer'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          iconColor: AppColors.greenTGTG,
          collapsedIconColor: AppColors.greenTGTG,
        ),
      ),
    );
  }
}
