import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import '../domain/models/grocery_item_model.dart';
import '../domain/models/market_store_model.dart';
// import '../domain/services/market_service.dart'; // We'll add this later for API calls

class MarketController extends GetxController {
  // final MarketService marketService; // For API calls later
  // MarketController({required this.marketService}); // For API calls later

  // --- Observable State Variables ---
  final RxBool _isGroceryLoading =
      true.obs; // To show loading indicator for groceries
  bool get isGroceryLoading => _isGroceryLoading.value;

  final RxBool _isStoresLoading =
      true.obs; // To show loading indicator for stores
  bool get isStoresLoading => _isStoresLoading.value;

  final RxList<GroceryItemModel> _groceryItems = <GroceryItemModel>[].obs;

  List<GroceryItemModel> get groceryItems => _groceryItems;

  final RxList<MarketStoreModel> _marketStores = <MarketStoreModel>[].obs;

  List<MarketStoreModel> get marketStores => _marketStores;

  SplashController splashController = Get.find();
  Future<void> setModuleSuperMarket()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("moduleId", "1");
    splashController.switchModule(0, true);
  }
  // --- Lifecycle Methods ---

  @override
  void onInit() {
    print("MarketController: onInit called."); // ADD THIS LINE
    super.onInit();
    fetchMarketData();
  }

  // --- Business Logic / Data Fetching ---
  Future<void> fetchMarketData() async {
    await fetchGroceryItems();
    await fetchMarketStores();
  }

  Future<void> fetchGroceryItems() async {
    try {
      _isGroceryLoading.value = true;
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // --- Static Demo Data (Replace with API call via marketService later) ---
      _groceryItems.assignAll([
        GroceryItemModel(
            id: '1',
            name: 'Fresh Apples',
            imageUrl:
                'https://media.kasperskydaily.com/wp-content/uploads/sites/92/2020/06/26131454/apple-app-clips-android-instant-apps-featured.jpg',
            storeName: 'Green Grocers',
            price: 2.99),
        GroceryItemModel(
            id: '2',
            name: 'Whole Wheat Bread',
            imageUrl:
                'https://www.mashed.com/img/gallery/nutrition-expert-exposes-the-truth-about-whole-wheat-bread/the-fda-didnt-do-it-so-somebody-else-did-1601578202.jpg',
            storeName: 'Bakery Bliss',
            price: 3.49),
        GroceryItemModel(
            id: '3',
            name: 'Organic Milk',
            imageUrl:
                'https://cdn.pixabay.com/photo/2017/07/05/15/41/milk-2474993_1280.jpg',
            storeName: 'Dairy Farms',
            price: 4.00),
        GroceryItemModel(
            id: '4',
            name: 'Pasta Noodles',
            imageUrl:
                'https://cdn.pixabay.com/photo/2010/12/13/10/00/pasta-2093_1280.jpg',
            storeName: 'Italian Pantry',
            price: 1.99),
        GroceryItemModel(
            id: '5',
            name: 'Chicken Breast',
            imageUrl:
                'https://www.tasteofhome.com/wp-content/uploads/2025/01/Air-Fryer-Chicken-Breasts_EXPS_FT25_278779_EC_0114_4.jpg',
            storeName: 'Butcher Block',
            price: 7.50),
        GroceryItemModel(
            id: '1',
            name: 'Fresh Apples',
            imageUrl:
                'https://media.kasperskydaily.com/wp-content/uploads/sites/92/2020/06/26131454/apple-app-clips-android-instant-apps-featured.jpg',
            storeName: 'Green Grocers',
            price: 2.99),
        GroceryItemModel(
            id: '2',
            name: 'Whole Wheat Bread',
            imageUrl:
                'https://www.mashed.com/img/gallery/nutrition-expert-exposes-the-truth-about-whole-wheat-bread/the-fda-didnt-do-it-so-somebody-else-did-1601578202.jpg',
            storeName: 'Bakery Bliss',
            price: 3.49),
        GroceryItemModel(
            id: '3',
            name: 'Organic Milk',
            imageUrl:
                'https://cdn.pixabay.com/photo/2017/07/05/15/41/milk-2474993_1280.jpg',
            storeName: 'Dairy Farms',
            price: 4.00),
        GroceryItemModel(
            id: '4',
            name: 'Pasta Noodles',
            imageUrl:
                'https://cdn.pixabay.com/photo/2010/12/13/10/00/pasta-2093_1280.jpg',
            storeName: 'Italian Pantry',
            price: 1.99),
        GroceryItemModel(
            id: '5',
            name: 'Chicken Breast',
            imageUrl:
                'https://www.tasteofhome.com/wp-content/uploads/2025/01/Air-Fryer-Chicken-Breasts_EXPS_FT25_278779_EC_0114_4.jpg',
            storeName: 'Butcher Block',
            price: 7.50),
        GroceryItemModel(
            id: '1',
            name: 'Fresh Apples',
            imageUrl:
                'https://media.kasperskydaily.com/wp-content/uploads/sites/92/2020/06/26131454/apple-app-clips-android-instant-apps-featured.jpg',
            storeName: 'Green Grocers',
            price: 2.99),
        GroceryItemModel(
            id: '2',
            name: 'Whole Wheat Bread',
            imageUrl:
                'https://www.mashed.com/img/gallery/nutrition-expert-exposes-the-truth-about-whole-wheat-bread/the-fda-didnt-do-it-so-somebody-else-did-1601578202.jpg',
            storeName: 'Bakery Bliss',
            price: 3.49),
        GroceryItemModel(
            id: '3',
            name: 'Organic Milk',
            imageUrl:
                'https://cdn.pixabay.com/photo/2017/07/05/15/41/milk-2474993_1280.jpg',
            storeName: 'Dairy Farms',
            price: 4.00),
        GroceryItemModel(
            id: '4',
            name: 'Pasta Noodles',
            imageUrl:
                'https://cdn.pixabay.com/photo/2010/12/13/10/00/pasta-2093_1280.jpg',
            storeName: 'Italian Pantry',
            price: 1.99),
        GroceryItemModel(
            id: '5',
            name: 'Chicken Breast',
            imageUrl:
                'https://www.tasteofhome.com/wp-content/uploads/2025/01/Air-Fryer-Chicken-Breasts_EXPS_FT25_278779_EC_0114_4.jpg',
            storeName: 'Butcher Block',
            price: 7.50),
      ]);
      // --- End Static Demo Data ---
    } catch (e) {
      // Handle error, maybe show a snackbar
      Get.snackbar('Error', 'Failed to load grocery items: ${e.toString()}');
    } finally {
      _isGroceryLoading.value = false;
    }
  }

  Future<void> fetchMarketStores() async {
    try {
      _isStoresLoading.value = true;
      // Simulate API call delay
      await Future.delayed(
          const Duration(milliseconds: 1500)); // Slightly different delay

      // --- Static Demo Data (Replace with API call via marketService later) ---
      _marketStores.assignAll([
        MarketStoreModel(
            id: 's1',
            name: 'Green Valley Grocers',
            logoUrl:
                'https://media.licdn.com/dms/image/v2/C560BAQGtebCfqaCwrg/company-logo_200_200/company-logo_200_200/0/1630602893378/green_valley_grocery_logo?e=2147483647&v=beta&t=N-uBM5mgr2kjZtqpJWppSz5QG8uRewCGRPJ16sbONnw',
            bannerUrl:
                'https://www.gvgrocery.com/wp-content/uploads/2022/04/greenvalleyinterio-reduced.jpg',
            description:
                'Your one-stop shop for fresh produce and daily essentials. We pride ourselves on quality and customer service.',
            items: [
              GroceryItemModel(
                id: 's1_i1',
                name: 'Organic Bananas',
                imageUrl:
                    'https://assets.farmjournal.com/dims4/default/c2ccbb2/2147483647/strip/true/crop/840x561+0+20/resize/800x534!/quality/90/?url=https%3A%2F%2Ffj-corp-pub.s3.us-east-2.amazonaws.com%2Fs3fs-public%2F2023-05%2Fbananas.jpg',
                storeName: 'Green Valley Grocers',
                price: 1.99,
              ),
              GroceryItemModel(
                id: 's1_i2',
                name: 'Fresh Eggs (Dozen)',
                imageUrl:
                    'https://www.treehugger.com/thmb/AIHOg8qRuJ-mIFcMQ-DiFdW47w0=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/how-long-do-fresh-eggs-last-4859426-06-bc9fdbffc4a94863a116ec73e1a07165.jpg',
                storeName: 'Green Valley Grocers',
                price: 3.20,
              ),
              GroceryItemModel(
                id: 's1_i1',
                name: 'Organic Bananas',
                imageUrl:
                    'https://assets.farmjournal.com/dims4/default/c2ccbb2/2147483647/strip/true/crop/840x561+0+20/resize/800x534!/quality/90/?url=https%3A%2F%2Ffj-corp-pub.s3.us-east-2.amazonaws.com%2Fs3fs-public%2F2023-05%2Fbananas.jpg',
                storeName: 'Green Valley Grocers',
                price: 1.99,
              ),
              GroceryItemModel(
                id: 's1_i2',
                name: 'Fresh Eggs (Dozen)',
                imageUrl:
                    'https://www.treehugger.com/thmb/AIHOg8qRuJ-mIFcMQ-DiFdW47w0=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/how-long-do-fresh-eggs-last-4859426-06-bc9fdbffc4a94863a116ec73e1a07165.jpg',
                storeName: 'Green Valley Grocers',
                price: 3.20,
              ),
              GroceryItemModel(
                id: 's1_i1',
                name: 'Organic Bananas',
                imageUrl:
                    'https://assets.farmjournal.com/dims4/default/c2ccbb2/2147483647/strip/true/crop/840x561+0+20/resize/800x534!/quality/90/?url=https%3A%2F%2Ffj-corp-pub.s3.us-east-2.amazonaws.com%2Fs3fs-public%2F2023-05%2Fbananas.jpg',
                storeName: 'Green Valley Grocers',
                price: 1.99,
              ),
              GroceryItemModel(
                id: 's1_i2',
                name: 'Fresh Eggs (Dozen)',
                imageUrl:
                    'https://www.treehugger.com/thmb/AIHOg8qRuJ-mIFcMQ-DiFdW47w0=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/how-long-do-fresh-eggs-last-4859426-06-bc9fdbffc4a94863a116ec73e1a07165.jpg',
                storeName: 'Green Valley Grocers',
                price: 3.20,
              ),
            ]),
        MarketStoreModel(
            id: 's2',
            name: 'City Mart',
            logoUrl:
                'https://cdn.pixabay.com/photo/2017/03/29/04/09/shopping-icon-2184065_1280.png',
            bannerUrl:
                'https://static.wixstatic.com/media/36deb0_c8ecffc10e2747b1bff695ef2e644a39~mv2.jpeg/v1/fill/w_320,h_213,al_c,q_80,usm_0.66_1.00_0.01,enc_avif,quality_auto/36deb0_c8ecffc10e2747b1bff695ef2e644a39~mv2.jpeg',
            description:
                'Conveniently located in the city center, offering a wide variety of groceries and household items.',
            items: [
              GroceryItemModel(
                id: 's2_i1',
                name: 'Canned Tomatoes',
                imageUrl:
                    'https://www.greenhousecanada.com/wp-content/uploads/2021/05/Verbeek4_2021-599x450.jpeg',
                storeName: 'City Mart',
                price: 0.99,
              ),
              GroceryItemModel(
                id: 's1_i1',
                name: 'Organic Bananas',
                imageUrl:
                    'https://assets.farmjournal.com/dims4/default/c2ccbb2/2147483647/strip/true/crop/840x561+0+20/resize/800x534!/quality/90/?url=https%3A%2F%2Ffj-corp-pub.s3.us-east-2.amazonaws.com%2Fs3fs-public%2F2023-05%2Fbananas.jpg',
                storeName: 'Green Valley Grocers',
                price: 1.99,
              ),
              GroceryItemModel(
                id: 's1_i2',
                name: 'Fresh Eggs (Dozen)',
                imageUrl:
                    'https://www.treehugger.com/thmb/AIHOg8qRuJ-mIFcMQ-DiFdW47w0=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/how-long-do-fresh-eggs-last-4859426-06-bc9fdbffc4a94863a116ec73e1a07165.jpg',
                storeName: 'Green Valley Grocers',
                price: 3.20,
              ),
              GroceryItemModel(
                id: 's1_i1',
                name: 'Organic Bananas',
                imageUrl:
                    'https://assets.farmjournal.com/dims4/default/c2ccbb2/2147483647/strip/true/crop/840x561+0+20/resize/800x534!/quality/90/?url=https%3A%2F%2Ffj-corp-pub.s3.us-east-2.amazonaws.com%2Fs3fs-public%2F2023-05%2Fbananas.jpg',
                storeName: 'Green Valley Grocers',
                price: 1.99,
              ),
              GroceryItemModel(
                id: 's1_i2',
                name: 'Fresh Eggs (Dozen)',
                imageUrl:
                    'https://www.treehugger.com/thmb/AIHOg8qRuJ-mIFcMQ-DiFdW47w0=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/how-long-do-fresh-eggs-last-4859426-06-bc9fdbffc4a94863a116ec73e1a07165.jpg',
                storeName: 'Green Valley Grocers',
                price: 3.20,
              ),
            ]),
        MarketStoreModel(
            id: 's3',
            name: 'The Corner Store',
            logoUrl:
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRrlsVv1mjZTuGivYq_sJClAoCO_SlKvw9Jtg&s',
            bannerUrl:
                'https://cdn.pixabay.com/photo/2016/03/02/20/13/grocery-1232944_1280.jpg',
            description:
                'Your friendly neighborhood store for quick grabs and everyday needs.',
            items: [
              GroceryItemModel(
                id: 's1_i2',
                name: 'Fresh Eggs (Dozen)',
                imageUrl:
                    'https://www.treehugger.com/thmb/AIHOg8qRuJ-mIFcMQ-DiFdW47w0=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/how-long-do-fresh-eggs-last-4859426-06-bc9fdbffc4a94863a116ec73e1a07165.jpg',
                storeName: 'Green Valley Grocers',
                price: 3.20,
              ),
              GroceryItemModel(
                id: 's1_i1',
                name: 'Organic Bananas',
                imageUrl:
                    'https://assets.farmjournal.com/dims4/default/c2ccbb2/2147483647/strip/true/crop/840x561+0+20/resize/800x534!/quality/90/?url=https%3A%2F%2Ffj-corp-pub.s3.us-east-2.amazonaws.com%2Fs3fs-public%2F2023-05%2Fbananas.jpg',
                storeName: 'Green Valley Grocers',
                price: 1.99,
              ),
              GroceryItemModel(
                id: 's1_i2',
                name: 'Fresh Eggs (Dozen)',
                imageUrl:
                    'https://www.treehugger.com/thmb/AIHOg8qRuJ-mIFcMQ-DiFdW47w0=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/how-long-do-fresh-eggs-last-4859426-06-bc9fdbffc4a94863a116ec73e1a07165.jpg',
                storeName: 'Green Valley Grocers',
                price: 3.20,
              ),
              GroceryItemModel(
                id: 's2_i1',
                name: 'Canned Tomatoes',
                imageUrl:
                    'https://www.greenhousecanada.com/wp-content/uploads/2021/05/Verbeek4_2021-599x450.jpeg',
                storeName: 'City Mart',
                price: 0.99,
              ),
            ]),
      ]);
      // --- End Static Demo Data ---
    } catch (e) {
      Get.snackbar('Error', 'Failed to load stores: ${e.toString()}');
    } finally {
      _isStoresLoading.value = false;
    }
  }

// --- Navigation or specific actions can go here if needed ---
// void navigateToStoreDetails(MarketStoreModel store) {
//   Get.toNamed(RouteHelper.getStoreDetailsRoute(store.id), arguments: store);
// }
}
