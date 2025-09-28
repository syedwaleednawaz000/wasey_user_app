import 'package:flutter/material.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';

class DeliverItemCardWidget extends StatelessWidget {
  final String image;
  final String itemName;
  final String description;
  final bool isDeliverItem;
  const DeliverItemCardWidget(
      {super.key,
      required this.image,
      required this.itemName,
      required this.description,
      this.isDeliverItem = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: isDeliverItem
            ? Theme.of(context).primaryColor.withAlpha((0.05 * 255).toInt())
            : Theme.of(context).cardColor.withAlpha((0.5 * 255).toInt()),
        border: Border.all(
            color: isDeliverItem
                ? Theme.of(context).primaryColor.withAlpha((0.1 * 255).toInt())
                : Theme.of(context).cardColor),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CustomImage(
          image: image,
          height: 30,
          width: 30,
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: ResponsiveHelper.isDesktop(context)
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.spaceBetween,
              children: [
                Text(itemName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: STCMedium),
                SizedBox(
                    height: ResponsiveHelper.isDesktop(context)
                        ? Dimensions.paddingSizeSmall
                        : 0),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: STCRegular.copyWith(
                      color: Theme.of(context).disabledColor,
                      fontSize: Dimensions.fontSizeSmall),
                ),
              ]),
        ),
      ]),
    );
  }
}
