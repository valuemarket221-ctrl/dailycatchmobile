import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Local API simulator. No request is ever forwarded to a network client.
/// Serialized transactions keep stock and orders consistent across services.
class DemoClient extends http.BaseClient {
  static const storageKey = 'dailycatch_demo_v1';
  static Future<void> _pending = Future.value();

  static Future<void> reset() async {
    await _pending;
    await (await SharedPreferences.getInstance()).remove(storageKey);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final result = Completer<http.StreamedResponse>();
    _pending = _pending.then((_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final saved = prefs.getString(storageKey);
        // Normalize first-run fixtures to the same mutable JSON types as reloads.
        final state =
            jsonDecode(saved ?? jsonEncode(_seed())) as Map<String, dynamic>;
        // Relocate existing demo data without deleting orders or edited stock.
        if (state['mapRegion'] != 'berlin') {
          final offers = _list(state, 'offers');
          for (var i = 0; i < offers.length; i++) {
            offers[i]['latitude'] = 52.5200 + i * .006;
            offers[i]['longitude'] = 13.4050 + i * .005;
          }
          final partner = state['partner'] as Map<String, dynamic>;
          partner['latitude'] = 52.5200;
          partner['longitude'] = 13.4050;
          partner['city'] = 'Berlin';
          partner['address'] = 'Mitte, Berlin';
          state['mapRegion'] = 'berlin';
        }
        final bytes = await request.finalize().toBytes();
        final body =
            request.headers['content-type']?.contains('application/json') ==
                        true &&
                    bytes.isNotEmpty
                ? jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>
                : <String, dynamic>{};
        final response = _dispatch(
          state,
          request.method,
          request.url,
          body,
          prefs,
        );
        await prefs.setString(storageKey, jsonEncode(state));
        result.complete(_response(response, 200));
      } on _DemoError catch (error) {
        result.complete(_response({'error': error.code}, error.status));
      } catch (error, stack) {
        result.completeError(error, stack);
      }
    });
    return result.future;
  }

  http.StreamedResponse _response(Map<String, dynamic> body, int status) =>
      http.StreamedResponse(
        Stream.value(utf8.encode(jsonEncode(body))),
        status,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );

  static String _now() => DateTime.now().toUtc().toIso8601String();
  static String _id() => 'demo_${DateTime.now().microsecondsSinceEpoch}';
  static List<Map<String, dynamic>> _list(Map<String, dynamic> s, String key) =>
      (s[key] as List).cast<Map<String, dynamic>>();
  static Map<String, dynamic> _find(
    List<Map<String, dynamic>> items,
    String id,
  ) =>
      items.where((e) => e['id'] == id || e['uid'] == id).firstOrNull ??
      (throw const _DemoError(404, 'not_found'));

  Map<String, dynamic> _dispatch(
    Map<String, dynamic> s,
    String method,
    Uri uri,
    Map<String, dynamic> b,
    SharedPreferences prefs,
  ) {
    final p = uri.path.replaceFirst('/api/v1', '');
    final parts = p.split('/').where((e) => e.isNotEmpty).toList();
    final get = method == 'GET';
    final offers = _list(s, 'offers');
    final orders = _list(s, 'orders');
    final role = prefs.getString('userRole') ?? 'client';
    final profile = s['profile'] as Map<String, dynamic>;
    profile['email'] =
        prefs.getString('userEmail') ?? 'client@dailycatch.local';
    profile['displayName'] = prefs.getString('userName') ?? 'Aminata Demo';
    profile['role'] = role;
    if (p == '/client/profile/me') {
      if (!get) profile.addAll(b);
      return {'profile': profile};
    }
    if (p.startsWith('/auth/')) {
      if (!get) profile.addAll(b);
      return {
        'session': {'user': profile, 'homeRoute': '/home'},
      };
    }
    if (p == '/product-offers') {
      return {'offers': offers.where((e) => e['active'] == true).toList()};
    }
    if (p == '/orders/me') return {'orders': orders.reversed.toList()};
    if (p == '/orders' && method == 'POST') {
      final previous =
          orders
              .where(
                (e) =>
                    b['idempotencyKey'] != null &&
                    e['idempotencyKey'] == b['idempotencyKey'],
              )
              .firstOrNull;
      if (previous != null) return {...previous, 'orderId': previous['id']};
      final quantities = <String, int>{};
      for (final item in (b['items'] as List? ?? [])) {
        final id = item['productId'] as String;
        final qty = item['quantity'] as int;
        if (qty <= 0) throw const _DemoError(400, 'invalid_quantity');
        quantities.update(id, (n) => n + qty, ifAbsent: () => qty);
      }
      if (quantities.isEmpty) throw const _DemoError(400, 'empty_cart');
      for (final entry in quantities.entries) {
        final offer = _find(offers, entry.key);
        if (offer['active'] != true ||
            (offer['availableQuantity'] as num) < entry.value) {
          throw const _DemoError(409, 'insufficient_stock');
        }
      }
      final items =
          quantities.entries.map((e) {
            final offer = _find(offers, e.key);
            offer['availableQuantity'] =
                (offer['availableQuantity'] as int) - e.value;
            return {
              'productId': e.key,
              'name': offer['name'],
              'productName': offer['name'],
              'storeId': offer['storeId'],
              'storeName': offer['storeName'],
              'quantity': e.value,
              'unitAmount': offer['unitAmount'],
              'image': (offer['mediaUrls'] as List).first,
            };
          }).toList();
      final order = _order(_id(), 'paid', items)..addAll({
        'idempotencyKey': b['idempotencyKey'],
        'pickupSlot': b['pickupSlot'],
        'deliveryMode': b['deliveryMode'] ?? 'pickup',
      });
      orders.add(order);
      _notify(
        s,
        'Reservation confirmee',
        'Votre paiement de demonstration est valide.',
        order['id'],
      );
      return {...order, 'orderId': order['id']};
    }
    if (parts.firstOrNull == 'orders' && parts.length >= 3) {
      final order = _find(orders, parts[1]);
      switch (parts[2]) {
        case 'cancel':
          if (order['status'] == 'picked_up') {
            throw const _DemoError(409, 'order_already_picked_up');
          }
          if (order['status'] != 'cancelled' && order['status'] != 'refunded') {
            _restoreStock(offers, order);
            order['status'] = 'cancelled';
            _notify(
              s,
              'Reservation annulee',
              'Remboursement simule, aucun debit reel.',
              order['id'],
            );
          }
        case 'pickup':
          if (role != 'partner' && role != 'admin') {
            throw const _DemoError(403, 'forbidden');
          }
          if (order['status'] != 'paid' ||
              b['pickupCode'] != order['pickupCode']) {
            throw const _DemoError(409, 'invalid_pickup_code');
          }
          order['status'] = 'picked_up';
          order['pickedUpAt'] = _now();
        case 'review':
          if (order['status'] != 'picked_up') {
            throw const _DemoError(409, 'order_not_picked_up');
          }
          order['review'] = b;
        default:
          throw const _DemoError(404, 'demo_route_not_implemented');
      }
      return {'orderId': order['id'], 'status': order['status']};
    }
    if (p == '/payments/payment-intents') {
      final order = _find(orders, b['orderId'] as String);
      return {
        'paymentIntentId': 'demo_${order['id']}',
        'clientSecret': 'demo_not_a_stripe_secret',
      };
    }
    if (p == '/payments/refunds') {
      final order = _find(orders, b['orderId'] as String);
      if (order['status'] != 'refunded' && order['status'] != 'cancelled') {
        _restoreStock(offers, order);
      }
      order['status'] = 'refunded';
      return {'orderId': order['id'], 'status': 'refunded', 'refundId': _id()};
    }
    if (p == '/partner/profile/me') {
      final partner = s['partner'] as Map<String, dynamic>;
      if (!get) partner.addAll(b);
      return {'profile': partner};
    }
    if (p == '/partner/offers' && !get) {
      final offer = {...offers.first, ...b, 'id': _id()};
      if ((offer['mediaUrls'] as List).isEmpty) {
        offer['mediaUrls'] = ['assets/images/saumon.jpg'];
      }
      offers.add(offer);
      return {'offerId': offer['id'], 'offer': offer};
    }
    if (p.startsWith('/partner/offers/')) {
      final offer = _find(offers, parts.last);
      offer.addAll(method == 'DELETE' ? {'active': false} : b);
      return {'offer': offer};
    }
    if (p.contains('/stores/')) {
      final storeId = parts[2];
      final storeOrders =
          orders
              .where(
                (e) => (e['items'] as List).any((i) => i['storeId'] == storeId),
              )
              .toList();
      if (parts.last == 'offers') {
        return {
          'offers': offers.where((e) => e['storeId'] == storeId).toList(),
        };
      }
      if (parts.last == 'reservations') return {'reservations': storeOrders};
      if (parts.last == 'pickups') {
        return {
          'pickups':
              storeOrders.where((e) => e['status'] == 'picked_up').toList(),
        };
      }
      if (parts.contains('finance')) {
        final revenue = storeOrders
            .where((e) => ['paid', 'picked_up'].contains(e['status']))
            .fold<int>(0, (n, e) => n + (e['amount'] as int));
        final summary = {
          'grossRevenue': revenue,
          'netRevenue': (revenue * .9).round(),
          'commissionAmount': (revenue * .1).round(),
          'refundsAmount': 0,
          'availableBalance': (revenue * .9).round(),
          'pendingBalance': 0,
          'averageRating': 4.7,
          'currency': 'xof',
        };
        if (parts.last == 'summary') return {'summary': summary};
        if (parts.last == 'transactions') {
          return {
            'transactions':
                storeOrders
                    .map(
                      (e) => {
                        ...e,
                        'orderId': e['id'],
                        'type': e['status'] == 'refunded' ? 'refund' : 'sale',
                      },
                    )
                    .toList(),
          };
        }
        if (parts.last == 'statements') {
          return {
            'statements': [
              {
                ...summary,
                'period': _now().substring(0, 7),
                'periodStart': _now(),
              },
            ],
          };
        }
        if (parts.last == 'download-intent') {
          return {
            'download': {
              'downloadUrl':
                  Uri.dataFromString(
                    'DailyCatch DEMO\nRevenus simules: $revenue XOF',
                    mimeType: 'text/plain',
                  ).toString(),
            },
          };
        }
      }
      if (parts.last == 'payouts') {
        return _collection(s, 'payoutRequests', 'payoutRequest', method, b);
      }
      if (parts.last == 'promotions') return {'promotions': s['promotions']};
    }
    if (p.startsWith('/partner/promotions')) {
      final response = _collection(
        s,
        'promotions',
        'promotion',
        method,
        b,
        id: parts.length > 2 ? parts.last : null,
      );
      return {
        ...response,
        'promotionId': (response['promotion'] as Map?)?['id'],
      };
    }
    if (p.contains('/addresses')) {
      return _collection(
        s,
        'addresses',
        'address',
        method,
        b,
        id: method == 'DELETE' ? parts.last : null,
      );
    }
    if (p.contains('/payment-methods')) {
      return _collection(
        s,
        'paymentMethods',
        'paymentMethod',
        method,
        b,
        id: method == 'DELETE' ? parts.last : null,
      );
    }
    if (p.endsWith('/upload-intent')) {
      final id = _id();
      final expires =
          DateTime.now()
              .add(const Duration(hours: 1))
              .toUtc()
              .toIso8601String();
      _list(
        s,
        'documents',
      ).add({'id': id, ...b, 'status': 'pending', 'createdAt': _now()});
      return {
        'documentId': id,
        'uploadIntentId': id,
        'objectKey': id,
        'storageUrl': 'assets/images/saumon.jpg',
        'uploadExpiresAt': expires,
        'upload': {
          'method': 'direct_put',
          'url': '/api/v1/demo-upload/$id',
          'expiresAt': expires,
        },
      };
    }
    if (p.startsWith('/demo-upload/')) return {'ok': true};
    if (p == '/partner/documents/me') return {'documents': s['documents']};
    if (p == '/support/tickets') {
      final response = _collection(s, 'tickets', 'ticket', method, b);
      return {...response, 'ticketId': (response['ticket'] as Map?)?['id']};
    }
    if (p == '/notifications/preferences/me') {
      if (!get) (s['preferences'] as Map).addAll(b);
      return {'preferences': s['preferences']};
    }
    if (p.contains('/device-tokens')) return {'updatedCount': 1};
    if (p == '/notifications/me') return {'notifications': s['notifications']};
    if (p == '/notifications/read-all') {
      for (final n in _list(s, 'notifications')) {
        n['readAt'] = _now();
      }
      return {'updatedCount': _list(s, 'notifications').length};
    }
    if (p.endsWith('/read') && p.startsWith('/notifications/')) {
      final n = _find(_list(s, 'notifications'), parts[1])..['readAt'] = _now();
      return {'notification': n};
    }
    if (p == '/notifications/queue/process') {
      return {'processed': 0, 'sent': 0, 'failed': 0, 'simulated': true};
    }
    if (p.startsWith('/messages/conversations')) {
      if (parts.length == 2) {
        final response = _collection(
          s,
          'conversations',
          'conversation',
          method,
          b,
        );
        return {
          ...response,
          'conversationId': (response['conversation'] as Map?)?['id'],
        };
      }
      if (parts.last == 'read') return {'updatedCount': 1};
      final messages = _list(s, 'messages');
      if (get) {
        return {
          'messages':
              messages.where((e) => e['conversationId'] == parts[2]).toList(),
        };
      }
      final id = _id();
      messages.add({
        'id': id,
        'conversationId': parts[2],
        'senderUserId': 'dev-$role',
        'sender_user_id': 'dev-$role',
        'body': b['body'],
        'createdAt': _now(),
        'created_at': _now(),
      });
      messages.add({
        'id': '${id}_reply',
        'conversationId': parts[2],
        'senderUserId': 'demo-assistant',
        'body':
            'Reponse simulee : merci ! Votre panier sera pret au creneau indique.',
        'createdAt': _now(),
      });
      return {'messageId': id};
    }
    if (p == '/admin/metrics') {
      return {
        'metrics': {
          'activeOffers': offers.where((e) => e['active'] == true).length,
          'lowStockOffers':
              offers.where((e) => (e['availableQuantity'] as num) < 3).length,
          'paidOrders': orders.where((e) => e['status'] == 'paid').length,
          'pickedUpOrders':
              orders.where((e) => e['status'] == 'picked_up').length,
          'grossRevenue': orders
              .where((e) => ['paid', 'picked_up'].contains(e['status']))
              .fold<int>(0, (n, e) => n + (e['amount'] as int)),
          'openSupportTickets':
              _list(s, 'tickets').where((e) => e['status'] == 'open').length,
          'refundPendingOrders': 0,
          'highRiskEvents': 0,
          'queuedNotifications': 0,
          'failedNotifications': 0,
          'sentNotificationsToday': _list(s, 'notifications').length,
        },
      };
    }
    if (p.startsWith('/admin/users')) {
      if (get) {
        return {
          'users':
              _list(s, 'users')
                  .where(
                    (e) =>
                        uri.queryParameters['role'] == null ||
                        e['role'] == uri.queryParameters['role'],
                  )
                  .toList(),
        };
      }
      final user = _find(_list(s, 'users'), parts.last)..addAll(b);
      return {'user': user};
    }
    if (p == '/admin/orders') return {'orders': orders};
    if (p == '/admin/partners/profiles') {
      return {
        'profiles': [s['partner']],
      };
    }
    if (p == '/admin/partner-applications' && get) {
      return {
        'applications': [s['partner']],
      };
    }
    if (p.contains('/admin/partners/profiles/') ||
        p.startsWith('/admin/partner-applications/')) {
      (s['partner'] as Map).addAll(b);
      return {'profile': s['partner'], 'application': s['partner']};
    }
    if (p.startsWith('/admin/partners/documents')) {
      return _collection(
        s,
        'documents',
        'document',
        method,
        b,
        id: get ? null : parts[3],
      );
    }
    if (p.startsWith('/admin/support/tickets')) {
      return _collection(
        s,
        'tickets',
        'ticket',
        method,
        b,
        id: get ? null : parts.last,
      );
    }
    if (p == '/admin/fraud-events') return {'events': <dynamic>[]};
    if (p == '/admin/audit-events') {
      return {
        'events': [
          {'id': 'demo-audit', 'action': 'demo_started', 'createdAt': _now()},
        ],
      };
    }
    if (p == '/admin/notifications/failures') return {'failures': <dynamic>[]};
    throw const _DemoError(501, 'demo_route_not_implemented');
  }

  Map<String, dynamic> _collection(
    Map<String, dynamic> s,
    String key,
    String singular,
    String method,
    Map<String, dynamic> body, {
    String? id,
  }) {
    final items = _list(s, key);
    if (method == 'GET') return {key: items};
    if (method == 'DELETE') {
      items.removeWhere((e) => e['id'] == id);
      return {'deleted': true};
    }
    if (id != null) {
      final item = _find(items, id)..addAll(body);
      return {singular: item};
    }
    if (body['isDefault'] == true) {
      for (final item in items) {
        item['isDefault'] = false;
      }
    }
    final item = {
      'id': _id(),
      'status': 'pending',
      'active': true,
      'country': 'SN',
      'isDefault': false,
      'createdAt': _now(),
      'updatedAt': _now(),
      ...body,
    };
    items.add(item);
    return {singular: item};
  }

  static void _restoreStock(
    List<Map<String, dynamic>> offers,
    Map<String, dynamic> order,
  ) {
    for (final item in order['items'] as List) {
      final offer = _find(offers, item['productId'] as String);
      offer['availableQuantity'] =
          (offer['availableQuantity'] as int) + (item['quantity'] as int);
    }
  }

  static void _notify(
    Map<String, dynamic> s,
    String title,
    String body,
    dynamic orderId,
  ) {
    _list(s, 'notifications').add({
      'id': _id(),
      'type': 'order_paid',
      'title': title,
      'body': body,
      'orderId': orderId,
      'status': 'sent',
      'deliveryAttempts': 0,
      'createdAt': _now(),
    });
  }

  static Map<String, dynamic> _order(
    String id,
    String status,
    List<Map<String, dynamic>> items,
  ) => {
    'id': id,
    'status': status,
    'amount': items.fold<int>(
      0,
      (n, e) => n + (e['quantity'] as int) * (e['unitAmount'] as int),
    ),
    'currency': 'xof',
    'deliveryMode': 'pickup',
    'deliveryFee': 0,
    'pickupCode':
        id == 'demo_order_ready'
            ? '123456'
            : DateTime.now().microsecondsSinceEpoch.toString().substring(10),
    'pickupSlot': 'Aujourd\'hui 17:00 - 20:00',
    'createdAt': _now(),
    'items': items,
    'userId': 'dev-client',
    'clientName': 'Aminata Demo',
    'customerName': 'Aminata Demo',
  };

  static Map<String, dynamic> _seed() {
    final now = _now();
    final offers = List.generate(
      6,
      (i) => <String, dynamic>{
        'id': 'demo_offer_$i',
        'storeId': i < 3 ? 'store_yoff' : 'store_ouakam',
        'storeName': i < 3 ? 'Poissonnerie Yoff' : 'Peche du jour Ouakam',
        'name':
            [
              'Panier poisson du jour',
              'Panier crevettes',
              'Panier familial',
              'Panier crustaces',
              'Panier surprise',
              'Panier fruits de mer',
            ][i],
        'description': 'Une selection de la peche du jour a prix reduit.',
        'currency': 'xof',
        'unitAmount': 2500 + i * 500,
        'originalUnitAmount': 6500 + i * 1000,
        'availableQuantity': [8, 2, 0, 6, 4, 3][i],
        'active': true,
        'category': i.isEven ? 'Poisson' : 'Crustaces',
        'weightEstimate': '1 - 2 kg',
        'pickupStartsAt':
            DateTime.now()
                .subtract(const Duration(hours: 1))
                .toUtc()
                .toIso8601String(),
        'pickupEndsAt':
            DateTime.now()
                .add(const Duration(days: 1))
                .toUtc()
                .toIso8601String(),
        'mediaUrls': [
          i.isEven ? 'assets/images/saumon.jpg' : 'assets/images/crevette.jpg',
        ],
        'latitude': 52.5200 + i * .006,
        'longitude': 13.4050 + i * .005,
        'distanceKm': .5 + i * .7,
        'createdAt': now,
      },
    );
    final sampleItem = {
      'productId': 'demo_offer_0',
      'name': 'Panier poisson du jour',
      'productName': 'Panier poisson du jour',
      'storeId': 'store_yoff',
      'storeName': 'Poissonnerie Yoff',
      'quantity': 1,
      'unitAmount': 2500,
      'image': 'assets/images/saumon.jpg',
    };
    final partner = <String, dynamic>{
      'id': 'dev-partner',
      'userId': 'dev-partner',
      'user_id': 'dev-partner',
      'uid': 'dev-partner',
      'storeId': 'store_yoff',
      'store_id': 'store_yoff',
      'storeName': 'Poissonnerie Yoff',
      'store_name': 'Poissonnerie Yoff',
      'ownerName': 'Moussa Demo',
      'email': 'vendeur@dailycatch.local',
      'phone': '+221 77 000 00 00',
      'city': 'Berlin',
      'address': 'Mitte, Berlin',
      'status': 'approved',
      'commerceType': 'fishmonger',
      'openingHours': {'Lundi': '08:00 - 20:00'},
      'latitude': 52.5200,
      'longitude': 13.4050,
      'createdAt': now,
    };
    return {
      'offers': offers,
      'partner': partner,
      'profile': {
        'uid': 'dev-client',
        'email': 'client@dailycatch.local',
        'displayName': 'Aminata Demo',
        'role': 'client',
        'active': true,
        'phone': '+221 77 000 00 01',
        'createdAt': now,
        'updatedAt': now,
      },
      'orders': [
        _order('demo_order_ready', 'paid', [sampleItem]),
        _order('demo_order_done', 'picked_up', [sampleItem]),
      ],
      'users':
          ['client', 'partner', 'admin', 'support']
              .map(
                (role) => {
                  'id': 'dev-$role',
                  'uid': 'dev-$role',
                  'email':
                      '${role == 'partner' ? 'vendeur' : role}@dailycatch.local',
                  'displayName': '$role Demo',
                  'role': role,
                  'active': true,
                  'createdAt': now,
                },
              )
              .toList(),
      'addresses': [
        {
          'id': 'demo_address',
          'label': 'Maison',
          'address': 'Yoff, Dakar',
          'country': 'SN',
          'isDefault': true,
          'createdAt': now,
          'updatedAt': now,
        },
      ],
      'paymentMethods': [
        {
          'id': 'demo_payment',
          'type': 'mobile_money',
          'label': 'Wave demonstration',
          'provider': 'wave',
          'maskedReference': '77 *** ** 01',
          'active': true,
          'isDefault': true,
          'createdAt': now,
          'updatedAt': now,
        },
      ],
      'notifications': [
        {
          'id': 'demo_welcome',
          'type': 'news',
          'title': 'Bienvenue sur DailyCatch',
          'body': 'Vos paniers de demonstration vous attendent.',
          'status': 'sent',
          'deliveryAttempts': 0,
          'createdAt': now,
        },
      ],
      'preferences': {
        'nearbyOffersEnabled': true,
        'ordersEnabled': true,
        'pickupRemindersEnabled': true,
        'newsEnabled': false,
      },
      'tickets': [
        {
          'id': 'demo_ticket',
          'subject': 'Horaire de retrait',
          'message': 'Puis-je recuperer mon panier a 18h ?',
          'status': 'open',
          'createdAt': now,
        },
      ],
      'documents': [
        {
          'id': 'demo_document',
          'userId': 'dev-partner',
          'documentType': 'business_registration',
          'fileName': 'Registre-demo.pdf',
          'status': 'approved',
          'createdAt': now,
        },
      ],
      'promotions': [
        {
          'id': 'demo_promo',
          'name': 'Offre decouverte',
          'code': 'BIENVENUE',
          'discountPercent': 10,
          'active': true,
          'createdAt': now,
        },
      ],
      'payoutRequests': <dynamic>[],
      'conversations': [
        {
          'id': 'demo_chat',
          'storeName': 'Poissonnerie Yoff',
          'partnerName': 'Moussa Demo',
          'clientName': 'Aminata Demo',
          'lastMessage': 'Votre panier vous attend !',
          'updatedAt': now,
          'unreadCount': 1,
        },
      ],
      'messages': [
        {
          'id': 'demo_message',
          'conversationId': 'demo_chat',
          'senderUserId': 'dev-partner',
          'body': 'Bonjour ! Votre panier vous attend au commerce.',
          'createdAt': now,
        },
      ],
    };
  }
}

class _DemoError implements Exception {
  const _DemoError(this.status, this.code);
  final int status;
  final String code;
}
