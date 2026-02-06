import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

// Import pages
import 'package:myapp/pages/splash_page.dart';
import 'package:myapp/pages/login_page.dart';
import 'package:myapp/pages/register_page.dart';
import 'package:myapp/pages/forget_page.dart';
import 'package:myapp/pages/home_page.dart';
import 'package:myapp/pages/map_page.dart';
import 'package:myapp/pages/search_page.dart';
import 'package:myapp/pages/favorite_page.dart';
import 'package:myapp/pages/profile_page.dart';
import 'package:myapp/pages/settings_page.dart';
import 'package:myapp/pages/help_page.dart';
import 'package:myapp/pages/legal_page.dart';
import 'package:myapp/pages/order_history_page.dart';
import 'package:myapp/pages/pickup_page.dart';
import 'package:myapp/pages/cart_page.dart';
import 'package:myapp/pages/payment_page.dart';
import 'package:myapp/pages/store_detail_page.dart';
import 'package:myapp/pages/addresses_page.dart';
import 'package:myapp/pages/payment_methods_page.dart';
import 'package:myapp/pages/notifications_settings_page.dart';
import 'package:myapp/pages/edit_profile_page.dart';
import 'package:myapp/pages/change_password_page.dart';
import 'package:myapp/pages/detail_page.dart';
import 'package:myapp/pages/categorie_pages.dart';
import 'package:myapp/pages/notification_page.dart';
import 'package:myapp/pages/product_selection_page.dart';

// Admin pages
import 'package:myapp/pages/Admin/admin_dashboard_page.dart';
import 'package:myapp/pages/Admin/admin_partners_page.dart';
import 'package:myapp/pages/Admin/admin_partner_registration_page.dart';
import 'package:myapp/pages/Admin/admin_partner_validation_page.dart';
import 'package:myapp/pages/Admin/admin_clients_page.dart';

import 'package:myapp/widgets/bottom_nav_bar.dart';

// Configuration du routeur DailyCatch - Clone TGTG
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <GoRoute>[
    // ========== ÉCRANS AUTHENTIFICATION ==========

    // Splash Screen
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashPage();
      },
    ),

    // Login
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginPage();
      },
    ),

    // Register
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterPage();
      },
    ),

    // Forgot Password
    GoRoute(
      path: '/forgot-password',
      builder: (BuildContext context, GoRouterState state) {
        return const ForgotPasswordPage();
      },
    ),

    // ========== ÉCRANS PRINCIPAUX ==========

    // Home - Discover
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
    ),

    // Map - Carte des boutiques
    GoRoute(
      path: '/map',
      builder: (BuildContext context, GoRouterState state) {
        final category = state.uri.queryParameters['category'] ?? 'Tous';
        return MapPage(initialCategory: category);
      },
    ),

    // Search
    GoRoute(
      path: '/search',
      builder: (BuildContext context, GoRouterState state) {
        return const SearchPage();
      },
    ),

    // Favorites
    GoRoute(
      path: '/favorites',
      builder: (BuildContext context, GoRouterState state) {
        return const FavoritePage();
      },
    ),

    // Profile
    GoRoute(
      path: '/profile',
      builder: (BuildContext context, GoRouterState state) {
        return const ProfilePage();
      },
    ),

    // Pickup / QR Code
    GoRoute(
      path: '/pickup',
      builder: (BuildContext context, GoRouterState state) {
        return const PickupPage();
      },
    ),

    // QR Code Display
    GoRoute(
      path: '/qr-code/:id',
      builder: (BuildContext context, GoRouterState state) {
        final reservationId = state.pathParameters['id'] ?? '';
        return QRCodePage(reservationId: reservationId);
      },
    ),

    // Save Confirmation
    GoRoute(
      path: '/save-confirmation',
      builder: (BuildContext context, GoRouterState state) {
        final data = state.extra as Map<String, dynamic>?;
        final product = data?['produit'] as Map<String, dynamic>?;
        final quantity = data?['quantity'] as int? ?? 1;
        return SaveConfirmationPage(product: product ?? {}, quantity: quantity);
      },
    ),

    // ========== ÉCRANS DÉTAILS ==========

    // Store Detail
    GoRoute(
      path: '/store/:id',
      builder: (BuildContext context, GoRouterState state) {
        final storeId = state.pathParameters['id'] ?? '';
        return StoreDetailPage(storeId: storeId);
      },
    ),

    // Product Selection
    GoRoute(
      path: '/product',
      builder: (BuildContext context, GoRouterState state) {
        final product = state.extra as Map<String, dynamic>?;
        return ProductSelectionPage(product: product ?? {});
      },
    ),

    // Cart
    GoRoute(
      path: '/cart',
      builder: (BuildContext context, GoRouterState state) {
        return const CartPage();
      },
    ),

    // Payment
    GoRoute(
      path: '/payment',
      builder: (BuildContext context, GoRouterState state) {
        final paymentData = state.extra as Map<String, dynamic>?;
        return PaymentPage(paymentData: paymentData);
      },
    ),

    // Order Confirmation
    GoRoute(
      path: '/order-confirmation',
      builder: (BuildContext context, GoRouterState state) {
        return const OrderConfirmationPage();
      },
    ),

    // ========== PROFILE & SETTINGS ==========

    // Order History
    GoRoute(
      path: '/orders',
      builder: (BuildContext context, GoRouterState state) {
        return const OrderHistoryPage();
      },
    ),

    // Settings
    GoRoute(
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) {
        return const SettingsPage();
      },
    ),

    // Help & FAQ
    GoRoute(
      path: '/help',
      builder: (BuildContext context, GoRouterState state) {
        return const HelpPage();
      },
    ),

    // Legal
    GoRoute(
      path: '/legal',
      builder: (BuildContext context, GoRouterState state) {
        return const LegalPage();
      },
    ),

    // Edit Profile
    GoRoute(
      path: '/edit-profile',
      builder: (BuildContext context, GoRouterState state) {
        return const EditProfilePage();
      },
    ),

    // Change Password
    GoRoute(
      path: '/change-password',
      builder: (BuildContext context, GoRouterState state) {
        return const ChangePasswordPage();
      },
    ),

    // Addresses
    GoRoute(
      path: '/addresses',
      builder: (BuildContext context, GoRouterState state) {
        return const AddressesPage();
      },
    ),

    // Payment Methods
    GoRoute(
      path: '/payment-methods',
      builder: (BuildContext context, GoRouterState state) {
        return const PaymentMethodsPage();
      },
    ),

    // Notifications List
    GoRoute(
      path: '/notifications',
      builder: (BuildContext context, GoRouterState state) {
        return NotificationPage();
      },
    ),

    // Notifications Settings
    GoRoute(
      path: '/notifications-settings',
      builder: (BuildContext context, GoRouterState state) {
        return const NotificationsPage();
      },
    ),

    // ========== ÉCRANS ADMIN ==========

    // Admin Dashboard
    GoRoute(
      path: '/admin/dashboard',
      builder: (BuildContext context, GoRouterState state) {
        return const AdminDashboardPage();
      },
    ),

    // Admin Partners List
    GoRoute(
      path: '/admin/partners',
      builder: (BuildContext context, GoRouterState state) {
        return const AdminPartnersPage();
      },
    ),

    // Admin Partner Registration
    GoRoute(
      path: '/admin/partners/new',
      builder: (BuildContext context, GoRouterState state) {
        return const PartnerRegistrationPage();
      },
    ),

    // Admin Partner Validation (Pending)
    GoRoute(
      path: '/admin/partners/pending',
      builder: (BuildContext context, GoRouterState state) {
        return const PartnerValidationPage();
      },
    ),

    // Admin Partner Detail
    GoRoute(
      path: '/admin/partners/:id',
      builder: (BuildContext context, GoRouterState state) {
        final partnerId = state.pathParameters['id'] ?? '';
        return PartnerDetailPage(partnerId: partnerId);
      },
    ),

    // Admin Clients List
    GoRoute(
      path: '/admin/clients',
      builder: (BuildContext context, GoRouterState state) {
        return const AdminClientsPage();
      },
    ),

    // Admin Client Detail
    GoRoute(
      path: '/admin/clients/:id',
      builder: (BuildContext context, GoRouterState state) {
        final clientId = state.pathParameters['id'] ?? '';
        return ClientDetailPage(clientId: clientId);
      },
    ),
  ],
);

// ========== MISSING PAGE CLASSES ==========

// Product Selection Page
class ProductSelectionPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductSelectionPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selectionner la quantite')),
      body: Center(
        child: Text('Produit: ${product['name'] ?? 'Non selectionne'}'),
      ),
    );
  }
}

// Order Confirmation Page
class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmation')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 24),
            Text(
              'Commande confirnee !',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Votre commande a ete enregistree avec succes.',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueBic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              onPressed: () => context.go('/pickup'),
              child: const Text('Voir mes reservations'),
            ),
          ],
        ),
      ),
    );
  }
}

// Partner Detail Page (Admin)
class PartnerDetailPage extends StatelessWidget {
  final String partnerId;

  const PartnerDetailPage({super.key, required this.partnerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail partenaire')),
      body: Center(child: Text('Partenaire: $partnerId')),
    );
  }
}

// Client Detail Page (Admin)
class ClientDetailPage extends StatelessWidget {
  final String clientId;

  const ClientDetailPage({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail client')),
      body: Center(child: Text('Client: $clientId')),
    );
  }
}
