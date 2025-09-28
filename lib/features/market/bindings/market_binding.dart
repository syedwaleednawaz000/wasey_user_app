import 'package:get/get.dart';
import '../controllers/market_controller.dart';
// import '../domain/services/market_service.dart'; // For API calls later
// import '../data/repository/market_repository.dart'; // For API calls later
// import '../data/provider/market_api_client.dart'; // For API calls later

// lib/features/market/bindings/market_binding.dart
class MarketBinding extends Bindings {
  @override
  void dependencies() {
    print("MarketBinding: Initializing dependencies..."); // ADD THIS LINE
    Get.lazyPut<MarketController>(() {
      print("MarketBinding: Creating MarketController instance."); // ADD THIS LINE
      return MarketController();
    });
  }
}