
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/src/features/discovery/domain/basket.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createOrder(Basket basket) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    await _firestore.collection('orders').add({
      'userId': user.uid,
      'basketId': basket.id,
      'basketName': basket.name,
      'partnerName': basket.partnerName,
      'price': basket.price,
      'pickupTime': basket.pickupTime,
      'orderDate': Timestamp.now(),
      'image': basket.image,
    });
  }
}
