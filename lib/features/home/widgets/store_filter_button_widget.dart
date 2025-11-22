import 'package:flutter/material.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class StoreFilterButtonWidget extends StatelessWidget {
  const StoreFilterButtonWidget({
    super.key,
    this.isSelected,
    this.onTap,
    required this.buttonText,
    this.isSeeAll = false,
  });

  final bool? isSelected;
  final void Function()? onTap;
  final String buttonText;
  final bool? isSeeAll;

  @override
  Widget build(BuildContext context) {
    return isSeeAll!
        ? ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  Dimensions.paddingSizeSmall,
                ),
              ),

            ),
            onPressed: onTap,
            child: Text(
              buttonText,
            ),
          )
        : InkWell(
            onTap: onTap,
            child: Container(
              height: 35,
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: isSelected == true
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                border: Border.all(
                    color: isSelected == true
                        ? Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .color!
                            .withAlpha((0.3 * 255).toInt())
                        : Theme.of(context)
                            .disabledColor
                            .withAlpha((0.3 * 255).toInt())),
              ),
              child: Center(
                  child: Text(buttonText,
                      style: STCRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          fontWeight: isSelected == true
                              ? FontWeight.bold
                              : FontWeight.w400,
                          color: isSelected == true
                              ? Theme.of(context).textTheme.bodyMedium!.color
                              : Theme.of(context).disabledColor))),
            ),
          );
  }
}
