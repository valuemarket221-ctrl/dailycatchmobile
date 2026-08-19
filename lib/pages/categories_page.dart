import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  static const _items = [
    ('Poissons', 'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png'),
    ('Fruits de mer', 'assets/images/ChatGPT Image 12 août 2026, 16_32_59.png'),
    ('Filets', 'assets/images/saumon.jpg'),
    ('Coquillages', 'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png'),
    ('Crustacés', 'assets/images/homard.jpg'),
    ('Autres', 'assets/images/ChatGPT Image 13 août 2026, 00_45_21.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Catégories', style: _title),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  itemCount: _items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 18,
                    childAspectRatio: 1.23,
                  ),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              item.$2,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(item.$1, style: _label),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }
}

final _title = GoogleFonts.poppins(
  fontSize: 20,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _label = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: const Color(0xFF263B3E),
);
