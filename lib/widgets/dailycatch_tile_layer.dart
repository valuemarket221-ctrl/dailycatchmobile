import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:myapp/utils/api_environment.dart';

class DailyCatchTileLayer extends StatelessWidget {
  const DailyCatchTileLayer({super.key});

  static bool debugUseTransparentTiles = false;

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: ApiEnvironment.mapTileUrlTemplate,
      userAgentPackageName: ApiEnvironment.mapTileUserAgentPackageName,
      tileProvider:
          debugUseTransparentTiles ? _TransparentTileProvider() : null,
    );
  }
}

class _TransparentTileProvider extends TileProvider {
  static final _transparentImage = MemoryImage(
    base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAQAAAAEAAQMAAABmvDolAAAAAXNSR0IB2cksfwAAAAlwSFlzAAALEwAACxMBAJqcGAAAAANQTFRF////p8QbyAAAAB9JREFUeJztwQENAAAAwqD3T20ON6AAAAAAAAAAAL4NIQAAAfFnIe4AAAAASUVORK5CYII=',
    ),
  );

  @override
  ImageProvider<Object> getImage(
    TileCoordinates coordinates,
    TileLayer options,
  ) {
    return _transparentImage;
  }
}
