import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/market/widgets/grocery_store_card_widget.dart';
import '../../../helper/route_helper.dart';
import '../../../util/dimensions.dart';
import '../controllers/market_controller.dart'; // Import controller

class StoresTabViewWidget extends StatelessWidget {
  const StoresTabViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the controller instance
    final MarketController marketController = Get.find<MarketController>();

    return Obx(() {
      // Use Obx for reactive updates
      if (marketController.isStoresLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (marketController.marketStores.isEmpty) {
        return Center(child: Text('no_store_available'.tr));
      }
      return Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: ListView.builder(
          itemCount: marketController.marketStores.length,
          itemBuilder: (context, index) {
            final store = marketController.marketStores[index];
            return GroceryStoreCardWidget(
                store: store,
                onTap: () {
                  Get.toNamed(
                    RouteHelper.getStoreDetailsRoute(store.id),
                    arguments: store,
                  );
                });
          },
        ),
      );
    });
  }
}
