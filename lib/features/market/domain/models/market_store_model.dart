import 'grocery_item_model.dart';

class MarketStoreModel {
  final String id;
  final String name;
  final String logoUrl;
  final String bannerUrl;
  final String description;
  final List<GroceryItemModel> items; // Items belonging to this store

  MarketStoreModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.bannerUrl,
    required this.description,
    required this.items,
  });
}