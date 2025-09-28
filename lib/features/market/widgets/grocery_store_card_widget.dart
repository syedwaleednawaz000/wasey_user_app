import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';
import '../domain/models/market_store_model.dart';

class GroceryStoreCardWidget extends StatelessWidget {
  final MarketStoreModel store;
  final VoidCallback onTap;

  const GroceryStoreCardWidget({super.key, required this.store, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 120, // Adjust height as needed
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radiusDefault),
                  topRight: Radius.circular(Dimensions.radiusDefault),
                ),
                child: CachedNetworkImage(
                  imageUrl: store.bannerUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[300]),
                  errorWidget: (context, url, error) => Container(color: Colors.grey[200], child: Icon(Icons.storefront, size: 50, color: Colors.grey[400])),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: CachedNetworkImage(
                      imageUrl: store.logoUrl,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(width: 50, height: 50, color: Colors.grey[300]),
                      errorWidget: (context, url, error) => Container(width: 50, height: 50, color: Colors.grey[200], child: Icon(Icons.business, color: Colors.grey[400])),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.name,
                          style: STCMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        Text(
                          store.description,
                          style: STCRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).disabledColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
