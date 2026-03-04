class ApiEndpoints {
  static const String baseUrl = 'http://38aa-180-248-34-255.ngrok-free.app/api';
  
  // Auth
  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/sign_up';
  static const String logout = '$baseUrl/logout';
  
  // Profile & Store
  static const String upgradeToSeller = '$baseUrl/upgradeToSeller';
  static const String getStoreStatus = '$baseUrl/getStoreStatus';
  static const String updateStatus = '$baseUrl/updateStatus';
  static const String checkLocation = '$baseUrl/checkLocation';
  
  // Products
  static const String tambahProduk = '$baseUrl/tambahProduk';

  // Home
  static const String tampilSeluruhPedagang = '$baseUrl/tampilSeluruhPedagang';

  // Orders
  static const String orderHistory = '$baseUrl/orderHistory';
}
