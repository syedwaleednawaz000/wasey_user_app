import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../features/item/domain/models/item_model.dart';
import '../../../util/dimensions.dart';

class ItemCardWidget extends StatelessWidget {
  final Item? item; // Assuming you have an 'Item' model
  final bool isStore;
  final bool inStorePage;

  const ItemCardWidget({
    super.key,
    required this.item,
    required this.isStore,
    required this.inStorePage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180, // Example width for horizontal items
      height: 200,
      margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                color: Colors.grey[300], // Placeholder for image
                child: const Center(
                  child: Icon(
                    Icons.image,
                    size: 50,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                item!.name ?? 'No name', // Assuming item has a name
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                '\$${item!.price?.toStringAsFixed(2) ?? 'N/A'}',
                // Assuming item has a price
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
