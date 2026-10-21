import 'package:flutter/material.dart';
import 'package:myapp/pages/search_page.dart';

/// Ancienne route de carte conservée pour compatibilité.
/// La carte dynamique principale est `SearchPage`.
class MapPage extends StatelessWidget {
  const MapPage({super.key, this.initialCategory = 'Tous'});

  final String initialCategory;

  @override
  Widget build(BuildContext context) {
    return const SearchPage();
  }
}
