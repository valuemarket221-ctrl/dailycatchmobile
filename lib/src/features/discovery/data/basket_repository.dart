
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:myapp/src/features/discovery/domain/basket.dart';

class BasketRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Basket>> getBaskets() {
    return _firestore.collection('baskets').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Basket(
          id: doc.id,
          partnerName: doc.data()['partnerName'] ?? '',
          name: doc.data()['name'] ?? '',
          image: doc.data()['image'] ?? '',
          price: (doc.data()['price'] ?? 0).toDouble(),
          rating: doc.data()['rating'] ?? 0,
          pickupTime: doc.data()['pickupTime'] ?? '',
          location: LatLng(
            (doc.data()['location'] as GeoPoint).latitude,
            (doc.data()['location'] as GeoPoint).longitude,
          ),
        );
      }).toList();
    });
  }
}
