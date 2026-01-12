import 'dart:developer';

import 'package:sixam_mart/common/widgets/card_design/store_card_with_distance.dart';
import 'package:sixam_mart/common/widgets/card_design/store_item_card.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/home/widgets/web/widgets/store_card_widget.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/common/widgets/item_shimmer.dart';
import 'package:sixam_mart/common/widgets/item_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/store/domain/models/category_with_stores.dart';

class ItemsView extends StatefulWidget {
  final List<Item?>? items;
  final List<Store?>? stores;
  final bool isStore;
  final EdgeInsetsGeometry padding;
  final bool isScrollable;
  final int shimmerLength;
  final String? noDataText;
  final String? categoryId;
  final int? categoryIdInt; // For home screen category pagination
  final bool isCampaign;
  final bool inStorePage;
  final bool isFeatured;
  final bool isFromHome;
  final bool? isFoodOrGrocery;

  const ItemsView({super.key,
    required this.stores,
    required this.items,
    required this.isStore,
    this.isScrollable = false,
    this.shimmerLength = 20,
    this.padding = const EdgeInsets.all(Dimensions.paddingSizeDefault),
    this.noDataText,
    this.isCampaign = false,
    this.inStorePage = false,
    this.isFeatured = false,
    this.isFromHome = false,
    this.isFoodOrGrocery = true,
    this.categoryId,
    this.categoryIdInt});

  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
  final ScrollController _horizontalScrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    // Add scroll listener for horizontal pagination when isFromHome is true
    if (widget.isFromHome && widget.isStore && widget.categoryIdInt != null) {
      _horizontalScrollController.addListener(_onHorizontalScroll);
    }
  }
  
  @override
  void dispose() {
    _horizontalScrollController.removeListener(_onHorizontalScroll);
    _horizontalScrollController.dispose();
    super.dispose();
  }
  
  void _onHorizontalScroll() {
    if (!_horizontalScrollController.hasClients) {
      return;
    }
    
    try {
      final double pixels = _horizontalScrollController.position.pixels;
      final double maxScroll = _horizontalScrollController.position.maxScrollExtent;
      
      // Check if scrolled to the end (within 150px of the end)
      // Also check if maxScroll is greater than 0 (meaning there's scrollable content)
      if (maxScroll > 0 && pixels >= maxScroll - 150) {
        // Load more stores for this category
        if (widget.categoryIdInt != null) {
          Get.find<StoreController>().loadMoreStoresForCategory(widget.categoryIdInt!);
        }
      }
    } catch (e) {
      // Silent error handling
    }
  }
  
  @override
  Widget build(BuildContext context) {
    bool isNull = true;
    int length = 0;
    if (widget.isStore) {
      isNull = widget.stores == null;
      if (!isNull) {
        length = widget.stores!.length;
      }
    } else {
      isNull = widget.items == null;
      if (!isNull) {
        length = widget.items!.length;
      }
    }

    return Column(children: [
      !isNull
          ? length > 0
          ? widget.stores != null &&
          !widget.isStore &&
          widget.items!.isEmpty
          ? Container(
        // color: Colors.green,
        height: 205,
        width: double.infinity,
        child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            // shrinkWrap: false,
            itemBuilder: (context, index) {
              if (widget.categoryId ==
                  widget.items![index]?.categoryId.toString()) {
              }
              return (widget.categoryId ==
                  widget.items![index]?.categoryId.toString())
                  ? ItemWidget(
                isStore: widget.isStore,
                item: widget.isStore
                    ? null
                    : widget.items![index],
                isFeatured: widget.isFeatured,
                store: widget.isStore
                    ? widget.stores![index]
                    : null,
                index: index,
                length: length,
                isCampaign: widget.isCampaign,
                inStore: widget.inStorePage,
              )
                  : SizedBox.shrink();
            }),
      )
          : widget.isFromHome
          ? GetBuilder<StoreController>(
              builder: (storeController) {
                // Get updated stores list for this category
                List<Store?>? updatedStores = widget.stores;
                if (widget.categoryIdInt != null) {
                  CategoryWithStores? category = storeController.categoryWithStoreList?.firstWhereOrNull(
                    (cat) => cat.cId == widget.categoryIdInt,
                  );
                  if (category != null && category.stores != null) {
                    updatedStores = category.stores;
                  }
                }
                
                final int itemCount = (updatedStores?.length ?? 0) + 
                    (storeController.isCategoryLoading(widget.categoryIdInt ?? 0) ? 1 : 0);
                
                return Container(
                  // color: Colors.green,
                  height: 165,
                  width: double.infinity,
                  child: ListView.builder(
                      controller: _horizontalScrollController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: itemCount,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      // shrinkWrap: false,
                      // padding: EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (context, index) {
                        // Show loading indicator at the end
                        if (index >= (updatedStores?.length ?? 0)) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        }
                        return Container(
                          width: 200,
                          // color: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          child: StoreCardWidget(
                            store: updatedStores![index],
                          ),
                        );
                      }),
                );
              },
            )
          :
      // widget.stores != null ? Text(widget.stores!.length.toString()): Text("data")
      GridView.builder(
                          key: UniqueKey(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing:
                                ResponsiveHelper.isDesktop(context)
                                    ? Dimensions.paddingSizeExtremeLarge
                                    : widget.stores != null
                                        ? Dimensions.paddingSizeExtraSmall
                                        : Dimensions.paddingSizeLarge,
                            mainAxisSpacing: ResponsiveHelper.isDesktop(context)
                                ? Dimensions.paddingSizeExtremeLarge
                                : widget.stores != null && widget.isStore
                                    ? Dimensions.paddingSizeSmall
                                    : Dimensions.paddingSizeSmall,
                            // childAspectRatio: ResponsiveHelper.isDesktop(context) && widget.isStore ? (1/0.6)
                            //     : ResponsiveHelper.isMobile(context) ? widget.stores != null && widget.isStore ? 2 : 3.8
                            //     : 3.3,
                            mainAxisExtent: ResponsiveHelper.isDesktop(
                                        context) &&
                                    widget.isStore
                                ? 220
                                : ResponsiveHelper.isMobile(context)
                                    ? widget.stores != null && widget.isStore
                                        ? 155
                                        : 180
                                    : 122,
                            crossAxisCount: ResponsiveHelper.isMobile(context)
                                ? widget.stores != null && widget.isStore
                                    ? 2
                                    : 2
                                : ResponsiveHelper.isDesktop(context) &&
                                        widget.stores != null
                                    ? 3
                                    : 3,
                          ),
                          // scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          // widget.isScrollable
                          //     ? const BouncingScrollPhysics()
                          //     : const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          // widget.isScrollable ? false : true,
                          itemCount: length,

                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeExtraSmall,
                          ),//widget.padding,
                          itemBuilder: (context, index) {
                            return widget.stores != null && widget.isStore
                                ? widget.isFoodOrGrocery! && widget.isStore
                                    ? StoreCardWidget(
                                        store: widget.stores![index])
                                    : StoreCardWithDistance(
                                        store: widget.stores![index]!,
                                        fromAllStore: true,
                                      )
                                : ItemWidget(
                                    isStore: widget.isStore,
                                    item: widget.isStore
                                        ? null
                                        : widget.items![index],
                                    isFeatured: widget.isFeatured,
                                    store: widget.isStore
                                        ? widget.stores![index]
                                        : null,
                                    index: index,
                                    length: length,
                                    isCampaign: widget.isCampaign,
                                    inStore: widget.inStorePage,
                                  );
                          },
                        )
          : NoDataScreen(
        text: widget.noDataText ??
            (widget.isStore
                ? Get
                .find<SplashController>()
                .configModel!
                .moduleConfig!
                .module!
                .showRestaurantText!
                ? 'no_restaurant_available'.tr
                : 'no_store_available'.tr
                : 'no_item_available'.tr),
      )
      //Shimmers starts from here
          : GridView.builder(
        key: UniqueKey(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: ResponsiveHelper.isDesktop(context)
              ? Dimensions.paddingSizeExtremeLarge
              : widget.stores != null
              ? Dimensions.paddingSizeLarge
              : Dimensions.paddingSizeLarge,
          mainAxisSpacing: ResponsiveHelper.isDesktop(context)
              ? Dimensions.paddingSizeLarge
              : widget.stores != null
              ? Dimensions.paddingSizeLarge
              : Dimensions.paddingSizeSmall,
          // childAspectRatio: ResponsiveHelper.isDesktop(context) && widget.isStore ? (1/0.6)
          //     : ResponsiveHelper.isMobile(context) ? widget.isStore ? 2 : 3.8
          //     : 3,
          mainAxisExtent:
          ResponsiveHelper.isDesktop(context) && widget.isStore
              ? 220
              : ResponsiveHelper.isMobile(context)
              ? widget.isStore
              ? 200
              : 110
              : 110,
          crossAxisCount: ResponsiveHelper.isMobile(context)
              ? widget.isStore
              ? 1
              : 2
              : ResponsiveHelper.isDesktop(context)
              ? 3
              : 3,
        ),
        physics: widget.isScrollable
            ? const BouncingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        shrinkWrap: widget.isScrollable ? false : true,
        itemCount: widget.shimmerLength,
        padding: widget.padding,
        itemBuilder: (context, index) {
          return widget.isStore
              ? widget.isFoodOrGrocery!
              ? const StoreCardShimmer()
              : const NewOnShimmerView()
              : ItemShimmer(
              isEnabled: isNull,
              isStore: widget.isStore,
              hasDivider: index != widget.shimmerLength - 1);
        },
      ),
    ]);
  }
}

class NewOnShimmerView extends StatelessWidget {
  const NewOnShimmerView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Stack(children: [
        Container(
          // width: fromAllStore ?  MediaQuery.of(context).size.width : 260,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Column(children: [
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(Dimensions.radiusDefault),
                    topRight: Radius.circular(Dimensions.radiusDefault)),
                child: Stack(clipBehavior: Clip.none, children: [
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Theme
                        .of(context)
                        .primaryColor
                        .withAlpha((0.1 * 255).toInt()),
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme
                            .of(context)
                            .cardColor
                            .withAlpha((0.8 * 255).toInt()),
                      ),
                      child: Icon(Icons.favorite_border,
                          color: Theme
                              .of(context)
                              .primaryColor, size: 20),
                    ),
                  ),
                ]),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 95),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              height: 5,
                              width: 100,
                              color: Theme
                                  .of(context)
                                  .cardColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(children: [
                            const Icon(Icons.location_on_outlined,
                                color: Colors.blue, size: 15),
                            const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall),
                            Expanded(
                              child: Container(
                                height: 10,
                                width: 100,
                                color: Theme
                                    .of(context)
                                    .cardColor,
                              ),
                            ),
                          ]),
                        ]),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 10,
                            width: 70,
                            padding: const EdgeInsets.symmetric(
                                vertical: 3,
                                horizontal: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              color: Theme
                                  .of(context)
                                  .primaryColor
                                  .withAlpha((0.1 * 255).toInt()),
                              borderRadius:
                              BorderRadius.circular(Dimensions.radiusLarge),
                            ),
                          ),
                          Container(
                            height: 20,
                            width: 65,
                            decoration: BoxDecoration(
                              color: Theme
                                  .of(context)
                                  .cardColor,
                              borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                          ),
                        ]),
                  ),
                ),
              ]),
            ),
          ]),
        ),
        Positioned(
          top: 60,
          left: 15,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 65,
                width: 65,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
