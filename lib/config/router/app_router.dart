import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import pages
import 'package:myapp/pages/splash_page.dart';
import 'package:myapp/pages/onboarding_page.dart';
import 'package:myapp/pages/login_page.dart';
import 'package:myapp/pages/forget_page.dart';
import 'package:myapp/pages/home_page.dart';
import 'package:myapp/pages/search_page.dart';
import 'package:myapp/pages/favorite_page.dart';
import 'package:myapp/pages/profile_page.dart';
import 'package:myapp/pages/messages_page.dart';
import 'package:myapp/pages/categories_page.dart';
import 'package:myapp/pages/faq_page.dart';
import 'package:myapp/pages/contact_page.dart';
import 'package:myapp/pages/client_missing_flow_pages.dart';
import 'package:myapp/pages/system_state_pages.dart';
import 'package:myapp/pages/join_partner_page.dart';
import 'package:myapp/pages/partner_mobile_flow_page.dart';
import 'package:myapp/pages/partner_mobile_key_pages.dart';
import 'package:myapp/pages/reservation_detail_page.dart';
import 'package:myapp/pages/settings_page.dart';
import 'package:myapp/pages/help_page.dart';
import 'package:myapp/pages/legal_page.dart';
import 'package:myapp/pages/order_history_page.dart';
import 'package:myapp/pages/pickup_page.dart' as pickup;
import 'package:myapp/pages/cart_page.dart';
import 'package:myapp/pages/delivery_page.dart';
import 'package:myapp/pages/payment_page.dart';
import 'package:myapp/pages/order_confirmation_page.dart' as order_confirm;
import 'package:myapp/pages/order_detail_page.dart';
import 'package:myapp/pages/order_completed_page.dart';
import 'package:myapp/pages/order_tracking_page.dart';
import 'package:myapp/pages/store_detail_page.dart';
import 'package:myapp/pages/withdrawal_code_page.dart';
import 'package:myapp/pages/addresses_page.dart';
import 'package:myapp/pages/payment_methods_page.dart';
import 'package:myapp/pages/notifications_settings_page.dart';
import 'package:myapp/pages/edit_profile_page.dart';
import 'package:myapp/pages/change_password_page.dart';
import 'package:myapp/pages/notification_page.dart';
import 'package:myapp/pages/product_selection_page.dart';
import 'package:myapp/pages/detail_page.dart';
import 'package:myapp/pages/my_reservations_page.dart';
import 'package:myapp/pages/pickup_confirmation_page.dart'
    as pickup_confirmation;
import 'package:myapp/pages/qr_scanner_page.dart';
import 'package:myapp/pages/rescued_products_page.dart';
import 'package:myapp/pages/parametre_page.dart';
import 'package:myapp/pages/role_selection_page.dart';
import 'package:myapp/pages/register_client_page.dart';
import 'package:myapp/pages/register_partner_page.dart';
import 'package:myapp/pages/prototypes/offer.dart';
import 'package:myapp/pages/prototypes/precommande.dart';

// Admin pages
import 'package:myapp/pages/Admin/admin_dashboard_page.dart';
import 'package:myapp/pages/Admin/admin_partners_page.dart';
import 'package:myapp/pages/Admin/admin_partner_registration_page.dart';
import 'package:myapp/pages/Admin/admin_partner_validation_page.dart';
import 'package:myapp/pages/Admin/admin_clients_page.dart';

CustomTransitionPage<void> _smoothPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 240),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.035, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

// Configuration du routeur DailyCatch
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

    // Onboarding
    GoRoute(
      path: '/onboarding',
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingPage();
      },
    ),

    GoRoute(
      path: '/payment-failed',
      builder:
          (BuildContext context, GoRouterState state) =>
              const SystemStatePage(kind: SystemStateKind.paymentFailed),
    ),

    GoRoute(
      path: '/reservation-expired',
      builder:
          (BuildContext context, GoRouterState state) =>
              const SystemStatePage(kind: SystemStateKind.reservationExpired),
    ),

    GoRoute(
      path: '/basket-unavailable',
      builder:
          (BuildContext context, GoRouterState state) =>
              const SystemStatePage(kind: SystemStateKind.basketUnavailable),
    ),

    GoRoute(
      path: '/permission-location',
      builder:
          (BuildContext context, GoRouterState state) =>
              const SystemStatePage(kind: SystemStateKind.locationPermission),
    ),

    GoRoute(
      path: '/permission-notifications',
      builder:
          (BuildContext context, GoRouterState state) => const SystemStatePage(
            kind: SystemStateKind.notificationPermission,
          ),
    ),

    GoRoute(
      path: '/offline',
      builder:
          (BuildContext context, GoRouterState state) =>
              const SystemStatePage(kind: SystemStateKind.offline),
    ),

    GoRoute(
      path: '/maintenance',
      builder:
          (BuildContext context, GoRouterState state) =>
              const SystemStatePage(kind: SystemStateKind.maintenance),
    ),

    // Login
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginPage();
      },
    ),

    // Role Selection
    GoRoute(
      path: '/role-selection',
      builder: (BuildContext context, GoRouterState state) {
        return const RoleSelectionPage();
      },
    ),

    // Register (deprecated, use role-selection instead)
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterClientPage();
      },
    ),

    // Register Client
    GoRoute(
      path: '/register-client',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterClientPage();
      },
    ),

    // Register Partner
    GoRoute(
      path: '/register-partner',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterPartnerPage();
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
        return const SearchPage();
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

    GoRoute(
      path: '/categories',
      builder: (BuildContext context, GoRouterState state) {
        return const CategoriesPage();
      },
    ),

    GoRoute(
      path: '/messages',
      builder: (BuildContext context, GoRouterState state) {
        return const MessagesPage();
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
        return const pickup.PickupPage();
      },
    ),

    GoRoute(
      path: '/reservation-detail',
      builder: (BuildContext context, GoRouterState state) {
        return const ReservationDetailPage();
      },
    ),

    GoRoute(
      path: '/withdrawal-code',
      builder: (BuildContext context, GoRouterState state) {
        return const WithdrawalCodePage();
      },
    ),

    GoRoute(
      path: '/order-tracking',
      builder: (BuildContext context, GoRouterState state) {
        return const OrderTrackingPage();
      },
    ),

    GoRoute(
      path: '/order-completed',
      builder: (BuildContext context, GoRouterState state) {
        return const OrderCompletedPage();
      },
    ),

    GoRoute(
      path: '/my-reservations',
      builder: (BuildContext context, GoRouterState state) {
        return const MyReservationsPage();
      },
    ),

    GoRoute(
      path: '/pickup-confirmation',
      builder: (BuildContext context, GoRouterState state) {
        return const pickup_confirmation.PickupConfirmationPage();
      },
    ),

    GoRoute(
      path: '/rate-review',
      builder: (BuildContext context, GoRouterState state) {
        return const ClientReviewPage();
      },
    ),

    GoRoute(
      path: '/chat-detail',
      builder: (BuildContext context, GoRouterState state) {
        final extra = state.extra;
        final data =
            extra is Map<String, dynamic> ? extra : <String, dynamic>{};
        return ClientChatPage(
          conversationId: data['conversationId']?.toString(),
          chatName: data['chatName']?.toString() ?? 'Poissonnerie Chez Moussa',
          currentUserId: data['currentUserId']?.toString() ?? 'dev-client',
        );
      },
    ),

    GoRoute(
      path: '/notification-detail',
      builder: (BuildContext context, GoRouterState state) {
        final extra = state.extra;
        final data =
            extra is Map<String, dynamic> ? extra : <String, dynamic>{};
        return NotificationDetailPage(
          title: data['title']?.toString() ?? 'Votre commande est prête !',
          body:
              data['body']?.toString() ??
              'Votre panier est prêt à être retiré.',
          orderId: data['orderId']?.toString(),
        );
      },
    ),

    GoRoute(
      path: '/cancel-order',
      builder: (BuildContext context, GoRouterState state) {
        return const CancelOrderPage();
      },
    ),

    GoRoute(
      path: '/refund-request',
      builder: (BuildContext context, GoRouterState state) {
        return const RefundRequestPage();
      },
    ),

    GoRoute(
      path: '/new-address',
      builder: (BuildContext context, GoRouterState state) {
        return const NewAddressPage();
      },
    ),

    GoRoute(
      path: '/add-payment',
      builder: (BuildContext context, GoRouterState state) {
        return const AddPaymentPage();
      },
    ),

    GoRoute(
      path: '/search-empty',
      builder: (BuildContext context, GoRouterState state) {
        return const SearchEmptyPage();
      },
    ),

    GoRoute(
      path: '/cart-empty',
      builder: (BuildContext context, GoRouterState state) {
        return const CartEmptyPage();
      },
    ),

    // QR Code Display
    GoRoute(
      path: '/qr-code/:id',
      builder: (BuildContext context, GoRouterState state) {
        final reservationId = state.pathParameters['id'] ?? '';
        return WithdrawalCodePage(reservationId: reservationId);
      },
    ),

    // Save Confirmation
    GoRoute(
      path: '/save-confirmation',
      builder: (BuildContext context, GoRouterState state) {
        final data = state.extra as Map<String, dynamic>?;
        final product = data?['produit'] as Map<String, dynamic>?;
        final storeId = data?['storeId'] as String? ?? '1';
        return SaveConfirmationPage(product: product ?? {}, storeId: storeId);
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

    GoRoute(
      path: '/detail',
      builder: (BuildContext context, GoRouterState state) {
        final produit = state.extra as Map<String, dynamic>?;
        return DetailPage(produit: produit ?? {});
      },
    ),

    GoRoute(
      path: '/rescued-products',
      builder: (BuildContext context, GoRouterState state) {
        return const RescuedProductsPage();
      },
    ),

    GoRoute(
      path: '/offer',
      builder: (BuildContext context, GoRouterState state) {
        return const OfferPage();
      },
    ),

    GoRoute(
      path: '/precommande',
      builder: (BuildContext context, GoRouterState state) {
        return const PrecommandePage();
      },
    ),

    // Cart
    GoRoute(
      path: '/cart',
      builder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        return CartPage(extra: extra);
      },
    ),

    GoRoute(
      path: '/delivery',
      builder: (BuildContext context, GoRouterState state) {
        final checkoutData = state.extra as Map<String, dynamic>?;
        return DeliveryPage(checkoutData: checkoutData);
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
        final orderData = state.extra as Map<String, dynamic>?;
        return order_confirm.OrderConfirmationPage(orderData: orderData);
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

    GoRoute(
      path: '/order-detail',
      builder: (BuildContext context, GoRouterState state) {
        return const OrderDetailPage();
      },
    ),

    // Settings
    GoRoute(
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) {
        return const SettingsPage();
      },
    ),

    GoRoute(
      path: '/parametre',
      builder: (BuildContext context, GoRouterState state) {
        return const ParametrePage();
      },
    ),

    // Help & FAQ
    GoRoute(
      path: '/help',
      builder: (BuildContext context, GoRouterState state) {
        return const HelpPage();
      },
    ),

    GoRoute(
      path: '/faq',
      builder: (BuildContext context, GoRouterState state) {
        return const FaqPage();
      },
    ),

    GoRoute(
      path: '/contact',
      builder: (BuildContext context, GoRouterState state) {
        return const ContactPage();
      },
    ),

    GoRoute(
      path: '/join-partner',
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              _smoothPage(state, const JoinPartnerPage()),
    ),

    GoRoute(
      path: '/partner/type',
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              _smoothPage(state, const PartnerTypePage()),
    ),

    GoRoute(
      path: '/partner/business-info',
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              _smoothPage(state, const PartnerBusinessInfoPage()),
    ),

    GoRoute(
      path: '/partner/extra-info',
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              _smoothPage(state, const PartnerExtraInfoPage()),
    ),

    GoRoute(
      path: '/partner/documents',
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              _smoothPage(state, const PartnerDocumentsPage()),
    ),

    GoRoute(
      path: '/partner/account-created',
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              _smoothPage(state, const PartnerAccountCreatedPage()),
    ),

    GoRoute(
      path: '/partner/publish-basket',
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              _smoothPage(state, const PublishBasketPage()),
    ),

    GoRoute(
      path: '/partner/publish-basket-time',
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              _smoothPage(state, const PublishBasketTimePage()),
    ),

    GoRoute(
      path: '/partner/basket-published',
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              _smoothPage(state, const BasketPublishedPage()),
    ),

    GoRoute(
      path: '/partner/mobile-dashboard',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerMobileDashboardPage(),
    ),

    GoRoute(
      path: '/partner/baskets',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerBasketsPage(),
    ),

    GoRoute(
      path: '/partner/new-basket',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerNewBasketStepOnePage(),
    ),

    GoRoute(
      path: '/partner/new-basket/photos',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerNewBasketPhotosPage(),
    ),

    GoRoute(
      path: '/partner/recurring-slots',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerRecurringSlotsPage(),
    ),

    GoRoute(
      path: '/partner/calendar',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerCalendarPage(),
    ),

    GoRoute(
      path: '/partner/opening-hours',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerOpeningHoursPage(),
    ),

    GoRoute(
      path: '/partner/documents-mobile',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerDocumentsMobilePage(),
    ),

    GoRoute(
      path: '/partner/validation-status',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerValidationStatusPage(),
    ),

    GoRoute(
      path: '/partner/basket-detail',
      builder: (BuildContext context, GoRouterState state) {
        final offer = state.extra as Map<String, dynamic>?;
        return PartnerBasketDetailPage(offer: offer ?? {});
      },
    ),

    GoRoute(
      path: '/partner/basket-edit',
      builder: (BuildContext context, GoRouterState state) {
        final offer = state.extra as Map<String, dynamic>?;
        return PartnerBasketEditPage(offer: offer ?? {});
      },
    ),

    GoRoute(
      path: '/partner/order-detail',
      builder: (BuildContext context, GoRouterState state) {
        final order = state.extra as Map<String, dynamic>?;
        return PartnerOrderDetailMobilePage(order: order ?? {});
      },
    ),

    GoRoute(
      path: '/partner/client-chat',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerClientChatPage(),
    ),

    GoRoute(
      path: '/partner/client-profile',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerClientProfilePage(),
    ),

    GoRoute(
      path: '/partner/scan-code',
      builder: (BuildContext context, GoRouterState state) {
        final order = state.extra as Map<String, dynamic>?;
        return QRScannerPage(order: order ?? {});
      },
    ),

    GoRoute(
      path: '/partner/manual-code',
      builder: (BuildContext context, GoRouterState state) {
        final order = state.extra as Map<String, dynamic>?;
        return PartnerManualCodePage(order: order ?? {});
      },
    ),

    GoRoute(
      path: '/partner/invalid-code',
      builder: (BuildContext context, GoRouterState state) {
        final order = state.extra as Map<String, dynamic>?;
        return PartnerInvalidCodePage(order: order ?? {});
      },
    ),

    GoRoute(
      path: '/partner/pickup-validated',
      builder: (BuildContext context, GoRouterState state) {
        final order = state.extra as Map<String, dynamic>?;
        return PartnerPickupValidatedPage(order: order ?? {});
      },
    ),

    GoRoute(
      path: '/partner/validated-pickups',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerValidatedPickupsPage(),
    ),

    GoRoute(
      path: '/partner/promotions',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerPromotionsPage(),
    ),

    GoRoute(
      path: '/partner/create-promotion',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerCreatePromotionPage(),
    ),

    GoRoute(
      path: '/partner/activity',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerActivityPage(),
    ),

    GoRoute(
      path: '/partner/revenue-detail',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerRevenueDetailPage(),
    ),

    GoRoute(
      path: '/partner/transactions',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerTransactionsPage(),
    ),

    GoRoute(
      path: '/partner/payouts',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerPayoutsPage(),
    ),

    GoRoute(
      path: '/partner/payment-coordinates',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerPaymentCoordinatesPage(),
    ),

    GoRoute(
      path: '/partner/invoices',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerInvoicesPage(),
    ),

    GoRoute(
      path: '/partner/stats',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerStatsPage(),
    ),

    GoRoute(
      path: '/partner/commerce-settings',
      builder:
          (BuildContext context, GoRouterState state) =>
              const PartnerCommerceSettingsPage(),
    ),

    GoRoute(
      path: '/about',
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              _smoothPage(state, const AboutDailyCatchPage()),
    ),

    GoRoute(
      path: '/how-it-works',
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              _smoothPage(state, const HowItWorksDetailPage()),
    ),

    GoRoute(
      path: '/terms',
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              _smoothPage(state, const TermsPage()),
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

    GoRoute(
      path: '/admin/orders',
      builder: (BuildContext context, GoRouterState state) {
        return const AdminPlaceholderPage(
          title: 'Réservations',
          icon: Icons.shopping_bag_outlined,
        );
      },
    ),

    GoRoute(
      path: '/admin/products',
      builder: (BuildContext context, GoRouterState state) {
        return const AdminPlaceholderPage(
          title: 'Paniers',
          icon: Icons.inventory_2_outlined,
          message:
              'Les paniers sont publiés par les vendeurs. L’admin surveille les abus, les ruptures et la qualité.',
        );
      },
    ),

    GoRoute(
      path: '/admin/products/new',
      builder: (BuildContext context, GoRouterState state) {
        return const AdminPlaceholderPage(
          title: 'Création réservée aux vendeurs',
          icon: Icons.storefront_outlined,
          message:
              'Chaque partenaire crée ses paniers depuis son espace vendeur. L’admin valide les partenaires et contrôle la plateforme.',
        );
      },
    ),

    GoRoute(
      path: '/admin/deliveries',
      builder: (BuildContext context, GoRouterState state) {
        return const AdminPlaceholderPage(
          title: 'Suivi retraits',
          icon: Icons.qr_code_scanner,
        );
      },
    ),

    GoRoute(
      path: '/admin/revenue',
      builder: (BuildContext context, GoRouterState state) {
        return const AdminPlaceholderPage(title: 'Revenus', icon: Icons.euro);
      },
    ),

    GoRoute(
      path: '/admin/partner-payments',
      builder: (BuildContext context, GoRouterState state) {
        return const AdminPlaceholderPage(
          title: 'Paiements partenaires',
          icon: Icons.payments_outlined,
        );
      },
    ),

    GoRoute(
      path: '/admin/settings',
      builder: (BuildContext context, GoRouterState state) {
        return const AdminPlaceholderPage(
          title: 'Paramètres admin',
          icon: Icons.settings_outlined,
        );
      },
    ),

    // ========== PARTNER DASHBOARD ==========

    // Partner Dashboard
    GoRoute(
      path: '/partner-dashboard',
      redirect:
          (BuildContext context, GoRouterState state) =>
              '/partner/mobile-dashboard',
    ),

    // Legacy vendor aliases kept for deep links and old buttons.
    GoRoute(
      path: '/partner/add-product',
      redirect:
          (BuildContext context, GoRouterState state) => '/partner/new-basket',
    ),

    GoRoute(
      path: '/partner/add-pack',
      redirect:
          (BuildContext context, GoRouterState state) => '/partner/new-basket',
    ),

    GoRoute(
      path: '/partner/products',
      redirect:
          (BuildContext context, GoRouterState state) => '/partner/baskets',
    ),

    GoRoute(
      path: '/partner/packs',
      redirect:
          (BuildContext context, GoRouterState state) => '/partner/baskets',
    ),

    GoRoute(
      path: '/partner/inventory',
      redirect:
          (BuildContext context, GoRouterState state) => '/partner/baskets',
    ),

    GoRoute(
      path: '/partner/orders',
      builder: (BuildContext context, GoRouterState state) {
        return const PartnerOrdersMobilePage();
      },
    ),

    GoRoute(
      path: '/partner/scan',
      builder: (BuildContext context, GoRouterState state) {
        final order = state.extra as Map<String, dynamic>?;
        return QRScannerPage(order: order ?? {});
      },
    ),

    GoRoute(
      path: '/partner/schedules',
      redirect:
          (BuildContext context, GoRouterState state) =>
              '/partner/opening-hours',
    ),

    GoRoute(
      path: '/partner/analytics',
      redirect: (BuildContext context, GoRouterState state) => '/partner/stats',
    ),
  ],
);

// ========== MISSING PAGE CLASSES ==========

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

class AdminPlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;

  const AdminPlaceholderPage({
    super.key,
    required this.title,
    required this.icon,
    this.message = 'Interface admin prête pour raccordement métier.',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 56, color: Colors.grey[500]),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder Page for Partner Dashboard
class PartnerPlaceholderPage extends StatelessWidget {
  final String title;

  const PartnerPlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '$title - En développement',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Cette page sera bientôt disponible',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
