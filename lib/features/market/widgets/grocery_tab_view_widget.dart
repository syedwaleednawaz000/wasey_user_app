// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../util/dimensions.dart';
// // import '../domain/models/grocery_item_model.dart'; // Model used in card
// import '../controllers/market_controller.dart'; // Import controller
// import 'grocery_item_card_widget.dart';
//
// class GroceryTabViewWidget extends StatelessWidget {
//   const GroceryTabViewWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // Get the controller instance
//     final MarketController marketController = Get.find<MarketController>();
//
//     return Obx(() { // Use Obx for reactive updates based on observable variables
//       if (marketController.isGroceryLoading) {
//         return const Center(child: CircularProgressIndicator());
//       }
//       if (marketController.groceryItems.isEmpty) {
//         return Center(child: Text('no_item_available'.tr));
//       }
//       const double bottomNavBarHeight = 65.0; // Example height, adjust as needed
//       const double additionalPadding = Dimensions.paddingSizeSmall; // Extra space
//
//       return Padding(
//         // Keep your existing overall padding for the sides and top
//         padding: const EdgeInsets.only(
//           left: Dimensions.paddingSizeSmall,
//           right: Dimensions.paddingSizeSmall,
//           top: Dimensions.paddingSizeSmall,
//           // REMOVE bottom from here if you want to control it specifically on GridView
//         ),
//         child: GridView.builder(
//           physics: const BouncingScrollPhysics(),
//           // Add padding specifically to the GridView for scrolling content
//           padding: const EdgeInsets.only(
//             // Keep any existing left/right/top padding you might want INSIDE the scroll area
//             // left: Dimensions.paddingSizeSmall, // Usually handled by outer Padding
//             // right: Dimensions.paddingSizeSmall, // Usually handled by outer Padding
//             // top: Dimensions.paddingSizeSmall, // Usually handled by outer Padding
//             bottom: bottomNavBarHeight + additionalPadding, // <<< KEY CHANGE HERE
//           ),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             childAspectRatio: 0.8, // Corrected aspect ratio
//             crossAxisSpacing: Dimensions.paddingSizeSmall,
//             mainAxisSpacing: Dimensions.paddingSizeSmall,
//           ),
//           itemCount: marketController.groceryItems.length,
//           itemBuilder: (context, index) {
//             return GroceryItemCardWidget(item: marketController.groceryItems[index]);
//           },
//         ),
//       );
//     });
//   }
// }
