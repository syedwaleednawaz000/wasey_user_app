import 'dart:math' as Math;

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/item_bottom_sheet.dart';
import 'package:sixam_mart/common/widgets/quantity_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartItemWidget extends StatelessWidget {
  final CartModel cart;
  final int cartIndex;
  final List<AddOns> addOns;
  final bool isAvailable;

  const CartItemWidget(
      {super.key,
      required this.cart,
      required this.cartIndex,
      required this.isAvailable,
      required this.addOns});

  @override
  Widget build(BuildContext context) {
    double? startingPrice = _calculatePriceWithVariation(item: cart.item);
    double? endingPrice =
        _calculatePriceWithVariation(item: cart.item, isStartingPrice: false);
    String? variationText = _setupVariationText(cart: cart);
    String addOnText = _setupAddonsText(cart: cart) ?? '';

    double? discount = cart.item!.storeDiscount == 0
        ? cart.item!.discount
        : cart.item!.storeDiscount;
    String? discountType =
        cart.item!.storeDiscount == 0 ? cart.item!.discountType : 'percent';
    String genericName = '';

    if (cart.item!.genericName != null && cart.item!.genericName!.isNotEmpty) {
      for (String name in cart.item!.genericName!) {
        genericName += name;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: Slidable(
        key: UniqueKey(),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.2,
          children: [
            SlidableAction(
              onPressed: (context) {
                Get.find<CartController>()
                    .removeFromCart(cartIndex, item: cart.item);
              },
              backgroundColor: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(
                      Get.find<LocalizationController>().isLtr
                          ? Dimensions.radiusLarge
                          : 0),
                  left: Radius.circular(Get.find<LocalizationController>().isLtr
                      ? 0
                      : Dimensions.radiusLarge)),
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              )
            ],
          ),
          child: CustomInkWell(
            onTap: () {
              ResponsiveHelper.isMobile(context)
                  ? showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (con) => ItemBottomSheet(
                        item: cart.item,
                        cartIndex: cartIndex,
                        cart: cart,
                      ),
                    )
                  : showDialog(
                      context: context,
                      builder: (con) => Dialog(
                            child: ItemBottomSheet(
                                item: cart.item,
                                cartIndex: cartIndex,
                                cart: cart),
                          ));
            },
            radius: Dimensions.radiusLarge,
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      child: CustomImage(
                        image: '${cart.item!.imageFullUrl}',
                        height: ResponsiveHelper.isDesktop(context) ? 100 : 85,
                        width: ResponsiveHelper.isDesktop(context) ? 100 : 85,
                        fit: BoxFit.cover,
                      ),
                    ),
                    isAvailable
                        ? const SizedBox()
                        : Positioned(
                            top: 0,
                            left: 0,
                            bottom: 0,
                            right: 0,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault),
                                  color: Colors.black
                                      .withAlpha((0.7 * 255).toInt())),
                              child: Text('not_available_now_break'.tr,
                                  textAlign: TextAlign.center,
                                  style: STCMedium.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                  )),
                            ),
                          ),
                  ],
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item Name & Badges
                      Row(children: [
                            Flexible(
                              child: Text(
                                cart.item!.name!,
                                style: STCBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).textTheme.bodyLarge!.color,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall),
                            ((Get.find<SplashController>()
                                            .configModel!
                                            .moduleConfig!
                                            .module!
                                            .unit! &&
                                        cart.item!.unitType != null &&
                                        !Get.find<SplashController>()
                                            .getModuleConfig(
                                                cart.item!.moduleType)
                                            .newVariation!) ||
                                    (Get.find<SplashController>()
                                            .configModel!
                                            .moduleConfig!
                                            .module!
                                            .vegNonVeg! &&
                                        Get.find<SplashController>()
                                            .configModel!
                                            .toggleVegNonVeg!))
                                ? !Get.find<SplashController>()
                                        .configModel!
                                        .moduleConfig!
                                        .module!
                                        .unit!
                                    ? CustomAssetImageWidget(
                                        cart.item!.veg == 0
                                            ? Images.nonVegImage
                                            : Images.vegImage,
                                        height: 11,
                                        width: 11,
                                      )
                                    : Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: Dimensions
                                                .paddingSizeExtraSmall,
                                            horizontal:
                                                Dimensions.paddingSizeSmall),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withAlpha((0.1 * 255).toInt()),
                                        ),
                                        child: Text(
                                          cart.item!.unitType ?? '',
                                          style: STCMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeExtraSmall,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                      )
                                : const SizedBox(),
                            SizedBox(
                                width: cart.item!.isStoreHalalActive! &&
                                        cart.item!.isHalalItem!
                                    ? Dimensions.paddingSizeExtraSmall
                                    : 0),
                            cart.item!.isStoreHalalActive! &&
                                    cart.item!.isHalalItem!
                                ? const CustomAssetImageWidget(Images.halalTag,
                                    height: 13, width: 13)
                                : const SizedBox(),
                          ]),
                          (genericName.isNotEmpty)
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Row(children: [
                                    Flexible(
                                      child: Text(
                                        genericName,
                                        style: STCMedium.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color:
                                              Theme.of(context).disabledColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ]),
                                )
                              : const SizedBox(),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Row(children: [
                            Text(
                              '${PriceConverter.convertPrice(startingPrice, discount: discount, discountType: discountType)}'
                              '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice, discount: discount, discountType: discountType)}' : ''}',
                              style: STCBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).primaryColor,
                              ),
                              textDirection: TextDirection.ltr,
                            ),
                            SizedBox(
                                width: discount! > 0
                                    ? Dimensions.paddingSizeSmall
                                    : 0),
                            discount > 0
                                ? Text(
                                    '${PriceConverter.convertPrice(startingPrice)}'
                                    '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice)}' : ''}',
                                    textDirection: TextDirection.ltr,
                                    style: STCRegular.copyWith(
                                      color: Theme.of(context).disabledColor,
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: Dimensions.fontSizeSmall,
                                    ),
                                  )
                                : const SizedBox(),
                          ]),
                          cart.item!.isPrescriptionRequired!
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          ResponsiveHelper.isDesktop(context)
                                              ? Dimensions.paddingSizeExtraSmall
                                              : 2),
                                  child: Text(
                                    '* ${'prescription_required'.tr}',
                                    style: STCRegular.copyWith(
                                        fontSize: Dimensions.fontSizeExtraSmall,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error),
                                  ),
                                )
                              : const SizedBox(),
                          addOnText.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: Dimensions.paddingSizeExtraSmall),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('${'addons'.tr}: ',
                                            style: STCMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall)),
                                        Flexible(
                                            child: Text(
                                          addOnText,
                                          style: STCRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(context)
                                                  .disabledColor),
                                        )),
                                      ]),
                                )
                              : const SizedBox(),
                          variationText!.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: Dimensions.paddingSizeExtraSmall),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('${'variations'.tr}: ',
                                            style: STCMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall)),
                                        Flexible(
                                            child: Text(
                                          variationText,
                                          style: STCRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(context)
                                                  .disabledColor),
                                        )),
                                      ]),
                                )
                              : const SizedBox(),
                          
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          
                          // Quantity Controls
                          GetBuilder<CartController>(builder: (cartController) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: cartController.isLoading
                                          ? null
                                          : () {
                                              if (cart.quantity! > 1) {
                                                Get.find<CartController>().setQuantity(
                                                    false,
                                                    cartIndex,
                                                    cart.stock,
                                                    cart.quantityLimit);
                                              } else {
                                                Get.find<CartController>().removeFromCart(
                                                    cartIndex,
                                                    item: cart.item);
                                              }
                                            },
                                      borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(
                                          Get.find<LocalizationController>().isLtr
                                              ? Dimensions.radiusLarge
                                              : 0,
                                        ),
                                        right: Radius.circular(
                                          Get.find<LocalizationController>().isLtr
                                              ? 0
                                              : Dimensions.radiusLarge,
                                        ),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        child: Icon(
                                          cart.quantity! == 1 
                                              ? Icons.delete_outline_rounded 
                                              : Icons.remove,
                                          size: 20,
                                          color: cartController.isLoading
                                              ? Theme.of(context).disabledColor
                                              : Theme.of(context).colorScheme.error,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeDefault,
                                    ),
                                    child: Text(
                                      cart.quantity.toString(),
                                      style: STCBold.copyWith(
                                        fontSize: Dimensions.fontSizeLarge,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: cartController.isLoading
                                          ? null
                                          : () {
                                              Get.find<CartController>()
                                                  .forcefullySetModule(
                                                      Get.find<CartController>()
                                                          .cartList[0]
                                                          .item!
                                                          .moduleId!);
                                              Get.find<CartController>().setQuantity(
                                                  true,
                                                  cartIndex,
                                                  cart.stock,
                                                  cart.quantityLimit);
                                            },
                                      borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(
                                          Get.find<LocalizationController>().isLtr
                                              ? Dimensions.radiusLarge
                                              : 0,
                                        ),
                                        left: Radius.circular(
                                          Get.find<LocalizationController>().isLtr
                                              ? 0
                                              : Dimensions.radiusLarge,
                                        ),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        child: Icon(
                                          Icons.add,
                                          size: 20,
                                          color: cartController.isLoading
                                              ? Theme.of(context).disabledColor
                                              : Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double? _calculatePriceWithVariation(
      {required Item? item, bool isStartingPrice = true}) {
    double? startingPrice;
    double? endingPrice;
    bool newVariation = Get.find<SplashController>()
            .getModuleConfig(item!.moduleType)
            .newVariation ??
        false;

    if (item.variations!.isNotEmpty && !newVariation) {
      List<double?> priceList = [];
      for (var variation in item.variations!) {
        priceList.add(variation.price);
      }
      priceList.sort((a, b) => a!.compareTo(b!));
      startingPrice = priceList[0];
      if (priceList[0]! < priceList[priceList.length - 1]!) {
        endingPrice = priceList[priceList.length - 1];
      }
    } else {
      startingPrice = item.price;
    }
    if (isStartingPrice) {
      return startingPrice;
    } else {
      return endingPrice;
    }
  }

  String? _setupVariationText({required CartModel cart}) {
    String? variationText = '';
    debugPrint('_setupVariationText ==========> ${cart.toJson()}');

    // Determine which variation system to use
    bool useFVariation = cart.fVariation != null && cart.fVariation!.isNotEmpty;

    if (useFVariation) {
      // Use fVariation system
      for (var variation in cart.fVariation!) {
        if (variation.name != null && variation.values != null) {
          variationText =
              '${variationText!}${variationText.isNotEmpty ? ', ' : ''}${variation.name} (';

          List<String> pairedValues = [];

          // Check if we have labels
          if (variation.values!.label != null &&
              variation.values!.label!.isNotEmpty) {
            // If toppingOptions is empty or null, only show labels
            if (variation.values!.toppingOptions == null ||
                variation.values!.toppingOptions!.isEmpty) {
              // Only add labels
              pairedValues.addAll(variation.values!.label!);
            }
            // If we have both labels and toppings, pair them
            else if (variation.values!.toppingOptions != null &&
                variation.values!.toppingOptions!.isNotEmpty) {
              int minLength = Math.min(variation.values!.label!.length,
                  variation.values!.toppingOptions!.length);
              // debugPrint('variationText ==========> labels: ${variation.values!.label}, toppings: ${variation.values!.toppingOptions}');

              for (int i = 0; i < minLength; i++) {
                String label = variation.values!.label![i];
                String? topping = variation.values!.toppingOptions![i];
                // debugPrint(' ==========> label: ${label}, topping: ${topping}');

                if (topping != null && topping.isNotEmpty) {
                  pairedValues.add('$label $topping');
                } else {
                  pairedValues.add(
                      label); // Just add the label if topping is null or empty
                }
              }
            }
          }

          variationText = '${variationText!}${pairedValues.join(', ')})';
        }
      }
    } else {
      // Use original systems
      if (Get.find<SplashController>()
          .getModuleConfig(cart.item!.moduleType)
          .newVariation!) {
        if (cart.foodVariations!.isNotEmpty) {
          for (int index = 0; index < cart.foodVariations!.length; index++) {
            if (cart.foodVariations![index].contains(true)) {
              variationText =
                  '${variationText!}${variationText.isNotEmpty ? ', ' : ''}${cart.item!.foodVariations![index].name} (';
              for (int i = 0; i < cart.foodVariations![index].length; i++) {
                if (cart.foodVariations![index][i]!) {
                  variationText =
                      '${variationText!}${variationText.endsWith('(') ? '' : ', '}${cart.item!.foodVariations![index].variationValues![i].level}';
                }
              }
              variationText = '${variationText!})';
            }
          }
        }
      } else {
        if (cart.variation!.isNotEmpty) {
          List<String> variationTypes = cart.variation![0].type!.split('-');
          if (variationTypes.length == cart.item!.choiceOptions!.length) {
            int index0 = 0;
            for (var choice in cart.item!.choiceOptions!) {
              variationText =
                  '${variationText!}${(index0 == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index0]}';
              index0 = index0 + 1;
            }
          } else {
            variationText = cart.item!.variations![0].type;
          }
        }
      }
    }

    // debugPrint('variationText ==========> ${variationText}');
    return variationText;
  }

/*  String? _setupVariationText({required CartModel cart}) {
    String? variationText = '';
    debugPrint('_setupVariationText ==========> ${cart.toJson()}');
    if (Get.find<SplashController>()
        .getModuleConfig(cart.item!.moduleType)
        .newVariation!) {
      if (cart.foodVariations!.isNotEmpty) {
        for (int index = 0; index < cart.foodVariations!.length; index++) {
          if (cart.foodVariations![index].contains(true)) {
            variationText =
                '${variationText!}${variationText.isNotEmpty ? ', ' : ''}${cart.item!.foodVariations![index].name} (';
            for (int i = 0; i < cart.foodVariations![index].length; i++) {
              if (cart.foodVariations![index][i]!) {
                variationText =
                    '${variationText!}${variationText.endsWith('(') ? '' : ', '}${cart.item!.foodVariations![index].variationValues![i].level}';
              }
            }
            variationText = '${variationText!})';
          }
        }
      }
    } else {
      if (cart.variation!.isNotEmpty) {
        List<String> variationTypes = cart.variation![0].type!.split('-');
        if (variationTypes.length == cart.item!.choiceOptions!.length) {
          int index0 = 0;
          for (var choice in cart.item!.choiceOptions!) {
            variationText =
                '${variationText!}${(index0 == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index0]}';
            index0 = index0 + 1;
          }
        } else {
          variationText = cart.item!.variations![0].type;
        }
      }
    }

    // First check fVariation
    if (cart.fVariation != null && cart.fVariation!.isNotEmpty) {
      for (var variation in cart.fVariation!) {
        if (variation.name != null && variation.values != null) {
          variationText =
          '${variationText!}${variationText.isNotEmpty ? ', ' : ''}${variation.name} (';

          // Pair each label with its corresponding toppingOption
          List<String> pairedValues = [];
          if (variation.values!.label != null && variation.values!.toppingOptions != null) {
            int minLength = Math.min(variation.values!.label!.length, variation.values!.toppingOptions!.length);

            for (int i = 0; i < minLength; i++) {
              String label = variation.values!.label![i];
              String topping = variation.values!.toppingOptions![i];
              pairedValues.add('$label $topping');
            }
          }

          variationText = '${variationText!}${pairedValues.join(', ')})';
        }
      }
    }
    debugPrint('variationText ==========> ${variationText}');

    return variationText;
  }*/

  String? _setupAddonsText({required CartModel cart}) {
    String addOnText = '';
    int index0 = 0;
    List<int?> ids = [];
    List<int?> qtys = [];
    for (var addOn in cart.addOnIds!) {
      ids.add(addOn.id);
      qtys.add(addOn.quantity);
    }
    for (var addOn in cart.item!.addOns!) {
      if (ids.contains(addOn.id)) {
        addOnText =
            '$addOnText${(index0 == 0) ? '' : ',  '}${addOn.name} (${qtys[index0]})';
        index0 = index0 + 1;
      }
    }
    return addOnText;
  }
}
