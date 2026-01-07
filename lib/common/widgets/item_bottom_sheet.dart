import 'package:cached_network_image/cached_network_image.dart';
import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart/common/widgets/custom_tool_tip_widget.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/discount_tag.dart';
import 'package:sixam_mart/common/widgets/quantity_button.dart';
import 'package:sixam_mart/common/widgets/rating_bar.dart';
import 'package:sixam_mart/features/checkout/screens/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/language/controllers/language_controller.dart';

class ItemBottomSheet extends StatefulWidget {
  final Item? item;
  final bool isCampaign;
  final CartModel? cart;
  final int? cartIndex;
  final int? storeStatus;
  final bool inStorePage;

  const ItemBottomSheet(
      {super.key,
      required this.item,
      this.isCampaign = false,
      this.cart,
      this.cartIndex,
      this.storeStatus = 1,
      this.inStorePage = false});

  @override
  State<ItemBottomSheet> createState() => _ItemBottomSheetState();
}

class _ItemBottomSheetState extends State<ItemBottomSheet> {
  bool _newVariation = false;
  int _currentListIndex = 0;

  @override
  void initState() {
    super.initState();

    if (Get.find<SplashController>().module == null) {
      if (Get.find<SplashController>().cacheModule != null) {
        Get.find<SplashController>()
            .setCacheConfigModule(Get.find<SplashController>().cacheModule);
      }
    }
    _newVariation = Get.find<SplashController>()
            .getModuleConfig(widget.item!.moduleType)
            .newVariation ??
        false;
    Get.find<ItemController>().initData(widget.item, widget.cart);
  }

  List<Widget> _getDynamicLists() {
    List<Widget> lists = [];
    if (widget.item!.foodVariations != null &&
        widget.item!.foodVariations!.isNotEmpty) {
      lists.add(NewVariationView(
        currentVariationIndex: _currentListIndex,
        item: widget.item,
        itemController: Get.find<ItemController>(),
        discount: (widget.isCampaign || widget.item!.storeDiscount == 0)
            ? (double.tryParse(widget.item!.discount.toString()) ?? 0.0)
            : (double.tryParse(widget.item!.storeDiscount.toString()) ?? 0.0),
        discountType: (widget.isCampaign || widget.item!.storeDiscount == 0)
            ? widget.item!.discountType
            : 'percent',
        showOriginalPrice: (widget.item!.price ?? 0) >
            (PriceConverter.convertWithDiscount(
                  widget.item!.price ?? 0,
                  (widget.isCampaign || widget.item!.storeDiscount == 0)
                      ? (double.tryParse(widget.item!.discount.toString()) ??
                          0.0)
                      : (double.tryParse(
                              widget.item!.storeDiscount.toString()) ??
                          0.0),
                  (widget.isCampaign || widget.item!.storeDiscount == 0)
                      ? widget.item!.discountType
                      : 'percent',
                ) ??
                0),
      ));
    }
    if (Get.find<SplashController>()
            .configModel!
            .moduleConfig!
            .module!
            .addOn! &&
        widget.item!.addOns != null &&
        widget.item!.addOns!.isNotEmpty) {
      lists.add(AddonView(
        item: widget.item!,
        itemController: Get.find<ItemController>(),
      ));
    }
    return lists;
  }

  void _nextList() {
    if ((widget.item!.foodVariations!.isNotEmpty) &&
        (_currentListIndex < widget.item!.foodVariations!.length - 1)) {
      setState(() {
        _currentListIndex++;
      });
    }
  }

  void _previousList() {
    if (_currentListIndex > 0) {
      setState(() {
        _currentListIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasFoodVariations = widget.item!.foodVariations != null &&
        widget.item!.foodVariations!.isNotEmpty;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        // top: GetPlatform.isWeb ? 0 : Get.height*.05,
        bottom: widget.item!.foodVariations!.isEmpty
            ? Get.height * 0.2
            : Get.height * 0.05,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        // color: Colors.green,
        borderRadius: GetPlatform.isWeb
            ? const BorderRadius.all(Radius.circular(Dimensions.radiusDefault))
            : const BorderRadius.vertical(
                top: Radius.circular(Dimensions.radiusExtraLarge),
              ),
      ),
      child: GetBuilder<ItemController>(builder: (itemController) {
        double? startingPrice;
        double? endingPrice;
        if (widget.item!.choiceOptions!.isNotEmpty &&
            widget.item!.foodVariations!.isEmpty &&
            !_newVariation) {
          List<double?> priceList = [];
          for (var variation in widget.item!.variations!) {
            priceList.add(variation.price);
          }
          priceList.sort((a, b) => a!.compareTo(b!));
          startingPrice = priceList[0];
          if (priceList[0]! < priceList[priceList.length - 1]!) {
            endingPrice = priceList[priceList.length - 1];
          }
        } else {
          startingPrice = widget.item!.price;
        }

        double? price = widget.item!.price;
        double variationPrice = 0;
        Variation? variation;
        double initialDiscount = (widget.isCampaign ||
                widget.item!.storeDiscount == 0)
            ? (double.tryParse(widget.item!.discount.toString()) ?? 0.0)
            : (double.tryParse(widget.item!.storeDiscount.toString()) ?? 0.0);
        double discount = (widget.isCampaign || widget.item!.storeDiscount == 0)
            ? (double.tryParse(widget.item!.discount.toString()) ?? 0.0)
            : (double.tryParse(widget.item!.storeDiscount.toString()) ?? 0.0);
        String? discountType =
            (widget.isCampaign || widget.item!.storeDiscount == 0)
                ? widget.item!.discountType
                : 'percent';
        int? stock = widget.item!.stock ?? 0;

        if (discountType == 'amount') {
          discount = discount! * itemController.quantity!;
        }

        if (_newVariation) {
          for (int index = 0;
              index < widget.item!.foodVariations!.length;
              index++) {
            for (int i = 0;
                i < widget.item!.foodVariations![index].variationValues!.length;
                i++) {
              if (itemController.selectedVariations[index][i]!) {
                variationPrice += widget.item!.foodVariations![index]
                    .variationValues![i].optionPrice!;
              }
            }
          }
        } else {
          List<String> variationList = [];
          for (int index = 0;
              index < widget.item!.choiceOptions!.length;
              index++) {
            variationList.add(widget.item!.choiceOptions![index]
                .options![itemController.variationIndex![index]]
                .replaceAll(' ', ''));
          }
          String variationType = '';
          bool isFirst = true;
          for (var variation in variationList) {
            if (isFirst) {
              variationType = '$variationType$variation';
              isFirst = false;
            } else {
              variationType = '$variationType-$variation';
            }
          }

          for (Variation variations in widget.item!.variations!) {
            if (variations.type == variationType) {
              price = variations.price;
              variation = variations;
              stock = variations.stock;
              break;
            }
          }
        }

        price = price! + variationPrice;
        double priceWithDiscount = PriceConverter.convertWithDiscount(
            price ?? 0, discount, discountType)!;
        double addonsCost = 0;
        List<AddOn> addOnIdList = [];
        List<AddOns> addOnsList = [];
        for (int index = 0; index < widget.item!.addOns!.length; index++) {
          if (itemController.addOnActiveList[index]) {
            addonsCost = addonsCost +
                (widget.item!.addOns![index].price! *
                    itemController.addOnQtyList[index]!);
            addOnIdList.add(AddOn(
                id: widget.item!.addOns![index].id,
                quantity: itemController.addOnQtyList[index]));
            addOnsList.add(widget.item!.addOns![index]);
          }
        }
        priceWithDiscount = priceWithDiscount;
        double? priceWithDiscountAndAddons = priceWithDiscount + addonsCost;
        bool isAvailable = DateConverter.isAvailable(
            widget.item!.availableTimeStarts, widget.item!.availableTimeEnds);

        List<Widget> dynamicLists = _getDynamicLists();
        bool hasLists = dynamicLists.isNotEmpty;

        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  bottom: Get.size.height * .04,
                  left: Dimensions.paddingSizeDefault),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          right: Dimensions.paddingSizeDefault,
                          top: ResponsiveHelper.isDesktop(context) ? 0 : 0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: widget.isCampaign
                                      ? null
                                      : () {
                                          if (!widget.isCampaign) {
                                            Get.toNamed(
                                                RouteHelper.getItemImagesRoute(
                                                    widget.item!));
                                          }
                                        },
                                  child: Stack(children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusExtraLarge),
                                      child: CustomImage(
                                        image: '${widget.item!.imageFullUrl}',
                                        width:
                                            ResponsiveHelper.isMobile(context)
                                                ? double.infinity
                                                : 140,
                                        height:
                                            ResponsiveHelper.isMobile(context)
                                                ? Get.size.height * .25
                                                : 140,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    DiscountTag(
                                      discount: initialDiscount,
                                      discountType: discountType,
                                      fromTop: 20,
                                    ),
                                  ]),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusExtraLarge),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 10.0,
                                          right: 12,
                                          left: 12,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              3),
                                                      margin:
                                                          const EdgeInsets.only(
                                                        bottom: 10,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          Dimensions
                                                              .radiusSmall,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        '${PriceConverter.convertPrice(startingPrice, discount: initialDiscount, discountType: discountType)}'
                                                        '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice, discount: initialDiscount, discountType: discountType)}' : ''}',
                                                        style: STCMedium.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeLarge),
                                                        textDirection:
                                                            TextDirection.ltr,
                                                      ),
                                                    ),
                                                    price > priceWithDiscount
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        6.0),
                                                            child: Text(
                                                              '${PriceConverter.convertPrice(startingPrice)}'
                                                              '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice)}' : ''}',
                                                              textDirection:
                                                                  TextDirection
                                                                      .ltr,
                                                              style: STCMedium.copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .disabledColor,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .lineThrough),
                                                            ),
                                                          )
                                                        : const SizedBox
                                                            .shrink(),
                                                  ],
                                                ),
                                                Container(
                                                  width: Get.size.width * .25,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Dimensions
                                                                .radiusSmall),
                                                  ),
                                                  child: Row(children: [
                                                    ItemCountButtons(
                                                      onTap: () {
                                                        if (itemController
                                                                .quantity! >
                                                            1) {
                                                          itemController
                                                              .setQuantity(
                                                                  false,
                                                                  stock,
                                                                  widget.item!
                                                                      .quantityLimit,
                                                                  getxSnackBar:
                                                                      true);
                                                        }
                                                      },
                                                      isIncrement: false,
                                                      fromSheet: true,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        textAlign:
                                                            TextAlign.center,
                                                        itemController.quantity
                                                            .toString(),
                                                        style: STCMedium.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeLarge),
                                                      ),
                                                    ),
                                                    ItemCountButtons(
                                                      onTap: () => itemController
                                                          .setQuantity(
                                                              true,
                                                              stock,
                                                              widget.item!
                                                                  .quantityLimit,
                                                              getxSnackBar:
                                                                  true),
                                                      isIncrement: true,
                                                      fromSheet: true,
                                                    ),
                                                  ]),
                                                ),
                                                const SizedBox(height: 10),
                                                Builder(builder: (context) {
                                                  double? cost = PriceConverter
                                                      .convertWithDiscount(
                                                          (price! *
                                                              itemController
                                                                  .quantity!),
                                                          discount,
                                                          discountType);
                                                  double withAddonCost =
                                                      cost! + addonsCost;
                                                  return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                            '${'total_amount'.tr}:',
                                                            style: STCMedium.copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSizeDefault,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Theme.of(
                                                                        context)
                                                                    .cardColor)),
                                                        const SizedBox(
                                                            width: Dimensions
                                                                .paddingSizeExtraSmall),
                                                        Row(children: [
                                                          // discount! > 0
                                                          //     ? PriceConverter
                                                          //     .convertAnimationPrice(
                                                          //     (price *
                                                          //         itemController
                                                          //             .quantity!) +
                                                          //         addonsCost,
                                                          //     textStyle: STCMedium
                                                          //         .copyWith(
                                                          //         color: Theme
                                                          //             .of(
                                                          //             context)
                                                          //             .disabledColor,
                                                          //         fontSize:
                                                          //         Dimensions
                                                          //             .fontSizeSmall,
                                                          //         decoration:
                                                          //         TextDecoration
                                                          //             .lineThrough))
                                                          //     : const SizedBox(),
                                                          // const SizedBox(
                                                          //     width: Dimensions
                                                          //         .paddingSizeExtraSmall),
                                                          PriceConverter.convertAnimationPrice(
                                                              withAddonCost,
                                                              textStyle: STCBold.copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .cardColor)),
                                                        ]),
                                                      ]);
                                                }),
                                              ],
                                            ),
                                            SizedBox(
                                              width: Get.size.width * .4,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    widget.item!.name!,
                                                    style: STCMedium.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeLarge,
                                                        color: Colors.white),
                                                    maxLines: 2,
                                                    textAlign: TextAlign.right,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      if (widget.inStorePage) {
                                                        Get.back();
                                                      } else {
                                                        Get.back();
                                                        Get.find<
                                                                CartController>()
                                                            .forcefullySetModule(
                                                                widget.item!
                                                                    .moduleId!);
                                                        Get.toNamed(
                                                          RouteHelper
                                                              .getStoreRoute(
                                                            id: widget
                                                                .item!.storeId,
                                                            page: 'item',
                                                          ),
                                                        );
                                                        Get.offNamed(
                                                          RouteHelper
                                                              .getStoreRoute(
                                                            id: widget
                                                                .item!.storeId,
                                                            page: 'item',
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(0, 5, 5, 5),
                                                      child: Text(
                                                        widget.item!.storeName!,
                                                        style:
                                                            STCRegular.copyWith(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  !widget.isCampaign
                                                      ? RatingBar(
                                                          rating: widget
                                                              .item!.avgRating,
                                                          size: 15,
                                                          ratingCount: widget
                                                              .item!
                                                              .ratingCount,
                                                        )
                                                      : const SizedBox(),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      (widget.item!.description != null &&
                                              widget.item!.description!
                                                  .isNotEmpty)
                                          ? Container(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                            "${'description'.tr}:",
                                                            style: STCBold.copyWith(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: Dimensions
                                                                    .fontSizeDefault)),
                                                        // widget.item!.unitType !=
                                                        //         ""
                                                        //     ? Container(
                                                        //         padding: EdgeInsets.symmetric(
                                                        //             vertical:
                                                        //                 widget.item!.unitType != ""
                                                        //                     ? 3
                                                        //                     : 0,
                                                        //             horizontal: widget.item!.unitType != ""
                                                        //                 ? Dimensions
                                                        //                     .paddingSizeSmall
                                                        //                 : 0),
                                                        //         decoration: BoxDecoration(
                                                        //             borderRadius:
                                                        //                 BorderRadius.circular(Dimensions
                                                        //                     .radiusExtraLarge),
                                                        //             color: Theme.of(context)
                                                        //                 .cardColor,
                                                        //             boxShadow: [
                                                        //               BoxShadow(
                                                        //                   color: Theme.of(context).primaryColor.withAlpha((0.2 * 255)
                                                        //                       .toInt()),
                                                        //                   blurRadius:
                                                        //                       5)
                                                        //             ]),
                                                        //         child: Get.find<SplashController>()
                                                        //                 .configModel!
                                                        //                 .moduleConfig!
                                                        //                 .module!
                                                        //                 .unit!
                                                        //             ? Text(
                                                        //                 widget.item!.unitType ??
                                                        //                     '',
                                                        //                 style: STCMedium
                                                        //                     .copyWith(
                                                        //                   fontSize:
                                                        //                       Dimensions.fontSizeExtraSmall,
                                                        //                   color:
                                                        //                       Theme.of(context).primaryColor,
                                                        //                 ),
                                                        //               )
                                                        //             : const SizedBox.shrink())
                                                        //     : const SizedBox.shrink(),
                                                      ]),
                                                  // const SizedBox(
                                                  //     height: Dimensions
                                                  //         .paddingSizeExtraSmall),
                                                  Text(
                                                    textAlign: TextAlign.right,
                                                    widget.item!.description!,
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: STCRegular.copyWith(
                                                      color: Theme.of(context)
                                                          .cardColor,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeExtraSmall,
                                                  ),
                                                ],
                                              ),
                                            )
                                          : const SizedBox(),
                                      Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(
                                            top: 8,
                                            left: 3,
                                            right: 3,
                                            bottom: 3),
                                        // padding: const EdgeInsets.symmetric(
                                        //     horizontal: 0),
                                        padding: const EdgeInsets.all(
                                          Dimensions.paddingSizeSmall,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          // color: Colors.amber,
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.paddingSizeDefault),
                                        ),
                                        child: Column(
                                          children: [
                                            (widget.item!.nutritionsName !=
                                                        null &&
                                                    widget.item!.nutritionsName!
                                                        .isNotEmpty)
                                                ? Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .cardColor,
                                                      borderRadius: BorderRadius
                                                          .circular(Dimensions
                                                              .radiusDefault),
                                                    ),
                                                    // padding: const EdgeInsets.all(
                                                    //   Dimensions.paddingSizeSmall,),
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              'nutrition_details'
                                                                  .tr,
                                                              style: STCBold.copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeLarge)),
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeExtraSmall),
                                                          Container(
                                                              color:
                                                                  Colors.white,
                                                              child: Wrap(
                                                                  children: List.generate(
                                                                      widget
                                                                          .item!
                                                                          .nutritionsName!
                                                                          .length,
                                                                      (index) => Text(
                                                                          '${widget.item!.nutritionsName![index]}${widget.item!.nutritionsName!.length - 1 == index ? '.' : ', '}',
                                                                          style:
                                                                              STCRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withAlpha((0.5 * 255).toInt())))))),
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeSmall),
                                                        ]),
                                                  )
                                                : const SizedBox(),
                                            (widget.item!.allergiesName !=
                                                        null &&
                                                    widget.item!.allergiesName!
                                                        .isNotEmpty)
                                                ? Container(
                                                    width: double.infinity,
                                                    color: Theme.of(context)
                                                        .cardColor,
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              'allergic_ingredients'
                                                                  .tr,
                                                              style: STCBold.copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeLarge)),
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeExtraSmall),
                                                          Wrap(
                                                              children: List.generate(
                                                                  widget
                                                                      .item!
                                                                      .allergiesName!
                                                                      .length,
                                                                  (index) => Text(
                                                                      '${widget.item!.allergiesName![index]}${widget.item!.allergiesName!.length - 1 == index ? '.' : ', '}',
                                                                      style: STCRegular.copyWith(
                                                                          color: Theme.of(context)
                                                                              .textTheme
                                                                              .bodyLarge!
                                                                              .color
                                                                              ?.withAlpha((0.5 * 255).toInt()))))),
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeLarge),
                                                        ]),
                                                  )
                                                : const SizedBox(),
                                            (widget.item!.genericName != null &&
                                                    widget.item!.genericName!
                                                        .isNotEmpty)
                                                ? Container(
                                                    width: double.infinity,
                                                    color: Theme.of(context)
                                                        .cardColor,
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              'generic_name'.tr,
                                                              style: STCBold.copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeLarge)),
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeExtraSmall),
                                                          Wrap(
                                                              children: List.generate(
                                                                  widget
                                                                      .item!
                                                                      .genericName!
                                                                      .length,
                                                                  (index) => Text(
                                                                      '${widget.item!.genericName![index]}${widget.item!.genericName!.length - 1 == index ? '.' : ', '}',
                                                                      style: STCRegular.copyWith(
                                                                          color: Theme.of(context)
                                                                              .textTheme
                                                                              .bodyLarge!
                                                                              .color
                                                                              ?.withAlpha((0.5 * 255).toInt()))))),
                                                          const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeLarge),
                                                        ]),
                                                  )
                                                : const SizedBox(),
                                            // _newVariation && hasLists
                                            //     ? dynamicLists[_currentListIndex]
                                            //     : !_newVariation
                                            //     ? VariationView(item: widget.item, itemController: itemController)
                                            //     : const SizedBox(),
                                            widget.item!.foodVariations!
                                                    .isNotEmpty
                                                ? Container(
                                                    height:
                                                        Get.size.height * .33,
                                                    width: double.infinity,
                                                    // color: Colors.red,
                                                    child: NewVariationView(
                                                      currentVariationIndex:
                                                          _currentListIndex,
                                                      item: widget.item,
                                                      itemController:
                                                          itemController,
                                                      discount: discount,
                                                      discountType:
                                                          discountType,
                                                      showOriginalPrice: (widget
                                                                  .item!
                                                                  .price ??
                                                              0) >
                                                          (PriceConverter
                                                                  .convertWithDiscount(
                                                                widget.item!
                                                                        .price ??
                                                                    0,
                                                                (widget.isCampaign ||
                                                                        widget.item!.storeDiscount ==
                                                                            0)
                                                                    ? (double.tryParse(widget
                                                                            .item!
                                                                            .discount
                                                                            .toString()) ??
                                                                        0.0)
                                                                    : (double.tryParse(widget
                                                                            .item!
                                                                            .storeDiscount
                                                                            .toString()) ??
                                                                        0.0),
                                                                (widget.isCampaign ||
                                                                        widget.item!.storeDiscount ==
                                                                            0)
                                                                    ? widget
                                                                        .item!
                                                                        .discountType
                                                                    : 'percent',
                                                              ) ??
                                                              0),
                                                    ))
                                                : SizedBox(),
                                            SizedBox(
                                                height: hasLists
                                                    ? 0
                                                    : Dimensions
                                                        .paddingSizeLarge),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    widget.isCampaign
                        ? const SizedBox(height: 25)
                        : GetBuilder<FavouriteController>(builder: (wishList) {
                            return InkWell(
                              onTap: () {
                                if (AuthHelper.isLoggedIn()) {
                                  wishList.wishItemIdList
                                          .contains(widget.item!.id)
                                      ? wishList.removeFromFavouriteList(
                                          widget.item!.id, false,
                                          getXSnackBar: true)
                                      : wishList.addToFavouriteList(
                                          widget.item, null, false,
                                          getXSnackBar: true);
                                } else {
                                  showCustomSnackBar('you_are_not_logged_in'.tr,
                                      getXSnackBar: true);
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault),
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withAlpha((0.05 * 255).toInt()),
                                ),
                                padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeSmall),
                                child: Icon(
                                  wishList.wishItemIdList
                                          .contains(widget.item!.id)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: wishList.wishItemIdList
                                          .contains(widget.item!.id)
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                            );
                          }),
                    widget.item!.isStoreHalalActive! &&
                            widget.item!.isHalalItem!
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeSmall,
                                horizontal: Dimensions.paddingSizeExtraSmall),
                            child: CustomToolTip(
                              message: 'this_is_a_halal_food'.tr,
                              preferredDirection: AxisDirection.up,
                              child: const CustomAssetImageWidget(
                                  Images.halalTag,
                                  height: 35,
                                  width: 35),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: InkWell(
                onTap: () {
                  itemController.sliceSelections.clear();
                  Get.back();
                },
                child: Container(
                  padding:
                      const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context)
                              .primaryColor
                              .withAlpha((0.3 * 255).toInt()),
                          blurRadius: 5)
                    ],
                  ),
                  child: const Icon(Icons.close, size: 14),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 22,
              right: 22,
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: Get.size.width * .08),
                child: Row(
                  mainAxisAlignment: (!hasFoodVariations ||
                          widget.item!.foodVariations!.length == 1)
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentListIndex > 0)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          side: BorderSide(color: Theme.of(context).cardColor),
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeSmall,
                            horizontal: Dimensions.paddingSizeSmall,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_back_rounded,
                            size: 25, color: Colors.white),
                        onPressed: _previousList,
                        label: Text(
                          "back".tr,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 0),
                    GetBuilder<CartController>(builder: (cartController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            side:
                                BorderSide(color: Theme.of(context).cardColor),
                            padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeSmall,
                              horizontal: Dimensions.paddingSizeSmall,
                            ),
                          ),
                          /*onPressed: (Get.find<SplashController>()
                              .configModel!
                              .moduleConfig!
                              .module!
                              .stock! &&
                              stock! <= 0)
                              ? null
                              : () {
                            if (!hasFoodVariations ||
                                (hasFoodVariations &&
                                    _currentListIndex ==
                                        widget.item!.foodVariations!.length - 1)) {
                              String? invalid;
                              if (hasFoodVariations && _newVariation) {
                                // Only run variation validation if there ARE variations
                                for (int index = 0;
                                index < widget.item!.foodVariations!.length;
                                index++) {
                                  if (!widget.item!.foodVariations![index].multiSelect! &&
                                      widget.item!.foodVariations![index].required! &&
                                      !itemController.selectedVariations[index].contains(true)) {
                                    invalid =
                                    '${'choose_a_variation_from'.tr} ${widget.item!.foodVariations![index].name}';
                                    break;
                                  } else if (widget.item!.foodVariations![index].multiSelect! &&
                                      (widget.item!.foodVariations![index].required! ||
                                          itemController.selectedVariations[index].contains(true)) &&
                                      widget.item!.foodVariations![index].min! >
                                          itemController.selectedVariationLength(
                                              itemController.selectedVariations, index)) {
                                    invalid =
                                    '${'select_minimum'.tr} ${widget.item!.foodVariations![index].min} '
                                        '${'and_up_to'.tr} ${widget.item!.foodVariations![index].max} ${'options_from'.tr}'
                                        ' ${widget.item!.foodVariations![index].name} ${'variation'.tr}';
                                    break;
                                  }
                                }
                              }

                              if (Get.find<SplashController>().moduleList != null) {
                                for (ModuleModel module in Get.find<SplashController>().moduleList!) {
                                  if (module.id == widget.item!.moduleId) {
                                    Get.find<SplashController>().setModule(module);
                                    break;
                                  }
                                }
                              }

                              if (invalid != null) {
                                showCustomSnackBar(invalid, getXSnackBar: true);
                              } else {
                                // // PROPER VARIATION HANDLING - FIXED
                                // List<OrderVariation> variationsForCart = [];
                                // List<Variation> selectedOldVariations = [];
                                //
                                // if (hasFoodVariations) {
                                //   if (_newVariation) {
                                //     // NEW VARIATION SYSTEM (with slices)
                                //     variationsForCart = _getSelectedVariations(
                                //       isFoodVariation: true,
                                //       foodVariations: widget.item!.foodVariations!,
                                //       selectedVariations: itemController.selectedVariations,
                                //     );
                                //   } else {
                                //     // OLD VARIATION SYSTEM
                                //     List<String> variationList = [];
                                //     for (int index = 0; index < widget.item!.choiceOptions!.length; index++) {
                                //       variationList.add(widget.item!.choiceOptions![index]
                                //           .options![itemController.variationIndex![index]]
                                //           .replaceAll(' ', ''));
                                //     }
                                //     String variationType = variationList.join('-');
                                //
                                //     for (Variation variation in widget.item!.variations!) {
                                //       if (variation.type == variationType) {
                                //         selectedOldVariations.add(variation);
                                //         break;
                                //       }
                                //     }
                                //   }
                                // }
                                //
                                // // Create cart model
                                // CartModel cartModel = CartModel(
                                //   null,
                                //   price,
                                //   priceWithDiscountAndAddons,
                                //   // For old variation system - pass the found variation or empty array
                                //   selectedOldVariations,
                                //   // For new variation system - pass selected variations
                                //   itemController.selectedVariations,
                                //   (price! - PriceConverter.convertWithDiscount(price, discount, discountType)!),
                                //   itemController.quantity,
                                //   addOnIdList,
                                //   addOnsList,
                                //   widget.isCampaign,
                                //   stock,
                                //   widget.item,
                                //   widget.item?.quantityLimit,
                                // );

                                // PROPER VARIATION HANDLING - THIS IS CORRECT
                                List<OrderVariation> variationsForCart = [];
                                List<Variation> selectedOldVariations = [];

                                if (hasFoodVariations) {
                                  if (_newVariation) {
                                    // NEW VARIATION SYSTEM (with slices) - THIS HANDLES SLICE INFO
                                    variationsForCart = _getSelectedVariations(
                                      isFoodVariation: true,
                                      foodVariations: widget.item!.foodVariations!,
                                      selectedVariations: itemController.selectedVariations,
                                    );
                                  } else {
                                    // OLD VARIATION SYSTEM
                                    List<String> variationList = [];
                                    for (int index = 0; index < widget.item!.choiceOptions!.length; index++) {
                                      variationList.add(widget.item!.choiceOptions![index]
                                          .options![itemController.variationIndex![index]]
                                          .replaceAll(' ', ''));
                                    }
                                    String variationType = variationList.join('-');

                                    for (Variation variation in widget.item!.variations!) {
                                      if (variation.type == variationType) {
                                        selectedOldVariations.add(variation);
                                        break;
                                      }
                                    }
                                  }
                                }

                                // Create cart model - THIS IS CORRECT
                                CartModel cartModel = CartModel(
                                  null,
                                  price,
                                  priceWithDiscountAndAddons,
                                  // For old variation system - pass the found variation or empty array
                                  selectedOldVariations, // ✅ CORRECT: Uses selectedOldVariations
                                  // For new variation system - pass selected variations
                                  itemController.selectedVariations, // ✅ CORRECT: Passes actual selected variations
                                  (price! - PriceConverter.convertWithDiscount(price, discount, discountType)!),
                                  itemController.quantity,
                                  addOnIdList,
                                  addOnsList,
                                  widget.isCampaign,
                                  stock,
                                  widget.item,
                                  widget.item?.quantityLimit,
                                );
                                List<int?> listOfAddOnId = _getSelectedAddonIds(addOnIdList: addOnIdList);
                                List<int?> listOfAddOnQty = _getSelectedAddonQtnList(addOnIdList: addOnIdList);

                                OnlineCart onlineCart = OnlineCart(
                                  (widget.cart != null || itemController.cartIndex != -1)
                                      ? widget.cart?.id ?? cartController.cartList[itemController.cartIndex].id
                                      : null,
                                  widget.isCampaign ? null : widget.item!.id,
                                  widget.isCampaign ? widget.item!.id : null,
                                  priceWithDiscountAndAddons.toString(),
                                  '',
                                  // For old variation system - pass variations or null
                                  selectedOldVariations.isNotEmpty ? selectedOldVariations : null,
                                  // For new variation system (with slice info) - pass variations or null
                                  variationsForCart.isNotEmpty ? variationsForCart : null,
                                  itemController.quantity,
                                  listOfAddOnId,
                                  addOnsList,
                                  listOfAddOnQty,
                                  'Item',
                                );

                                // --- Your existing campaign/non-campaign and cart update/add logic ---
                                if (widget.isCampaign) {
                                  Get.toNamed(RouteHelper.getCheckoutRoute('campaign'),
                                      arguments: CheckoutScreen(
                                          storeId: null, fromCart: false, cartList: [cartModel]));
                                } else {
                                  if (Get.find<CartController>().existAnotherStoreItem(
                                      cartModel.item!.storeId,
                                      Get.find<SplashController>().module != null
                                          ? Get.find<SplashController>().module!.id
                                          : Get.find<SplashController>().cacheModule!.id)) {
                                    Get.dialog(
                                        ConfirmationDialog(
                                          icon: Images.warning,
                                          title: 'are_you_sure_to_reset'.tr,
                                          description: Get.find<SplashController>()
                                              .configModel!
                                              .moduleConfig!
                                              .module!
                                              .showRestaurantText!
                                              ? 'if_you_continue'.tr
                                              : 'if_you_continue_without_another_store'.tr,
                                          onYesPressed: () {
                                            Get.back();
                                            Get.find<CartController>().clearCartOnline().then((success) async {
                                              if (success) {
                                                await Get.find<CartController>().addToCartOnline(onlineCart);
                                                Get.back();
                                              }
                                            });
                                          },
                                        ),
                                        barrierDismissible: false);
                                  } else {
                                    if (widget.cart != null || itemController.cartIndex != -1) {
                                      Get.find<CartController>().updateCartOnline(onlineCart).then((success) {
                                        if (success) {
                                          Get.back();
                                        }
                                      });
                                    } else {
                                      Get.find<CartController>().addToCartOnline(onlineCart).then((success) {
                                        if (success) {
                                          Get.back();
                                        }
                                      });
                                    }
                                  }
                                }
                                // --- End of existing cart logic ---
                              }
                            } else if (hasFoodVariations) {
                              // Only call _nextList if there ARE variations and it's not the last step
                              _nextList();
                            }
                          },*/

                          onPressed: (Get.find<SplashController>()
                                      .configModel!
                                      .moduleConfig!
                                      .module!
                                      .stock! &&
                                  stock! <= 0)
                              ? null
                              : () {
                                  if (widget.storeStatus == 1) {
                                    if (!hasFoodVariations ||
                                        (hasFoodVariations &&
                                            _currentListIndex ==
                                                widget.item!.foodVariations!
                                                        .length -
                                                    1)) {
                                      String? invalid;
                                      if (hasFoodVariations && _newVariation) {
                                        // Only run variation validation if there ARE variations
                                        for (int index = 0;
                                            index <
                                                widget.item!.foodVariations!
                                                    .length; // Safe due to hasFoodVariations check
                                            index++) {
                                          if (!widget
                                                  .item!
                                                  .foodVariations![index]
                                                  .multiSelect! &&
                                              widget
                                                  .item!
                                                  .foodVariations![index]
                                                  .required! &&
                                              !itemController
                                                  .selectedVariations[index]
                                                  .contains(true)) {
                                            invalid =
                                                '${'choose_a_variation_from'.tr} ${widget.item!.foodVariations![index].name}';
                                            break;
                                          } else if (widget
                                                  .item!
                                                  .foodVariations![index]
                                                  .multiSelect! &&
                                              (widget
                                                      .item!
                                                      .foodVariations![index]
                                                      .required! ||
                                                  itemController
                                                      .selectedVariations[index]
                                                      .contains(true)) &&
                                              widget
                                                      .item!
                                                      .foodVariations![index]
                                                      .min! >
                                                  itemController
                                                      .selectedVariationLength(
                                                          itemController
                                                              .selectedVariations,
                                                          index)) {
                                            invalid =
                                                '${'select_minimum'.tr} ${widget.item!.foodVariations![index].min} '
                                                '${'and_up_to'.tr} ${widget.item!.foodVariations![index].max} ${'options_from'.tr}'
                                                ' ${widget.item!.foodVariations![index].name} ${'variation'.tr}';
                                            break;
                                          }
                                        }
                                      }

                                      if (Get.find<SplashController>()
                                              .moduleList !=
                                          null) {
                                        for (ModuleModel module
                                            in Get.find<SplashController>()
                                                .moduleList!) {
                                          if (module.id ==
                                              widget.item!.moduleId) {
                                            Get.find<SplashController>()
                                                .setModule(module);
                                            break;
                                          }
                                        }
                                      }

                                      if (invalid != null) {
                                        showCustomSnackBar(invalid,
                                            getXSnackBar: true);
                                      } else {
                                        if (variation != null) {
                                          debugPrint(
                                              'variation=======> ${variation!.toJson()}');
                                        }
                                        // ADD TO CART LOGIC (your existing code here is mostly fine)
                                        CartModel cartModel = CartModel(
                                            null,
                                            price,
                                            priceWithDiscountAndAddons,
                                            // Ensure 'variation' is null or empty if no variations
                                            (hasFoodVariations &&
                                                    variation != null)
                                                ? [variation!]
                                                : [],
                                            itemController.selectedVariations,
                                            // This might need adjustment if no variations
                                            (price! -
                                                PriceConverter
                                                    .convertWithDiscount(
                                                        price,
                                                        discount,
                                                        discountType)!),
                                            itemController.quantity,
                                            addOnIdList,
                                            // Assuming addons are handled separately and this is fine
                                            addOnsList,
                                            // Assuming addons are handled separately and this is fine
                                            widget.isCampaign,
                                            stock,
                                            widget.item,
                                            widget.item?.quantityLimit);

                                        List<OrderVariation> variationsForCart =
                                            [];
                                        if (hasFoodVariations) {
                                          // Only get selected variations if they exist
                                          variationsForCart =
                                              _getSelectedVariations(
                                            isFoodVariation:
                                                Get.find<SplashController>()
                                                    .getModuleConfig(
                                                        widget.item!.moduleType)
                                                    .newVariation!,
                                            foodVariations:
                                                widget.item!.foodVariations!,
                                            // Safe due to hasFoodVariations
                                            selectedVariations: itemController
                                                .selectedVariations,
                                          );
                                        }

                                        List<int?> listOfAddOnId =
                                            _getSelectedAddonIds(
                                                addOnIdList: addOnIdList);
                                        List<int?> listOfAddOnQty =
                                            _getSelectedAddonQtnList(
                                                addOnIdList: addOnIdList);

                                        OnlineCart onlineCart = OnlineCart(
                                          (widget.cart != null ||
                                                  itemController.cartIndex !=
                                                      -1)
                                              ? widget.cart?.id ??
                                                  cartController
                                                      .cartList[itemController
                                                          .cartIndex]
                                                      .id
                                              : null,
                                          widget.isCampaign
                                              ? null
                                              : widget.item!.id,
                                          widget.isCampaign
                                              ? widget.item!.id
                                              : null,
                                          priceWithDiscountAndAddons.toString(),
                                          '',
                                          // Ensure 'variation' for OnlineCart is null or empty if no variations
                                          (hasFoodVariations &&
                                                  variation != null)
                                              ? [variation]
                                              : null,
                                          Get.find<SplashController>()
                                                  .getModuleConfig(
                                                      widget.item!.moduleType)
                                                  .newVariation!
                                              ? variationsForCart // Use the potentially empty list
                                              : null,
                                          null,
                                          itemController.quantity,
                                          listOfAddOnId,
                                          addOnsList,
                                          listOfAddOnQty,
                                          'Item',
                                        );

                                        debugPrint(
                                            'variationsForCart =======> ${variationsForCart}');

                                        // --- Your existing campaign/non-campaign and cart update/add logic ---
                                        // This part of your code seems generally fine and can remain as is.
                                        // It correctly handles different scenarios based on widget.isCampaign
                                        // and whether the item already exists in the cart.
                                        if (widget.isCampaign) {
                                          Get.toNamed(
                                              RouteHelper.getCheckoutRoute(
                                                  'campaign'),
                                              arguments: CheckoutScreen(
                                                  storeId: null,
                                                  fromCart: false,
                                                  cartList: [cartModel]));
                                        } else {
                                          if (Get.find<CartController>()
                                              .existAnotherStoreItem(
                                                  cartModel.item!.storeId,
                                                  Get.find<SplashController>()
                                                              .module !=
                                                          null
                                                      ? Get.find<
                                                              SplashController>()
                                                          .module!
                                                          .id
                                                      : Get.find<
                                                              SplashController>()
                                                          .cacheModule!
                                                          .id)) {
                                            Get.dialog(
                                                ConfirmationDialog(
                                                  icon: Images.warning,
                                                  title: 'are_you_sure_to_reset'
                                                      .tr,
                                                  description: Get.find<
                                                              SplashController>()
                                                          .configModel!
                                                          .moduleConfig!
                                                          .module!
                                                          .showRestaurantText!
                                                      ? 'if_you_continue'.tr
                                                      : 'if_you_continue_without_another_store'
                                                          .tr,
                                                  onYesPressed: () {
                                                    Get.back();
                                                    Get.find<CartController>()
                                                        .clearCartOnline()
                                                        .then((success) async {
                                                      if (success) {
                                                        await Get.find<
                                                                CartController>()
                                                            .addToCartOnline(
                                                                onlineCart);
                                                        Get.back();
                                                      }
                                                    });
                                                  },
                                                ),
                                                barrierDismissible: false);
                                          } else {
                                            debugPrint(
                                                'onlineCart: ======> ${onlineCart.toJson()}');
                                            if (widget.cart != null ||
                                                itemController.cartIndex !=
                                                    -1) {
                                              Get.find<CartController>()
                                                  .updateCartOnline(onlineCart)
                                                  .then((success) {
                                                if (success) {
                                                  Get.back();
                                                }
                                              });
                                            } else {
                                              Get.find<CartController>()
                                                  .addToCartOnline(onlineCart)
                                                  .then((success) {
                                                if (success) {
                                                  Get.back();
                                                }
                                              });
                                            }
                                          }
                                        }
                                        // --- End of existing cart logic ---
                                      }
                                    } else if (hasFoodVariations) {
                                      // Only call _nextList if there ARE variations and it's not the last step
                                      _nextList();
                                    }
                                  } else if (widget.storeStatus == -1) {
                                    Get.back();
                                    showCustomSnackBar(
                                        "restaurant_is_currently_closed".tr);
                                  } else {
                                    Get.back();
                                    showCustomSnackBar("restaurant_is_currently_closed".tr);
                                  }
                                  // --- END: Modified onPressed Logic ---
                                },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  (!hasFoodVariations ||
                                          (hasFoodVariations &&
                                              _currentListIndex ==
                                                  widget.item!.foodVariations!
                                                          .length -
                                                      1))
                                      ? (Get.find<
                                                      SplashController>() // Out of stock check for final step
                                                  .configModel!
                                                  .moduleConfig!
                                                  .module!
                                                  .stock! &&
                                              stock! <= 0)
                                          ? 'out_of_stock'.tr
                                          : widget.isCampaign
                                              ? 'order_now'.tr
                                              : (widget.cart != null ||
                                                      itemController
                                                              .cartIndex !=
                                                          -1)
                                                  ? 'update_in_cart'.tr
                                                  : 'add_to_cart'.tr
                                      : 'next'.tr,
                                  // Text for intermediate variation steps
                                  // --- END: Modified Button Text Logic ---
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white)),
                              const SizedBox(width: 8),
                              (Get.find<SplashController>() // Out of stock check for final step
                                          .configModel!
                                          .moduleConfig!
                                          .module!
                                          .stock! &&
                                      stock! <= 0)
                                  ? const Icon(
                                      Icons.strikethrough_s_outlined,
                                      size: 25,
                                      color: Colors.white,
                                    )
                                  : const Icon(
                                      Icons.turn_right_rounded,
                                      size: 25,
                                      color: Colors.white,
                                    ),
                            ],
                          ),
                        ),
                      );
                    })

                    // GetBuilder<CartController>(builder: (cartController) {
                    //   return ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Theme.of(context).primaryColor,
                    //       side: BorderSide(color: Theme.of(context).cardColor),
                    //       padding: const EdgeInsets.symmetric(
                    //         vertical: Dimensions.paddingSizeSmall,
                    //         horizontal: Dimensions.paddingSizeSmall,
                    //       ),
                    //     ),
                    //     onPressed: (Get.find<SplashController>()
                    //                 .configModel!
                    //                 .moduleConfig!
                    //                 .module!
                    //                 .stock! &&
                    //             stock! <= 0)
                    //         ? null
                    //         : () {
                    //             if (_currentListIndex ==
                    //                 widget.item!.foodVariations!.length - 1) {
                    //               String? invalid;
                    //               if (_newVariation) {
                    //                 for (int index = 0;
                    //                     index <
                    //                         widget.item!.foodVariations!.length;
                    //                     index++) {
                    //                   if (!widget.item!.foodVariations![index]
                    //                           .multiSelect! &&
                    //                       widget.item!.foodVariations![index]
                    //                           .required! &&
                    //                       !itemController
                    //                           .selectedVariations[index]
                    //                           .contains(true)) {
                    //                     invalid =
                    //                         '${'choose_a_variation_from'.tr} ${widget.item!.foodVariations![index].name}';
                    //                     break;
                    //                   } else if (widget
                    //                           .item!
                    //                           .foodVariations![index]
                    //                           .multiSelect! &&
                    //                       (widget.item!.foodVariations![index]
                    //                               .required! ||
                    //                           itemController
                    //                               .selectedVariations[index]
                    //                               .contains(true)) &&
                    //                       widget.item!.foodVariations![index]
                    //                               .min! >
                    //                           itemController
                    //                               .selectedVariationLength(
                    //                                   itemController
                    //                                       .selectedVariations,
                    //                                   index)) {
                    //                     invalid =
                    //                         '${'select_minimum'.tr} ${widget.item!.foodVariations![index].min} '
                    //                         '${'and_up_to'.tr} ${widget.item!.foodVariations![index].max} ${'options_from'.tr}'
                    //                         ' ${widget.item!.foodVariations![index].name} ${'variation'.tr}';
                    //                     break;
                    //                   }
                    //                 }
                    //               }
                    //
                    //               if (Get.find<SplashController>().moduleList !=
                    //                   null) {
                    //                 for (ModuleModel module
                    //                     in Get.find<SplashController>()
                    //                         .moduleList!) {
                    //                   if (module.id == widget.item!.moduleId) {
                    //                     Get.find<SplashController>()
                    //                         .setModule(module);
                    //                     break;
                    //                   }
                    //                 }
                    //               }
                    //
                    //               if (invalid != null) {
                    //                 showCustomSnackBar(invalid,
                    //                     getXSnackBar: true);
                    //               } else {
                    //                 CartModel cartModel = CartModel(
                    //                     null,
                    //                     price,
                    //                     priceWithDiscountAndAddons,
                    //                     variation != null ? [variation] : [],
                    //                     itemController.selectedVariations,
                    //                     (price! -
                    //                         PriceConverter.convertWithDiscount(
                    //                             price,
                    //                             discount,
                    //                             discountType)!),
                    //                     itemController.quantity,
                    //                     addOnIdList,
                    //                     addOnsList,
                    //                     widget.isCampaign,
                    //                     stock,
                    //                     widget.item,
                    //                     widget.item?.quantityLimit);
                    //
                    //                 List<OrderVariation> variations =
                    //                     _getSelectedVariations(
                    //                   isFoodVariation:
                    //                       Get.find<SplashController>()
                    //                           .getModuleConfig(
                    //                               widget.item!.moduleType)
                    //                           .newVariation!,
                    //                   foodVariations:
                    //                       widget.item!.foodVariations!,
                    //                   selectedVariations:
                    //                       itemController.selectedVariations,
                    //                 );
                    //                 List<int?> listOfAddOnId =
                    //                     _getSelectedAddonIds(
                    //                         addOnIdList: addOnIdList);
                    //                 List<int?> listOfAddOnQty =
                    //                     _getSelectedAddonQtnList(
                    //                         addOnIdList: addOnIdList);
                    //
                    //                 OnlineCart onlineCart = OnlineCart(
                    //                   (widget.cart != null ||
                    //                           itemController.cartIndex != -1)
                    //                       ? widget.cart?.id ??
                    //                           cartController
                    //                               .cartList[
                    //                                   itemController.cartIndex]
                    //                               .id
                    //                       : null,
                    //                   widget.isCampaign
                    //                       ? null
                    //                       : widget.item!.id,
                    //                   widget.isCampaign
                    //                       ? widget.item!.id
                    //                       : null,
                    //                   priceWithDiscountAndAddons.toString(),
                    //                   '',
                    //                   variation != null ? [variation] : null,
                    //                   Get.find<SplashController>()
                    //                           .getModuleConfig(
                    //                               widget.item!.moduleType)
                    //                           .newVariation!
                    //                       ? variations
                    //                       : null,
                    //                   itemController.quantity,
                    //                   listOfAddOnId,
                    //                   addOnsList,
                    //                   listOfAddOnQty,
                    //                   'Item',
                    //                 );
                    //
                    //                 if (widget.isCampaign) {
                    //                   Get.toNamed(
                    //                       RouteHelper.getCheckoutRoute(
                    //                           'campaign'),
                    //                       arguments: CheckoutScreen(
                    //                           storeId: null,
                    //                           fromCart: false,
                    //                           cartList: [cartModel]));
                    //                 } else {
                    //                   if (Get.find<CartController>()
                    //                       .existAnotherStoreItem(
                    //                           cartModel.item!.storeId,
                    //                           Get.find<SplashController>()
                    //                                       .module !=
                    //                                   null
                    //                               ? Get.find<SplashController>()
                    //                                   .module!
                    //                                   .id
                    //                               : Get.find<SplashController>()
                    //                                   .cacheModule!
                    //                                   .id)) {
                    //                     Get.dialog(
                    //                         ConfirmationDialog(
                    //                           icon: Images.warning,
                    //                           title: 'are_you_sure_to_reset'.tr,
                    //                           description: Get.find<
                    //                                       SplashController>()
                    //                                   .configModel!
                    //                                   .moduleConfig!
                    //                                   .module!
                    //                                   .showRestaurantText!
                    //                               ? 'if_you_continue'.tr
                    //                               : 'if_you_continue_without_another_store'
                    //                                   .tr,
                    //                           onYesPressed: () {
                    //                             Get.back();
                    //                             Get.find<CartController>()
                    //                                 .clearCartOnline()
                    //                                 .then((success) async {
                    //                               if (success) {
                    //                                 await Get.find<
                    //                                         CartController>()
                    //                                     .addToCartOnline(
                    //                                         onlineCart);
                    //                                 Get.back();
                    //                               }
                    //                             });
                    //                           },
                    //                         ),
                    //                         barrierDismissible: false);
                    //                   } else {
                    //                     if (widget.cart != null ||
                    //                         itemController.cartIndex != -1) {
                    //                       Get.find<CartController>()
                    //                           .updateCartOnline(onlineCart)
                    //                           .then((success) {
                    //                         if (success) {
                    //                           Get.back();
                    //                         }
                    //                       });
                    //                     } else {
                    //                       Get.find<CartController>()
                    //                           .addToCartOnline(onlineCart)
                    //                           .then((success) {
                    //                         if (success) {
                    //                           Get.back();
                    //                         }
                    //                       });
                    //                     }
                    //                   }
                    //                 }
                    //               }
                    //             } else {
                    //               _nextList();
                    //             }
                    //           },
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Text(
                    //             ((widget.item!.foodVariations!.isNotEmpty) &&
                    //                     (_currentListIndex ==
                    //                         widget.item!.foodVariations!
                    //                                 .length -
                    //                             1))
                    //                 ? (Get.find<SplashController>()
                    //                             .configModel!
                    //                             .moduleConfig!
                    //                             .module!
                    //                             .stock! &&
                    //                         stock! <= 0)
                    //                     ? 'out_of_stock'.tr
                    //                     : widget.isCampaign
                    //                         ? 'order_now'.tr
                    //                         : (widget.cart != null ||
                    //                                 itemController.cartIndex !=
                    //                                     -1)
                    //                             ? 'update_in_cart'.tr
                    //                             : 'add_to_cart'.tr
                    //                 : 'next'.tr,
                    //             style: TextStyle(
                    //                 fontSize: 16, color: Colors.white)),
                    //         SizedBox(width: 8),
                    //         Icon(
                    //           Icons.turn_right_rounded,
                    //           size: 25,
                    //           color: Colors.white,
                    //         ),
                    //       ],
                    //     ),
                    //   );
                    // }),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

/*  List<OrderVariation> _getSelectedVariations(
      {required bool isFoodVariation,
      required List<FoodVariation>? foodVariations,
      required List<List<bool?>> selectedVariations}) {
    debugPrint('isFoodVariation: $isFoodVariation, foodVariations: ${foodVariations},  selectedVariations: ${selectedVariations}');
    List<OrderVariation> variations = [];
    if (isFoodVariation) {
      for (int i = 0; i < foodVariations!.length; i++) {
        debugPrint('foodVariation: ${foodVariations[i].toJson()}');
        if (selectedVariations[i].contains(true)) {
          variations.add(OrderVariation(
              name: foodVariations[i].name,
              values: OrderVariationValue(label: [])));
          for (int j = 0; j < foodVariations[i].variationValues!.length; j++) {
            if (selectedVariations[i][j]!) {
              variations[variations.length - 1]
                  .values!
                  .label!
                  .add('${foodVariations[i].variationValues![j].level}');
            }
          }
        }
      }
    }
    return variations;
  }*/

  List<OrderVariation> _getSelectedVariations(
      {required bool isFoodVariation,
      required List<FoodVariation>? foodVariations,
      required List<List<bool?>> selectedVariations}) {
    debugPrint(
        'isFoodVariation: $isFoodVariation, foodVariations: ${foodVariations},  selectedVariations: ${selectedVariations}');
    List<OrderVariation> variations = [];
    if (isFoodVariation) {
      for (int i = 0; i < foodVariations!.length; i++) {
        debugPrint('foodVariation: ${foodVariations[i].toJson()}');
        if (selectedVariations[i].contains(true)) {
          variations.add(OrderVariation(
              name: foodVariations[i].name,
              values: OrderVariationValue(label: [], toppingOptions: [])));
          for (int j = 0; j < foodVariations[i].variationValues!.length; j++) {
            if (selectedVariations[i][j]!) {
              String variationName =
                  foodVariations[i].variationValues![j].level!;
              String sliceName = '';

              // Add slice information if available (for pizza items)
              int sliceValue =
                  Get.find<ItemController>().getSliceSelection(i, j);
              if (sliceValue > 0 && isPizzaItem(widget.item!)) {
                sliceName = Get.find<ItemController>().getSliceName(sliceValue);
                variationName = '$variationName';
              }

              variations[variations.length - 1]
                  .values!
                  .label!
                  .add(variationName);
              variations[variations.length - 1]
                  .values!
                  .toppingOptions!
                  .add(sliceName);
            }
          }
        }
      }
    }

    debugPrint('variations: ---------->  ${variations.first.toJson()}');
    return variations;
  }

  List<int?> _getSelectedAddonIds({required List<AddOn> addOnIdList}) {
    List<int?> listOfAddOnId = [];
    for (var addOn in addOnIdList) {
      listOfAddOnId.add(addOn.id);
    }
    return listOfAddOnId;
  }

  List<int?> _getSelectedAddonQtnList({required List<AddOn> addOnIdList}) {
    List<int?> listOfAddOnQty = [];
    for (var addOn in addOnIdList) {
      listOfAddOnQty.add(addOn.quantity);
    }
    return listOfAddOnQty;
  }
}

class AddonView extends StatelessWidget {
  final Item item;
  final ItemController itemController;

  const AddonView(
      {super.key, required this.item, required this.itemController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('addons'.tr, style: STCMedium),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .disabledColor
                    .withAlpha((0.1 * 255).toInt()),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: Text(
                'optional'.tr,
                style: STCRegular.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeSmall),
              ),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: item.addOns!.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  if (!itemController.addOnActiveList[index]) {
                    itemController.addAddOn(true, index);
                  } else if (itemController.addOnQtyList[index] == 1) {
                    itemController.addAddOn(false, index);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: Dimensions.paddingSizeExtraSmall),
                  child: Row(children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: itemController.addOnActiveList[index],
                            activeColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall)),
                            onChanged: (bool? newValue) {
                              if (!itemController.addOnActiveList[index]) {
                                itemController.addAddOn(true, index);
                              } else if (itemController.addOnQtyList[index] ==
                                  1) {
                                itemController.addAddOn(false, index);
                              }
                            },
                            visualDensity: const VisualDensity(
                                horizontal: -3, vertical: -3),
                            side: BorderSide(
                                width: 2, color: Theme.of(context).hintColor),
                          ),
                          Text(
                            item.addOns![index].name!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: itemController.addOnActiveList[index]
                                ? STCMedium
                                : STCRegular.copyWith(
                                    color: Theme.of(context).hintColor),
                          ),
                        ]),
                    const Spacer(),
                    Text(
                      item.addOns![index].price! > 0
                          ? PriceConverter.convertPrice(
                              item.addOns![index].price)
                          : 'free'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.ltr,
                      style: itemController.addOnActiveList[index]
                          ? STCMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall)
                          : STCRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor),
                    ),
                    itemController.addOnActiveList[index]
                        ? Container(
                            height: 25,
                            width: 90,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall),
                                color: Theme.of(context).cardColor),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        if (itemController
                                                .addOnQtyList[index]! >
                                            1) {
                                          itemController.setAddOnQuantity(
                                              false, index);
                                        } else {
                                          itemController.addAddOn(false, index);
                                        }
                                      },
                                      child: Center(
                                          child: Icon(
                                        (itemController.addOnQtyList[index]! >
                                                1)
                                            ? Icons.remove
                                            : Icons.delete_outline_outlined,
                                        size: 18,
                                        color: (itemController
                                                    .addOnQtyList[index]! >
                                                1)
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context)
                                                .colorScheme
                                                .error,
                                      )),
                                    ),
                                  ),
                                  Text(
                                    itemController.addOnQtyList[index]
                                        .toString(),
                                    style: STCMedium.copyWith(
                                        fontSize: Dimensions.fontSizeDefault),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => itemController
                                          .setAddOnQuantity(true, index),
                                      child: Center(
                                          child: Icon(Icons.add,
                                              size: 18,
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                    ),
                                  ),
                                ]),
                          )
                        : const SizedBox(),
                  ]),
                ),
              );
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        ],
      ),
    );
  }
}

class VariationView extends StatelessWidget {
  final Item? item;
  final ItemController itemController;

  const VariationView(
      {super.key, required this.item, required this.itemController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: item!.choiceOptions!.length,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(
            bottom: item!.choiceOptions!.isNotEmpty
                ? Dimensions.paddingSizeLarge
                : 0),
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item!.choiceOptions![index].title!, style: STCMedium),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: Theme.of(context).cardColor,
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: item!.choiceOptions![index].options!.length,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeExtraSmall),
                      child: InkWell(
                        onTap: () {
                          itemController.setCartVariationIndex(index, i, item);
                        },
                        child: Row(children: [
                          Expanded(
                            child: Text(
                              item!.choiceOptions![index].options![i].trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: STCRegular,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Radio<int>(
                            value: i,
                            groupValue: itemController.variationIndex![index],
                            onChanged: (int? value) => itemController
                                .setCartVariationIndex(index, i, item),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            activeColor: Theme.of(context).primaryColor,
                          ),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                  height: index != item!.choiceOptions!.length - 1
                      ? Dimensions.paddingSizeLarge
                      : 0),
            ],
          );
        },
      ),
    );
  }
}

class NewVariationView extends StatelessWidget {
  final int currentVariationIndex;
  final Item? item;
  final ItemController itemController;
  final double? discount;
  final String? discountType;
  final bool showOriginalPrice;

  const NewVariationView(
      {super.key,
      required this.currentVariationIndex,
      required this.item,
      required this.itemController,
      required this.discount,
      required this.discountType,
      required this.showOriginalPrice});

  @override
  Widget build(BuildContext context) {
    int index = currentVariationIndex;
    // int selectedCount = 0;
    //             if (item!.foodVariations![index].required!) {
    //               for (var value in itemController.selectedVariations[index]) {
    //                 if (value == true) {
    //                   selectedCount++;
    //                 }
    //               }
    //             }
    return item!.foodVariations != null
        ? SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              margin: const EdgeInsets.only(
                bottom: Dimensions.paddingSizeSmall,
                top: Dimensions.paddingSizeExtraSmall,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                // border: Border.all(
                //   color: itemController.selectedVariations[index].contains(true)
                //       ? Theme.of(context).primaryColor
                //       : Theme.of(context).disabledColor,
                //   width: 0.5,
                // ),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Container(
                        //   decoration: BoxDecoration(
                        //     color: item!.foodVariations![index].required! &&
                        //         (item!.foodVariations![index].multiSelect!
                        //             ? item!.foodVariations![index].min!
                        //             : 1) >
                        //             selectedCount
                        //         ? Theme.of(context)
                        //         .colorScheme
                        //         .error
                        //         .withAlpha((0.1 * 255).toInt())
                        //         : Theme.of(context)
                        //         .disabledColor
                        //         .withAlpha((0.1 * 255).toInt()),
                        //     borderRadius:
                        //     BorderRadius.circular(Dimensions.radiusSmall),
                        //   ),
                        //   padding: const EdgeInsets.all(3),
                        //   child: Text(
                        //     item!.foodVariations![index].required!
                        //         ? (item!.foodVariations![index].multiSelect!
                        //         ? item!.foodVariations![index].min!
                        //         : 1) <=
                        //         selectedCount
                        //         ? 'completed'.tr
                        //         : 'required'.tr
                        //         : 'optional'.tr,
                        //     style: STCRegular.copyWith(
                        //       color: item!.foodVariations![index].required!
                        //           ? (item!.foodVariations![index].multiSelect!
                        //           ? item!.foodVariations![index].min!
                        //           : 1) <=
                        //           selectedCount
                        //           ? Theme.of(context).hintColor
                        //           : Theme.of(context).colorScheme.error
                        //           : Theme.of(context).hintColor,
                        //       fontSize: Dimensions.fontSizeSmall,
                        //     ),
                        //   ),
                        // ),
                        Text(
                          "${index + 1}/${item!.foodVariations!.length.toString()}",
                        ),
                        const Spacer(),
                        Text(
                          item!.foodVariations![index].name!,
                          style: STCMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  item!.foodVariations![index].multiSelect!
                      ? Text(
                          '${'select_minimum'.tr} ${'${item!.foodVariations![index].min}' ' ${'and_up_to'.tr} ${item!.foodVariations![index].max} ${'options'.tr}'}',
                          style: STCMedium.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).disabledColor),
                        )
                      : Text(
                          'select_one'.tr,
                          style: STCMedium.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).primaryColor),
                        ),
                  SizedBox(
                      height: item!.foodVariations![index].multiSelect!
                          ? Dimensions.paddingSizeExtraSmall
                          : 0),
                  const Divider(height: .5),
                  SizedBox(
                    // color: Colors.red,
                    // decoration: BoxDecoration(
                    //   borderRadius: BorderRadius.circular(12),
                    //  border: Border.symmetric(vertical: BorderSide(color: Colors.grey)),
                    // ),

                    height: Get.size.height * .2,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(),
                      // padding: EdgeInsets.zero,
                      itemCount: itemController.collapseVariation[index]
                          ? item!.foodVariations![index].variationValues!
                                      .length >
                                  4
                              ? 5
                              : item!.foodVariations![index].variationValues!
                                  .length
                          : item!
                              .foodVariations![index].variationValues!.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: ResponsiveHelper.isDesktop(context)
                                  ? Dimensions.paddingSizeExtraSmall
                                  : 0),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  itemController.setNewCartVariationIndex(
                                      index, i, item!);
                                },
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      item!.foodVariations![index].multiSelect!
                                          ? Checkbox(
                                              value: itemController
                                                  .selectedVariations[index][i],
                                              activeColor: Theme.of(context)
                                                  .primaryColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .radiusSmall)),
                                              onChanged: (bool? newValue) {
                                                itemController
                                                    .setNewCartVariationIndex(
                                                        index, i, item!);
                                              },
                                              visualDensity:
                                                  const VisualDensity(
                                                      horizontal: -3,
                                                      vertical: -3),
                                              side: BorderSide(
                                                  width: 2,
                                                  color: Theme.of(context)
                                                      .hintColor),
                                            )
                                          : Radio(
                                              value: i,
                                              groupValue: itemController
                                                  .selectedVariations[index]
                                                  .indexOf(true),
                                              onChanged: (dynamic value) {
                                                itemController
                                                    .setNewCartVariationIndex(
                                                        index, i, item!);
                                              },
                                              activeColor: Theme.of(context)
                                                  .primaryColor,
                                              toggleable: false,
                                              visualDensity:
                                                  const VisualDensity(
                                                      horizontal: -3,
                                                      vertical: -3),
                                            ),
                                      showOriginalPrice
                                          ? Text(
                                              '+${PriceConverter.convertPrice(item!.foodVariations![index].variationValues![i].optionPrice)}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textDirection: TextDirection.ltr,
                                              style: STCRegular.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeExtraSmall,
                                                  color: Theme.of(context)
                                                      .disabledColor,
                                                  decoration: TextDecoration
                                                      .lineThrough),
                                            )
                                          : const SizedBox(),
                                      SizedBox(
                                          width: showOriginalPrice
                                              ? Dimensions.paddingSizeExtraSmall
                                              : 0),
                                      Text(
                                        (item!
                                                        .foodVariations![index]
                                                        .variationValues![i]
                                                        .optionPrice ??
                                                    0.0) >
                                                0.0
                                            ? '+${PriceConverter.convertPrice(item!.foodVariations![index].variationValues![i].optionPrice, discount: discount, discountType: discountType, isFoodVariation: true)}'
                                            : '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textDirection: TextDirection.ltr,
                                        style: itemController
                                                .selectedVariations[index][i]!
                                            ? STCMedium.copyWith(
                                                fontSize: Dimensions
                                                    .fontSizeExtraSmall)
                                            : STCRegular.copyWith(
                                                fontSize: Dimensions
                                                    .fontSizeExtraSmall,
                                                color: Theme.of(context)
                                                    .disabledColor),
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        width: Get.size.width * 0.5,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                item!.foodVariations![index]
                                                    .variationValues![i].level!
                                                    .trim(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: itemController
                                                            .selectedVariations[
                                                        index][i]!
                                                    ? STCMedium
                                                    : STCRegular.copyWith(
                                                        color: Theme.of(context)
                                                            .hintColor,
                                                      ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: item!
                                                          .foodVariations![
                                                              index]
                                                          .variationValues![i]
                                                          .image !=
                                                      ""
                                                  ? 12
                                                  : 0,
                                            ),
                                            Builder(builder: (context) {
                                              final variationValue = item
                                                  ?.foodVariations?[index]
                                                  ?.variationValues?[i];
                                              final String? imagePath =
                                                  variationValue?.image;

                                              if (imagePath != null &&
                                                  imagePath.isNotEmpty) {
                                                return CachedNetworkImage(
                                                  imageUrl: AppConstants
                                                          .variationsBaseUrl +
                                                      imagePath,
                                                  height: 60,
                                                  width: 60,
                                                  placeholder: (context, url) =>
                                                      const SizedBox(
                                                          width: 25,
                                                          height: 25,
                                                          child: Center(
                                                              child: SizedBox(
                                                                  width: 15,
                                                                  height: 15,
                                                                  child: CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2)))),
                                                  errorWidget:
                                                      (context, url, error) {
                                                    print(
                                                        "Error loading image: $url, Error: $error"); // Log the error
                                                    return const SizedBox(
                                                        width: 25,
                                                        height: 25,
                                                        child: Icon(
                                                            Icons.broken_image,
                                                            size: 15));
                                                  },
                                                );
                                              } else {
                                                return const SizedBox.shrink();
                                              }
                                            }),
                                            SizedBox(
                                              width: item!
                                                          .foodVariations![
                                                              index]
                                                          .variationValues![i]
                                                          .image !=
                                                      ""
                                                  ? 12
                                                  : 0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]),
                              ),
                              if (itemController.selectedVariations[index]
                                      [i]! &&
                                  isPizzaItem(item!))
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SliceSelector(
                                      variationIndex: index,
                                      optionIndex: i,
                                      itemController: itemController,
                                      item: item!,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider()
                ],
              ),
            ),
          )
        : SizedBox();
    // Container(
    //   padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
    //   margin: EdgeInsets.only(
    //       bottom: index != item!.foodVariations!.length - 1
    //           ? Dimensions.paddingSizeLarge
    //           : 0),
    //   decoration: BoxDecoration(
    //     color:
    //     itemController.selectedVariations[index].contains(true)
    //         ? Theme.of(context)
    //         .primaryColor
    //         .withAlpha((0.01 * 255).toInt())
    //         : Theme.of(context)
    //         .disabledColor
    //         .withAlpha((0.05 * 255).toInt()),
    //     border: Border.all(
    //       color: itemController.selectedVariations[index]
    //           .contains(true)
    //           ? Theme.of(context).primaryColor
    //           : Theme.of(context).disabledColor,
    //       width: 0.5,
    //     ),
    //     borderRadius:
    //     BorderRadius.circular(Dimensions.radiusDefault),
    //   ),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: [
    //           Text(item!.foodVariations![index].name!,
    //               style: STCMedium.copyWith(
    //                   fontSize: Dimensions.fontSizeLarge)),
    //           Container(
    //             decoration: BoxDecoration(
    //               color: item!.foodVariations![index].required! &&
    //                   (item!.foodVariations![index].multiSelect!
    //                       ? item!
    //                       .foodVariations![index].min!
    //                       : 1) >
    //                       selectedCount
    //                   ? Theme.of(context)
    //                   .colorScheme
    //                   .error
    //                   .withAlpha((0.1 * 255).toInt())
    //                   : Theme.of(context)
    //                   .disabledColor
    //                   .withAlpha((0.1 * 255).toInt()),
    //               borderRadius:
    //               BorderRadius.circular(Dimensions.radiusSmall),
    //             ),
    //             padding: const EdgeInsets.all(
    //                 Dimensions.paddingSizeExtraSmall),
    //             child: Text(
    //               item!.foodVariations![index].required!
    //                   ? (item!.foodVariations![index].multiSelect!
    //                   ? item!
    //                   .foodVariations![index].min!
    //                   : 1) <=
    //                   selectedCount
    //                   ? 'completed'.tr
    //                   : 'required'.tr
    //                   : 'optional'.tr,
    //               style: STCRegular.copyWith(
    //                 color: item!.foodVariations![index].required!
    //                     ? (item!.foodVariations![index].multiSelect!
    //                     ? item!
    //                     .foodVariations![index].min!
    //                     : 1) <=
    //                     selectedCount
    //                     ? Theme.of(context).hintColor
    //                     : Theme.of(context).colorScheme.error
    //                     : Theme.of(context).hintColor,
    //                 fontSize: Dimensions.fontSizeSmall,
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //       const SizedBox(height: Dimensions.paddingSizeExtraSmall),
    //       item!.foodVariations![index].multiSelect!
    //           ? Text(
    //         '${'select_minimum'.tr} ${'${item!.foodVariations![index].min}' ' ${'and_up_to'.tr} ${item!.foodVariations![index].max} ${'options'.tr}'}',
    //         style: STCMedium.copyWith(
    //             fontSize: Dimensions.fontSizeExtraSmall,
    //             color: Theme.of(context).disabledColor),
    //       )
    //           : Text(
    //         'select_one'.tr,
    //         style: STCMedium.copyWith(
    //             fontSize: Dimensions.fontSizeExtraSmall,
    //             color: Theme.of(context).primaryColor),
    //       ),
    //       SizedBox(
    //           height: item!.foodVariations![index].multiSelect!
    //               ? Dimensions.paddingSizeExtraSmall
    //               : 0),
    //       ListView.builder(
    //         shrinkWrap: true,
    //         physics: const NeverScrollableScrollPhysics(),
    //         padding: EdgeInsets.zero,
    //         itemCount: itemController.collapseVariation[index]
    //             ? item!.foodVariations![index].variationValues!
    //             .length >
    //             4
    //             ? 5
    //             : item!.foodVariations![index].variationValues!
    //             .length
    //             : item!
    //             .foodVariations![index].variationValues!.length,
    //         itemBuilder: (context, i) {
    //           if (i == 4 &&
    //               itemController.collapseVariation[index]) {
    //             return Padding(
    //               padding: const EdgeInsets.all(
    //                   Dimensions.paddingSizeExtraSmall),
    //               child: InkWell(
    //                 onTap: () => itemController
    //                     .showMoreSpecificSection(index),
    //                 child: Row(children: [
    //                   Icon(Icons.expand_more,
    //                       size: 18,
    //                       color: Theme.of(context).primaryColor),
    //                   const SizedBox(
    //                       width: Dimensions.paddingSizeExtraSmall),
    //                   Text(
    //                     '${'view'.tr} ${item!.foodVariations![index].variationValues!.length - 4} ${'more_option'.tr}',
    //                     style: STCMedium.copyWith(
    //                         color: Theme.of(context).primaryColor),
    //                   ),
    //                 ]),
    //               ),
    //             );
    //           } else {
    //             return Padding(
    //               padding: EdgeInsets.symmetric(
    //                   vertical: ResponsiveHelper.isDesktop(context)
    //                       ? Dimensions.paddingSizeExtraSmall
    //                       : 0),
    //               child: InkWell(
    //                 onTap: () {
    //                   itemController.setNewCartVariationIndex(
    //                       index, i, item!);
    //                 },
    //                 child: Row(children: [
    //                   Row(
    //                       crossAxisAlignment:
    //                       CrossAxisAlignment.center,
    //                       children: [
    //                         item!.foodVariations![index]
    //                             .multiSelect!
    //                             ? Checkbox(
    //                           value: itemController
    //                               .selectedVariations[
    //                           index][i],
    //                           activeColor: Theme.of(context)
    //                               .primaryColor,
    //                           shape: RoundedRectangleBorder(
    //                               borderRadius:
    //                               BorderRadius.circular(
    //                                   Dimensions
    //                                       .radiusSmall)),
    //                           onChanged: (bool? newValue) {
    //                             itemController
    //                                 .setNewCartVariationIndex(
    //                                 index, i, item!);
    //                           },
    //                           visualDensity:
    //                           const VisualDensity(
    //                               horizontal: -3,
    //                               vertical: -3),
    //                           side: BorderSide(
    //                               width: 2,
    //                               color: Theme.of(context)
    //                                   .hintColor),
    //                         )
    //                             : Radio(
    //                           value: i,
    //                           groupValue: itemController
    //                               .selectedVariations[index]
    //                               .indexOf(true),
    //                           onChanged: (dynamic value) {
    //                             itemController
    //                                 .setNewCartVariationIndex(
    //                                 index, i, item!);
    //                           },
    //                           activeColor: Theme.of(context)
    //                               .primaryColor,
    //                           toggleable: false,
    //                           visualDensity:
    //                           const VisualDensity(
    //                               horizontal: -3,
    //                               vertical: -3),
    //                         ),
    //                         Text(
    //                           item!.foodVariations![index]
    //                               .variationValues![i].level!
    //                               .trim(),
    //                           maxLines: 1,
    //                           overflow: TextOverflow.ellipsis,
    //                           style: itemController
    //                               .selectedVariations[index][i]!
    //                               ? STCMedium
    //                               : STCRegular.copyWith(
    //                               color: Theme.of(context)
    //                                   .hintColor),
    //                         ),
    //                       ]),
    //                   const Spacer(),
    //                   showOriginalPrice
    //                       ? Text(
    //                     '+${PriceConverter.convertPrice(item!.foodVariations![index].variationValues![i].optionPrice)}',
    //                     maxLines: 1,
    //                     overflow: TextOverflow.ellipsis,
    //                     textDirection: TextDirection.ltr,
    //                     style: STCRegular.copyWith(
    //                         fontSize:
    //                         Dimensions.fontSizeExtraSmall,
    //                         color: Theme.of(context)
    //                             .disabledColor,
    //                         decoration:
    //                         TextDecoration.lineThrough),
    //                   )
    //                       : const SizedBox(),
    //                   SizedBox(
    //                       width: showOriginalPrice
    //                           ? Dimensions.paddingSizeExtraSmall
    //                           : 0),
    //                   Text(
    //                     '+${PriceConverter.convertPrice(item!.foodVariations![index].variationValues![i].optionPrice, discount: discount, discountType: discountType, isFoodVariation: true)}',
    //                     maxLines: 1,
    //                     overflow: TextOverflow.ellipsis,
    //                     textDirection: TextDirection.ltr,
    //                     style: itemController
    //                         .selectedVariations[index][i]!
    //                         ? STCMedium.copyWith(
    //                         fontSize:
    //                         Dimensions.fontSizeExtraSmall)
    //                         : STCRegular.copyWith(
    //                         fontSize:
    //                         Dimensions.fontSizeExtraSmall,
    //                         color: Theme.of(context)
    //                             .disabledColor),
    //                   ),
    //                 ]),
    //               ),
    //             );
    //           }
    //         },
    //       ),
    //     ],
    //   ),
    // );
    // ? Container(
    //     color: Theme.of(context).cardColor,
    //     child: ListView.builder(
    //       shrinkWrap: true,
    //       itemCount: item!.foodVariations!.length,
    //       physics: const NeverScrollableScrollPhysics(),
    //       padding: EdgeInsets.only(
    //           bottom: (item!.foodVariations != null &&
    //                   item!.foodVariations!.isNotEmpty)
    //               ? Dimensions.paddingSizeLarge
    //               : 0),
    //       itemBuilder: (context, index) {
    //         int selectedCount = 0;
    //         if (item!.foodVariations![index].required!) {
    //           for (var value in itemController.selectedVariations[index]) {
    //             if (value == true) {
    //               selectedCount++;
    //             }
    //           }
    //         }
    //         return Container(
    //           padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
    //           margin: EdgeInsets.only(
    //               bottom: index != item!.foodVariations!.length - 1
    //                   ? Dimensions.paddingSizeLarge
    //                   : 0),
    //           decoration: BoxDecoration(
    //             color:
    //                 itemController.selectedVariations[index].contains(true)
    //                     ? Theme.of(context)
    //                         .primaryColor
    //                         .withAlpha((0.01 * 255).toInt())
    //                     : Theme.of(context)
    //                         .disabledColor
    //                         .withAlpha((0.05 * 255).toInt()),
    //             border: Border.all(
    //               color: itemController.selectedVariations[index]
    //                       .contains(true)
    //                   ? Theme.of(context).primaryColor
    //                   : Theme.of(context).disabledColor,
    //               width: 0.5,
    //             ),
    //             borderRadius:
    //                 BorderRadius.circular(Dimensions.radiusDefault),
    //           ),
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 crossAxisAlignment: CrossAxisAlignment.center,
    //                 children: [
    //                   Text(item!.foodVariations![index].name!,
    //                       style: STCMedium.copyWith(
    //                           fontSize: Dimensions.fontSizeLarge)),
    //                   Container(
    //                     decoration: BoxDecoration(
    //                       color: item!.foodVariations![index].required! &&
    //                               (item!.foodVariations![index].multiSelect!
    //                                       ? item!
    //                                           .foodVariations![index].min!
    //                                       : 1) >
    //                                   selectedCount
    //                           ? Theme.of(context)
    //                               .colorScheme
    //                               .error
    //                               .withAlpha((0.1 * 255).toInt())
    //                           : Theme.of(context)
    //                               .disabledColor
    //                               .withAlpha((0.1 * 255).toInt()),
    //                       borderRadius:
    //                           BorderRadius.circular(Dimensions.radiusSmall),
    //                     ),
    //                     padding: const EdgeInsets.all(
    //                         Dimensions.paddingSizeExtraSmall),
    //                     child: Text(
    //                       item!.foodVariations![index].required!
    //                           ? (item!.foodVariations![index].multiSelect!
    //                                       ? item!
    //                                           .foodVariations![index].min!
    //                                       : 1) <=
    //                                   selectedCount
    //                               ? 'completed'.tr
    //                               : 'required'.tr
    //                           : 'optional'.tr,
    //                       style: STCRegular.copyWith(
    //                         color: item!.foodVariations![index].required!
    //                             ? (item!.foodVariations![index].multiSelect!
    //                                         ? item!
    //                                             .foodVariations![index].min!
    //                                         : 1) <=
    //                                     selectedCount
    //                                 ? Theme.of(context).hintColor
    //                                 : Theme.of(context).colorScheme.error
    //                             : Theme.of(context).hintColor,
    //                         fontSize: Dimensions.fontSizeSmall,
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               const SizedBox(height: Dimensions.paddingSizeExtraSmall),
    //               item!.foodVariations![index].multiSelect!
    //                   ? Text(
    //                       '${'select_minimum'.tr} ${'${item!.foodVariations![index].min}' ' ${'and_up_to'.tr} ${item!.foodVariations![index].max} ${'options'.tr}'}',
    //                       style: STCMedium.copyWith(
    //                           fontSize: Dimensions.fontSizeExtraSmall,
    //                           color: Theme.of(context).disabledColor),
    //                     )
    //                   : Text(
    //                       'select_one'.tr,
    //                       style: STCMedium.copyWith(
    //                           fontSize: Dimensions.fontSizeExtraSmall,
    //                           color: Theme.of(context).primaryColor),
    //                     ),
    //               SizedBox(
    //                   height: item!.foodVariations![index].multiSelect!
    //                       ? Dimensions.paddingSizeExtraSmall
    //                       : 0),
    //               ListView.builder(
    //                 shrinkWrap: true,
    //                 physics: const NeverScrollableScrollPhysics(),
    //                 padding: EdgeInsets.zero,
    //                 itemCount: itemController.collapseVariation[index]
    //                     ? item!.foodVariations![index].variationValues!
    //                                 .length >
    //                             4
    //                         ? 5
    //                         : item!.foodVariations![index].variationValues!
    //                             .length
    //                     : item!
    //                         .foodVariations![index].variationValues!.length,
    //                 itemBuilder: (context, i) {
    //                   if (i == 4 &&
    //                       itemController.collapseVariation[index]) {
    //                     return Padding(
    //                       padding: const EdgeInsets.all(
    //                           Dimensions.paddingSizeExtraSmall),
    //                       child: InkWell(
    //                         onTap: () => itemController
    //                             .showMoreSpecificSection(index),
    //                         child: Row(children: [
    //                           Icon(Icons.expand_more,
    //                               size: 18,
    //                               color: Theme.of(context).primaryColor),
    //                           const SizedBox(
    //                               width: Dimensions.paddingSizeExtraSmall),
    //                           Text(
    //                             '${'view'.tr} ${item!.foodVariations![index].variationValues!.length - 4} ${'more_option'.tr}',
    //                             style: STCMedium.copyWith(
    //                                 color: Theme.of(context).primaryColor),
    //                           ),
    //                         ]),
    //                       ),
    //                     );
    //                   } else {
    //                     return Padding(
    //                       padding: EdgeInsets.symmetric(
    //                           vertical: ResponsiveHelper.isDesktop(context)
    //                               ? Dimensions.paddingSizeExtraSmall
    //                               : 0),
    //                       child: InkWell(
    //                         onTap: () {
    //                           itemController.setNewCartVariationIndex(
    //                               index, i, item!);
    //                         },
    //                         child: Row(children: [
    //                           Row(
    //                               crossAxisAlignment:
    //                                   CrossAxisAlignment.center,
    //                               children: [
    //                                 item!.foodVariations![index]
    //                                         .multiSelect!
    //                                     ? Checkbox(
    //                                         value: itemController
    //                                                 .selectedVariations[
    //                                             index][i],
    //                                         activeColor: Theme.of(context)
    //                                             .primaryColor,
    //                                         shape: RoundedRectangleBorder(
    //                                             borderRadius:
    //                                                 BorderRadius.circular(
    //                                                     Dimensions
    //                                                         .radiusSmall)),
    //                                         onChanged: (bool? newValue) {
    //                                           itemController
    //                                               .setNewCartVariationIndex(
    //                                                   index, i, item!);
    //                                         },
    //                                         visualDensity:
    //                                             const VisualDensity(
    //                                                 horizontal: -3,
    //                                                 vertical: -3),
    //                                         side: BorderSide(
    //                                             width: 2,
    //                                             color: Theme.of(context)
    //                                                 .hintColor),
    //                                       )
    //                                     : Radio(
    //                                         value: i,
    //                                         groupValue: itemController
    //                                             .selectedVariations[index]
    //                                             .indexOf(true),
    //                                         onChanged: (dynamic value) {
    //                                           itemController
    //                                               .setNewCartVariationIndex(
    //                                                   index, i, item!);
    //                                         },
    //                                         activeColor: Theme.of(context)
    //                                             .primaryColor,
    //                                         toggleable: false,
    //                                         visualDensity:
    //                                             const VisualDensity(
    //                                                 horizontal: -3,
    //                                                 vertical: -3),
    //                                       ),
    //                                 Text(
    //                                   item!.foodVariations![index]
    //                                       .variationValues![i].level!
    //                                       .trim(),
    //                                   maxLines: 1,
    //                                   overflow: TextOverflow.ellipsis,
    //                                   style: itemController
    //                                           .selectedVariations[index][i]!
    //                                       ? STCMedium
    //                                       : STCRegular.copyWith(
    //                                           color: Theme.of(context)
    //                                               .hintColor),
    //                                 ),
    //                               ]),
    //                           const Spacer(),
    //                           showOriginalPrice
    //                               ? Text(
    //                                   '+${PriceConverter.convertPrice(item!.foodVariations![index].variationValues![i].optionPrice)}',
    //                                   maxLines: 1,
    //                                   overflow: TextOverflow.ellipsis,
    //                                   textDirection: TextDirection.ltr,
    //                                   style: STCRegular.copyWith(
    //                                       fontSize:
    //                                           Dimensions.fontSizeExtraSmall,
    //                                       color: Theme.of(context)
    //                                           .disabledColor,
    //                                       decoration:
    //                                           TextDecoration.lineThrough),
    //                                 )
    //                               : const SizedBox(),
    //                           SizedBox(
    //                               width: showOriginalPrice
    //                                   ? Dimensions.paddingSizeExtraSmall
    //                                   : 0),
    //                           Text(
    //                             '+${PriceConverter.convertPrice(item!.foodVariations![index].variationValues![i].optionPrice, discount: discount, discountType: discountType, isFoodVariation: true)}',
    //                             maxLines: 1,
    //                             overflow: TextOverflow.ellipsis,
    //                             textDirection: TextDirection.ltr,
    //                             style: itemController
    //                                     .selectedVariations[index][i]!
    //                                 ? STCMedium.copyWith(
    //                                     fontSize:
    //                                         Dimensions.fontSizeExtraSmall)
    //                                 : STCRegular.copyWith(
    //                                     fontSize:
    //                                         Dimensions.fontSizeExtraSmall,
    //                                     color: Theme.of(context)
    //                                         .disabledColor),
    //                           ),
    //                         ]),
    //                       ),
    //                     );
    //                   }
    //                 },
    //               ),
    //             ],
    //           ),
    //         );
    //       },
    //     ),
    //   )
    // : const SizedBox();
  }
}

class SliceSelector extends StatelessWidget {
  final int variationIndex;
  final int optionIndex;
  final ItemController itemController;
  final Item item;

  const SliceSelector({
    super.key,
    required this.variationIndex,
    required this.optionIndex,
    required this.itemController,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    // Get the current slice selection for this specific variation option
    final currentSlice =
        itemController.getSliceSelection(variationIndex, optionIndex).obs;

    return Obx(() => Get.find<LocalizationController>().isLtr
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSliceButton(1, Images.fullSliceIcon, currentSlice),
              _buildSliceButton(2, Images.leftSliceIcon, currentSlice),
              _buildSliceButton(3, Images.rightSliceIcon, currentSlice),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSliceButton(1, Images.rightSliceIcon, currentSlice),
              _buildSliceButton(2, Images.leftSliceIcon, currentSlice),
              _buildSliceButton(3, Images.fullSliceIcon, currentSlice),
            ],
          ));
  }

  Widget _buildSliceButton(int value, String image, RxInt currentSlice) {
    return GestureDetector(
      onTap: () {
        currentSlice.value = value;
        itemController.setSliceSelection(
            variationIndex, optionIndex, value, item);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: currentSlice.value == value
              ? Get.theme.primaryColor
              : Get.theme.primaryColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
                color: Get.theme.cardColor, shape: BoxShape.circle),
            child: Image.asset(image,
                height: 30, width: 30, color: Get.theme.primaryColor)),
      ),
    );
  }
}

/*class SliceSelector extends StatelessWidget {
  final RxInt selectedSlice = 0.obs; // 0 = none, 1 = full, 2 = left, 3 = right

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSliceButton(1, Images.fullSliceIcon, "Full"),
            _buildSliceButton(2, Images.leftSliceIcon, "Left"),
            _buildSliceButton(3, Images.rightSliceIcon, "Right"),
          ],
        ));
  }

  Widget _buildSliceButton(int value, String image, String label) {
    return GestureDetector(
      onTap: () {
        selectedSlice.value = value;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selectedSlice.value == value
              ? Get.theme.primaryColor
              : Get.theme.primaryColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
                color: Get.theme.cardColor, shape: BoxShape.circle),
            child: Image.asset(image,
                height: 30, width: 30, color: Get.theme.primaryColor)),
      ),
    );
  }
}*/
// import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
// import 'package:sixam_mart/common/widgets/custom_tool_tip_widget.dart';
// import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
// import 'package:sixam_mart/features/item/controllers/item_controller.dart';
// import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
// import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
// import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
// import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
// import 'package:sixam_mart/features/item/domain/models/item_model.dart';
// import 'package:sixam_mart/common/models/module_model.dart';
// import 'package:sixam_mart/helper/auth_helper.dart';
// import 'package:sixam_mart/helper/date_converter.dart';
// import 'package:sixam_mart/helper/price_converter.dart';
// import 'package:sixam_mart/helper/responsive_helper.dart';
// import 'package:sixam_mart/helper/route_helper.dart';
// import 'package:sixam_mart/util/dimensions.dart';
// import 'package:sixam_mart/util/images.dart';
// import 'package:sixam_mart/util/styles.dart';
// import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
// import 'package:sixam_mart/common/widgets/custom_button.dart';
// import 'package:sixam_mart/common/widgets/custom_image.dart';
// import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
// import 'package:sixam_mart/common/widgets/discount_tag.dart';
// import 'package:sixam_mart/common/widgets/quantity_button.dart';
// import 'package:sixam_mart/common/widgets/rating_bar.dart';
// import 'package:sixam_mart/features/checkout/screens/checkout_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class ItemBottomSheet extends StatefulWidget {
//   final Item? item;
//   final bool isCampaign;
//   final CartModel? cart;
//   final int? cartIndex;
//   final bool inStorePage;
//
//   const ItemBottomSheet(
//       {super.key,
//       required this.item,
//       this.isCampaign = false,
//       this.cart,
//       this.cartIndex,
//       this.inStorePage = false});
//
//   @override
//   State<ItemBottomSheet> createState() => _ItemBottomSheetState();
// }
//
// class _ItemBottomSheetState extends State<ItemBottomSheet> {
//   bool _newVariation = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (Get.find<SplashController>().module == null) {
//       if (Get.find<SplashController>().cacheModule != null) {
//         Get.find<SplashController>()
//             .setCacheConfigModule(Get.find<SplashController>().cacheModule);
//       }
//     }
//     _newVariation = Get.find<SplashController>()
//             .getModuleConfig(widget.item!.moduleType)
//             .newVariation ??
//         false;
//     Get.find<ItemController>().initData(widget.item, widget.cart);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity, //550,
//       margin: EdgeInsets.only(
//         top: GetPlatform.isWeb ? 0 : 30,
//       ),
//       decoration: BoxDecoration(
//         // color: Theme.of(context).cardColor,
//         color: Colors.transparent,
//         borderRadius: GetPlatform.isWeb
//             ? const BorderRadius.all(Radius.circular(Dimensions.radiusDefault))
//             : const BorderRadius.vertical(
//                 top: Radius.circular(Dimensions.radiusExtraLarge),
//                 // bottom: Radius.circular(Dimensions.radiusExtraLarge),
//               ),
//       ),
//       child: GetBuilder<ItemController>(builder: (itemController) {
//         double? startingPrice;
//         double? endingPrice;
//         if (widget.item!.choiceOptions!.isNotEmpty &&
//             widget.item!.foodVariations!.isEmpty &&
//             !_newVariation) {
//           List<double?> priceList = [];
//           for (var variation in widget.item!.variations!) {
//             priceList.add(variation.price);
//           }
//           priceList.sort((a, b) => a!.compareTo(b!));
//           startingPrice = priceList[0];
//           if (priceList[0]! < priceList[priceList.length - 1]!) {
//             endingPrice = priceList[priceList.length - 1];
//           }
//         } else {
//           startingPrice = widget.item!.price;
//         }
//
//         double? price = widget.item!.price;
//         double variationPrice = 0;
//         Variation? variation;
//         double initialDiscount = (widget.isCampaign ||
//                 widget.item!.storeDiscount == 0)
//             ? (double.tryParse(widget.item!.discount.toString()) ?? 0.0)
//             : (double.tryParse(widget.item!.storeDiscount.toString()) ?? 0.0);
//         // If widget.item!.discount is a String
//         double discount = (widget.isCampaign || widget.item!.storeDiscount == 0)
//             ? (double.tryParse(widget.item!.discount.toString()) ?? 0.0)
//             : (double.tryParse(widget.item!.storeDiscount.toString()) ?? 0.0);
//         String? discountType =
//             (widget.isCampaign || widget.item!.storeDiscount == 0)
//                 ? widget.item!.discountType
//                 : 'percent';
//         int? stock = widget.item!.stock ?? 0;
//
//         if (discountType == 'amount') {
//           discount = discount! * itemController.quantity!;
//         }
//
//         if (_newVariation) {
//           for (int index = 0;
//               index < widget.item!.foodVariations!.length;
//               index++) {
//             for (int i = 0;
//                 i < widget.item!.foodVariations![index].variationValues!.length;
//                 i++) {
//               if (itemController.selectedVariations[index][i]!) {
//                 variationPrice += widget.item!.foodVariations![index]
//                     .variationValues![i].optionPrice!;
//               }
//             }
//           }
//         } else {
//           List<String> variationList = [];
//           for (int index = 0;
//               index < widget.item!.choiceOptions!.length;
//               index++) {
//             variationList.add(widget.item!.choiceOptions![index]
//                 .options![itemController.variationIndex![index]]
//                 .replaceAll(' ', ''));
//           }
//           String variationType = '';
//           bool isFirst = true;
//           for (var variation in variationList) {
//             if (isFirst) {
//               variationType = '$variationType$variation';
//               isFirst = false;
//             } else {
//               variationType = '$variationType-$variation';
//             }
//           }
//
//           for (Variation variations in widget.item!.variations!) {
//             if (variations.type == variationType) {
//               price = variations.price;
//               variation = variations;
//               stock = variations.stock;
//               break;
//             }
//           }
//         }
//
//         price = price! + variationPrice;
//         double priceWithDiscount = PriceConverter.convertWithDiscount(
//             price ?? 0, discount, discountType)!;
//         double addonsCost = 0;
//         List<AddOn> addOnIdList = [];
//         List<AddOns> addOnsList = [];
//         for (int index = 0; index < widget.item!.addOns!.length; index++) {
//           if (itemController.addOnActiveList[index]) {
//             addonsCost = addonsCost +
//                 (widget.item!.addOns![index].price! *
//                     itemController.addOnQtyList[index]!);
//             addOnIdList.add(AddOn(
//                 id: widget.item!.addOns![index].id,
//                 quantity: itemController.addOnQtyList[index]));
//             addOnsList.add(widget.item!.addOns![index]);
//           }
//         }
//         priceWithDiscount = priceWithDiscount;
//         double? priceWithDiscountAndAddons = priceWithDiscount + addonsCost;
//         bool isAvailable = DateConverter.isAvailable(
//             widget.item!.availableTimeStarts, widget.item!.availableTimeEnds);
//
//         return ConstrainedBox(
//           constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.95),
//           child: Stack(
//             children: [
//               Padding(
//                 padding: EdgeInsets.only(bottom: Get.size.height * .04),
//                 child: Column(mainAxisSize: MainAxisSize.min, children: [
//                   const SizedBox(height: Dimensions.paddingSizeDefault),
//                   Expanded(
//                     child: SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       padding: const EdgeInsets.only(
//                         left: Dimensions.paddingSizeDefault,
//                         // bottom: Dimensions.paddingSizeDefault,
//                       ),
//                       child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Padding(
//                               padding: EdgeInsets.only(
//                                 right: Dimensions.paddingSizeDefault,
//                                 top: ResponsiveHelper.isDesktop(context)
//                                     ? 0
//                                     : 0, //Dimensions.paddingSizeDefault,
//                                 // bottom: Dimensions.paddingSizeDefault
//                               ),
//                               child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     //Product
//                                     Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           InkWell(
//                                             onTap: widget.isCampaign
//                                                 ? null
//                                                 : () {
//                                                     if (!widget.isCampaign) {
//                                                       Get.toNamed(RouteHelper
//                                                           .getItemImagesRoute(
//                                                               widget.item!));
//                                                     }
//                                                   },
//                                             child: Stack(children: [
//                                               ClipRRect(
//                                                 borderRadius:
//                                                     BorderRadius.circular(
//                                                   Dimensions.radiusExtraLarge,
//                                                 ),
//                                                 child: CustomImage(
//                                                   image:
//                                                       '${widget.item!.imageFullUrl}',
//                                                   width:
//                                                       ResponsiveHelper.isMobile(
//                                                               context)
//                                                           ? double.infinity
//                                                           : 140,
//                                                   height:
//                                                       ResponsiveHelper.isMobile(
//                                                               context)
//                                                           ? Get.size.width * .6
//                                                           : 140,
//                                                   fit: BoxFit.fill,
//                                                 ),
//                                               ),
//                                               DiscountTag(
//                                                   discount: initialDiscount,
//                                                   discountType: discountType,
//                                                   fromTop: 20),
//                                             ]),
//                                           ),
//                                           const SizedBox(height: 12),
//                                           Container(
//                                             width: double.infinity,
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(
//                                                 Dimensions.radiusExtraLarge,
//                                               ),
//                                               color: Theme.of(context)
//                                                   .primaryColor,
//                                               // color: Theme.of(context).cardColor,
//                                             ),
//                                             child: Column(
//                                               children: [
//                                                 Padding(
//                                                   padding:
//                                                       const EdgeInsets.only(
//                                                     top: 10.0,
//                                                     right: 12,
//                                                     left: 12,
//                                                   ),
//                                                   child: Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .spaceBetween,
//                                                     children: [
//                                                       Column(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .start,
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: [
//                                                           Container(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .all(3),
//                                                             margin:
//                                                                 const EdgeInsets
//                                                                     .only(
//                                                                     bottom: 10),
//                                                             decoration:
//                                                                 BoxDecoration(
//                                                               color:
//                                                                   Colors.white,
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                 Dimensions
//                                                                     .radiusSmall,
//                                                               ),
//                                                             ),
//                                                             child: Text(
//                                                               '${PriceConverter.convertPrice(startingPrice, discount: initialDiscount, discountType: discountType)}'
//                                                               '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice, discount: initialDiscount, discountType: discountType)}' : ''}',
//                                                               style: STCMedium.copyWith(
//                                                                   fontSize:
//                                                                       Dimensions
//                                                                           .fontSizeLarge),
//                                                               textDirection:
//                                                                   TextDirection
//                                                                       .ltr,
//                                                             ),
//                                                           ),
//                                                           price >
//                                                                   priceWithDiscount
//                                                               ? Text(
//                                                                   '${PriceConverter.convertPrice(startingPrice)}'
//                                                                   '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice)}' : ''}',
//                                                                   textDirection:
//                                                                       TextDirection
//                                                                           .ltr,
//                                                                   style: STCMedium.copyWith(
//                                                                       color: Theme.of(
//                                                                               context)
//                                                                           .disabledColor,
//                                                                       decoration:
//                                                                           TextDecoration
//                                                                               .lineThrough),
//                                                                 )
//                                                               : const SizedBox
//                                                                   .shrink(),
//
//                                                           ///counting here
//                                                           Container(
//                                                             width:
//                                                                 Get.size.width *
//                                                                     .25,
//                                                             decoration:
//                                                                 BoxDecoration(
//                                                               color:
//                                                                   Colors.white,
//                                                               borderRadius:
//                                                                   BorderRadius.circular(
//                                                                       Dimensions
//                                                                           .radiusSmall),
//                                                             ),
//                                                             child:
//                                                                 Row(children: [
//                                                               ItemCountButtons(
//                                                                 onTap: () {
//                                                                   if (itemController
//                                                                           .quantity! >
//                                                                       1) {
//                                                                     itemController.setQuantity(
//                                                                         false,
//                                                                         stock,
//                                                                         widget
//                                                                             .item!
//                                                                             .quantityLimit,
//                                                                         getxSnackBar:
//                                                                             true);
//                                                                   }
//                                                                 },
//                                                                 isIncrement:
//                                                                     false,
//                                                                 fromSheet: true,
//                                                               ),
//                                                               Expanded(
//                                                                 child: Text(
//                                                                   textAlign:
//                                                                       TextAlign
//                                                                           .center,
//                                                                   itemController
//                                                                       .quantity
//                                                                       .toString(),
//                                                                   style: STCMedium
//                                                                       .copyWith(
//                                                                     fontSize:
//                                                                         Dimensions
//                                                                             .fontSizeLarge,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               ItemCountButtons(
//                                                                 onTap: () => itemController.setQuantity(
//                                                                     true,
//                                                                     stock,
//                                                                     widget.item!
//                                                                         .quantityLimit,
//                                                                     getxSnackBar:
//                                                                         true),
//                                                                 isIncrement:
//                                                                     true,
//                                                                 fromSheet: true,
//                                                               ),
//                                                             ]),
//                                                           ),
//                                                           const SizedBox(
//                                                               height: 10),
//
//                                                           ///Total price here
//                                                           Builder(builder:
//                                                               (context) {
//                                                             double? cost = PriceConverter
//                                                                 .convertWithDiscount(
//                                                                     (price! *
//                                                                         itemController
//                                                                             .quantity!),
//                                                                     discount,
//                                                                     discountType);
//                                                             double
//                                                                 withAddonCost =
//                                                                 cost! +
//                                                                     addonsCost;
//                                                             return Row(
//                                                                 mainAxisAlignment:
//                                                                     MainAxisAlignment
//                                                                         .spaceBetween,
//                                                                 children: [
//                                                                   Text(
//                                                                       '${'total_amount'.tr}:',
//                                                                       style: STCMedium
//                                                                           .copyWith(
//                                                                         fontSize:
//                                                                             Dimensions.fontSizeDefault,
//                                                                         fontWeight:
//                                                                             FontWeight.bold,
//                                                                         color: Theme.of(context)
//                                                                             .cardColor,
//                                                                       )),
//                                                                   const SizedBox(
//                                                                       width: Dimensions
//                                                                           .paddingSizeExtraSmall),
//                                                                   Row(
//                                                                       children: [
//                                                                         discount! >
//                                                                                 0
//                                                                             ? PriceConverter.convertAnimationPrice(
//                                                                                 (price * itemController.quantity!) + addonsCost,
//                                                                                 textStyle: STCMedium.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall, decoration: TextDecoration.lineThrough),
//                                                                               )
//                                                                             : const SizedBox(),
//                                                                         const SizedBox(
//                                                                             width:
//                                                                                 Dimensions.paddingSizeExtraSmall),
//                                                                         PriceConverter
//                                                                             .convertAnimationPrice(
//                                                                           withAddonCost,
//                                                                           textStyle:
//                                                                               STCBold.copyWith(
//                                                                             fontWeight:
//                                                                                 FontWeight.bold,
//                                                                             color:
//                                                                                 Theme.of(context).cardColor,
//                                                                           ),
//                                                                         ),
//                                                                       ]),
//                                                                 ]);
//                                                           }),
//                                                         ],
//                                                       ),
//                                                       Column(
//                                                           crossAxisAlignment:
//                                                               CrossAxisAlignment
//                                                                   .end,
//                                                           children: [
//                                                             Text(
//                                                               widget
//                                                                   .item!.name!,
//                                                               style: STCMedium
//                                                                   .copyWith(
//                                                                 fontSize: Dimensions
//                                                                     .fontSizeLarge,
//                                                                 color: Colors
//                                                                     .white,
//                                                               ),
//                                                               maxLines: 2,
//                                                               textAlign:
//                                                                   TextAlign
//                                                                       .right,
//                                                               overflow:
//                                                                   TextOverflow
//                                                                       .ellipsis,
//                                                             ),
//                                                             InkWell(
//                                                               onTap: () {
//                                                                 if (widget
//                                                                     .inStorePage) {
//                                                                   Get.back();
//                                                                 } else {
//                                                                   Get.back();
//                                                                   Get.find<
//                                                                           CartController>()
//                                                                       .forcefullySetModule(widget
//                                                                           .item!
//                                                                           .moduleId!);
//                                                                   Get.toNamed(
//                                                                     RouteHelper.getStoreRoute(
//                                                                         id: widget
//                                                                             .item!
//                                                                             .storeId,
//                                                                         page:
//                                                                             'item'),
//                                                                   );
//                                                                   Get.offNamed(RouteHelper.getStoreRoute(
//                                                                       id: widget
//                                                                           .item!
//                                                                           .storeId,
//                                                                       page:
//                                                                           'item'));
//                                                                 }
//                                                               },
//                                                               child: Padding(
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                         .fromLTRB(
//                                                                         0,
//                                                                         5,
//                                                                         5,
//                                                                         5),
//                                                                 child: Text(
//                                                                   widget.item!
//                                                                       .storeName!,
//                                                                   style: STCRegular
//                                                                       .copyWith(
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .w500,
//                                                                     color: Colors
//                                                                         .white,
//                                                                     fontSize:
//                                                                         Dimensions
//                                                                             .fontSizeSmall,
//                                                                     // color: Theme.of(context)
//                                                                     //     .primaryColor,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             !widget.isCampaign
//                                                                 ? RatingBar(
//                                                                     rating: widget
//                                                                         .item!
//                                                                         .avgRating,
//                                                                     size: 15,
//                                                                     ratingCount:
//                                                                         widget
//                                                                             .item!
//                                                                             .ratingCount)
//                                                                 : const SizedBox(),
//                                                           ]),
//                                                     ],
//                                                   ),
//                                                 ),
//                                                 (widget.item!.description !=
//                                                             null &&
//                                                         widget
//                                                             .item!
//                                                             .description!
//                                                             .isNotEmpty)
//                                                     ? Container(
//                                                         color: Theme.of(context)
//                                                             .primaryColor,
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .symmetric(
//                                                                 horizontal: 12),
//                                                         child: Column(
//                                                           crossAxisAlignment:
//                                                               CrossAxisAlignment
//                                                                   .end,
//                                                           children: [
//                                                             Row(
//                                                                 mainAxisAlignment:
//                                                                     MainAxisAlignment
//                                                                         .spaceBetween,
//                                                                 children: [
//                                                                   Text(
//                                                                     "${'description'.tr}:",
//                                                                     style: STCBold
//                                                                         .copyWith(
//                                                                       color: Colors
//                                                                           .white,
//                                                                       fontSize:
//                                                                           Dimensions
//                                                                               .fontSizeDefault,
//                                                                     ),
//                                                                   ),
//                                                                   ((Get.find<SplashController>()
//                                                                               .configModel!
//                                                                               .moduleConfig!
//                                                                               .module!
//                                                                               .unit! &&
//                                                                           widget.item!.unitType !=
//                                                                               null))
//                                                                       // ||
//                                                                       //     (Get.find<SplashController>().configModel!.moduleConfig!.module!.vegNonVeg! &&
//                                                                       //         Get.find<SplashController>()
//                                                                       //             .configModel!
//                                                                       //             .toggleVegNonVeg!)
//                                                                       ? widget.item!.unitType !=
//                                                                               null
//                                                                           ? Container(
//                                                                               padding: EdgeInsets.symmetric(
//                                                                                 vertical: widget.item!.unitType != null ? 3 : 0,
//                                                                                 //Dimensions.paddingSizeExtraSmall,
//                                                                                 horizontal: widget.item!.unitType != null ? Dimensions.paddingSizeSmall : 0,
//                                                                               ),
//                                                                               decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge), color: Theme.of(context).cardColor, boxShadow: [
//                                                                                 BoxShadow(color: Theme.of(context).primaryColor.withAlpha((0.2 * 255).toInt()), blurRadius: 5)
//                                                                               ]),
//                                                                               child: Get.find<SplashController>().configModel!.moduleConfig!.module!.unit!
//                                                                                   ? Text(
//                                                                                       widget.item!.unitType ?? 'vds',
//                                                                                       style: STCMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
//                                                                                     )
//                                                                                   : SizedBox.shrink()
//                                                                               // Row(children: [
//                                                                               //         Image.asset(widget.item!.veg == 1 ? Images.vegLogo : Images.nonVegLogo, height: 18, width: 18),
//                                                                               //         const SizedBox(width: Dimensions.paddingSizeSmall),
//                                                                               //         Text(
//                                                                               //           widget.item!.veg == 1 ? 'veg'.tr : 'non_veg'.tr,
//                                                                               //           style: STCMedium.copyWith(
//                                                                               //             fontSize: Dimensions.fontSizeSmall,
//                                                                               //           ),
//                                                                               //         ),
//                                                                               //       ]),
//                                                                               )
//                                                                           : const SizedBox.shrink()
//                                                                       : const SizedBox.shrink(),
//                                                                 ]),
//                                                             const SizedBox(
//                                                               height: Dimensions
//                                                                   .paddingSizeExtraSmall,
//                                                             ),
//                                                             Text(
//                                                               textAlign:
//                                                                   TextAlign
//                                                                       .right,
//                                                               widget.item!
//                                                                   .description!,
//                                                               style: STCRegular
//                                                                   .copyWith(
//                                                                 color: Theme.of(
//                                                                         context)
//                                                                     .cardColor,
//                                                               ),
//                                                             ),
//                                                             // const SizedBox(
//                                                             //   height: Dimensions
//                                                             //       .paddingSizeExtraSmall,
//                                                             // ),
//                                                           ],
//                                                         ),
//                                                       )
//                                                     : const SizedBox(),
//                                                 Container(
//                                                   margin: const EdgeInsets.only(
//                                                       top: 8,
//                                                       left: 3,
//                                                       right: 3,
//                                                       bottom: 3),
//                                                   padding: const EdgeInsets
//                                                       .symmetric(
//                                                     horizontal: 6,
//                                                   ),
//                                                   decoration: BoxDecoration(
//                                                     color: Theme.of(context)
//                                                         .cardColor,
//                                                     borderRadius: BorderRadius
//                                                         .circular(Dimensions
//                                                             .paddingSizeDefault),
//                                                   ),
//                                                   child: Column(
//                                                     children: [
//                                                       const SizedBox(
//                                                           height: Dimensions
//                                                               .paddingSizeSmall),
//
//                                                       (widget.item!.nutritionsName !=
//                                                                   null &&
//                                                               widget
//                                                                   .item!
//                                                                   .nutritionsName!
//                                                                   .isNotEmpty)
//                                                           ? Container(
//                                                               color: Theme.of(
//                                                                       context)
//                                                                   .cardColor,
//                                                               child: Column(
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .start,
//                                                                 children: [
//                                                                   Text(
//                                                                       'nutrition_details'
//                                                                           .tr,
//                                                                       style: STCBold.copyWith(
//                                                                           fontSize:
//                                                                               Dimensions.fontSizeLarge)),
//                                                                   const SizedBox(
//                                                                       height: Dimensions
//                                                                           .paddingSizeExtraSmall),
//                                                                   Container(
//                                                                     color: Colors
//                                                                         .white,
//                                                                     child: Wrap(
//                                                                         children: List.generate(
//                                                                             widget.item!.nutritionsName!.length,
//                                                                             (index) {
//                                                                       return Text(
//                                                                         '${widget.item!.nutritionsName![index]}${widget.item!.nutritionsName!.length - 1 == index ? '.' : ', '}',
//                                                                         style: STCRegular.copyWith(
//                                                                             color:
//                                                                                 Theme.of(context).textTheme.bodyLarge!.color?.withAlpha((0.5 * 255).toInt())),
//                                                                       );
//                                                                     })),
//                                                                   ),
//                                                                   const SizedBox(
//                                                                       height: Dimensions
//                                                                           .paddingSizeLarge),
//                                                                 ],
//                                                               ),
//                                                             )
//                                                           : const SizedBox(),
//
//                                                       (widget.item!.allergiesName !=
//                                                                   null &&
//                                                               widget
//                                                                   .item!
//                                                                   .allergiesName!
//                                                                   .isNotEmpty)
//                                                           ? Container(
//                                                               color: Theme.of(
//                                                                       context)
//                                                                   .cardColor,
//                                                               child: Column(
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .start,
//                                                                 children: [
//                                                                   Text(
//                                                                       'allergic_ingredients'
//                                                                           .tr,
//                                                                       style: STCBold.copyWith(
//                                                                           fontSize:
//                                                                               Dimensions.fontSizeLarge)),
//                                                                   const SizedBox(
//                                                                       height: Dimensions
//                                                                           .paddingSizeExtraSmall),
//                                                                   Wrap(
//                                                                       children: List.generate(
//                                                                           widget
//                                                                               .item!
//                                                                               .allergiesName!
//                                                                               .length,
//                                                                           (index) {
//                                                                     return Text(
//                                                                       '${widget.item!.allergiesName![index]}${widget.item!.allergiesName!.length - 1 == index ? '.' : ', '}',
//                                                                       style: STCRegular.copyWith(
//                                                                           color: Theme.of(context)
//                                                                               .textTheme
//                                                                               .bodyLarge!
//                                                                               .color
//                                                                               ?.withAlpha((0.5 * 255).toInt())),
//                                                                     );
//                                                                   })),
//                                                                   const SizedBox(
//                                                                       height: Dimensions
//                                                                           .paddingSizeLarge),
//                                                                 ],
//                                                               ),
//                                                             )
//                                                           : const SizedBox(),
//
//                                                       (widget.item!.genericName !=
//                                                                   null &&
//                                                               widget
//                                                                   .item!
//                                                                   .genericName!
//                                                                   .isNotEmpty)
//                                                           ? Container(
//                                                               color: Theme.of(
//                                                                       context)
//                                                                   .cardColor,
//                                                               child: Column(
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .start,
//                                                                 children: [
//                                                                   Text(
//                                                                       'generic_name'
//                                                                           .tr,
//                                                                       style: STCBold.copyWith(
//                                                                           fontSize:
//                                                                               Dimensions.fontSizeLarge)),
//                                                                   const SizedBox(
//                                                                       height: Dimensions
//                                                                           .paddingSizeExtraSmall),
//                                                                   Wrap(
//                                                                       children: List.generate(
//                                                                           widget
//                                                                               .item!
//                                                                               .genericName!
//                                                                               .length,
//                                                                           (index) {
//                                                                     return Text(
//                                                                       '${widget.item!.genericName![index]}${widget.item!.genericName!.length - 1 == index ? '.' : ', '}',
//                                                                       style: STCRegular.copyWith(
//                                                                           color: Theme.of(context)
//                                                                               .textTheme
//                                                                               .bodyLarge!
//                                                                               .color
//                                                                               ?.withAlpha((0.5 * 255).toInt())),
//                                                                     );
//                                                                   })),
//                                                                   const SizedBox(
//                                                                       height: Dimensions
//                                                                           .paddingSizeLarge),
//                                                                 ],
//                                                               ),
//                                                             )
//                                                           : const SizedBox(),
//
//                                                       // Variation
//                                                       _newVariation
//                                                           ? Container(
//                                                               color: Theme.of(
//                                                                       context)
//                                                                   .cardColor,
//                                                               child:
//                                                                   NewVariationView(
//                                                                 item:
//                                                                     widget.item,
//                                                                 itemController:
//                                                                     itemController,
//                                                                 discount:
//                                                                     initialDiscount,
//                                                                 discountType:
//                                                                     discountType,
//                                                                 showOriginalPrice: (price >
//                                                                         priceWithDiscount) &&
//                                                                     (discountType ==
//                                                                         'percent'),
//                                                               ),
//                                                             )
//                                                           : Container(
//                                                               color: Theme.of(
//                                                                       context)
//                                                                   .cardColor,
//                                                               child:
//                                                                   VariationView(
//                                                                 item:
//                                                                     widget.item,
//                                                                 itemController:
//                                                                     itemController,
//                                                               ),
//                                                             ),
//                                                       SizedBox(
//                                                           height: (Get.find<
//                                                                           SplashController>()
//                                                                       .configModel!
//                                                                       .moduleConfig!
//                                                                       .module!
//                                                                       .addOn! &&
//                                                                   widget
//                                                                       .item!
//                                                                       .addOns!
//                                                                       .isNotEmpty)
//                                                               ? Dimensions
//                                                                   .paddingSizeLarge
//                                                               : 0),
//
//                                                       // Addons
//                                                       (Get.find<SplashController>()
//                                                                   .configModel!
//                                                                   .moduleConfig!
//                                                                   .module!
//                                                                   .addOn! &&
//                                                               widget
//                                                                   .item!
//                                                                   .addOns!
//                                                                   .isNotEmpty)
//                                                           ? Container(
//                                                               color: Theme.of(
//                                                                       context)
//                                                                   .cardColor,
//                                                               child: AddonView(
//                                                                   itemController:
//                                                                       itemController,
//                                                                   item: widget
//                                                                       .item!),
//                                                             )
//                                                           : const SizedBox(),
//
//                                                       isAvailable
//                                                           ? const SizedBox()
//                                                           : Container(
//                                                               alignment:
//                                                                   Alignment
//                                                                       .center,
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .all(
//                                                                       Dimensions
//                                                                           .paddingSizeSmall),
//                                                               margin: const EdgeInsets
//                                                                   .only(
//                                                                   bottom: Dimensions
//                                                                       .paddingSizeSmall),
//                                                               decoration:
//                                                                   BoxDecoration(
//                                                                 borderRadius:
//                                                                     BorderRadius.circular(
//                                                                         Dimensions
//                                                                             .radiusSmall),
//                                                                 color: Theme.of(
//                                                                         context)
//                                                                     .primaryColor
//                                                                     .withAlpha((0.1 *
//                                                                             255)
//                                                                         .toInt()),
//                                                               ),
//                                                               child: Column(
//                                                                   children: [
//                                                                     Text(
//                                                                         'not_available_now'
//                                                                             .tr,
//                                                                         style: STCMedium
//                                                                             .copyWith(
//                                                                           color:
//                                                                               Theme.of(context).primaryColor,
//                                                                           fontSize:
//                                                                               Dimensions.fontSizeLarge,
//                                                                         )),
//                                                                     Text(
//                                                                       '${'available_will_be'.tr} ${DateConverter.convertTimeToTime(widget.item!.availableTimeStarts!)} '
//                                                                       '- ${DateConverter.convertTimeToTime(widget.item!.availableTimeEnds!)}',
//                                                                       style:
//                                                                           STCRegular,
//                                                                     ),
//                                                                   ]),
//                                                             ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ]),
//                                   ]),
//                             ),
//                           ]),
//                     ),
//                   ),
//                 ]),
//               ),
//               Positioned(
//                 top: 10,
//                 left: 10,
//                 child: Container(
//                   margin: const EdgeInsets.only(bottom: 8),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).cardColor,
//                     borderRadius: BorderRadius.circular(
//                       Dimensions.radiusLarge,
//                     ),
//                   ),
//                   child: Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         widget.isCampaign
//                             ? const SizedBox(height: 25)
//                             : GetBuilder<FavouriteController>(
//                                 builder: (wishList) {
//                                 return InkWell(
//                                   onTap: () {
//                                     if (AuthHelper.isLoggedIn()) {
//                                       wishList.wishItemIdList
//                                               .contains(widget.item!.id)
//                                           ? wishList.removeFromFavouriteList(
//                                               widget.item!.id, false,
//                                               getXSnackBar: true)
//                                           : wishList.addToFavouriteList(
//                                               widget.item, null, false,
//                                               getXSnackBar: true);
//                                     } else {
//                                       showCustomSnackBar(
//                                           'you_are_not_logged_in'.tr,
//                                           getXSnackBar: true);
//                                     }
//                                   },
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(
//                                             Dimensions.radiusDefault),
//                                         color: Theme.of(context)
//                                             .primaryColor
//                                             .withAlpha((0.05 * 255).toInt())),
//                                     padding: const EdgeInsets.all(
//                                         Dimensions.paddingSizeSmall),
//                                     // margin:
//                                     //     const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
//                                     child: Icon(
//                                       wishList.wishItemIdList
//                                               .contains(widget.item!.id)
//                                           ? Icons.favorite
//                                           : Icons.favorite_border,
//                                       color: wishList.wishItemIdList
//                                               .contains(widget.item!.id)
//                                           ? Theme.of(context).primaryColor
//                                           : Theme.of(context).primaryColor,
//                                     ),
//                                   ),
//                                 );
//                               }),
//                         // const SizedBox(
//                         //     height: Dimensions
//                         //         .paddingSizeDefault),
//                         widget.item!.isStoreHalalActive! &&
//                                 widget.item!.isHalalItem!
//                             ? Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     vertical: Dimensions.paddingSizeSmall,
//                                     horizontal:
//                                         Dimensions.paddingSizeExtraSmall),
//                                 child: CustomToolTip(
//                                   message: 'this_is_a_halal_food'.tr,
//                                   preferredDirection: AxisDirection.up,
//                                   child: const CustomAssetImageWidget(
//                                       Images.halalTag,
//                                       height: 35,
//                                       width: 35),
//                                 ),
//                               )
//                             : const SizedBox(),
//                       ]),
//                 ),
//               ),
//               Positioned(
//                 top: 10,
//                 right: 10,
//                 child: InkWell(
//                   onTap: () => Get.back(),
//                   child: Container(
//                     padding:
//                         const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).cardColor,
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                             color: Theme.of(context)
//                                 .primaryColor
//                                 .withAlpha((0.3 * 255).toInt()),
//                             blurRadius: 5)
//                       ],
//                     ),
//                     child: const Icon(Icons.close, size: 14),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: 8,
//                 left: 22,
//                 right: 22,
//                 child: Container(
//                   color: Colors.transparent,
//                   padding:
//                       EdgeInsets.symmetric(horizontal: Get.size.width * .08),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Theme.of(context).primaryColor,
//                           padding: const EdgeInsets.symmetric(
//                             vertical: Dimensions.paddingSizeSmall,
//                             horizontal: Dimensions.paddingSizeSmall,
//                           ),
//                         ),
//                         icon: const Icon(
//                           Icons.arrow_back_rounded,
//                           size: 25,
//                           color: Colors.white,
//                         ),
//                         onPressed: () => Get.back(),
//                         label: Text(
//                           "back".tr,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                       // const SizedBox(width: 32),
//                       GetBuilder<CartController>(builder: (cartController) {
//                         return ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Theme.of(context).primaryColor,
//                             padding: const EdgeInsets.symmetric(
//                               vertical: Dimensions.paddingSizeSmall,
//                               horizontal: Dimensions.paddingSizeSmall,
//                             ),
//                           ),
//                           onPressed: (Get.find<SplashController>()
//                                       .configModel!
//                                       .moduleConfig!
//                                       .module!
//                                       .stock! &&
//                                   stock! <= 0)
//                               ? null
//                               : () async {
//                                   String? invalid;
//                                   if (_newVariation) {
//                                     for (int index = 0;
//                                         index <
//                                             widget.item!.foodVariations!.length;
//                                         index++) {
//                                       if (!widget.item!.foodVariations![index]
//                                               .multiSelect! &&
//                                           widget.item!.foodVariations![index]
//                                               .required! &&
//                                           !itemController
//                                               .selectedVariations[index]
//                                               .contains(true)) {
//                                         invalid =
//                                             '${'choose_a_variation_from'.tr} ${widget.item!.foodVariations![index].name}';
//                                         break;
//                                       } else if (widget
//                                               .item!
//                                               .foodVariations![index]
//                                               .multiSelect! &&
//                                           (widget.item!.foodVariations![index]
//                                                   .required! ||
//                                               itemController
//                                                   .selectedVariations[index]
//                                                   .contains(true)) &&
//                                           widget.item!.foodVariations![index]
//                                                   .min! >
//                                               itemController
//                                                   .selectedVariationLength(
//                                                       itemController
//                                                           .selectedVariations,
//                                                       index)) {
//                                         invalid =
//                                             '${'select_minimum'.tr} ${widget.item!.foodVariations![index].min} '
//                                             '${'and_up_to'.tr} ${widget.item!.foodVariations![index].max} ${'options_from'.tr}'
//                                             ' ${widget.item!.foodVariations![index].name} ${'variation'.tr}';
//                                         break;
//                                       }
//                                     }
//                                   }
//
//                                   if (Get.find<SplashController>().moduleList !=
//                                       null) {
//                                     for (ModuleModel module
//                                         in Get.find<SplashController>()
//                                             .moduleList!) {
//                                       if (module.id == widget.item!.moduleId) {
//                                         Get.find<SplashController>()
//                                             .setModule(module);
//                                         break;
//                                       }
//                                     }
//                                   }
//
//                                   if (invalid != null) {
//                                     showCustomSnackBar(invalid,
//                                         getXSnackBar: true);
//                                   } else {
//                                     CartModel cartModel = CartModel(
//                                         null,
//                                         price,
//                                         priceWithDiscountAndAddons,
//                                         variation != null ? [variation] : [],
//                                         itemController.selectedVariations,
//                                         (price! -
//                                             PriceConverter.convertWithDiscount(
//                                                 price,
//                                                 discount,
//                                                 discountType)!),
//                                         itemController.quantity,
//                                         addOnIdList,
//                                         addOnsList,
//                                         widget.isCampaign,
//                                         stock,
//                                         widget.item,
//                                         widget.item?.quantityLimit);
//
//                                     List<OrderVariation> variations =
//                                         _getSelectedVariations(
//                                       isFoodVariation:
//                                           Get.find<SplashController>()
//                                               .getModuleConfig(
//                                                   widget.item!.moduleType)
//                                               .newVariation!,
//                                       foodVariations:
//                                           widget.item!.foodVariations!,
//                                       selectedVariations:
//                                           itemController.selectedVariations,
//                                     );
//                                     List<int?> listOfAddOnId =
//                                         _getSelectedAddonIds(
//                                             addOnIdList: addOnIdList);
//                                     List<int?> listOfAddOnQty =
//                                         _getSelectedAddonQtnList(
//                                             addOnIdList: addOnIdList);
//
//                                     OnlineCart onlineCart = OnlineCart(
//                                       (widget.cart != null ||
//                                               itemController.cartIndex != -1)
//                                           ? widget.cart?.id ??
//                                               cartController
//                                                   .cartList[
//                                                       itemController.cartIndex]
//                                                   .id
//                                           : null,
//                                       widget.isCampaign
//                                           ? null
//                                           : widget.item!.id,
//                                       widget.isCampaign
//                                           ? widget.item!.id
//                                           : null,
//                                       priceWithDiscountAndAddons.toString(),
//                                       '',
//                                       variation != null ? [variation] : null,
//                                       Get.find<SplashController>()
//                                               .getModuleConfig(
//                                                   widget.item!.moduleType)
//                                               .newVariation!
//                                           ? variations
//                                           : null,
//                                       itemController.quantity,
//                                       listOfAddOnId,
//                                       addOnsList,
//                                       listOfAddOnQty,
//                                       'Item',
//                                     );
//
//                                     if (widget.isCampaign) {
//                                       Get.toNamed(
//                                           RouteHelper.getCheckoutRoute(
//                                               'campaign'),
//                                           arguments: CheckoutScreen(
//                                             storeId: null,
//                                             fromCart: false,
//                                             cartList: [cartModel],
//                                           ));
//                                     } else {
//                                       if (Get.find<CartController>()
//                                           .existAnotherStoreItem(
//                                         cartModel.item!.storeId,
//                                         Get.find<SplashController>().module !=
//                                                 null
//                                             ? Get.find<SplashController>()
//                                                 .module!
//                                                 .id
//                                             : Get.find<SplashController>()
//                                                 .cacheModule!
//                                                 .id,
//                                       )) {
//                                         Get.dialog(
//                                             ConfirmationDialog(
//                                               icon: Images.warning,
//                                               title: 'are_you_sure_to_reset'.tr,
//                                               description: Get.find<
//                                                           SplashController>()
//                                                       .configModel!
//                                                       .moduleConfig!
//                                                       .module!
//                                                       .showRestaurantText!
//                                                   ? 'if_you_continue'.tr
//                                                   : 'if_you_continue_without_another_store'
//                                                       .tr,
//                                               onYesPressed: () {
//                                                 Get.back();
//                                                 Get.find<CartController>()
//                                                     .clearCartOnline()
//                                                     .then((success) async {
//                                                   if (success) {
//                                                     await Get.find<
//                                                             CartController>()
//                                                         .addToCartOnline(
//                                                             onlineCart);
//                                                     Get.back();
//                                                     //showCartSnackBar();
//                                                   }
//                                                 });
//                                               },
//                                             ),
//                                             barrierDismissible: false);
//                                       } else {
//                                         if (widget.cart != null ||
//                                             itemController.cartIndex != -1) {
//                                           await Get.find<CartController>()
//                                               .updateCartOnline(onlineCart)
//                                               .then((success) {
//                                             if (success) {
//                                               Get.back();
//                                             }
//                                           });
//                                         } else {
//                                           await Get.find<CartController>()
//                                               .addToCartOnline(onlineCart)
//                                               .then((success) {
//                                             if (success) {
//                                               Get.back();
//                                             }
//                                           });
//                                         }
//
//                                         //showCartSnackBar();
//                                       }
//                                     }
//                                   }
//                                 },
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                   (Get.find<SplashController>()
//                                               .configModel!
//                                               .moduleConfig!
//                                               .module!
//                                               .stock! &&
//                                           stock! <= 0)
//                                       ? 'out_of_stock'.tr
//                                       : widget.isCampaign
//                                           ? 'order_now'.tr
//                                           : (widget.cart != null ||
//                                                   itemController.cartIndex !=
//                                                       -1)
//                                               ? 'update_in_cart'.tr
//                                               : 'add_to_cart'.tr,
//                                   style: TextStyle(
//                                       fontSize: 16, color: Colors.white)),
//                               SizedBox(width: 8),
//                               Icon(
//                                 Icons.turn_right_rounded,
//                                 size: 25,
//                                 color: Colors.white,
//                               ),
//                             ],
//                           ),
//                         );
//                       }),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }
//
//   List<OrderVariation> _getSelectedVariations(
//       {required bool isFoodVariation,
//       required List<FoodVariation>? foodVariations,
//       required List<List<bool?>> selectedVariations}) {
//     List<OrderVariation> variations = [];
//     if (isFoodVariation) {
//       for (int i = 0; i < foodVariations!.length; i++) {
//         if (selectedVariations[i].contains(true)) {
//           variations.add(OrderVariation(
//               name: foodVariations[i].name,
//               values: OrderVariationValue(label: [])));
//           for (int j = 0; j < foodVariations[i].variationValues!.length; j++) {
//             if (selectedVariations[i][j]!) {
//               variations[variations.length - 1]
//                   .values!
//                   .label!
//                   .add(foodVariations[i].variationValues![j].level);
//             }
//           }
//         }
//       }
//     }
//     return variations;
//   }
//
//   List<int?> _getSelectedAddonIds({required List<AddOn> addOnIdList}) {
//     List<int?> listOfAddOnId = [];
//     for (var addOn in addOnIdList) {
//       listOfAddOnId.add(addOn.id);
//     }
//     return listOfAddOnId;
//   }
//
//   List<int?> _getSelectedAddonQtnList({required List<AddOn> addOnIdList}) {
//     List<int?> listOfAddOnQty = [];
//     for (var addOn in addOnIdList) {
//       listOfAddOnQty.add(addOn.quantity);
//     }
//     return listOfAddOnQty;
//   }
// }
//
// class AddonView extends StatelessWidget {
//   final Item item;
//   final ItemController itemController;
//
//   const AddonView(
//       {super.key, required this.item, required this.itemController});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//             Text('addons'.tr, style: STCMedium),
//             Container(
//               decoration: BoxDecoration(
//                 color: Theme.of(context)
//                     .disabledColor
//                     .withAlpha((0.1 * 255).toInt()),
//                 borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//               ),
//               padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//               child: Text(
//                 'optional'.tr,
//                 style: STCRegular.copyWith(
//                     color: Theme.of(context).hintColor,
//                     fontSize: Dimensions.fontSizeSmall),
//               ),
//             ),
//           ]),
//           const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             padding: EdgeInsets.zero,
//             itemCount: item.addOns!.length,
//             itemBuilder: (context, index) {
//               return InkWell(
//                 onTap: () {
//                   if (!itemController.addOnActiveList[index]) {
//                     itemController.addAddOn(true, index);
//                   } else if (itemController.addOnQtyList[index] == 1) {
//                     itemController.addAddOn(false, index);
//                   }
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.only(
//                       bottom: Dimensions.paddingSizeExtraSmall),
//                   child: Row(children: [
//                     Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Checkbox(
//                             value: itemController.addOnActiveList[index],
//                             activeColor: Theme.of(context).primaryColor,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(
//                                     Dimensions.radiusSmall)),
//                             onChanged: (bool? newValue) {
//                               if (!itemController.addOnActiveList[index]) {
//                                 itemController.addAddOn(true, index);
//                               } else if (itemController.addOnQtyList[index] ==
//                                   1) {
//                                 itemController.addAddOn(false, index);
//                               }
//                             },
//                             visualDensity: const VisualDensity(
//                                 horizontal: -3, vertical: -3),
//                             side: BorderSide(
//                                 width: 2, color: Theme.of(context).hintColor),
//                           ),
//                           Text(
//                             item.addOns![index].name!,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: itemController.addOnActiveList[index]
//                                 ? STCMedium
//                                 : STCRegular.copyWith(
//                                     color: Theme.of(context).hintColor),
//                           ),
//                         ]),
//                     const Spacer(),
//                     Text(
//                       item.addOns![index].price! > 0
//                           ? PriceConverter.convertPrice(
//                               item.addOns![index].price)
//                           : 'free'.tr,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       textDirection: TextDirection.ltr,
//                       style: itemController.addOnActiveList[index]
//                           ? STCMedium.copyWith(
//                               fontSize: Dimensions.fontSizeSmall)
//                           : STCRegular.copyWith(
//                               fontSize: Dimensions.fontSizeSmall,
//                               color: Theme.of(context).disabledColor),
//                     ),
//                     itemController.addOnActiveList[index]
//                         ? Container(
//                             height: 25,
//                             width: 90,
//                             decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(
//                                     Dimensions.radiusSmall),
//                                 color: Theme.of(context).cardColor),
//                             child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Expanded(
//                                     child: InkWell(
//                                       onTap: () {
//                                         if (itemController
//                                                 .addOnQtyList[index]! >
//                                             1) {
//                                           itemController.setAddOnQuantity(
//                                               false, index);
//                                         } else {
//                                           itemController.addAddOn(false, index);
//                                         }
//                                       },
//                                       child: Center(
//                                           child: Icon(
//                                         (itemController.addOnQtyList[index]! >
//                                                 1)
//                                             ? Icons.remove
//                                             : Icons.delete_outline_outlined,
//                                         size: 18,
//                                         color: (itemController
//                                                     .addOnQtyList[index]! >
//                                                 1)
//                                             ? Theme.of(context).primaryColor
//                                             : Theme.of(context)
//                                                 .colorScheme
//                                                 .error,
//                                       )),
//                                     ),
//                                   ),
//                                   Text(
//                                     itemController.addOnQtyList[index]
//                                         .toString(),
//                                     style: STCMedium.copyWith(
//                                         fontSize: Dimensions.fontSizeDefault),
//                                   ),
//                                   Expanded(
//                                     child: InkWell(
//                                       onTap: () => itemController
//                                           .setAddOnQuantity(true, index),
//                                       child: Center(
//                                           child: Icon(Icons.add,
//                                               size: 18,
//                                               color: Theme.of(context)
//                                                   .primaryColor)),
//                                     ),
//                                   ),
//                                 ]),
//                           )
//                         : const SizedBox(),
//                   ]),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//         ],
//       ),
//     );
//   }
// }
//
// class VariationView extends StatelessWidget {
//   final Item? item;
//   final ItemController itemController;
//
//   const VariationView(
//       {super.key, required this.item, required this.itemController});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Theme.of(context).cardColor,
//       child: ListView.builder(
//         shrinkWrap: true,
//         itemCount: item!.choiceOptions!.length,
//         physics: const NeverScrollableScrollPhysics(),
//         padding: EdgeInsets.only(
//             bottom: item!.choiceOptions!.isNotEmpty
//                 ? Dimensions.paddingSizeLarge
//                 : 0),
//         itemBuilder: (context, index) {
//           return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(item!.choiceOptions![index].title!, style: STCMedium),
//                 const SizedBox(height: Dimensions.paddingSizeSmall),
//                 Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//                     color: Theme.of(context).cardColor,
//                   ),
//                   padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//                   child: ListView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     padding: EdgeInsets.zero,
//                     itemCount: item!.choiceOptions![index].options!.length,
//                     itemBuilder: (context, i) {
//                       return Padding(
//                         padding: const EdgeInsets.only(
//                             bottom: Dimensions.paddingSizeExtraSmall),
//                         child: InkWell(
//                           onTap: () {
//                             itemController.setCartVariationIndex(
//                                 index, i, item);
//                           },
//                           child: Row(children: [
//                             Expanded(
//                                 child: Text(
//                               item!.choiceOptions![index].options![i].trim(),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: STCRegular,
//                             )),
//                             const SizedBox(width: Dimensions.paddingSizeSmall),
//                             Radio<int>(
//                               value: i,
//                               groupValue: itemController.variationIndex![index],
//                               onChanged: (int? value) => itemController
//                                   .setCartVariationIndex(index, i, item),
//                               materialTapTargetSize:
//                                   MaterialTapTargetSize.shrinkWrap,
//                               activeColor: Theme.of(context).primaryColor,
//                             ),
//                           ]),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 SizedBox(
//                     height: index != item!.choiceOptions!.length - 1
//                         ? Dimensions.paddingSizeLarge
//                         : 0),
//               ]);
//         },
//       ),
//     );
//   }
// }
//
// class NewVariationView extends StatelessWidget {
//   final Item? item;
//   final ItemController itemController;
//   final double? discount;
//   final String? discountType;
//   final bool showOriginalPrice;
//
//   const NewVariationView(
//       {super.key,
//       required this.item,
//       required this.itemController,
//       required this.discount,
//       required this.discountType,
//       required this.showOriginalPrice});
//
//   @override
//   Widget build(BuildContext context) {
//     return item!.foodVariations != null
//         ? Container(
//             color: Theme.of(context).cardColor,
//             child: ListView.builder(
//               shrinkWrap: true,
//               itemCount: item!.foodVariations!.length,
//               physics: const NeverScrollableScrollPhysics(),
//               padding: EdgeInsets.only(
//                   bottom: (item!.foodVariations != null &&
//                           item!.foodVariations!.isNotEmpty)
//                       ? Dimensions.paddingSizeLarge
//                       : 0),
//               itemBuilder: (context, index) {
//                 int selectedCount = 0;
//                 if (item!.foodVariations![index].required!) {
//                   for (var value in itemController.selectedVariations[index]) {
//                     if (value == true) {
//                       selectedCount++;
//                     }
//                   }
//                 }
//                 return Container(
//                   padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//                   margin: EdgeInsets.only(
//                       bottom: index != item!.foodVariations!.length - 1
//                           ? Dimensions.paddingSizeLarge
//                           : 0),
//                   decoration: BoxDecoration(
//                       color: itemController.selectedVariations[index]
//                               .contains(true)
//                           ? Theme.of(context)
//                               .primaryColor
//                               .withAlpha((0.01 * 255).toInt())
//                           : Theme.of(context)
//                               .disabledColor
//                               .withAlpha((0.05 * 255).toInt()),
//                       border: Border.all(
//                           color: itemController.selectedVariations[index]
//                                   .contains(true)
//                               ? Theme.of(context).primaryColor
//                               : Theme.of(context).disabledColor,
//                           width: 0.5),
//                       borderRadius:
//                           BorderRadius.circular(Dimensions.radiusDefault)),
//                   child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text(item!.foodVariations![index].name!,
//                                   style: STCMedium.copyWith(
//                                       fontSize: Dimensions.fontSizeLarge)),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: item!.foodVariations![index]
//                                               .required! &&
//                                           (item!.foodVariations![index]
//                                                       .multiSelect!
//                                                   ? item!.foodVariations![index]
//                                                       .min!
//                                                   : 1) >
//                                               selectedCount
//                                       ? Theme.of(context)
//                                           .colorScheme
//                                           .error
//                                           .withAlpha((0.1 * 255).toInt())
//                                       : Theme.of(context)
//                                           .disabledColor
//                                           .withAlpha((0.1 * 255).toInt()),
//                                   borderRadius: BorderRadius.circular(
//                                       Dimensions.radiusSmall),
//                                 ),
//                                 padding: const EdgeInsets.all(
//                                     Dimensions.paddingSizeExtraSmall),
//                                 child: Text(
//                                   item!.foodVariations![index].required!
//                                       ? (item!.foodVariations![index]
//                                                       .multiSelect!
//                                                   ? item!.foodVariations![index]
//                                                       .min!
//                                                   : 1) <=
//                                               selectedCount
//                                           ? 'completed'.tr
//                                           : 'required'.tr
//                                       : 'optional'.tr,
//                                   style: STCRegular.copyWith(
//                                     color: item!
//                                             .foodVariations![index].required!
//                                         ? (item!.foodVariations![index]
//                                                         .multiSelect!
//                                                     ? item!
//                                                         .foodVariations![index]
//                                                         .min!
//                                                     : 1) <=
//                                                 selectedCount
//                                             ? Theme.of(context).hintColor
//                                             : Theme.of(context)
//                                                 .colorScheme
//                                                 .error
//                                         : Theme.of(context).hintColor,
//                                     fontSize: Dimensions.fontSizeSmall,
//                                   ),
//                                 ),
//                               ),
//                             ]),
//                         const SizedBox(
//                             height: Dimensions.paddingSizeExtraSmall),
//                         item!.foodVariations![index].multiSelect!
//                             ? Text(
//                                 '${'select_minimum'.tr} ${'${item!.foodVariations![index].min}'
//                                     ' ${'and_up_to'.tr} ${item!.foodVariations![index].max} ${'options'.tr}'}',
//                                 style: STCMedium.copyWith(
//                                     fontSize: Dimensions.fontSizeExtraSmall,
//                                     color: Theme.of(context).disabledColor),
//                               )
//                             : Text(
//                                 'select_one'.tr,
//                                 style: STCMedium.copyWith(
//                                     fontSize: Dimensions.fontSizeExtraSmall,
//                                     color: Theme.of(context).primaryColor),
//                               ),
//                         SizedBox(
//                             height: item!.foodVariations![index].multiSelect!
//                                 ? Dimensions.paddingSizeExtraSmall
//                                 : 0),
//                         ListView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           padding: EdgeInsets.zero,
//                           itemCount: itemController.collapseVariation[index]
//                               ? item!.foodVariations![index].variationValues!
//                                           .length >
//                                       4
//                                   ? 5
//                                   : item!.foodVariations![index]
//                                       .variationValues!.length
//                               : item!.foodVariations![index].variationValues!
//                                   .length,
//                           itemBuilder: (context, i) {
//                             if (i == 4 &&
//                                 itemController.collapseVariation[index]) {
//                               return Padding(
//                                 padding: const EdgeInsets.all(
//                                     Dimensions.paddingSizeExtraSmall),
//                                 child: InkWell(
//                                   onTap: () => itemController
//                                       .showMoreSpecificSection(index),
//                                   child: Row(children: [
//                                     Icon(Icons.expand_more,
//                                         size: 18,
//                                         color: Theme.of(context).primaryColor),
//                                     const SizedBox(
//                                         width:
//                                             Dimensions.paddingSizeExtraSmall),
//                                     Text(
//                                       '${'view'.tr} ${item!.foodVariations![index].variationValues!.length - 4} ${'more_option'.tr}',
//                                       style: STCMedium.copyWith(
//                                           color:
//                                               Theme.of(context).primaryColor),
//                                     ),
//                                   ]),
//                                 ),
//                               );
//                             } else {
//                               return Padding(
//                                 padding: EdgeInsets.symmetric(
//                                     vertical:
//                                         ResponsiveHelper.isDesktop(context)
//                                             ? Dimensions.paddingSizeExtraSmall
//                                             : 0),
//                                 child: InkWell(
//                                   onTap: () {
//                                     itemController.setNewCartVariationIndex(
//                                         index, i, item!);
//                                   },
//                                   child: Row(children: [
//                                     Row(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.center,
//                                         children: [
//                                           item!.foodVariations![index]
//                                                   .multiSelect!
//                                               ? Checkbox(
//                                                   value: itemController
//                                                           .selectedVariations[
//                                                       index][i],
//                                                   activeColor: Theme.of(context)
//                                                       .primaryColor,
//                                                   shape: RoundedRectangleBorder(
//                                                       borderRadius: BorderRadius
//                                                           .circular(Dimensions
//                                                               .radiusSmall)),
//                                                   onChanged: (bool? newValue) {
//                                                     itemController
//                                                         .setNewCartVariationIndex(
//                                                             index, i, item!);
//                                                   },
//                                                   visualDensity:
//                                                       const VisualDensity(
//                                                           horizontal: -3,
//                                                           vertical: -3),
//                                                   side: BorderSide(
//                                                       width: 2,
//                                                       color: Theme.of(context)
//                                                           .hintColor),
//                                                 )
//                                               : Radio(
//                                                   value: i,
//                                                   groupValue: itemController
//                                                       .selectedVariations[index]
//                                                       .indexOf(true),
//                                                   onChanged: (dynamic value) {
//                                                     itemController
//                                                         .setNewCartVariationIndex(
//                                                             index, i, item!);
//                                                   },
//                                                   activeColor: Theme.of(context)
//                                                       .primaryColor,
//                                                   toggleable: false,
//                                                   visualDensity:
//                                                       const VisualDensity(
//                                                           horizontal: -3,
//                                                           vertical: -3),
//                                                 ),
//                                           Text(
//                                             item!.foodVariations![index]
//                                                 .variationValues![i].level!
//                                                 .trim(),
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: itemController
//                                                         .selectedVariations[
//                                                     index][i]!
//                                                 ? STCMedium
//                                                 : STCRegular.copyWith(
//                                                     color: Theme.of(context)
//                                                         .hintColor),
//                                           ),
//                                         ]),
//                                     const Spacer(),
//                                     showOriginalPrice
//                                         ? Text(
//                                             '+${PriceConverter.convertPrice(item!.foodVariations![index].variationValues![i].optionPrice)}',
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                             textDirection: TextDirection.ltr,
//                                             style: STCRegular.copyWith(
//                                                 fontSize: Dimensions
//                                                     .fontSizeExtraSmall,
//                                                 color: Theme.of(context)
//                                                     .disabledColor,
//                                                 decoration:
//                                                     TextDecoration.lineThrough),
//                                           )
//                                         : const SizedBox(),
//                                     SizedBox(
//                                         width: showOriginalPrice
//                                             ? Dimensions.paddingSizeExtraSmall
//                                             : 0),
//                                     Text(
//                                       '+${PriceConverter.convertPrice(item!.foodVariations![index].variationValues![i].optionPrice, discount: discount, discountType: discountType, isFoodVariation: true)}',
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       textDirection: TextDirection.ltr,
//                                       style: itemController
//                                               .selectedVariations[index][i]!
//                                           ? STCMedium.copyWith(
//                                               fontSize:
//                                                   Dimensions.fontSizeExtraSmall)
//                                           : STCRegular.copyWith(
//                                               fontSize:
//                                                   Dimensions.fontSizeExtraSmall,
//                                               color: Theme.of(context)
//                                                   .disabledColor),
//                                     ),
//                                   ]),
//                                 ),
//                               );
//                             }
//                           },
//                         ),
//                       ]),
//                 );
//               },
//             ),
//           )
//         : const SizedBox();
//   }
// }

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

// import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
// import 'package:sixam_mart/common/widgets/custom_tool_tip_widget.dart';
// import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
// import 'package:sixam_mart/features/item/controllers/item_controller.dart';
// import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
// import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
// import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
// import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
// import 'package:sixam_mart/features/item/domain/models/item_model.dart';
// import 'package:sixam_mart/common/models/module_model.dart';
// import 'package:sixam_mart/helper/auth_helper.dart';
// import 'package:sixam_mart/helper/date_converter.dart';
// import 'package:sixam_mart/helper/price_converter.dart';
// import 'package:sixam_mart/helper/responsive_helper.dart';
// import 'package:sixam_mart/helper/route_helper.dart';
// import 'package:sixam_mart/util/dimensions.dart';
// import 'package:sixam_mart/util/images.dart';
// import 'package:sixam_mart/util/styles.dart';
// import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
// import 'package:sixam_mart/common/widgets/custom_button.dart';
// import 'package:sixam_mart/common/widgets/custom_image.dart';
// import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
// import 'package:sixam_mart/common/widgets/discount_tag.dart';
// import 'package:sixam_mart/common/widgets/quantity_button.dart';
// import 'package:sixam_mart/common/widgets/rating_bar.dart';
// import 'package:sixam_mart/features/checkout/screens/checkout_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class ItemBottomSheet extends StatefulWidget {
//   final Item? item;
//   final bool isCampaign;
//   final CartModel? cart;
//   final int? cartIndex;
//   final bool inStorePage;
//   const ItemBottomSheet(
//       {super.key,
//       required this.item,
//       this.isCampaign = false,
//       this.cart,
//       this.cartIndex,
//       this.inStorePage = false});
//
//   @override
//   State<ItemBottomSheet> createState() => _ItemBottomSheetState();
// }
//
// class _ItemBottomSheetState extends State<ItemBottomSheet> {
//   bool _newVariation = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (Get.find<SplashController>().module == null) {
//       if (Get.find<SplashController>().cacheModule != null) {
//         Get.find<SplashController>()
//             .setCacheConfigModule(Get.find<SplashController>().cacheModule);
//       }
//     }
//     _newVariation = Get.find<SplashController>()
//             .getModuleConfig(widget.item!.moduleType)
//             .newVariation ??
//         false;
//     Get.find<ItemController>().initData(widget.item, widget.cart);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 550,
//       margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: GetPlatform.isWeb
//             ? const BorderRadius.all(Radius.circular(Dimensions.radiusDefault))
//             : const BorderRadius.vertical(
//                 top: Radius.circular(Dimensions.radiusExtraLarge)),
//       ),
//       child: GetBuilder<ItemController>(builder: (itemController) {
//         double? startingPrice;
//         double? endingPrice;
//         if (widget.item!.choiceOptions!.isNotEmpty &&
//             widget.item!.foodVariations!.isEmpty &&
//             !_newVariation) {
//           List<double?> priceList = [];
//           for (var variation in widget.item!.variations!) {
//             priceList.add(variation.price);
//           }
//           priceList.sort((a, b) => a!.compareTo(b!));
//           startingPrice = priceList[0];
//           if (priceList[0]! < priceList[priceList.length - 1]!) {
//             endingPrice = priceList[priceList.length - 1];
//           }
//         } else {
//           startingPrice = widget.item!.price;
//         }
//
//         double? price = widget.item!.price;
//         double variationPrice = 0;
//         Variation? variation;
//         double? initialDiscount =
//             (widget.isCampaign || widget.item!.storeDiscount == 0)
//                 ? widget.item!.discount
//                 : widget.item!.storeDiscount;
//         double? discount =
//             (widget.isCampaign || widget.item!.storeDiscount == 0)
//                 ? widget.item!.discount
//                 : widget.item!.storeDiscount;
//         String? discountType =
//             (widget.isCampaign || widget.item!.storeDiscount == 0)
//                 ? widget.item!.discountType
//                 : 'percent';
//         int? stock = widget.item!.stock ?? 0;
//
//         if (discountType == 'amount') {
//           discount = discount! * itemController.quantity!;
//         }
//
//         if (_newVariation) {
//           for (int index = 0;
//               index < widget.item!.foodVariations!.length;
//               index++) {
//             for (int i = 0;
//                 i < widget.item!.foodVariations![index].variationValues!.length;
//                 i++) {
//               if (itemController.selectedVariations[index][i]!) {
//                 variationPrice += widget.item!.foodVariations![index]
//                     .variationValues![i].optionPrice!;
//               }
//             }
//           }
//         } else {
//           List<String> variationList = [];
//           for (int index = 0;
//               index < widget.item!.choiceOptions!.length;
//               index++) {
//             variationList.add(widget.item!.choiceOptions![index]
//                 .options![itemController.variationIndex![index]]
//                 .replaceAll(' ', ''));
//           }
//           String variationType = '';
//           bool isFirst = true;
//           for (var variation in variationList) {
//             if (isFirst) {
//               variationType = '$variationType$variation';
//               isFirst = false;
//             } else {
//               variationType = '$variationType-$variation';
//             }
//           }
//
//           for (Variation variations in widget.item!.variations!) {
//             if (variations.type == variationType) {
//               price = variations.price;
//               variation = variations;
//               stock = variations.stock;
//               break;
//             }
//           }
//         }
//
//         price = price! + variationPrice;
//         double priceWithDiscount =
//             PriceConverter.convertWithDiscount(price, discount, discountType)!;
//         double addonsCost = 0;
//         List<AddOn> addOnIdList = [];
//         List<AddOns> addOnsList = [];
//         for (int index = 0; index < widget.item!.addOns!.length; index++) {
//           if (itemController.addOnActiveList[index]) {
//             addonsCost = addonsCost +
//                 (widget.item!.addOns![index].price! *
//                     itemController.addOnQtyList[index]!);
//             addOnIdList.add(AddOn(
//                 id: widget.item!.addOns![index].id,
//                 quantity: itemController.addOnQtyList[index]));
//             addOnsList.add(widget.item!.addOns![index]);
//           }
//         }
//         priceWithDiscount = priceWithDiscount;
//         double? priceWithDiscountAndAddons = priceWithDiscount + addonsCost;
//         bool isAvailable = DateConverter.isAvailable(
//             widget.item!.availableTimeStarts, widget.item!.availableTimeEnds);
//
//         return ConstrainedBox(
//           constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.9),
//           child: Stack(
//             children: [
//               Column(mainAxisSize: MainAxisSize.min, children: [
//                 const SizedBox(height: Dimensions.paddingSizeLarge),
//
//                 Flexible(
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.only(
//                         left: Dimensions.paddingSizeDefault,
//                         bottom: Dimensions.paddingSizeDefault),
//                     child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Padding(
//                             padding: EdgeInsets.only(
//                               right: Dimensions.paddingSizeDefault,
//                               top: ResponsiveHelper.isDesktop(context)
//                                   ? 0
//                                   : Dimensions.paddingSizeDefault,
//                             ),
//                             child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   //Product
//                                   Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         InkWell(
//                                           onTap: widget.isCampaign
//                                               ? null
//                                               : () {
//                                                   if (!widget.isCampaign) {
//                                                     Get.toNamed(RouteHelper
//                                                         .getItemImagesRoute(
//                                                             widget.item!));
//                                                   }
//                                                 },
//                                           child: Stack(children: [
//                                             ClipRRect(
//                                               borderRadius:
//                                                   BorderRadius.circular(
//                                                       Dimensions.radiusSmall),
//                                               child: CustomImage(
//                                                 image:
//                                                     '${widget.item!.imageFullUrl}',
//                                                 width:
//                                                     ResponsiveHelper.isMobile(
//                                                             context)
//                                                         ? 100
//                                                         : 140,
//                                                 height:
//                                                     ResponsiveHelper.isMobile(
//                                                             context)
//                                                         ? 100
//                                                         : 140,
//                                                 fit: BoxFit.cover,
//                                               ),
//                                             ),
//                                             DiscountTag(
//                                                 discount: initialDiscount,
//                                                 discountType: discountType,
//                                                 fromTop: 20),
//                                           ]),
//                                         ),
//                                         const SizedBox(width: 10),
//                                         Expanded(
//                                           child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   widget.item!.name!,
//                                                   style: STCMedium.copyWith(
//                                                       fontSize: Dimensions
//                                                           .fontSizeLarge),
//                                                   maxLines: 2,
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                                 InkWell(
//                                                   onTap: () {
//                                                     if (widget.inStorePage) {
//                                                       Get.back();
//                                                     } else {
//                                                       Get.back();
//                                                       Get.find<CartController>()
//                                                           .forcefullySetModule(
//                                                               widget.item!
//                                                                   .moduleId!);
//                                                       Get.toNamed(
//                                                         RouteHelper
//                                                             .getStoreRoute(
//                                                                 id: widget.item!
//                                                                     .storeId,
//                                                                 page: 'item'),
//                                                       );
//                                                       Get.offNamed(RouteHelper
//                                                           .getStoreRoute(
//                                                               id: widget.item!
//                                                                   .storeId,
//                                                               page: 'item'));
//                                                     }
//                                                   },
//                                                   child: Padding(
//                                                     padding: const EdgeInsets
//                                                         .fromLTRB(0, 5, 5, 5),
//                                                     child: Text(
//                                                       widget.item!.storeName!,
//                                                       style: STCRegular.copyWith(
//                                                           fontSize: Dimensions
//                                                               .fontSizeSmall,
//                                                           color: Theme.of(
//                                                                   context)
//                                                               .primaryColor),
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 !widget.isCampaign
//                                                     ? RatingBar(
//                                                         rating: widget
//                                                             .item!.avgRating,
//                                                         size: 15,
//                                                         ratingCount: widget
//                                                             .item!.ratingCount)
//                                                     : const SizedBox(),
//                                                 Text(
//                                                   '${PriceConverter.convertPrice(startingPrice, discount: initialDiscount, discountType: discountType)}'
//                                                   '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice, discount: initialDiscount, discountType: discountType)}' : ''}',
//                                                   style: STCMedium.copyWith(
//                                                       fontSize: Dimensions
//                                                           .fontSizeLarge),
//                                                   textDirection:
//                                                       TextDirection.ltr,
//                                                 ),
//                                                 price > priceWithDiscount
//                                                     ? Text(
//                                                         '${PriceConverter.convertPrice(startingPrice)}'
//                                                         '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice)}' : ''}',
//                                                         textDirection:
//                                                             TextDirection.ltr,
//                                                         style: STCMedium.copyWith(
//                                                             color: Theme.of(
//                                                                     context)
//                                                                 .disabledColor,
//                                                             decoration:
//                                                                 TextDecoration
//                                                                     .lineThrough),
//                                                       )
//                                                     : const SizedBox(),
//                                               ]),
//                                         ),
//                                         Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.end,
//                                             children: [
//                                               widget.isCampaign
//                                                   ? const SizedBox(height: 25)
//                                                   : GetBuilder<
//                                                           FavouriteController>(
//                                                       builder: (wishList) {
//                                                       return InkWell(
//                                                         onTap: () {
//                                                           if (AuthHelper
//                                                               .isLoggedIn()) {
//                                                             wishList.wishItemIdList
//                                                                     .contains(
//                                                                         widget
//                                                                             .item!
//                                                                             .id)
//                                                                 ? wishList.removeFromFavouriteList(
//                                                                     widget.item!
//                                                                         .id,
//                                                                     false,
//                                                                     getXSnackBar:
//                                                                         true)
//                                                                 : wishList.addToFavouriteList(
//                                                                     widget.item,
//                                                                     null,
//                                                                     false,
//                                                                     getXSnackBar:
//                                                                         true);
//                                                           } else {
//                                                             showCustomSnackBar(
//                                                                 'you_are_not_logged_in'
//                                                                     .tr,
//                                                                 getXSnackBar:
//                                                                     true);
//                                                           }
//                                                         },
//                                                         child: Container(
//                                                           decoration: BoxDecoration(
//                                                               borderRadius:
//                                                                   BorderRadius.circular(
//                                                                       Dimensions
//                                                                           .radiusDefault),
//                                                               color: Theme.of(
//                                                                       context)
//                                                                   .primaryColor
//                                                                   .withAlpha((0.05 * 255).toInt())),
//                                                           padding: const EdgeInsets
//                                                               .all(Dimensions
//                                                                   .paddingSizeSmall),
//                                                           margin: const EdgeInsets
//                                                               .only(
//                                                               top: Dimensions
//                                                                   .paddingSizeSmall),
//                                                           child: Icon(
//                                                             wishList.wishItemIdList
//                                                                     .contains(
//                                                                         widget
//                                                                             .item!
//                                                                             .id)
//                                                                 ? Icons.favorite
//                                                                 : Icons
//                                                                     .favorite_border,
//                                                             color: wishList
//                                                                     .wishItemIdList
//                                                                     .contains(
//                                                                         widget
//                                                                             .item!
//                                                                             .id)
//                                                                 ? Theme.of(
//                                                                         context)
//                                                                     .primaryColor
//                                                                 : Theme.of(
//                                                                         context)
//                                                                     .disabledColor,
//                                                           ),
//                                                         ),
//                                                       );
//                                                     }),
//                                               const SizedBox(
//                                                   height: Dimensions
//                                                       .paddingSizeDefault),
//                                               widget.item!.isStoreHalalActive! &&
//                                                       widget.item!.isHalalItem!
//                                                   ? Padding(
//                                                       padding: const EdgeInsets
//                                                           .symmetric(
//                                                           vertical: Dimensions
//                                                               .paddingSizeSmall,
//                                                           horizontal: Dimensions
//                                                               .paddingSizeExtraSmall),
//                                                       child: CustomToolTip(
//                                                         message:
//                                                             'this_is_a_halal_food'
//                                                                 .tr,
//                                                         preferredDirection:
//                                                             AxisDirection.up,
//                                                         child:
//                                                             const CustomAssetImageWidget(
//                                                                 Images.halalTag,
//                                                                 height: 35,
//                                                                 width: 35),
//                                                       ),
//                                                     )
//                                                   : const SizedBox(),
//                                             ]),
//                                       ]),
//
//                                   const SizedBox(
//                                       height: Dimensions.paddingSizeLarge),
//
//                                   (widget.item!.description != null &&
//                                           widget.item!.description!.isNotEmpty)
//                                       ? Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   Text('description'.tr,
//                                                       style: STCBold.copyWith(
//                                                           fontSize: Dimensions
//                                                               .fontSizeLarge)),
//                                                   ((Get.find<SplashController>()
//                                                                   .configModel!
//                                                                   .moduleConfig!
//                                                                   .module!
//                                                                   .unit! &&
//                                                               widget.item!
//                                                                       .unitType !=
//                                                                   null) ||
//                                                           (Get.find<SplashController>()
//                                                                   .configModel!
//                                                                   .moduleConfig!
//                                                                   .module!
//                                                                   .vegNonVeg! &&
//                                                               Get.find<
//                                                                       SplashController>()
//                                                                   .configModel!
//                                                                   .toggleVegNonVeg!))
//                                                       ? Container(
//                                                           padding: const EdgeInsets
//                                                               .symmetric(
//                                                               vertical: Dimensions
//                                                                   .paddingSizeExtraSmall,
//                                                               horizontal: Dimensions
//                                                                   .paddingSizeSmall),
//                                                           decoration: BoxDecoration(
//                                                               borderRadius:
//                                                                   BorderRadius.circular(
//                                                                       Dimensions
//                                                                           .radiusExtraLarge),
//                                                               color: Theme.of(
//                                                                       context)
//                                                                   .cardColor,
//                                                               boxShadow: [
//                                                                 BoxShadow(
//                                                                     color: Theme.of(
//                                                                             context)
//                                                                         .primaryColor
//                                                                         .withAlpha((0.2 * 255).toInt()),
//                                                                     blurRadius:
//                                                                         5)
//                                                               ]),
//                                                           child: Get.find<
//                                                                       SplashController>()
//                                                                   .configModel!
//                                                                   .moduleConfig!
//                                                                   .module!
//                                                                   .unit!
//                                                               ? Text(
//                                                                   widget.item!
//                                                                           .unitType ??
//                                                                       '',
//                                                                   style: STCMedium.copyWith(
//                                                                       fontSize:
//                                                                           Dimensions
//                                                                               .fontSizeExtraSmall,
//                                                                       color: Theme.of(
//                                                                               context)
//                                                                           .primaryColor),
//                                                                 )
//                                                               : Row(children: [
//                                                                   Image.asset(
//                                                                       widget.item!.veg == 1
//                                                                           ? Images
//                                                                               .vegLogo
//                                                                           : Images
//                                                                               .nonVegLogo,
//                                                                       height:
//                                                                           20,
//                                                                       width:
//                                                                           20),
//                                                                   const SizedBox(
//                                                                       width: Dimensions
//                                                                           .paddingSizeSmall),
//                                                                   Text(
//                                                                       widget.item!.veg == 1
//                                                                           ? 'veg'
//                                                                               .tr
//                                                                           : 'non_veg'
//                                                                               .tr,
//                                                                       style: STCMedium.copyWith(
//                                                                           fontSize:
//                                                                               Dimensions.fontSizeDefault)),
//                                                                 ]),
//                                                         )
//                                                       : const SizedBox(),
//                                                 ]),
//                                             const SizedBox(
//                                                 height: Dimensions
//                                                     .paddingSizeExtraSmall),
//                                             Text(widget.item!.description!,
//                                                 style: STCRegular.copyWith(
//                                                     color: Theme.of(context)
//                                                         .textTheme
//                                                         .bodyLarge!
//                                                         .color
//                                                         ?.withAlpha((0.5 * 255).toInt()))),
//                                             const SizedBox(
//                                                 height: Dimensions
//                                                     .paddingSizeLarge),
//                                           ],
//                                         )
//                                       : const SizedBox(),
//
//                                   (widget.item!.nutritionsName != null &&
//                                           widget
//                                               .item!.nutritionsName!.isNotEmpty)
//                                       ? Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text('nutrition_details'.tr,
//                                                 style: STCBold.copyWith(
//                                                     fontSize: Dimensions
//                                                         .fontSizeLarge)),
//                                             const SizedBox(
//                                                 height: Dimensions
//                                                     .paddingSizeExtraSmall),
//                                             Wrap(
//                                                 children: List.generate(
//                                                     widget.item!.nutritionsName!
//                                                         .length, (index) {
//                                               return Text(
//                                                 '${widget.item!.nutritionsName![index]}${widget.item!.nutritionsName!.length - 1 == index ? '.' : ', '}',
//                                                 style: STCRegular.copyWith(
//                                                     color: Theme.of(context)
//                                                         .textTheme
//                                                         .bodyLarge!
//                                                         .color
//                                                         ?.withAlpha((0.5 * 255).toInt())),
//                                               );
//                                             })),
//                                             const SizedBox(
//                                                 height: Dimensions
//                                                     .paddingSizeLarge),
//                                           ],
//                                         )
//                                       : const SizedBox(),
//
//                                   (widget.item!.allergiesName != null &&
//                                           widget
//                                               .item!.allergiesName!.isNotEmpty)
//                                       ? Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text('allergic_ingredients'.tr,
//                                                 style: STCBold.copyWith(
//                                                     fontSize: Dimensions
//                                                         .fontSizeLarge)),
//                                             const SizedBox(
//                                                 height: Dimensions
//                                                     .paddingSizeExtraSmall),
//                                             Wrap(
//                                                 children: List.generate(
//                                                     widget.item!.allergiesName!
//                                                         .length, (index) {
//                                               return Text(
//                                                 '${widget.item!.allergiesName![index]}${widget.item!.allergiesName!.length - 1 == index ? '.' : ', '}',
//                                                 style: STCRegular.copyWith(
//                                                     color: Theme.of(context)
//                                                         .textTheme
//                                                         .bodyLarge!
//                                                         .color
//                                                         ?.withAlpha((0.5 * 255).toInt())),
//                                               );
//                                             })),
//                                             const SizedBox(
//                                                 height: Dimensions
//                                                     .paddingSizeLarge),
//                                           ],
//                                         )
//                                       : const SizedBox(),
//
//                                   (widget.item!.genericName != null &&
//                                           widget.item!.genericName!.isNotEmpty)
//                                       ? Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text('generic_name'.tr,
//                                                 style: STCBold.copyWith(
//                                                     fontSize: Dimensions
//                                                         .fontSizeLarge)),
//                                             const SizedBox(
//                                                 height: Dimensions
//                                                     .paddingSizeExtraSmall),
//                                             Wrap(
//                                                 children: List.generate(
//                                                     widget.item!.genericName!
//                                                         .length, (index) {
//                                               return Text(
//                                                 '${widget.item!.genericName![index]}${widget.item!.genericName!.length - 1 == index ? '.' : ', '}',
//                                                 style: STCRegular.copyWith(
//                                                     color: Theme.of(context)
//                                                         .textTheme
//                                                         .bodyLarge!
//                                                         .color
//                                                         ?.withAlpha((0.5 * 255).toInt())),
//                                               );
//                                             })),
//                                             const SizedBox(
//                                                 height: Dimensions
//                                                     .paddingSizeLarge),
//                                           ],
//                                         )
//                                       : const SizedBox(),
//
//                                   // Variation
//                                   _newVariation
//                                       ? NewVariationView(
//                                           item: widget.item,
//                                           itemController: itemController,
//                                           discount: initialDiscount,
//                                           discountType: discountType,
//                                           showOriginalPrice:
//                                               (price > priceWithDiscount) &&
//                                                   (discountType == 'percent'),
//                                         )
//                                       : VariationView(
//                                           item: widget.item,
//                                           itemController: itemController,
//                                         ),
//                                   SizedBox(
//                                       height: (Get.find<SplashController>()
//                                                   .configModel!
//                                                   .moduleConfig!
//                                                   .module!
//                                                   .addOn! &&
//                                               widget.item!.addOns!.isNotEmpty)
//                                           ? Dimensions.paddingSizeLarge
//                                           : 0),
//
//                                   // Addons
//                                   (Get.find<SplashController>()
//                                               .configModel!
//                                               .moduleConfig!
//                                               .module!
//                                               .addOn! &&
//                                           widget.item!.addOns!.isNotEmpty)
//                                       ? AddonView(
//                                           itemController: itemController,
//                                           item: widget.item!)
//                                       : const SizedBox(),
//
//                                   isAvailable
//                                       ? const SizedBox()
//                                       : Container(
//                                           alignment: Alignment.center,
//                                           padding: const EdgeInsets.all(
//                                               Dimensions.paddingSizeSmall),
//                                           margin: const EdgeInsets.only(
//                                               bottom:
//                                                   Dimensions.paddingSizeSmall),
//                                           decoration: BoxDecoration(
//                                             borderRadius: BorderRadius.circular(
//                                                 Dimensions.radiusSmall),
//                                             color: Theme.of(context)
//                                                 .primaryColor
//                                                 .withAlpha((0.1 * 255).toInt()),
//                                           ),
//                                           child: Column(children: [
//                                             Text('not_available_now'.tr,
//                                                 style: STCMedium.copyWith(
//                                                   color: Theme.of(context)
//                                                       .primaryColor,
//                                                   fontSize:
//                                                       Dimensions.fontSizeLarge,
//                                                 )),
//                                             Text(
//                                               '${'available_will_be'.tr} ${DateConverter.convertTimeToTime(widget.item!.availableTimeStarts!)} '
//                                               '- ${DateConverter.convertTimeToTime(widget.item!.availableTimeEnds!)}',
//                                               style: STCRegular,
//                                             ),
//                                           ]),
//                                         ),
//                                 ]),
//                           ),
//                         ]),
//                   ),
//                 ),
//
//                 ///Bottom side..
//                 (!widget.item!.scheduleOrder! && !isAvailable)
//                     ? const SizedBox()
//                     : Container(
//                         decoration: BoxDecoration(
//                           color: Theme.of(context).cardColor,
//                           borderRadius: GetPlatform.isWeb
//                               ? const BorderRadius.only(
//                                   bottomLeft: Radius.circular(20),
//                                   bottomRight: Radius.circular(40))
//                               : const BorderRadius.all(Radius.circular(0)),
//                           boxShadow: ResponsiveHelper.isDesktop(context)
//                               ? null
//                               : const [
//                                   BoxShadow(
//                                       color: Colors.black12,
//                                       blurRadius: 5,
//                                       spreadRadius: 1)
//                                 ],
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: Dimensions.paddingSizeDefault,
//                             vertical: Dimensions.paddingSizeDefault),
//                         child: Column(children: [
//                           Builder(builder: (context) {
//                             double? cost = PriceConverter.convertWithDiscount(
//                                 (price! * itemController.quantity!),
//                                 discount,
//                                 discountType);
//                             double withAddonCost = cost! + addonsCost;
//                             return Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text('${'total_amount'.tr}:',
//                                       style: STCMedium.copyWith(
//                                           fontSize: Dimensions.fontSizeDefault,
//                                           color:
//                                               Theme.of(context).primaryColor)),
//                                   const SizedBox(
//                                       width: Dimensions.paddingSizeExtraSmall),
//                                   Row(children: [
//                                     discount! > 0
//                                         ? PriceConverter.convertAnimationPrice(
//                                             (price * itemController.quantity!) +
//                                                 addonsCost,
//                                             textStyle: STCMedium.copyWith(
//                                                 color: Theme.of(context)
//                                                     .disabledColor,
//                                                 fontSize:
//                                                     Dimensions.fontSizeSmall,
//                                                 decoration:
//                                                     TextDecoration.lineThrough),
//                                           )
//                                         : const SizedBox(),
//                                     const SizedBox(
//                                         width:
//                                             Dimensions.paddingSizeExtraSmall),
//                                     PriceConverter.convertAnimationPrice(
//                                       withAddonCost,
//                                       textStyle: STCBold.copyWith(
//                                           color:
//                                               Theme.of(context).primaryColor),
//                                     ),
//                                   ]),
//                                 ]);
//                           }),
//                           const SizedBox(height: Dimensions.paddingSizeSmall),
//                           SafeArea(
//                             child: Row(children: [
//                               // Quantity
//                               Row(children: [
//                                 QuantityButton(
//                                   onTap: () {
//                                     if (itemController.quantity! > 1) {
//                                       itemController.setQuantity(false, stock,
//                                           widget.item!.quantityLimit,
//                                           getxSnackBar: true);
//                                     }
//                                   },
//                                   isIncrement: false,
//                                   fromSheet: true,
//                                 ),
//                                 Text(itemController.quantity.toString(),
//                                     style: STCMedium.copyWith(
//                                         fontSize: Dimensions.fontSizeLarge)),
//                                 QuantityButton(
//                                   onTap: () => itemController.setQuantity(
//                                       true, stock, widget.item!.quantityLimit,
//                                       getxSnackBar: true),
//                                   isIncrement: true,
//                                   fromSheet: true,
//                                 ),
//                               ]),
//                               const SizedBox(
//                                   width: Dimensions.paddingSizeSmall),
//
//                               Expanded(child: GetBuilder<CartController>(
//                                   builder: (cartController) {
//                                 return CustomButton(
//                                   width: ResponsiveHelper.isDesktop(context)
//                                       ? MediaQuery.of(context).size.width / 2.0
//                                       : null,
//                                   /*buttonText: isCampaign ? 'order_now'.tr : isExistInCart ? 'already_added_in_cart'.tr : fromCart
//                                           ? 'update_in_cart'.tr : 'add_to_cart'.tr,*/
//                                   isLoading: cartController.isLoading,
//                                   buttonText: (Get.find<SplashController>()
//                                               .configModel!
//                                               .moduleConfig!
//                                               .module!
//                                               .stock! &&
//                                           stock! <= 0)
//                                       ? 'out_of_stock'.tr
//                                       : widget.isCampaign
//                                           ? 'order_now'.tr
//                                           : (widget.cart != null ||
//                                                   itemController.cartIndex !=
//                                                       -1)
//                                               ? 'update_in_cart'.tr
//                                               : 'add_to_cart'.tr,
//                                   onPressed: (Get.find<SplashController>()
//                                               .configModel!
//                                               .moduleConfig!
//                                               .module!
//                                               .stock! &&
//                                           stock! <= 0)
//                                       ? null
//                                       : () async {
//                                           String? invalid;
//                                           if (_newVariation) {
//                                             for (int index = 0;
//                                                 index <
//                                                     widget.item!.foodVariations!
//                                                         .length;
//                                                 index++) {
//                                               if (!widget
//                                                       .item!
//                                                       .foodVariations![index]
//                                                       .multiSelect! &&
//                                                   widget
//                                                       .item!
//                                                       .foodVariations![index]
//                                                       .required! &&
//                                                   !itemController
//                                                       .selectedVariations[index]
//                                                       .contains(true)) {
//                                                 invalid =
//                                                     '${'choose_a_variation_from'.tr} ${widget.item!.foodVariations![index].name}';
//                                                 break;
//                                               } else if (widget
//                                                       .item!
//                                                       .foodVariations![index]
//                                                       .multiSelect! &&
//                                                   (widget
//                                                           .item!
//                                                           .foodVariations![
//                                                               index]
//                                                           .required! ||
//                                                       itemController
//                                                           .selectedVariations[
//                                                               index]
//                                                           .contains(true)) &&
//                                                   widget
//                                                           .item!
//                                                           .foodVariations![
//                                                               index]
//                                                           .min! >
//                                                       itemController
//                                                           .selectedVariationLength(
//                                                               itemController
//                                                                   .selectedVariations,
//                                                               index)) {
//                                                 invalid =
//                                                     '${'select_minimum'.tr} ${widget.item!.foodVariations![index].min} '
//                                                     '${'and_up_to'.tr} ${widget.item!.foodVariations![index].max} ${'options_from'.tr}'
//                                                     ' ${widget.item!.foodVariations![index].name} ${'variation'.tr}';
//                                                 break;
//                                               }
//                                             }
//                                           }
//
//                                           if (Get.find<SplashController>()
//                                                   .moduleList !=
//                                               null) {
//                                             for (ModuleModel module
//                                                 in Get.find<SplashController>()
//                                                     .moduleList!) {
//                                               if (module.id ==
//                                                   widget.item!.moduleId) {
//                                                 Get.find<SplashController>()
//                                                     .setModule(module);
//                                                 break;
//                                               }
//                                             }
//                                           }
//
//                                           if (invalid != null) {
//                                             showCustomSnackBar(invalid,
//                                                 getXSnackBar: true);
//                                           } else {
//                                             CartModel cartModel = CartModel(
//                                                 null,
//                                                 price,
//                                                 priceWithDiscountAndAddons,
//                                                 variation != null
//                                                     ? [variation]
//                                                     : [],
//                                                 itemController
//                                                     .selectedVariations,
//                                                 (price! -
//                                                     PriceConverter
//                                                         .convertWithDiscount(
//                                                             price,
//                                                             discount,
//                                                             discountType)!),
//                                                 itemController.quantity,
//                                                 addOnIdList,
//                                                 addOnsList,
//                                                 widget.isCampaign,
//                                                 stock,
//                                                 widget.item,
//                                                 widget.item?.quantityLimit);
//
//                                             List<OrderVariation> variations =
//                                                 _getSelectedVariations(
//                                               isFoodVariation:
//                                                   Get.find<SplashController>()
//                                                       .getModuleConfig(widget
//                                                           .item!.moduleType)
//                                                       .newVariation!,
//                                               foodVariations:
//                                                   widget.item!.foodVariations!,
//                                               selectedVariations: itemController
//                                                   .selectedVariations,
//                                             );
//                                             List<int?> listOfAddOnId =
//                                                 _getSelectedAddonIds(
//                                                     addOnIdList: addOnIdList);
//                                             List<int?> listOfAddOnQty =
//                                                 _getSelectedAddonQtnList(
//                                                     addOnIdList: addOnIdList);
//
//                                             OnlineCart onlineCart = OnlineCart(
//                                               (widget.cart != null ||
//                                                       itemController
//                                                               .cartIndex !=
//                                                           -1)
//                                                   ? widget.cart?.id ??
//                                                       cartController
//                                                           .cartList[
//                                                               itemController
//                                                                   .cartIndex]
//                                                           .id
//                                                   : null,
//                                               widget.isCampaign
//                                                   ? null
//                                                   : widget.item!.id,
//                                               widget.isCampaign
//                                                   ? widget.item!.id
//                                                   : null,
//                                               priceWithDiscountAndAddons
//                                                   .toString(),
//                                               '',
//                                               variation != null
//                                                   ? [variation]
//                                                   : null,
//                                               Get.find<SplashController>()
//                                                       .getModuleConfig(widget
//                                                           .item!.moduleType)
//                                                       .newVariation!
//                                                   ? variations
//                                                   : null,
//                                               itemController.quantity,
//                                               listOfAddOnId,
//                                               addOnsList,
//                                               listOfAddOnQty,
//                                               'Item',
//                                             );
//
//                                             if (widget.isCampaign) {
//                                               Get.toNamed(
//                                                   RouteHelper.getCheckoutRoute(
//                                                       'campaign'),
//                                                   arguments: CheckoutScreen(
//                                                     storeId: null,
//                                                     fromCart: false,
//                                                     cartList: [cartModel],
//                                                   ));
//                                             } else {
//                                               if (Get.find<CartController>()
//                                                   .existAnotherStoreItem(
//                                                 cartModel.item!.storeId,
//                                                 Get.find<SplashController>()
//                                                             .module !=
//                                                         null
//                                                     ? Get.find<
//                                                             SplashController>()
//                                                         .module!
//                                                         .id
//                                                     : Get.find<
//                                                             SplashController>()
//                                                         .cacheModule!
//                                                         .id,
//                                               )) {
//                                                 Get.dialog(
//                                                     ConfirmationDialog(
//                                                       icon: Images.warning,
//                                                       title:
//                                                           'are_you_sure_to_reset'
//                                                               .tr,
//                                                       description: Get.find<
//                                                                   SplashController>()
//                                                               .configModel!
//                                                               .moduleConfig!
//                                                               .module!
//                                                               .showRestaurantText!
//                                                           ? 'if_you_continue'.tr
//                                                           : 'if_you_continue_without_another_store'
//                                                               .tr,
//                                                       onYesPressed: () {
//                                                         Get.back();
//                                                         Get.find<
//                                                                 CartController>()
//                                                             .clearCartOnline()
//                                                             .then(
//                                                                 (success) async {
//                                                           if (success) {
//                                                             await Get.find<
//                                                                     CartController>()
//                                                                 .addToCartOnline(
//                                                                     onlineCart);
//                                                             Get.back();
//                                                             //showCartSnackBar();
//                                                           }
//                                                         });
//                                                       },
//                                                     ),
//                                                     barrierDismissible: false);
//                                               } else {
//                                                 if (widget.cart != null ||
//                                                     itemController.cartIndex !=
//                                                         -1) {
//                                                   await Get.find<
//                                                           CartController>()
//                                                       .updateCartOnline(
//                                                           onlineCart)
//                                                       .then((success) {
//                                                     if (success) {
//                                                       Get.back();
//                                                     }
//                                                   });
//                                                 } else {
//                                                   await Get.find<
//                                                           CartController>()
//                                                       .addToCartOnline(
//                                                           onlineCart)
//                                                       .then((success) {
//                                                     if (success) {
//                                                       Get.back();
//                                                     }
//                                                   });
//                                                 }
//
//                                                 //showCartSnackBar();
//                                               }
//                                             }
//                                           }
//                                         },
//                                 );
//                               })),
//                             ]),
//                           ),
//                         ]),
//                       ),
//               ]),
//               Positioned(
//                 top: 5,
//                 right: 10,
//                 child: InkWell(
//                   onTap: () => Get.back(),
//                   child: Container(
//                     padding:
//                         const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).cardColor,
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                             color: Theme.of(context)
//                                 .primaryColor
//                                 .withAlpha((0.3 * 255).toInt()),
//                             blurRadius: 5)
//                       ],
//                     ),
//                     child: const Icon(Icons.close, size: 14),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }
//
//   List<OrderVariation> _getSelectedVariations(
//       {required bool isFoodVariation,
//       required List<FoodVariation>? foodVariations,
//       required List<List<bool?>> selectedVariations}) {
//     List<OrderVariation> variations = [];
//     if (isFoodVariation) {
//       for (int i = 0; i < foodVariations!.length; i++) {
//         if (selectedVariations[i].contains(true)) {
//           variations.add(OrderVariation(
//               name: foodVariations[i].name,
//               values: OrderVariationValue(label: [])));
//           for (int j = 0; j < foodVariations[i].variationValues!.length; j++) {
//             if (selectedVariations[i][j]!) {
//               variations[variations.length - 1]
//                   .values!
//                   .label!
//                   .add(foodVariations[i].variationValues![j].level);
//             }
//           }
//         }
//       }
//     }
//     return variations;
//   }
//
//   List<int?> _getSelectedAddonIds({required List<AddOn> addOnIdList}) {
//     List<int?> listOfAddOnId = [];
//     for (var addOn in addOnIdList) {
//       listOfAddOnId.add(addOn.id);
//     }
//     return listOfAddOnId;
//   }
//
//   List<int?> _getSelectedAddonQtnList({required List<AddOn> addOnIdList}) {
//     List<int?> listOfAddOnQty = [];
//     for (var addOn in addOnIdList) {
//       listOfAddOnQty.add(addOn.quantity);
//     }
//     return listOfAddOnQty;
//   }
// }
//
// class AddonView extends StatelessWidget {
//   final Item item;
//   final ItemController itemController;
//   const AddonView(
//       {super.key, required this.item, required this.itemController});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//           Text('addons'.tr, style: STCMedium),
//           Container(
//             decoration: BoxDecoration(
//               color: Theme.of(context).disabledColor.withAlpha((0.1 * 255).toInt()),
//               borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//             ),
//             padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//             child: Text(
//               'optional'.tr,
//               style: STCRegular.copyWith(
//                   color: Theme.of(context).hintColor,
//                   fontSize: Dimensions.fontSizeSmall),
//             ),
//           ),
//         ]),
//         const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//         ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           padding: EdgeInsets.zero,
//           itemCount: item.addOns!.length,
//           itemBuilder: (context, index) {
//             return InkWell(
//               onTap: () {
//                 if (!itemController.addOnActiveList[index]) {
//                   itemController.addAddOn(true, index);
//                 } else if (itemController.addOnQtyList[index] == 1) {
//                   itemController.addAddOn(false, index);
//                 }
//               },
//               child: Padding(
//                 padding: const EdgeInsets.only(
//                     bottom: Dimensions.paddingSizeExtraSmall),
//                 child: Row(children: [
//                   Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
//                     Checkbox(
//                       value: itemController.addOnActiveList[index],
//                       activeColor: Theme.of(context).primaryColor,
//                       shape: RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.circular(Dimensions.radiusSmall)),
//                       onChanged: (bool? newValue) {
//                         if (!itemController.addOnActiveList[index]) {
//                           itemController.addAddOn(true, index);
//                         } else if (itemController.addOnQtyList[index] == 1) {
//                           itemController.addAddOn(false, index);
//                         }
//                       },
//                       visualDensity:
//                           const VisualDensity(horizontal: -3, vertical: -3),
//                       side: BorderSide(
//                           width: 2, color: Theme.of(context).hintColor),
//                     ),
//                     Text(
//                       item.addOns![index].name!,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: itemController.addOnActiveList[index]
//                           ? STCMedium
//                           : STCRegular.copyWith(
//                               color: Theme.of(context).hintColor),
//                     ),
//                   ]),
//                   const Spacer(),
//                   Text(
//                     item.addOns![index].price! > 0
//                         ? PriceConverter.convertPrice(item.addOns![index].price)
//                         : 'free'.tr,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     textDirection: TextDirection.ltr,
//                     style: itemController.addOnActiveList[index]
//                         ? STCMedium.copyWith(fontSize: Dimensions.fontSizeSmall)
//                         : STCRegular.copyWith(
//                             fontSize: Dimensions.fontSizeSmall,
//                             color: Theme.of(context).disabledColor),
//                   ),
//                   itemController.addOnActiveList[index]
//                       ? Container(
//                           height: 25,
//                           width: 90,
//                           decoration: BoxDecoration(
//                               borderRadius:
//                                   BorderRadius.circular(Dimensions.radiusSmall),
//                               color: Theme.of(context).cardColor),
//                           child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Expanded(
//                                   child: InkWell(
//                                     onTap: () {
//                                       if (itemController.addOnQtyList[index]! >
//                                           1) {
//                                         itemController.setAddOnQuantity(
//                                             false, index);
//                                       } else {
//                                         itemController.addAddOn(false, index);
//                                       }
//                                     },
//                                     child: Center(
//                                         child: Icon(
//                                       (itemController.addOnQtyList[index]! > 1)
//                                           ? Icons.remove
//                                           : Icons.delete_outline_outlined,
//                                       size: 18,
//                                       color: (itemController
//                                                   .addOnQtyList[index]! >
//                                               1)
//                                           ? Theme.of(context).primaryColor
//                                           : Theme.of(context).colorScheme.error,
//                                     )),
//                                   ),
//                                 ),
//                                 Text(
//                                   itemController.addOnQtyList[index].toString(),
//                                   style: STCMedium.copyWith(
//                                       fontSize: Dimensions.fontSizeDefault),
//                                 ),
//                                 Expanded(
//                                   child: InkWell(
//                                     onTap: () => itemController
//                                         .setAddOnQuantity(true, index),
//                                     child: Center(
//                                         child: Icon(Icons.add,
//                                             size: 18,
//                                             color: Theme.of(context)
//                                                 .primaryColor)),
//                                   ),
//                                 ),
//                               ]),
//                         )
//                       : const SizedBox(),
//                 ]),
//               ),
//             );
//           },
//         ),
//         const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//       ],
//     );
//   }
// }
//
// class VariationView extends StatelessWidget {
//   final Item? item;
//   final ItemController itemController;
//   const VariationView(
//       {super.key, required this.item, required this.itemController});
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       shrinkWrap: true,
//       itemCount: item!.choiceOptions!.length,
//       physics: const NeverScrollableScrollPhysics(),
//       padding: EdgeInsets.only(
//           bottom: item!.choiceOptions!.isNotEmpty
//               ? Dimensions.paddingSizeLarge
//               : 0),
//       itemBuilder: (context, index) {
//         return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(item!.choiceOptions![index].title!, style: STCMedium),
//           const SizedBox(height: Dimensions.paddingSizeSmall),
//           Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//               color: Theme.of(context).cardColor,
//             ),
//             padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//             child: ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               padding: EdgeInsets.zero,
//               itemCount: item!.choiceOptions![index].options!.length,
//               itemBuilder: (context, i) {
//                 return Padding(
//                   padding: const EdgeInsets.only(
//                       bottom: Dimensions.paddingSizeExtraSmall),
//                   child: InkWell(
//                     onTap: () {
//                       itemController.setCartVariationIndex(index, i, item);
//                     },
//                     child: Row(children: [
//                       Expanded(
//                           child: Text(
//                         item!.choiceOptions![index].options![i].trim(),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: STCRegular,
//                       )),
//                       const SizedBox(width: Dimensions.paddingSizeSmall),
//                       Radio<int>(
//                         value: i,
//                         groupValue: itemController.variationIndex![index],
//                         onChanged: (int? value) => itemController
//                             .setCartVariationIndex(index, i, item),
//                         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         activeColor: Theme.of(context).primaryColor,
//                       ),
//                     ]),
//                   ),
//                 );
//               },
//             ),
//           ),
//           SizedBox(
//               height: index != item!.choiceOptions!.length - 1
//                   ? Dimensions.paddingSizeLarge
//                   : 0),
//         ]);
//       },
//     );
//   }
// }
//
// class NewVariationView extends StatelessWidget {
//   final Item? item;
//   final ItemController itemController;
//   final double? discount;
//   final String? discountType;
//   final bool showOriginalPrice;
//   const NewVariationView(
//       {super.key,
//       required this.item,
//       required this.itemController,
//       required this.discount,
//       required this.discountType,
//       required this.showOriginalPrice});
//
//   @override
//   Widget build(BuildContext context) {
//     return item!.foodVariations != null
//         ? ListView.builder(
//             shrinkWrap: true,
//             itemCount: item!.foodVariations!.length,
//             physics: const NeverScrollableScrollPhysics(),
//             padding: EdgeInsets.only(
//                 bottom: (item!.foodVariations != null &&
//                         item!.foodVariations!.isNotEmpty)
//                     ? Dimensions.paddingSizeLarge
//                     : 0),
//             itemBuilder: (context, index) {
//               int selectedCount = 0;
//               if (item!.foodVariations![index].required!) {
//                 for (var value in itemController.selectedVariations[index]) {
//                   if (value == true) {
//                     selectedCount++;
//                   }
//                 }
//               }
//               return Container(
//                 padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//                 margin: EdgeInsets.only(
//                     bottom: index != item!.foodVariations!.length - 1
//                         ? Dimensions.paddingSizeLarge
//                         : 0),
//                 decoration: BoxDecoration(
//                     color: itemController.selectedVariations[index]
//                             .contains(true)
//                         ? Theme.of(context).primaryColor.withAlpha((0.01 * 255).toInt())
//                         : Theme.of(context)
//                             .disabledColor
//                             .withAlpha((0.05 * 255).toInt()),
//                     border: Border.all(
//                         color: itemController.selectedVariations[index]
//                                 .contains(true)
//                             ? Theme.of(context).primaryColor
//                             : Theme.of(context).disabledColor,
//                         width: 0.5),
//                     borderRadius:
//                         BorderRadius.circular(Dimensions.radiusDefault)),
//                 child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Text(item!.foodVariations![index].name!,
//                                 style: STCMedium.copyWith(
//                                     fontSize: Dimensions.fontSizeLarge)),
//                             Container(
//                               decoration: BoxDecoration(
//                                 color: item!.foodVariations![index].required! &&
//                                         (item!.foodVariations![index]
//                                                     .multiSelect!
//                                                 ? item!
//                                                     .foodVariations![index].min!
//                                                 : 1) >
//                                             selectedCount
//                                     ? Theme.of(context)
//                                         .colorScheme
//                                         .error
//                                         .withAlpha((0.1 * 255).toInt())
//                                     : Theme.of(context)
//                                         .disabledColor
//                                         .withAlpha((0.1 * 255).toInt()),
//                                 borderRadius: BorderRadius.circular(
//                                     Dimensions.radiusSmall),
//                               ),
//                               padding: const EdgeInsets.all(
//                                   Dimensions.paddingSizeExtraSmall),
//                               child: Text(
//                                 item!.foodVariations![index].required!
//                                     ? (item!.foodVariations![index].multiSelect!
//                                                 ? item!
//                                                     .foodVariations![index].min!
//                                                 : 1) <=
//                                             selectedCount
//                                         ? 'completed'.tr
//                                         : 'required'.tr
//                                     : 'optional'.tr,
//                                 style: STCRegular.copyWith(
//                                   color: item!.foodVariations![index].required!
//                                       ? (item!.foodVariations![index]
//                                                       .multiSelect!
//                                                   ? item!.foodVariations![index]
//                                                       .min!
//                                                   : 1) <=
//                                               selectedCount
//                                           ? Theme.of(context).hintColor
//                                           : Theme.of(context).colorScheme.error
//                                       : Theme.of(context).hintColor,
//                                   fontSize: Dimensions.fontSizeSmall,
//                                 ),
//                               ),
//                             ),
//                           ]),
//                       const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//                       item!.foodVariations![index].multiSelect!
//                           ? Text(
//                               '${'select_minimum'.tr} ${'${item!.foodVariations![index].min}'
//                                   ' ${'and_up_to'.tr} ${item!.foodVariations![index].max} ${'options'.tr}'}',
//                               style: STCMedium.copyWith(
//                                   fontSize: Dimensions.fontSizeExtraSmall,
//                                   color: Theme.of(context).disabledColor),
//                             )
//                           : Text(
//                               'select_one'.tr,
//                               style: STCMedium.copyWith(
//                                   fontSize: Dimensions.fontSizeExtraSmall,
//                                   color: Theme.of(context).primaryColor),
//                             ),
//                       SizedBox(
//                           height: item!.foodVariations![index].multiSelect!
//                               ? Dimensions.paddingSizeExtraSmall
//                               : 0),
//                       ListView.builder(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         padding: EdgeInsets.zero,
//                         itemCount: itemController.collapseVariation[index]
//                             ? item!.foodVariations![index].variationValues!
//                                         .length >
//                                     4
//                                 ? 5
//                                 : item!.foodVariations![index].variationValues!
//                                     .length
//                             : item!
//                                 .foodVariations![index].variationValues!.length,
//                         itemBuilder: (context, i) {
//                           if (i == 4 &&
//                               itemController.collapseVariation[index]) {
//                             return Padding(
//                               padding: const EdgeInsets.all(
//                                   Dimensions.paddingSizeExtraSmall),
//                               child: InkWell(
//                                 onTap: () => itemController
//                                     .showMoreSpecificSection(index),
//                                 child: Row(children: [
//                                   Icon(Icons.expand_more,
//                                       size: 18,
//                                       color: Theme.of(context).primaryColor),
//                                   const SizedBox(
//                                       width: Dimensions.paddingSizeExtraSmall),
//                                   Text(
//                                     '${'view'.tr} ${item!.foodVariations![index].variationValues!.length - 4} ${'more_option'.tr}',
//                                     style: STCMedium.copyWith(
//                                         color: Theme.of(context).primaryColor),
//                                   ),
//                                 ]),
//                               ),
//                             );
//                           } else {
//                             return Padding(
//                               padding: EdgeInsets.symmetric(
//                                   vertical: ResponsiveHelper.isDesktop(context)
//                                       ? Dimensions.paddingSizeExtraSmall
//                                       : 0),
//                               child: InkWell(
//                                 onTap: () {
//                                   itemController.setNewCartVariationIndex(
//                                       index, i, item!);
//                                 },
//                                 child: Row(children: [
//                                   Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         item!.foodVariations![index]
//                                                 .multiSelect!
//                                             ? Checkbox(
//                                                 value: itemController
//                                                         .selectedVariations[
//                                                     index][i],
//                                                 activeColor: Theme.of(context)
//                                                     .primaryColor,
//                                                 shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             Dimensions
//                                                                 .radiusSmall)),
//                                                 onChanged: (bool? newValue) {
//                                                   itemController
//                                                       .setNewCartVariationIndex(
//                                                           index, i, item!);
//                                                 },
//                                                 visualDensity:
//                                                     const VisualDensity(
//                                                         horizontal: -3,
//                                                         vertical: -3),
//                                                 side: BorderSide(
//                                                     width: 2,
//                                                     color: Theme.of(context)
//                                                         .hintColor),
//                                               )
//                                             : Radio(
//                                                 value: i,
//                                                 groupValue: itemController
//                                                     .selectedVariations[index]
//                                                     .indexOf(true),
//                                                 onChanged: (dynamic value) {
//                                                   itemController
//                                                       .setNewCartVariationIndex(
//                                                           index, i, item!);
//                                                 },
//                                                 activeColor: Theme.of(context)
//                                                     .primaryColor,
//                                                 toggleable: false,
//                                                 visualDensity:
//                                                     const VisualDensity(
//                                                         horizontal: -3,
//                                                         vertical: -3),
//                                               ),
//                                         Text(
//                                           item!.foodVariations![index]
//                                               .variationValues![i].level!
//                                               .trim(),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                           style: itemController
//                                                   .selectedVariations[index][i]!
//                                               ? STCMedium
//                                               : STCRegular.copyWith(
//                                                   color: Theme.of(context)
//                                                       .hintColor),
//                                         ),
//                                       ]),
//                                   const Spacer(),
//                                   showOriginalPrice
//                                       ? Text(
//                                           '+${PriceConverter.convertPrice(item!.foodVariations![index].variationValues![i].optionPrice)}',
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                           textDirection: TextDirection.ltr,
//                                           style: STCRegular.copyWith(
//                                               fontSize:
//                                                   Dimensions.fontSizeExtraSmall,
//                                               color: Theme.of(context)
//                                                   .disabledColor,
//                                               decoration:
//                                                   TextDecoration.lineThrough),
//                                         )
//                                       : const SizedBox(),
//                                   SizedBox(
//                                       width: showOriginalPrice
//                                           ? Dimensions.paddingSizeExtraSmall
//                                           : 0),
//                                   Text(
//                                     '+${PriceConverter.convertPrice(item!.foodVariations![index].variationValues![i].optionPrice, discount: discount, discountType: discountType, isFoodVariation: true)}',
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                     textDirection: TextDirection.ltr,
//                                     style: itemController
//                                             .selectedVariations[index][i]!
//                                         ? STCMedium.copyWith(
//                                             fontSize:
//                                                 Dimensions.fontSizeExtraSmall)
//                                         : STCRegular.copyWith(
//                                             fontSize:
//                                                 Dimensions.fontSizeExtraSmall,
//                                             color: Theme.of(context)
//                                                 .disabledColor),
//                                   ),
//                                 ]),
//                               ),
//                             );
//                           }
//                         },
//                       ),
//                     ]),
//               );
//             },
//           )
//         : const SizedBox();
//   }
// }
