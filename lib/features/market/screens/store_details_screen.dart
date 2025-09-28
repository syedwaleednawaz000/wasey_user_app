import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../../../common/widgets/custom_app_bar.dart'; // Your app bar
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';
import '../domain/models/market_store_model.dart';
import '../widgets/grocery_item_card_widget.dart'; // Re-use the item card

class StoreDetailsScreen extends StatelessWidget {
  final MarketStoreModel store; // We'll pass the store object via arguments

  const StoreDetailsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: store.name), // Show store name in app bar
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Store Banner
            SizedBox(
              height: 200, // Adjust as needed
              child: CachedNetworkImage(
                imageUrl: store.bannerUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[300], child: const Center(child: CircularProgressIndicator())),
                errorWidget: (context, url, error) => Container(color: Colors.grey[200], child: Icon(Icons.broken_image, size: 100, color: Colors.grey[400])),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Store Info (Logo, Name, Description)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        child: CachedNetworkImage(
                          imageUrl: store.logoUrl,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(width: 80, height: 80, color: Colors.grey[300]),
                          errorWidget: (context, url, error) => Container(width: 80, height: 80, color: Colors.grey[200], child: Icon(Icons.business, size: 40,color: Colors.grey[400])),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: STCBold.copyWith(fontSize: Dimensions.fontSizeOverLarge),
                            ),
                            // Add other info like ratings, delivery time if available later
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Text(
                    'about_store'.tr, // "About Store"
                    style: STCMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text(
                    store.description,
                    style: STCRegular.copyWith(color: Theme.of(context).hintColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Items in this Store
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Text(
                'items_from_this_store'.tr, // "Items from this Store"
                style: STCMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            if (store.items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Center(child: Text('no_items_in_this_store_yet'.tr)),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                // Using a ListView.builder for potentially many items,
                // but wrapped in a Column so it needs either a fixed height or shrinkWrap.
                // For a long list inside SingleChildScrollView, consider alternatives if performance issues arise.
                child: GridView.builder(
                  shrinkWrap: true, // Important inside SingleChildScrollView
                  physics: const NeverScrollableScrollPhysics(), // To avoid nested scrolling conflicts
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: Dimensions.paddingSizeSmall,
                    mainAxisSpacing: Dimensions.paddingSizeSmall,
                  ),
                  itemCount: store.items.length,
                  itemBuilder: (context, index) {
                    return GroceryItemCardWidget(item: store.items[index]);
                  },
                ),
              ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
          ],
        ),
      ),
    );
  }
}
