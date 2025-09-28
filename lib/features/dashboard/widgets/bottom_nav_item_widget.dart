import 'package:flutter/material.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class BottomNavItemWidget extends StatelessWidget {
  final String selectedIcon;
  final String unSelectedIcon;
  final String title;
  final Function? onTap;
  final bool isSelected;
  final bool isMarket;

  const BottomNavItemWidget(
      {super.key,
      this.onTap,
      this.isSelected = false,
      this.isMarket = false,
      required this.title,
      required this.selectedIcon,
      required this.unSelectedIcon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          isMarket
              ? Icon(
                  isSelected
                      ? Icons.store_mall_directory
                      : Icons.store_mall_directory_outlined,
                  size: 25,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyMedium!.color!,
                )
              : Image.asset(
                  isSelected ? selectedIcon : unSelectedIcon,
                  height: 28,
                  width: 28,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyMedium!.color!,
                ),
          SizedBox(
              height: isSelected
                  ? Dimensions.paddingSizeExtraSmall
                  : Dimensions.paddingSizeSmall),
          Text(
            title,
            style: STCRegular.copyWith(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodyMedium!.color!,
                fontSize: 12),
          ),
        ]),
      ),
    );
  }
}
