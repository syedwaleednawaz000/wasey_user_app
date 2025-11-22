import 'package:flutter/material.dart';
import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';

import '../../../util/dimensions.dart';
import '../../../util/styles.dart';

class PaymentMethodButton extends StatelessWidget {
  String? paymentName;
  String? paymentImagePath;
  bool? isSelected;
  bool? isNetworkImage;
  Function? onTap;

  PaymentMethodButton({
    required this.paymentName,
    required this.paymentImagePath,
    required this.isSelected,
    this.isNetworkImage = false,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        width: 100,
        height: 110,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeExtraSmall,
          vertical: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).disabledColor.withOpacity(.15),
          borderRadius: BorderRadius.circular(
            Dimensions.radiusDefault,
          ),
          border: Border.all(
            color: isSelected!
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor.withOpacity(.4),
            width: isSelected! ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            isNetworkImage!
                ? CustomImage(
                    height: 35,
                    fit: BoxFit.fitHeight,
                    image: paymentImagePath!,
                  )
                : (paymentImagePath != null &&
                        paymentImagePath != '' &&
                        paymentImagePath!.isNotEmpty)
                    ? CustomAssetImageWidget(
                        paymentImagePath!,
                        height: 35,
                        fit: BoxFit.fitHeight,
                      )
                    : const Icon(
                        Icons.wallet,
                        size: 35,
                      ),
            const SizedBox(
              height: Dimensions.paddingSizeExtraSmall,
            ),
            Text(
              paymentName!,
              style: STCRegular.copyWith(
                overflow: TextOverflow.ellipsis,
                fontWeight: isSelected! ? FontWeight.bold : null,
                color: isSelected!
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
