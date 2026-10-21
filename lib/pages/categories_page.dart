import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  static const _categories = [
    ('Poissons', 'Poisson', 'assets/images/category_fish.jpg'),
    ('Fruits de mer', 'Fruits de mer', 'assets/images/crevette.jpg'),
    ('Filets', 'Filets', 'assets/images/saumon.jpg'),
    ('Coquillages', 'Coquillages', 'assets/images/category_shellfish.jpg'),
    ('Crustacés', 'Crustaces', 'assets/images/homard.jpg'),
    ('Autres', 'Autres', 'assets/images/langoustines.jpg'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      title: const Text('Catégories'),
      backgroundColor: Colors.white,
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          itemCount: _categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 20,
            childAspectRatio: 1.12,
          ),
          itemBuilder: (context, index) {
            final (label, filter, image) = _categories[index];
            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap:
                  () => context.push(
                    Uri(
                      path: '/category-products',
                      queryParameters: {'category': filter},
                    ).toString(),
                  ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
    bottomNavigationBar: const BottomNavBar(currentIndex: 1),
  );
}
