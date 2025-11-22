import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

import '../../../util/images.dart';
import '../../cart/controllers/cart_controller.dart';

class BottomNavItemWidget extends StatelessWidget {
  final String selectedIcon;
  final String unSelectedIcon;
  final String title;
  final Function? onTap;
  final bool isSelected;
  // final bool isMarket;
  final bool isParcel;
  final bool isNotParcel;

  const BottomNavItemWidget(
      {super.key,
      this.onTap,
      this.isSelected = false,
      // this.isMarket = false,
      this.isParcel = false,
      this.isNotParcel = false,
      required this.title,
      required this.selectedIcon,
      required this.unSelectedIcon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          isParcel
              ? Icon(
                  CupertinoIcons.add,
                  size: 35,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyMedium!.color!,
                )
              : isNotParcel
                  ? Stack(clipBehavior: Clip.none, children: [
                      Image.asset(
                        Images.myCarts,
                        height: 30,
                        width: 30,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).textTheme.bodyMedium!.color!,
                      ),
                      GetBuilder<CartController>(builder: (cartController) {
                        return cartController.cartList.isNotEmpty
                            ? Positioned(
                                top: -6,
                                right: -8,
                                child: Container(
                                  height: 22 < 20 ? 10 : 22 / 1.5,
                                  width: 22 < 20 ? 10 : 22 / 1.5,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).colorScheme.error,
                                    border: Border.all(
                                        width: 22 < 20 ? 0.7 : 1,
                                        color: Theme.of(context).cardColor),
                                  ),
                                  child: Text(
                                    cartController.cartList.length.toString(),
                                    style: STCRegular.copyWith(
                                      fontSize: 22 / 3,
                                      color: Theme.of(context).cardColor,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox();
                      }),
                    ]):
                  Image.asset(
                          isSelected ? selectedIcon : unSelectedIcon,
                          height: 30,
                          width: 30,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).textTheme.bodyMedium!.color!,
                        ),
          SizedBox(
            height: isSelected
                ? Dimensions.paddingSizeExtraSmall
                : Dimensions.paddingSizeSmall,
          ),
          Text(
            title,
            style: STCRegular.copyWith(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).textTheme.bodyMedium!.color!,
              fontSize: 12,
            ),
          ),
        ]),
      ),
    );
  }
}
