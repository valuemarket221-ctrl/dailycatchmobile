import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _slides = [
    _OnboardingData(
      title: 'Sauvez du bon\npoisson, pas du\npoisson pour rien.',
      subtitle: 'Des paniers surprise à prix réduits\nprès de chez vous.',
      image: 'assets/images/ChatGPT Image 12 août 2026, 16_32_59.png',
      imageHeightFactor: .9,
      button: 'Suivant',
    ),
    _OnboardingData(
      title: 'Agir ensemble\ncontre le gaspillage\nalimentaire.',
      subtitle:
          'Chaque geste compte pour\nla planète et pour\nles communautés locales.',
      button: 'Suivant',
      points: [
        _OnboardingPoint(Icons.favorite_border, 'Bon pour vous'),
        _OnboardingPoint(Icons.groups_2_outlined, 'Bon pour les pêcheurs'),
        _OnboardingPoint(Icons.eco_outlined, 'Bon pour la planète'),
      ],
    ),
    _OnboardingData(
      title: 'Des poissons frais\nà prix réduit',
      subtitle:
          'Profitez de produits de qualité\nà petit prix, disponibles\nchaque jour.',
      image: 'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png',
      imageHeightFactor: .88,
      button: 'Suivant',
    ),
    _OnboardingData(
      title: 'Trouvez, réservez,\nrécupérez.',
      subtitle: 'C’est simple, rapide\net sécurisé.',
      button: 'Commencer',
      points: [
        _OnboardingPoint(Icons.search_outlined, 'Trouvez un panier'),
        _OnboardingPoint(Icons.calendar_month_outlined, 'Réservez en 1 clic'),
        _OnboardingPoint(
          Icons.volunteer_activism_outlined,
          'Récupérez et savourez',
        ),
      ],
    ),
  ];

  final _controller = PageController();
  int _index = 0;

  void _next() {
    if (_index == _slides.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _finish() => context.go('/login');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _controller,
        onPageChanged: (value) => setState(() => _index = value),
        itemCount: _slides.length,
        itemBuilder:
            (context, index) => _OnboardingSlide(
              data: _slides[index],
              index: index,
              count: _slides.length,
              onNext: _next,
              onSkip: _finish,
            ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.data,
    required this.index,
    required this.count,
    required this.onNext,
    required this.onSkip,
  });

  final _OnboardingData data;
  final int index;
  final int count;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomPadding = media.padding.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(30, 26, 30, 18 + bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${index + 1}/$count', style: _counter),
            const SizedBox(height: 28),
            Text(data.title, style: _title),
            const SizedBox(height: 20),
            Text(data.subtitle, style: _subtitle),
            const SizedBox(height: 24),
            Expanded(child: _SlideVisual(data: data)),
            const SizedBox(height: 18),
            _PrimaryButton(label: data.button, onPressed: onNext),
            const SizedBox(height: 18),
            Center(
              child: TextButton(
                onPressed: onSkip,
                child: Text(
                  index == count - 1 ? 'Plus tard' : 'Passer',
                  style: _skip,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideVisual extends StatelessWidget {
  const _SlideVisual({required this.data});

  final _OnboardingData data;

  @override
  Widget build(BuildContext context) {
    if (data.points.isNotEmpty) {
      return Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(top: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                data.points
                    .map(
                      (point) => Padding(
                        padding: const EdgeInsets.only(bottom: 36),
                        child: _PointRow(point: point),
                      ),
                    )
                    .toList(),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Image.asset(
            data.image!,
            width: double.infinity,
            height: constraints.maxHeight * data.imageHeightFactor.clamp(.1, 1),
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        );
      },
    );
  }
}

class _PointRow extends StatelessWidget {
  const _PointRow({required this.point});

  final _OnboardingPoint point;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 42,
          height: 42,
          child: Icon(point.icon, color: AppColors.blueBic, size: 30),
        ),
        const SizedBox(width: 22),
        Expanded(child: Text(point.label, style: _point)),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.blueBic,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(label, style: _button),
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.title,
    required this.subtitle,
    required this.button,
    this.image,
    this.imageHeightFactor = .5,
    this.points = const [],
  });

  final String title;
  final String subtitle;
  final String button;
  final String? image;
  final double imageHeightFactor;
  final List<_OnboardingPoint> points;
}

class _OnboardingPoint {
  const _OnboardingPoint(this.icon, this.label);

  final IconData icon;
  final String label;
}

final _counter = GoogleFonts.poppins(
  fontSize: 15,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _title = GoogleFonts.poppins(
  fontSize: 27,
  height: 1.18,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _subtitle = GoogleFonts.poppins(
  fontSize: 16,
  height: 1.65,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF526669),
);
final _point = GoogleFonts.poppins(
  fontSize: 16.5,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF263B3E),
);
final _button = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
final _skip = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);
