import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

class LegalPage extends StatefulWidget {
  const LegalPage({super.key});

  @override
  State<LegalPage> createState() => _LegalPageState();
}

class _LegalPageState extends State<LegalPage> {
  int _selectedTab = 0;

  final List<Map<String, String>> tabs = [
    {'title': 'CGU', 'file': 'cgu'},
    {'title': 'Confidentialité', 'file': 'privacy'},
    {'title': 'Mentions légales', 'file': 'legal'},
  ];

  final Map<String, String> content = {
    'cgu': '''
**CONDITIONS GÉNÉRALES D'UTILISATION**

**1. Objet**

Les présentes Conditions Générales d'Utilisation (CGU) régissent l'utilisation de l'application DailyCatch. En utilisant notre application, vous acceptez ces conditions.

**2. Description du service**

DailyCatch est une plateforme permettant aux utilisateurs de commander des produits alimentaires auprès de commerces partenaires à des prix réduits, afin de lutter contre le gaspillage alimentaire.

**3. Inscription et compte utilisateur**

Pour utiliser DailyCatch, vous devez créer un compte en fournissant des informations valides. Vous êtes responsable de la confidentialité de votre mot de passe.

**4. Commandes et paiements**

- Les commandes sont passées via l'application
- Le paiement s'effectue en ligne au moment de la commande
- Les prix indiqués sont ceux pratiqués par les commerces partenaires

**5. Retrait des commandes**

Vous devez récupérer votre commande pendant les horaires indiqués. En cas de non-retrait, aucun remboursement ne sera effectué.

**6. Droit de rétractation**

Conformément à la réglementation, vous disposez d'un délai de 14 jours pour exercer votre droit de rétractation, sauf pour les produits alimentaires périssables.

**7. Responsabilités**

DailyCatch agit comme intermédiaire entre les utilisateurs et les commerces partenaires. Nous ne pouvons être tenus responsables de la qualité des produits.

**8. Protection des données**

Vos données personnelles sont protégées conformément à notre politique de confidentialité.

**9. Modification des CGU**

Nous nous réservons le droit de modifier ces conditions à tout moment.

**10. Droit applicable**

Les présentes CGU sont soumises au droit français.
''',
    'privacy': '''
**POLITIQUE DE CONFIDENTIALITÉ**

**1. Introduction**

DailyCatch s'engage à protéger votre vie privée. Cette politique décrit comment nous collectons, utilisons et partageons vos données personnelles.

**2. Données collectées**

Nous collectons les informations suivantes :
- Données d'identification (nom, email, téléphone)
- Données de paiement (sécurisées par notre partenaire)
- Données de localisation (avec votre consentement)
- Données de navigation et d'utilisation de l'application

**3. Utilisation des données**

Vos données sont utilisées pour :
- Créer et gérer votre compte
- Traiter vos commandes
- Améliorer nos services
- Vous envoyer des notifications (avec votre consentement)

**4. Partage des données**

Nous partageons vos données avec :
- Les commerces partenaires (pour traiter vos commandes)
- Nos prestataires de paiement (sécurisés)
- Les autorités légales (si requis par la loi)

**5. Conservation des données**

Vos données sont conservées pendant la durée nécessaire aux finalités pour lesquelles elles ont été collectées.

**6. Vos droits**

Vous disposez des droits suivants :
- Accès à vos données
- Rectification de vos données
- Effacement de vos données
- Opposition au traitement
- Portabilité de vos données

**7. Sécurité**

Nous mettons en œuvre des mesures de sécurité appropriées pour protéger vos données.

**8. Cookies**

L'application utilise des cookies pour améliorer votre expérience.

**9. Contact**

Pour toute question, contactez : privacy@dailycatch.fr
''',
    'legal': '''
**MENTIONS LÉGALES**

**ÉDITEUR DE L'APPLICATION**

DailyCatch SAS
Siège social : 15 Rue du Port, 29000 Quimper
SIREN : 123 456 789
SIRET : 123 456 789 00012
Capital social : 10 000 €

Directeur de publication : [Nom du directeur]

**HÉBERGEUR**

[Hébergeur]
[Adresse]
[Coordonnées]

**PROPRIÉTÉ INTELLECTUELLE**

L'ensemble du contenu de cette application (textes, images, graphismes, logo, icônes, etc.) est la propriété de DailyCatch SAS, sauf mention contraire. Toute reproduction est strictement interdite.

**LIENS HYPERTEXTES**

L'application peut contenir des liens vers d'autres sites. DailyCatch n'exerce aucun contrôle sur ces sites et n'assume aucune responsabilité quant à leur contenu.

**RESPONSABILITÉ**

DailyCatch s'efforce d'assurer l'exactitude et la mise à jour des informations diffusées sur cette application. Nous nous réservons le droit de corriger, à tout moment et sans préavis, le contenu de cette application.

**DROIT APPLICABLE**

Les présentes mentions légales sont soumises au droit français.

**CONTACT**

Pour toute question : contact@dailycatch.fr
''',
  };

  @override
  Widget build(BuildContext context) {
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
          'Informations légales',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children:
                  tabs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final tab = entry.value;
                    final isSelected = _selectedTab == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTab = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppColors.greenTGTG
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tab['title']!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                              color:
                                  isSelected ? Colors.white : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildMarkdownContent(
                content[tabs[_selectedTab]['file']]!,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownContent(String text) {
    final lines = text.split('\n');
    final widgets = <Widget>[];
    String? currentParagraph;

    for (var line in lines) {
      if (line.startsWith('**') && line.endsWith('**')) {
        if (currentParagraph != null) {
          widgets.add(_buildParagraph(currentParagraph));
          currentParagraph = null;
        }
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              line.replaceAll('**', ''),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        );
      } else if (line.trim().isEmpty) {
        if (currentParagraph != null) {
          widgets.add(_buildParagraph(currentParagraph));
          currentParagraph = null;
        }
      } else if (line.startsWith('**')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              line.replaceAll('**', ''),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        );
      } else if (line.startsWith('- ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.greenTGTG,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.startsWith('   - ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 32, bottom: 4),
            child: Text(
              line.substring(5),
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
        );
      } else {
        currentParagraph =
            currentParagraph != null ? '$currentParagraph $line' : line;
      }
    }

    if (currentParagraph != null) {
      widgets.add(_buildParagraph(currentParagraph));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey[700],
          height: 1.5,
        ),
      ),
    );
  }
}
