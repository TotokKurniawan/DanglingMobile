class ApiEndpoints {
  // Ganti baseUrl sesuai IP Lokal / Domain Backend Anda
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static const String _host = '127.0.0.1'; // Host backend (tanpa http)

  // Laravel Reverb WebSocket URL (ws:// untuk lokal, wss:// untuk production)
  // Format: ws://{host}:{reverbPort}/app/{reverbKey}
  static const int reverbPort = 8080; // default Reverb port
  static const String reverbAppKey = 'dangling-reverb-key'; // sesuaikan dengan .env REVERB_APP_KEY
  static String reverbWsUrl = 'ws://$_host:$reverbPort/app/$reverbAppKey';
  
  // Auth
  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register'; // Menggunakan /register yang baru
  static const String logout = '$baseUrl/logout';
  static const String forgotPassword = '$baseUrl/forgot-password';
  static const String resetPassword = '$baseUrl/reset-password';
  
  // Profile & Store
  static const String upgradeToSeller = '$baseUrl/upgrade-to-seller';
  static const String getStoreStatus = '$baseUrl/store-status';
  static const String updateStoreStatus = '$baseUrl/store-status';
  static const String updateLocation = '$baseUrl/sellers/me/location';
  static const String getSellerStats = '$baseUrl/sellers/me/stats';
  static const String uploadProfilePhoto = '$baseUrl/profile/photo';
  static const String updateBuyerProfile = '$baseUrl/buyers'; // + /{id}
  static const String changePassword = '$baseUrl/change-password';
  static const String deleteAccount = '$baseUrl/account';

  // Notifications
  static const String notifications = '$baseUrl/notifications';
  static const String unreadNotificationsCount = '$baseUrl/notifications/unread-count';

  // Reviews & Complaints
  static const String submitReview = '$baseUrl/reviews';
  static const String submitComplaint = '$baseUrl/complaints';
  
  // Favorites
  static const String favorites = '$baseUrl/favorites';
  
  // Products
  static const String getProducts = '$baseUrl/products'; // Seller Only
  static const String tambahProduk = '$baseUrl/products'; // Seller Only
  static const String updateProduk = '$baseUrl/products/'; // + {id}
  static const String deleteProduk = '$baseUrl/products/'; // + {id}

  // Home (Buyer)
  static const String tampilSeluruhPedagang = '$baseUrl/sellers';
  
  // Categories
  static const String categories = '$baseUrl/categories';

  // Orders
  static const String createOrder = '$baseUrl/orders';
  static const String orderHistory = '$baseUrl/order-history';

  // Seller Order Controls
  static const String pendingOrders = '$baseUrl/orders/pending';
  static const String acceptOrder = '$baseUrl/orders'; // /{id}/accept
  static const String rejectOrder = '$baseUrl/orders'; // /{id}/reject
  static const String completeOrder = '$baseUrl/orders'; // /{id}/complete
  static const String cancelOrder = '$baseUrl/orders'; // /{id}/cancel

  // Chat
  static const String chat = '$baseUrl/chat'; // GET /chat, POST /chat, GET /chat/{id}, POST /chat/{id}
}
