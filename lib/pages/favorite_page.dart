import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/utils/favorite_store_ids.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  void initState() {
    super.initState();
    FavoriteStoreIds.load();
  }

  static const _items = [
    (
      '1',
      'Poissonnerie Yoff',
      '0,2 km',
      'assets/images/ChatGPT Image 13 août 2026, 00_41_42.png',
    ),
    (
      '2',
      'Mareyeur Soumbédioune',
      '2,1 km',
      'assets/images/ChatGPT Image 12 août 2026, 16_32_59.png',
    ),
    (
      '4',
      'Blue Sea Seafood',
      '3,2 km',
      'assets/images/ChatGPT Image 12 août 2026, 16_27_47.png',
    ),
    (
      '3',
      'Chez Ousmane',
      '4,0 km',
      'assets/images/ChatGPT Image 13 août 2026, 00_23_55.png',
    ),
    (
      '5',
      'Fruit de Mer Dakar',
      '5,1 km',
      'assets/images/ChatGPT Image 13 août 2026, 00_45_21.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 26, 26, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (context.canPop())
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.blueBic,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  Text('FAVORIS', style: _title),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ValueListenableBuilder<Set<String>>(
                  valueListenable: FavoriteStoreIds.ids,
                  builder: (context, favoriteIds, _) {
                    final items =
                        _items
                            .where((item) => favoriteIds.contains(item.$1))
                            .toList();
                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.favorite_border,
                              color: AppColors.blueBic,
                              size: 42,
                            ),
                            const SizedBox(height: 14),
                            Text('Aucun favori pour le moment', style: _name),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () => context.go('/search'),
                              child: Text('Explorer la carte', style: _link),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 18),
                      itemCount: items.length,
                      separatorBuilder:
                          (_, __) => const Divider(
                            height: 30,
                            thickness: 1,
                            color: Color(0xFFE6ECEC),
                          ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return InkWell(
                          onTap: () => context.push('/store/${item.$1}'),
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: 74,
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    item.$4,
                                    width: 68,
                                    height: 68,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 17),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.$2,
                                        style: _name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(item.$3, style: _distance),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed:
                                      () => FavoriteStoreIds.toggle(item.$1),
                                  icon: const Icon(
                                    Icons.favorite,
                                    size: 20,
                                    color: AppColors.blueBic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}

final _title = GoogleFonts.poppins(
  fontSize: 17,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _name = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _distance = GoogleFonts.poppins(
  fontSize: 11.5,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF5A6A6D),
);
final _link = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);
