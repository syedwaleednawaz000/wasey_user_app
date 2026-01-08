import 'package:sixam_mart/util/dimensions.dart';
import 'package:flutter/material.dart';

class QuantityButton extends StatelessWidget {
  final bool isIncrement;
  final Function? onTap;
  final bool fromSheet;
  final bool showRemoveIcon;
  final bool fromCart;
  final Color? color;

  const QuantityButton({
    super.key,
    required this.isIncrement,
    required this.onTap,
    this.fromSheet = false,
    this.fromCart = false,
    this.showRemoveIcon = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return fromCart
        ? InkWell(
            onTap: onTap as void Function()?,
            child: Container(
              height: fromCart ? 30 : 22,
              width: fromCart ? 30 : 22,
              margin: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeExtraSmall,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    width: 1,
                    color: showRemoveIcon
                        ? Theme.of(context).colorScheme.error
                        : isIncrement
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor),
                color: showRemoveIcon
                    ? Theme.of(context).cardColor
                    : isIncrement
                        ? color ?? Theme.of(context).primaryColor
                        : Theme.of(context)
                            .disabledColor
                            .withAlpha((0.2 * 255).toInt()),
              ),
              alignment: Alignment.center,
              child: Icon(
                showRemoveIcon
                    ? Icons.delete_outline_outlined
                    : isIncrement
                        ? Icons.add
                        : Icons.remove,
                size: 15,
                color: showRemoveIcon
                    ? Theme.of(context).colorScheme.error
                    : isIncrement
                        ? Theme.of(context).cardColor
                        : Theme.of(context).disabledColor,
              ),
            ),
          )
        : InkWell(
            onTap: onTap as void Function()?,
            child: Container(
              height: fromSheet ? 30 : 22,
              width: fromSheet ? 30 : 22,
              margin: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    width: 1,
                    color: showRemoveIcon
                        ? Theme.of(context).colorScheme.error
                        : isIncrement
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor),
                color: showRemoveIcon
                    ? Theme.of(context).cardColor
                    : isIncrement
                        ? color ?? Theme.of(context).primaryColor
                        : Theme.of(context)
                            .disabledColor
                            .withAlpha((0.2 * 255).toInt()),
              ),
              alignment: Alignment.center,
              child: Icon(
                showRemoveIcon
                    ? Icons.delete_outline_outlined
                    : isIncrement
                        ? Icons.add
                        : Icons.remove,
                size: 15,
                color: showRemoveIcon
                    ? Theme.of(context).colorScheme.error
                    : isIncrement
                        ? Theme.of(context).cardColor
                        : Theme.of(context).disabledColor,
              ),
            ),
          );
  }
}

class ItemCountButtons extends StatelessWidget {
  final bool isIncrement;
  final Function? onTap;
  final bool fromSheet;
  final bool showRemoveIcon;
  final Color? color;

  const ItemCountButtons(
      {super.key,
      required this.isIncrement,
      required this.onTap,
      this.fromSheet = false,
      this.showRemoveIcon = false,
      this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          isIncrement
              ? Container(
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  width: .5,
                  height: 20,
                  color: Colors.black,
                )
              : const SizedBox(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: Icon(
              showRemoveIcon
                  ? Icons.delete_outline_outlined
                  : isIncrement
                      ? Icons.add
                      : Icons.remove,
              size: 20,
              color: Colors.black,
            ),
          ),
          isIncrement
              ? const SizedBox()
              : Container(
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  width: .5,
                  height: 20,
                  color: Colors.black,
                ),
        ],
      ),
    );
  }
}
