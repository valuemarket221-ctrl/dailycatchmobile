import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/utils/navigation_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

class PickupPage extends StatelessWidget {
  const PickupPage({super.key});

  static const _items = [
    (
      'Poissonnerie Yoff',
      '3 000 FCFA',
      'Aujourd’hui 17:00 - 19:00',
      'DCYF24',
      'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
      true,
    ),
    (
      'Mareyeur Soumbédioune',
      '4 000 FCFA',
      'Demain 18:30 - 19:30',
      'DCSB12',
      'assets/images/ChatGPT Image 12 août 2026, 16_32_59.png',
      true,
    ),
    (
      'Chez Ousmane',
      '3 500 FCFA',
      '12 mai 17:00 - 18:00',
      'DCOS89',
      'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png',
      false,
    ),
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
                  Expanded(
                    child: Text(
                      'Mes réservations',
                      style: _title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Center(child: Text('À venir', style: _tabActive)),
                  ),
                  Expanded(
                    child: Center(child: Text('Terminées', style: _tab)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 2,
                width: MediaQuery.sizeOf(context).width / 2 - 44,
                color: AppColors.greenTGTG,
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder:
                      (_, __) =>
                          const Divider(height: 24, color: Color(0xFFE8EEEE)),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return InkWell(
                      onTap: () => context.push('/reservation-detail'),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              item.$5,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.$1,
                                  style: _name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(item.$2, style: _price),
                                Text(
                                  item.$3,
                                  style: _sub,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Text('Code : ${item.$4}', style: _code),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 58,
                            child: Column(
                              children: [
                                Icon(
                                  item.$6
                                      ? Icons.check_circle
                                      : Icons.favorite_border,
                                  color:
                                      item.$6
                                          ? Colors.green
                                          : const Color(0xFF8BA0A3),
                                  size: 18,
                                ),
                                const SizedBox(height: 35),
                                Text(
                                  'Confirmée',
                                  style: _confirmed,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => context.push('/reservation-detail'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.blueBic,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Voir le détail', style: _button),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class QRCodePage extends StatelessWidget {
  const QRCodePage({super.key, required this.reservationId});
  final String reservationId;
  @override
  Widget build(BuildContext context) => const PickupPage();
}

final _title = GoogleFonts.poppins(
  fontSize: 20,
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
final _price = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _sub = GoogleFonts.poppins(
  fontSize: 10,
  fontWeight: FontWeight.w600,
  color: const Color(0xFF526669),
);
final _code = GoogleFonts.poppins(
  fontSize: 10,
  fontWeight: FontWeight.w800,
  color: const Color(0xFF526669),
);
final _confirmed = GoogleFonts.poppins(
  fontSize: 9,
  fontWeight: FontWeight.w900,
  color: Colors.green,
);
final _button = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
