import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});
  static const _orders = [
    (
      'Poissonnerie Yoff',
      '10 mai 2024 • 17:00 - 19:00',
      '13 000 FCFA',
      'Confirmée',
      'assets/images/ChatGPT Image 12 août 2026, 16_32_59.png',
      Colors.green,
    ),
    (
      'Blue Sea Seafood',
      '8 mai 2024 • 18:00 - 20:00',
      '5 000 FCFA',
      'Terminée',
      'assets/images/ChatGPT Image 12 août 2026, 16_27_47.png',
      Colors.green,
    ),
    (
      'Mareyeur Soumbédioune',
      '5 mai 2024 • 11:30 - 19:30',
      '4 000 FCFA',
      'Terminée',
      'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png',
      Colors.green,
    ),
    (
      'Chez Ousmane',
      '5 mai 2024 • 17:00 - 18:00',
      '3 500 FCFA',
      'Annulée',
      'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
      Colors.red,
    ),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.blueBic),
                ),
                const Spacer(),
                Text('MES COMMANDES', style: _header),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Center(child: Text('À venir', style: _tabActive)),
                ),
                Expanded(child: Center(child: Text('Terminées', style: _tab))),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 2,
              width: MediaQuery.sizeOf(context).width / 2 - 44,
              color: AppColors.greenTGTG,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: _orders.length,
                separatorBuilder:
                    (_, __) =>
                        const Divider(height: 28, color: Color(0xFFE8EEEE)),
                itemBuilder: (context, index) {
                  final o = _orders[index];
                  return InkWell(
                    onTap: () => context.push('/order-detail'),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            o.$5,
                            width: 68,
                            height: 68,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(o.$1, style: _name),
                              Text(o.$2, style: _sub),
                              const SizedBox(height: 5),
                              Text(o.$3, style: _price),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            const Icon(
                              Icons.favorite_border,
                              size: 18,
                              color: Color(0xFF526669),
                            ),
                            const SizedBox(height: 32),
                            Text(o.$4, style: _status.copyWith(color: o.$6)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: const BottomNavBar(currentIndex: 0),
  );
}

final _header = GoogleFonts.poppins(
  fontSize: 15,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _tabActive = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _tab = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w800,
  color: const Color(0xFF526669),
);
final _name = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _sub = GoogleFonts.poppins(
  fontSize: 10,
  fontWeight: FontWeight.w600,
  color: const Color(0xFF526669),
);
final _price = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _status = GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w900);
