
import 'package:latlong2/latlong.dart';

class Basket {
  final String id;
  final String partnerName;
  final String image;
  final double price;
  final int rating;
  final String pickupTime;
  final String name;
  final LatLng location;

  Basket({
    required this.id,
    required this.partnerName,
    required this.image,
    required this.price,
    required this.rating,
    required this.pickupTime,
    required this.name,
    required this.location,
  });
}
