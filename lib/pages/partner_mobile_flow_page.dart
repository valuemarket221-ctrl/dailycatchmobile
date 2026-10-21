import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/utils/navigation_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/widgets/partner_bottom_nav_bar.dart';

class PartnerTypePage extends StatefulWidget {
  const PartnerTypePage({super.key});

  @override
  State<PartnerTypePage> createState() => _PartnerTypePageState();
}

class _PartnerTypePageState extends State<PartnerTypePage> {
  static const _types = [
    (Icons.set_meal_outlined, 'Poissonnerie'),
    (Icons.local_shipping_outlined, 'Mareyeur'),
    (Icons.restaurant_outlined, 'Restaurant'),
    (Icons.store_mall_directory_outlined, 'Supermarché'),
    (Icons.tune_outlined, 'Autre'),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) => _PageShell(
    title: 'TYPE DE COMMERCE',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quel est votre type de commerce ?', style: _section),
        const SizedBox(height: 28),
        ..._types.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ChoiceTile(
              icon: entry.value.$1,
              label: entry.value.$2,
              selected: entry.key == _selectedIndex,
              onTap: () => setState(() => _selectedIndex = entry.key),
            ),
          ),
        ),
        const Spacer(),
        _PrimaryButton(
          label: 'Continuer',
          onPressed: () => context.go('/partner/business-info'),
        ),
      ],
    ),
  );
}

class PartnerBusinessInfoPage extends StatelessWidget {
  const PartnerBusinessInfoPage({super.key});

  @override
  Widget build(BuildContext context) => _PageShell(
    title: 'INFORMATIONS COMMERCE',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Field(label: 'Nom du commerce', value: 'Poissonnerie Yoff'),
        const _Field(label: 'Adresse', value: 'Marché de Yoff, Dakar'),
        Row(
          children: const [
            Expanded(child: _Field(label: 'Code postal', value: '10500')),
            SizedBox(width: 18),
            Expanded(child: _Field(label: 'Ville', value: 'Dakar')),
          ],
        ),
        const _Field(label: 'Téléphone', value: '+221 77 123 45 67'),
        const _Field(label: 'Email', value: 'contact@yoffpoisson.sn'),
        const Spacer(),
        _PrimaryButton(
          label: 'Continuer',
          onPressed: () => context.go('/partner/extra-info'),
        ),
      ],
    ),
  );
}

class PartnerExtraInfoPage extends StatelessWidget {
  const PartnerExtraInfoPage({super.key});

  @override
  Widget build(BuildContext context) => _PageShell(
    title: 'INFORMATIONS SUPPLÉMENTAIRES',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Field(
          label: 'Description de votre commerce',
          value:
              'Poissonnerie spécialisée dans les\npoissons frais et fruits de mer.',
          height: 78,
        ),
        const _Field(label: 'Horaires d’ouverture', value: '07:00 - 19:00'),
        Text('Jours d’ouverture', style: _label),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _Day('Lun', true),
            _Day('Mar', true),
            _Day('Mer', true),
            _Day('Jeu', true),
            _Day('Ven', true),
            _Day('Sam', false),
            _Day('Dim', false),
          ],
        ),
        const SizedBox(height: 28),
        Text('Photo de votre commerce', style: _label),
        const SizedBox(height: 16),
        Row(
          children: [
            _Photo('assets/images/ChatGPT Image 12 août 2026, 16_27_47.png'),
            const SizedBox(width: 14),
            _Photo('assets/images/ChatGPT Image 13 août 2026, 00_45_21.png'),
            const SizedBox(width: 14),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDDE6E6), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFF718487),
              ),
            ),
          ],
        ),
        const Spacer(),
        _PrimaryButton(
          label: 'Continuer',
          onPressed: () => context.go('/partner/documents'),
        ),
      ],
    ),
  );
}

class PartnerDocumentsPage extends StatelessWidget {
  const PartnerDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) => _PageShell(
    title: 'DOCUMENTS',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ajoutez les documents requis', style: _section),
        const SizedBox(height: 26),
        const _Document('Photo de la devanture'),
        const _Document('Pièce d’identité'),
        const _Document('RIB / Coordonnées bancaires'),
        const _Document('Autorisation / Licence\n(si applicable)'),
        const Spacer(),
        _PrimaryButton(
          label: 'Continuer',
          onPressed: () => context.go('/partner/account-created'),
        ),
      ],
    ),
  );
}

class PartnerAccountCreatedPage extends StatelessWidget {
  const PartnerAccountCreatedPage({super.key});

  @override
  Widget build(BuildContext context) => _PageShell(
    title: 'COMPTE CRÉÉ',
    child: Column(
      children: [
        const Spacer(flex: 2),
        const Icon(
          Icons.verified_outlined,
          size: 118,
          color: AppColors.blueBic,
        ),
        const SizedBox(height: 42),
        Text('Félicitations !', style: _bigTitle),
        const SizedBox(height: 22),
        Text(
          'Votre compte commerçant a été\ncréé avec succès.\n\nVous pouvez maintenant commencer\nà publier vos paniers surprise.',
          textAlign: TextAlign.center,
          style: _body,
        ),
        const Spacer(flex: 3),
        _PrimaryButton(
          label: 'Accéder à mon espace',
          onPressed: () => context.go('/partner/publish-basket'),
        ),
        const SizedBox(height: 18),
        TextButton(
          onPressed: () => context.go('/home'),
          child: Text('Plus tard', style: _link),
        ),
      ],
    ),
  );
}

class PublishBasketPage extends StatelessWidget {
  const PublishBasketPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 24, 26, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text('PUBLIER UN PANIER', style: _header)),
            const SizedBox(height: 32),
            Text('Informations sur le panier', style: _section),
            const SizedBox(height: 20),
            const _Field(
              label: 'Titre du panier',
              value: 'Panier surprise du jour',
            ),
            const _Field(
              label: 'Description',
              value: 'Assortiment de poissons frais du jour,\nsurprise.',
              height: 82,
            ),
            const _Field(
              label: 'Poids estimé',
              value: '3 - 4 kg',
              trailing: true,
            ),
            const _Field(label: 'Quantité disponible', value: '10'),
            const _Field(label: 'Prix', value: '3000 FCFA', boldValue: true),
          ],
        ),
      ),
    ),
    bottomNavigationBar: const PartnerBottomNavBar(currentIndex: 1),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: _PrimaryButton(
        label: 'Continuer',
        onPressed: () => context.go('/partner/publish-basket-time'),
      ),
    ),
  );
}

class PublishBasketTimePage extends StatelessWidget {
  const PublishBasketTimePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 24, 26, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text('PUBLIER UN PANIER (2)', style: _header)),
            const SizedBox(height: 44),
            Text('Retrait', style: _section),
            const SizedBox(height: 24),
            const _Field(label: 'Date', value: 'Aujourd’hui', trailing: true),
            Text('Créneaux horaires', style: _label),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E8E8)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  _Slot('17:00 - 19:00', true),
                  Divider(height: 1, color: Color(0xFFE6ECEC)),
                  _Slot('19:00 - 21:00', false),
                ],
              ),
            ),
            const Spacer(),
            _PrimaryButton(
              label: 'Publier le panier',
              onPressed: () => context.go('/partner/basket-published'),
            ),
            const SizedBox(height: 52),
          ],
        ),
      ),
    ),
    bottomNavigationBar: const PartnerBottomNavBar(currentIndex: 1),
  );
}

class BasketPublishedPage extends StatelessWidget {
  const BasketPublishedPage({super.key});

  @override
  Widget build(BuildContext context) => _PageShell(
    title: 'PANIER PUBLIÉ',
    child: Column(
      children: [
        const Spacer(flex: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/ChatGPT Image 13 août 2026, 00_45_21.png',
            width: 210,
            height: 164,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 48),
        Text('Votre panier a été publié !', style: _headline),
        const SizedBox(height: 22),
        Text(
          'Il est maintenant visible par\nles utilisateurs.',
          textAlign: TextAlign.center,
          style: _body,
        ),
        const Spacer(flex: 3),
        _PrimaryButton(
          label: 'Voir le panier',
          onPressed: () => context.go('/store/1'),
        ),
        const SizedBox(height: 18),
      ],
    ),
  );
}

class AboutDailyCatchPage extends StatelessWidget {
  const AboutDailyCatchPage({super.key});

  @override
  Widget build(BuildContext context) => _PageShell(
    title: 'À PROPOS',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('À propos de DailyCatch', style: _bigTitle),
        const SizedBox(height: 28),
        Text(
          'DailyCatch est la première plateforme\nau Sénégal dédiée à la lutte contre le\ngaspillage alimentaire dans le secteur\nde la pêche.\n\nNotre mission est de connecter les\nprofessionnels de la mer avec les\nconsommateurs pour sauver du\npoisson, soutenir les revenus locaux\net protéger notre environnement.',
          style: _bodyLeft,
        ),
        const Spacer(),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/ChatGPT Image 12 août 2026, 16_27_47.png',
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}

class HowItWorksDetailPage extends StatelessWidget {
  const HowItWorksDetailPage({super.key});

  @override
  Widget build(BuildContext context) => _PageShell(
    title: 'COMMENT ÇA MARCHE ?',
    child: Column(
      children: [
        const SizedBox(height: 24),
        const _TimelineStep(
          1,
          'Découvrez',
          'Trouvez des paniers surprise\ndisponibles près de chez vous.',
        ),
        const _TimelineStep(
          2,
          'Réservez',
          'Réservez et payez directement\nsur l’application.',
        ),
        const _TimelineStep(
          3,
          'Récupérez',
          'Récupérez votre panier au\ncréneau choisi.',
        ),
        const _TimelineStep(
          4,
          'Sauvez',
          'Profitez de délicieux produits\ntout en évitant le gaspillage.',
          last: true,
        ),
        const Spacer(),
        _PrimaryButton(
          label: 'Explorer les offres',
          onPressed: () => context.go('/home'),
        ),
      ],
    ),
  );
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) => _PageShell(
    title: 'CGU',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('Conditions générales d’utilisation', style: _headline),
        const SizedBox(height: 8),
        Text('Dernière mise à jour : 30 avril 2024', style: _muted),
        const SizedBox(height: 28),
        Text('1. Objet', style: _section),
        const SizedBox(height: 10),
        Text(
          'Les présentes Conditions Générales\nd’Utilisation (CGU) régissent l’utilisation\nde l’application DailyCatch.',
          style: _bodyLeft,
        ),
        const SizedBox(height: 24),
        Text('2. Utilisation du service', style: _section),
        const SizedBox(height: 10),
        Text(
          'L’application permet aux utilisateurs\nde réserver des paniers de produits\nalimentaires invendus proposés par\ndes commerces partenaires.',
          style: _bodyLeft,
        ),
        const SizedBox(height: 24),
        Text('3. Réservations et paiements', style: _section),
        const SizedBox(height: 10),
        Text(
          'Les réservations sont fermes et\ndéfinitives après paiement.',
          style: _bodyLeft,
        ),
        const Spacer(),
        _PrimaryButton(
          label: 'Accepter et continuer',
          onPressed: () => context.go('/home'),
        ),
      ],
    ),
  );
}

class _PageShell extends StatelessWidget {
  const _PageShell({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(26, 24, 26, 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 52,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (context.canPop())
                          IconButton(
                            onPressed: () => safePop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.blueBic,
                            ),
                          )
                        else
                          const SizedBox(width: 48),
                        const Spacer(),
                        Text(title, style: _header),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                    Expanded(child: child),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xFFE8F4F3) : Colors.white,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? const Color(0xFFB4DAD7) : const Color(0xFFE0E8E8),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 27,
              color: selected ? AppColors.blueBic : const Color(0xFF718487),
            ),
            const SizedBox(width: 22),
            Expanded(child: Text(label, style: _fieldText)),
            if (selected)
              const Icon(
                Icons.check_circle,
                color: AppColors.blueBic,
                size: 20,
              ),
          ],
        ),
      ),
    ),
  );
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    this.height = 62,
    this.trailing = false,
    this.boldValue = false,
  });

  final String label;
  final String value;
  final double height;
  final bool trailing;
  final bool boldValue;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _label),
        const SizedBox(height: 8),
        Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E8E8)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: boldValue ? _fieldBold : _fieldText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing)
                const Icon(Icons.keyboard_arrow_down, color: Color(0xFF718487)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Day extends StatelessWidget {
  const _Day(this.text, this.active);
  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) => Container(
    width: 50,
    height: 31,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: active ? AppColors.blueBic : Colors.white,
      border: Border.all(color: const Color(0xFFE0E8E8)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(text, style: active ? _dayActive : _dayInactive),
  );
}

class _Photo extends StatelessWidget {
  const _Photo(this.asset);
  final String asset;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.asset(asset, width: 76, height: 76, fit: BoxFit.cover),
  );
}

class _Document extends StatelessWidget {
  const _Document(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    height: 70,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFE0E8E8)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        const Icon(Icons.badge_outlined, color: Color(0xFF718487), size: 30),
        const SizedBox(width: 20),
        Expanded(child: Text(text, style: _fieldText)),
        Text('Ajouter', style: _linkSmall),
      ],
    ),
  );
}

class _Slot extends StatelessWidget {
  const _Slot(this.text, this.active);
  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 60,
    child: Row(
      children: [
        const SizedBox(width: 16),
        Expanded(child: Text(text, style: active ? _slotActive : _fieldText)),
        if (active)
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.radio_button_checked,
              size: 20,
              color: AppColors.blueBic,
            ),
          ),
      ],
    ),
  );
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep(this.number, this.title, this.text, {this.last = false});
  final int number;
  final String title;
  final String text;
  final bool last;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 39,
              height: 39,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.blueBic,
                shape: BoxShape.circle,
              ),
              child: Text('$number', style: _number),
            ),
            if (!last)
              Expanded(
                child: Container(width: 1.4, color: const Color(0xFFD7E2E2)),
              ),
          ],
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _headline),
                const SizedBox(height: 8),
                Text(text, style: _bodyLeft),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 56,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.blueBic,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: _button),
    ),
  );
}

final _header = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _section = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF263B3E),
);
final _label = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w800,
  color: const Color(0xFF526669),
);
final _fieldText = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w800,
  color: const Color(0xFF526669),
);
final _fieldBold = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF263B3E),
);
final _button = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
final _link = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);
final _linkSmall = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);
final _dayActive = GoogleFonts.poppins(
  fontSize: 10,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
final _dayInactive = GoogleFonts.poppins(
  fontSize: 10,
  fontWeight: FontWeight.w800,
  color: const Color(0xFF526669),
);
final _bigTitle = GoogleFonts.poppins(
  fontSize: 20,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _headline = GoogleFonts.poppins(
  fontSize: 15,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _body = GoogleFonts.poppins(
  fontSize: 12,
  height: 1.9,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF526669),
);
final _bodyLeft = GoogleFonts.poppins(
  fontSize: 13,
  height: 1.85,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF526669),
);
final _muted = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF8A9698),
);
final _slotActive = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);
final _number = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
