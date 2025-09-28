import 'dart:convert';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/widgets/cart_count_view.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';
import 'package:sixam_mart/features/store/widgets/bottom_cart_widget.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import '../../../common/models/module_model.dart';
import '../../../common/widgets/custom_image.dart';
import '../../../helper/price_converter.dart';
import '../../../helper/route_helper.dart';
import '../../../util/app_constants.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';
import '../../category/domain/models/category_model.dart';
import '../../item/controllers/item_controller.dart';
import '../../item/domain/models/item_model.dart';
import '../../language/controllers/language_controller.dart';
import '../../splash/controllers/splash_controller.dart';
import '../component/store_item_view.dart';
import '../controllers/store_controller.dart';
import '../domain/models/store_model.dart';
import '../domain/models/store_model_new_api.dart';

class StoreCategoriesScreen extends StatefulWidget {
  const StoreCategoriesScreen({super.key, this.store});

  final Store? store;

  @override
  State<StoreCategoriesScreen> createState() => _StoreCategoriesScreenState();
}

class _StoreCategoriesScreenState extends State<StoreCategoriesScreen> {
  late ScrollController _scrollController;
  final Map<int, GlobalKey> _subCategoryKeys = {};
  final _currentSubCategoryIndex = 0.obs;
  bool _isScrolling = false;

/*  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        // near bottom
        Get.find<StoreController>().loadNextItems();
      }

      // Set scrolling flag
      _isScrolling = _scrollController.position.isScrollingNotifier.value;

      // Auto-detect which subcategory is currently in view
      if (_isScrolling) {
        _updateCurrentSubCategory();
      }
    });


    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Get.find<StoreController>().getSubCatWithItems();
      }
    });
  }

  void _updateCurrentSubCategory() {
    final storeController = Get.find<StoreController>();
    final subCategories = storeController.selectedStoreSubCategories;

    if (subCategories == null || subCategories.isEmpty) return;

    // Find which subcategory is currently most visible
    int newIndex = _currentSubCategoryIndex.value;
    double maxVisibility = 0;

    for (int i = 0; i < subCategories.length; i++) {
      final key = _subCategoryKeys[i];
      if (key?.currentContext != null) {
        final box = key!.currentContext!.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        final viewportHeight = MediaQuery.of(context).size.height;

        // Calculate how much of this section is visible
        double visibleHeight = box.size.height;
        if (position.dy < 0) {
          visibleHeight += position.dy; // Top is above screen
        }
        if (position.dy + box.size.height > viewportHeight) {
          visibleHeight -= (position.dy + box.size.height - viewportHeight); // Bottom is below screen
        }

        double visibility = visibleHeight / box.size.height;

        // If more than 30% of this section is visible, consider it the active one
        if (visibility > 0.3 && visibility > maxVisibility) {
          maxVisibility = visibility;
          newIndex = i;
        }
      }
    }

    // Update if the active subcategory has changed
    if (_currentSubCategoryIndex != newIndex) {

        _currentSubCategoryIndex.value = newIndex;

      // Automatically select this subcategory
      final subCat = subCategories[newIndex];
      if (storeController.selectedSubCategoryId != subCat.id) {
        storeController.getSubCatItems(subCat.id);
      }
    }
  }*/

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        // near bottom
        Get.find<StoreController>().loadNextItems();
      }

      // Always update subcategory during scrolling, not just when isScrolling is true
      _updateCurrentSubCategory();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Get.find<StoreController>().getSubCatWithItems();

        // Add a small delay to ensure all keys are available
        Future.delayed(const Duration(milliseconds: 300), () {
          _updateCurrentSubCategory();
        });
      }
    });
  }

  void _updateCurrentSubCategory() {
    final storeController = Get.find<StoreController>();
    final subCategories = storeController.selectedStoreSubCategories;

    if (subCategories == null || subCategories.isEmpty) return;

    // Find which subcategory is currently most visible
    int newIndex = _currentSubCategoryIndex.value;
    double maxVisibility = 0;
    bool foundVisible = false;

    for (int i = 0; i < subCategories.length; i++) {
      final key = _subCategoryKeys[i];
      if (key?.currentContext != null && key!.currentContext!.mounted) {
        final box = key.currentContext!.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        final viewportHeight = MediaQuery.of(context).size.height;

        // Check if this section is even partially in view
        if (position.dy + box.size.height < 0 || position.dy > viewportHeight) {
          continue; // Section is completely off-screen
        }

        // Calculate how much of this section is visible
        double visibleHeight = box.size.height;
        if (position.dy < 0) {
          visibleHeight += position.dy; // Top is above screen
        }
        if (position.dy + box.size.height > viewportHeight) {
          visibleHeight -= (position.dy +
              box.size.height -
              viewportHeight); // Bottom is below screen
        }

        double visibility = visibleHeight / box.size.height;

        // If more than 10% of this section is visible, consider it
        if (visibility > 0.3 && visibility > maxVisibility) {
          maxVisibility = visibility;
          newIndex = i;
          foundVisible = true;
        }
      }
    }

    // If no section is found visible, default to the last one when at bottom
    if (!foundVisible &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50) {
      newIndex = subCategories.length - 1;
    }

    // Update if the active subcategory has changed - FIXED COMPARISON
    if (_currentSubCategoryIndex.value != newIndex) {
      _currentSubCategoryIndex.value = newIndex;

      // Automatically select this subcategory
      final subCat = subCategories[newIndex];
      if (storeController.selectedSubCategoryId != subCat.id) {
        storeController.getSubCatItems(subCat.id);
      }
    }
  }

  void _scrollToSubCategory(int index) {
    if (index >= 0 && index < _subCategoryKeys.length) {
      final context = _subCategoryKeys[index]?.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.1, // Slightly above center
        );
        _currentSubCategoryIndex.value = index;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (storeController) {
      Store? store;
      if (storeController.store != null) {
        store = storeController.store;
      }
      bool ltr = Get.find<LocalizationController>().isLtr;

      // Initialize keys for subcategories
      final subCategories = storeController.selectedStoreSubCategories ?? [];
      for (int i = 0; i < subCategories.length; i++) {
        _subCategoryKeys.putIfAbsent(i, () => GlobalKey());
      }

      return Scaffold(
          backgroundColor: Theme.of(context).disabledColor.withOpacity(.2),
          appBar: AppBar(
            backgroundColor: Theme.of(context).cardColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: const SizedBox.shrink(),
            leadingWidth: 0,
            titleSpacing: 0,
            title: SizedBox(
              height: 40,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 1,
                    child: InkWell(
                      onTap: () => Get.back(),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              spreadRadius: 1,
                              blurRadius: .5,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.chevron_left,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 6,
                    child: GestureDetector(
                      onTap: () {
                        if (store != null && store!.id != null) {
                          Get.toNamed(
                              RouteHelper.getSearchStoreItemRoute(store!.id!));
                        } else {
                          print(
                              "Error: Store ID is null, cannot navigate to search.");
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              spreadRadius: .5,
                              blurRadius: .5,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: AbsorbPointer(
                          child: TextFormField(
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: "🔍︎  ${'search_products'.tr}",
                              hintStyle: TextStyle(
                                color: Theme.of(context).disabledColor,
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              fillColor: Theme.of(context).cardColor,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppConstants.webHostedUrl.isNotEmpty
                      ? Flexible(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              storeController.shareStore();
                            },
                            child: Container(
                              height: 40,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).cardColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    spreadRadius: 1,
                                    blurRadius: .5,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.share,
                                size: 17,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          body: (storeController.store != null &&
                  storeController.store!.name != null)
              ? Column(
                  children: [
                    Container(
                      color: Theme.of(context).cardColor,
                      child: Column(
                        children: [
                          const SizedBox(height: 6),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Align(
                              alignment:
                                  ltr ? Alignment.topLeft : Alignment.topRight,
                              child: Text(
                                "available_categories".tr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          GetBuilder<StoreController>(
                              builder: (storeController) {
                            return SizedBox(
                              height: 100,
                              width: double.infinity,
                              child: GetBuilder<CategoryController>(
                                  builder: (categoryController) {
                                if (store!.categoryIds == null ||
                                    store.categoryIds!.isEmpty) {
                                  return Container(
                                    padding: const EdgeInsets.all(16.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                        "no_categories_found_for_store".tr),
                                  );
                                }

                                if (categoryController.categoryList == null) {
                                  return Container(
                                    padding: const EdgeInsets.all(16.0),
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const CircularProgressIndicator(),
                                        const SizedBox(height: 10),
                                        Text("loading_categories".tr),
                                      ],
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  itemCount: store!.categoryIds!.length,
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeSmall,
                                      vertical: Dimensions.paddingSizeSmall),
                                  itemBuilder: (context, index) {
                                    CategoryModel? category;
                                    int? catId;
                                    String errorMessage =
                                        "category_not_found".tr;

                                    if (index < store!.categoryIds!.length) {
                                      catId = store!.categoryIds![index];
                                      if (categoryController.categoryList !=
                                          null) {
                                        category = categoryController
                                            .categoryList!
                                            .firstWhereOrNull((categoryItem) =>
                                                categoryItem.id == catId);
                                      } else {
                                        errorMessage =
                                            "error_loading_category_details".tr;
                                      }
                                    } else {
                                      errorMessage =
                                          "error_loading_category_details".tr;
                                    }

                                    if (category != null) {
                                      return Container(
                                        width: 90,
                                        height: 90,
                                        margin: const EdgeInsets.only(
                                            right: Dimensions.paddingSizeSmall),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                          color: Theme.of(context).cardColor,
                                          border: catId ==
                                                  Get.find<StoreController>()
                                                      .selectedCategoryId
                                              ? Border.all(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  width: 2,
                                                )
                                              : Border.all(
                                                  color: Theme.of(context)
                                                      .disabledColor,
                                                  width: 1,
                                                ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              spreadRadius: 1,
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            print(
                                                'Tapped on category: ${category?.name}');
                                            Get.find<StoreController>()
                                                .getSubCategoriesWithItems(
                                                    catId);
                                            _currentSubCategoryIndex.value = 0;
                                          },
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions.radiusSmall),
                                                child: CustomImage(
                                                  image:
                                                      category.imageFullUrl ??
                                                          '',
                                                  fit: BoxFit.cover,
                                                  height: 90,
                                                  width: 90,
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                left: 0,
                                                right: 0,
                                                child: ClipRRect(
                                                  child: BackdropFilter(
                                                    filter: ui.ImageFilter.blur(
                                                      sigmaX: 3.0,
                                                      sigmaY: 3.0,
                                                    ),
                                                    child: Container(
                                                      color: Colors.white
                                                          .withOpacity(0.15),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 6.0),
                                                      child: Text(
                                                        category.name ??
                                                            "category_not_found"
                                                                .tr,
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: catId ==
                                                                  Get.find<
                                                                          StoreController>()
                                                                      .selectedCategoryId
                                                              ? Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                              : null,
                                                          shadows: const [
                                                            Shadow(
                                                              blurRadius: 2.0,
                                                              color: Colors
                                                                  .black26,
                                                              offset: Offset(
                                                                  0.5, 0.5),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Container(
                                        width: 120,
                                        margin: const EdgeInsets.only(
                                            right: Dimensions.paddingSizeSmall),
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                          color: Theme.of(context)
                                              .disabledColor
                                              .withOpacity(0.1),
                                        ),
                                        child: Center(
                                          child: Text(
                                            errorMessage,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error
                                                  .withOpacity(0.7),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                );
                              }),
                            );
                          }),
                          const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall),
                          SizedBox(
                            height: 42,
                            child: Row(
                              children: [
                                ListView.builder(
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: storeController
                                        .selectedStoreSubCategories!.length,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    itemBuilder: (context, index) {
                                      final int selectedSubCatId =
                                          storeController.selectedSubCategoryId;
                                      final cat = storeController
                                          .selectedStoreSubCategories![index];
                                      final isSelected =
                                          _currentSubCategoryIndex.value ==
                                              index; // Use value

                                      return InkWell(
                                        onTap: () {
                                          storeController
                                              .getSubCatItems(cat.id);
                                          _scrollToSubCategory(index);
                                          // _currentSubCategoryIndex.value = index;
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          decoration: BoxDecoration(
                                            color: selectedSubCatId == cat.id
                                                // color: isSelected
                                                ? Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(.3)
                                                : Theme.of(context)
                                                    .disabledColor
                                                    .withOpacity(.3),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              cat.name.toString(),
                                              style: STCRegular.copyWith(
                                                color:
                                                    selectedSubCatId == cat.id
                                                        // isSelected
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : null,
                                                fontWeight:
                                                    selectedSubCatId == cat.id
                                                        // isSelected
                                                        ? FontWeight.bold
                                                        : null,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    })
                              ],
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                        ],
                      ),
                    ),

                    // Create a section for each subcategory with items
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        child: Column(children: [
                          ...List.generate(subCategories.length, (index) {
                            final subCat = subCategories[index];
                            final hasItems = subCat.items != null &&
                                subCat.items!.isNotEmpty;
                            final isLastIndex =
                                index == subCategories.length - 1;
                            return Column(
                              key: _subCategoryKeys[index],
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6.0),
                                        child: Text(
                                          subCat.name ?? "Unnamed Category",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _currentSubCategoryIndex
                                                        .value ==
                                                    index
                                                ? Theme.of(context).primaryColor
                                                : null,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      )
                                    ],
                                  ),
                                ),

                                hasItems
                                    ? GridView.builder(
                                        itemCount: subCat.items!.length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeSmall),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          mainAxisSpacing:
                                              Dimensions.paddingSizeSmall,
                                          crossAxisSpacing:
                                              Dimensions.paddingSizeSmall,
                                          childAspectRatio: 0.54,
                                        ),
                                        itemBuilder: (context, itemIndex) {
                                          Item item = subCat.items![itemIndex];
                                          final isLastIndex =
                                              index == subCategories.length - 1;
                                          return InkWell(
                                            onTap: () {
                                              Get.find<ItemController>()
                                                  .navigateToItemPage(
                                                      item, context,
                                                      inStore: true,
                                                      isCampaign: false);
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 0),
                                              decoration: BoxDecoration(
                                                color:
                                                    Theme.of(context).cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Card(
                                                elevation: 0.1,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    SizedBox(
                                                      height: 80,
                                                      width: double.infinity,
                                                      child: CustomImage(
                                                        image: item.imageFullUrl
                                                            .toString(),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 4.0,
                                                                vertical: 4.0),
                                                        child: Column(
                                                          crossAxisAlignment: ltr
                                                              ? CrossAxisAlignment
                                                                  .start
                                                              : CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment: ltr
                                                                  ? CrossAxisAlignment
                                                                      .start
                                                                  : CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Text(
                                                                  PriceConverter
                                                                          .convertPrice(
                                                                              item.price) ??
                                                                      'No Price',
                                                                  style: STCRegular
                                                                      .copyWith(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                Text(
                                                                  item.name ??
                                                                      'No Name',
                                                                  style: STCRegular
                                                                      .copyWith(
                                                                          fontSize:
                                                                              13),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                Text(
                                                                  item.description ??
                                                                      'No desc',
                                                                  style: STCRegular
                                                                      .copyWith(
                                                                    fontSize:
                                                                        11,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .dividerColor
                                                                        .withOpacity(
                                                                            .5),
                                                                  ),
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ],
                                                            ),
                                                            Center(
                                                              child:
                                                                  CartCountView(
                                                                item: item,
                                                                index: index,
                                                                child:
                                                                    Container(
                                                                  height: 30,
                                                                  width: 30,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .only(
                                                                      topLeft: Radius.circular(
                                                                          Dimensions
                                                                              .radiusLarge),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              Dimensions.radiusLarge),
                                                                    ),
                                                                  ),
                                                                  child: Icon(
                                                                    Icons.add,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .cardColor,
                                                                    size: 20,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            // InkWell(
                                                            //   onTap: () {
                                                            //     Get.find<ItemController>()
                                                            //         .itemDirectlyAddToCart(
                                                            //         item, context,
                                                            //         inStore: true,
                                                            //         isCampaign: false);
                                                            //   },
                                                            //   child: Align(
                                                            //     alignment: Alignment.bottomCenter,
                                                            //     child: Padding(
                                                            //       padding: const EdgeInsets.only(
                                                            //           top: 4.0),
                                                            //       child: Icon(
                                                            //         Icons.add,
                                                            //         color: Theme.of(context)
                                                            //             .primaryColor,
                                                            //       ),
                                                            //     ),
                                                            //   ),
                                                            // ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : const Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(
                                            'No items in this category.',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                // Add 20% extra height for the last index
                                if (isLastIndex)
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.2,
                                  ),
                              ],
                            );
                          }),
                        ]),
                      ),
                    ),
                  ],
                )
              : SizedBox(),
          bottomNavigationBar:
              GetBuilder<CartController>(builder: (cartController) {
            return cartController.cartList.isNotEmpty &&
                    !ResponsiveHelper.isDesktop(context)
                ? const BottomCartWidget()
                : const SizedBox();
          }));
    });
  }
}

/*class StoreCategoriesScreen extends StatefulWidget {
  const StoreCategoriesScreen({super.key, this.store});

  final Store? store;

  @override
  State<StoreCategoriesScreen> createState() => _StoreCategoriesScreenState();
}

class _StoreCategoriesScreenState extends State<StoreCategoriesScreen> {
  late ScrollController _scrollController;
  @override
  void initState() {
    // TODO: implement initState
    _scrollController = ScrollController();
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        // near bottom
        Get.find<StoreController>().loadNextItems();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This code will run after the first frame is built
      if (mounted) {
        // Good practice to check if the widget is still mounted
        Get.find<StoreController>().getSubCatWithItems();
        // If getSubCatWithItems takes an argument, pass it here,
        // e.g., Get.find<StoreController>().getSubCatWithItems(someInitialId);
      }
    });
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (storeController) {
      Store? store;
      if (storeController.store != null) {
        store = storeController.store;
      }
      bool ltr = Get.find<LocalizationController>().isLtr;
      return Scaffold(
        backgroundColor: Theme.of(context).disabledColor.withOpacity(.2),
        appBar: AppBar(
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: const SizedBox.shrink(),
          leadingWidth: 0,
          titleSpacing: 0,
          title: SizedBox(
            height: 40,
            child: Row(
              children: [
                const SizedBox(width: 8),
                Flexible(
                  flex: 1,
                  child: InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                      // height: 50,
                      // width: 50,
                      // margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            spreadRadius: 1,
                            blurRadius: .5,
                            offset:
                                const Offset(0, 0), // Shadow moves downwards
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.chevron_left,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 6,
                  child: GestureDetector(
                    onTap: () {
                      // Ensure 'store' and 'store.id' are not null before navigating
                      if (store != null && store!.id != null) {
                        Get.toNamed(
                            RouteHelper.getSearchStoreItemRoute(store!.id!));
                      } else {
                        // Handle the case where store or store.id is null, maybe show a message
                        print(
                            "Error: Store ID is null, cannot navigate to search.");
                        // Get.snackbar("Error", "Could not initiate search. Store details missing.");
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            spreadRadius: .5,
                            blurRadius: .5,
                            offset:
                                const Offset(0, 0), // Shadow moves downwards
                          ),
                        ],
                      ),
                      child: AbsorbPointer(
                        // Makes sure the TextFormField doesn't try to handle taps
                        child: TextFormField(
                          enabled: false,
                          // Disables the TextFormField for input
                          decoration: InputDecoration(
                            hintText: "🔍︎  ${'search_products'.tr}",
                            hintStyle: TextStyle(
                              color: Theme.of(context).disabledColor,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Theme.of(context).cardColor,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical:
                                  10, // Added some vertical padding to better center hint text
                            ),
                            // To make it look more like a button if `enabled: false` changes its appearance too much:
                            disabledBorder: OutlineInputBorder(
                              // Define how it looks when disabled
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none, // Keep no border
                            ),
                          ),
                          // style: TextStyle(color: Colors.transparent), // Optional: hides the caret if it still appears
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AppConstants.webHostedUrl.isNotEmpty
                    ? Flexible(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            storeController.shareStore();
                          },
                          child: Container(
                            height: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).cardColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  spreadRadius: 1,
                                  blurRadius: .5,
                                  offset: const Offset(
                                      0, 0), // Shadow moves downwards
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.share,
                              size: 17,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        body: (storeController.store != null &&
                storeController.store!.name != null)
            ? SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      color: Theme.of(context).cardColor,
                      child: Column(
                        children: [
                          const SizedBox(height: 6),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Align(
                              alignment:
                                  ltr ? Alignment.topLeft : Alignment.topRight,
                              child: Text(
                                "available_categories".tr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  // fontSize: 15
                                ),
                              ),
                            ),
                          ),
                          GetBuilder<StoreController>(
                              builder: (storeController) {
                            return SizedBox(
                              height: 100,
                              width: double.infinity,
                              child: GetBuilder<CategoryController>(
                                  builder: (categoryController) {
                                // First, check if the store even has category IDs
                                if (store!.categoryIds == null ||
                                    store.categoryIds!.isEmpty) {
                                  return Container(
                                    padding: const EdgeInsets.all(16.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                        "no_categories_found_for_store".tr),
                                  );
                                }

                                // If categoryList in controller is null (still loading perhaps), show loading
                                // This assumes categoryList is fetched elsewhere and this widget depends on it.
                                // If not, you might need a loading state specific to this process.
                                if (categoryController.categoryList == null) {
                                  return Container(
                                    padding: const EdgeInsets.all(16.0),
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const CircularProgressIndicator(),
                                        const SizedBox(height: 10),
                                        Text("loading_categories".tr),
                                      ],
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  itemCount: store!.categoryIds!.length,
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeSmall,
                                      vertical: Dimensions.paddingSizeSmall),
                                  itemBuilder: (context, index) {
                                    CategoryModel? category;
                                    int? catId;
                                    String errorMessage =
                                        "category_not_found".tr;

                                    if (index < store!.categoryIds!.length) {
                                      catId = store!.categoryIds![index];
                                      if (categoryController.categoryList !=
                                          null) {
                                        category = categoryController
                                            .categoryList!
                                            .firstWhereOrNull((categoryItem) =>
                                                categoryItem.id == catId);
                                      } else {
                                        errorMessage =
                                            "error_loading_category_details".tr;
                                      }
                                    } else {
                                      errorMessage =
                                          "error_loading_category_details".tr;
                                    }

                                    if (category != null) {
                                      return Container(
                                        width: 90,
                                        height: 90,
                                        margin: const EdgeInsets.only(
                                            right: Dimensions.paddingSizeSmall),
                                        // Spacing between items
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                          color: Theme.of(context).cardColor,
                                          border: catId ==
                                                  Get.find<StoreController>()
                                                      .selectedCategoryId
                                              ? Border.all(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  width: 2,
                                                )
                                              : Border.all(
                                                  color: Theme.of(context)
                                                      .disabledColor,
                                                  width: 1,
                                                ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              // Softer shadow
                                              spreadRadius: 1,
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            print(
                                                'Tapped on category: ${category?.name}');
                                            Get.find<StoreController>()
                                                .getSubCategoriesWithItems(
                                                    catId);
                                          },
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions.radiusSmall),
                                                child: CustomImage(
                                                  image:
                                                      category.imageFullUrl ??
                                                          '',
                                                  fit: BoxFit.cover,
                                                  height: 90,
                                                  width: 90,
                                                ),
                                              ),
                                              // Positioned(
                                              //     top: 0,
                                              //     child: Text(
                                              //         category.id.toString())),
                                              Positioned(
                                                bottom: 0,
                                                left: 0,
                                                right: 0,
                                                child: ClipRRect(
                                                  child: BackdropFilter(
                                                    filter: ui.ImageFilter.blur(
                                                      sigmaX: 3.0,
                                                      sigmaY: 3.0,
                                                    ),
                                                    // Adjust blur strength
                                                    child: Container(
                                                      color: Colors.white
                                                          .withOpacity(0.15),
                                                      // Very subtle white tint for the frosted area
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 6.0),
                                                      child: Text(
                                                        category.name ??
                                                            "category_not_found"
                                                                .tr,
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          // Bold often looks good on frosted glass
                                                          color: catId ==
                                                                  Get.find<
                                                                          StoreController>()
                                                                      .selectedCategoryId
                                                              ? Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                              : null,
                                                          // Solid white text
                                                          shadows: const [
                                                            Shadow(
                                                              // A very subtle shadow can still help
                                                              blurRadius: 2.0,
                                                              color: Colors
                                                                  .black26,
                                                              offset: Offset(
                                                                  0.5, 0.5),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      // Placeholder for when category details are not found for a specific ID
                                      return Container(
                                        width: 120,
                                        // Give it the same width
                                        margin: const EdgeInsets.only(
                                            right: Dimensions.paddingSizeSmall),
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                          color: Theme.of(context)
                                              .disabledColor
                                              .withOpacity(0.1),
                                        ),
                                        child: Center(
                                          child: Text(
                                            errorMessage,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error
                                                  .withOpacity(0.7),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                );
                              }),
                            );
                          }),
                          const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall),
                          SizedBox(
                            height: 42,
                            child: Row(
                              children: [
                                ListView.builder(
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: storeController
                                        .selectedStoreSubCategories!.length,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                    itemBuilder: (context, index) {
                                      final int selectedSubCatId =
                                          storeController.selectedSubCategoryId;
                                      final cat = storeController
                                          .selectedStoreSubCategories![index];
                                      return InkWell(
                                        onTap: () => storeController
                                            .getSubCatItems(cat.id),
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          decoration: BoxDecoration(
                                            color: selectedSubCatId == cat.id
                                                ? Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(.3)
                                                : Theme.of(context)
                                                    .disabledColor
                                                    .withOpacity(.3),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              cat.name.toString(),
                                              style: STCRegular.copyWith(
                                                color:
                                                    selectedSubCatId == cat.id
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : null,
                                                fontWeight:
                                                    selectedSubCatId == cat.id
                                                        ? FontWeight.bold
                                                        : null,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    })
                              ],
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          GetBuilder<StoreController>(
                            builder: (controller) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6.0),
                                child: Text(
                                  // Assuming selectedSubCategory getter exists in your controller
                                  // and its 'name' property is what you want to display.
                                  // Also assuming 'name' itself can be null.
                                  controller.selectedSubCategory?.name ??
                                      "Please select a category",
                                  // You can add style, maxLines, etc. here
                                ),
                              );
                            },
                          ),
                          Expanded(
                            child: Divider(
                              color: Theme.of(context).dividerColor,
                              // thickness: 2,
                            ),
                          )
                        ],
                      ),
                    ),
                    (storeController.selectedSubCategory != null &&
                            storeController.selectedSubCategory!.items !=
                                null && // Explicitly check if items list is not null
                            storeController
                                .selectedSubCategory!.items!.isNotEmpty)
                        ? // Also check if it's not empty
                        GridView.builder(
                          controller: _scrollController,
                            itemCount: storeController
                                    .selectedSubCategory!.items!.length ??
                                0,
                            shrinkWrap: true,
                            // physics: const NeverScrollableScrollPhysics(),
                            // Adjust if this grid is the main scroll area
                            padding: const EdgeInsets.all(
                                Dimensions.paddingSizeSmall),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: Dimensions.paddingSizeSmall,
                              crossAxisSpacing: Dimensions.paddingSizeSmall,
                              childAspectRatio:
                                  0.55, // << YOU WILL NEED TO TUNE THIS VALUE
                              // This was your ListView item width: 110.
                              // If your SizedBox height was 200, then 110/200 = 0.55
                              // This is a starting point for height.
                            ),
                            itemBuilder: (context, index) {
                              Item item = storeController
                                  .selectedSubCategory!.items![index];

                              return InkWell(
                                onTap: () {
                                  Get.find<ItemController>().navigateToItemPage(
                                      item, context,
                                      inStore: true, isCampaign: false);
                                },
                                child: Container(
                                  // width: 110, // Width is now controlled by GridView's crossAxisCount
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 0),
                                  // GridView handles spacing via crossAxisSpacing
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .cardColor, // From your original code
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Card(
                                    elevation: 0.1,
                                    // Your original elevation
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          6), // Your original shape
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    // Good to add if Card contains an image
                                    child: Column(
                                      // crossAxisAlignment: CrossAxisAlignment.center, // This will center children horizontally
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      // To make image and text areas take full width
                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween, // Retained from your original
                                      // This will distribute space.
                                      // Be mindful of how much space it creates.
                                      children: [
                                        // To maintain a similar visual proportion to your ListView item (height 80 for image)
                                        // You might need to wrap CustomImage in a SizedBox or AspectRatio if Expanded doesn't give precise control
                                        SizedBox(
                                          height: 80,
                                          // Approximate height from your ListView item
                                          width: double.infinity,
                                          // Take full width of the card
                                          child: CustomImage(
                                            image: item.imageFullUrl.toString(),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Expanded(
                                          // Allow the text and icon area to take remaining space
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4.0, vertical: 4.0),
                                            // Adjust padding
                                            child: Column(
                                              crossAxisAlignment: ltr
                                                  ? CrossAxisAlignment.start
                                                  : CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              // Distribute space within this inner column
                                              children: [
                                                Column(
                                                  // Grouping texts
                                                  crossAxisAlignment: ltr
                                                      ? CrossAxisAlignment.start
                                                      : CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      PriceConverter
                                                              .convertPrice(
                                                                  item.price) ??
                                                          'No Price',
                                                      style:
                                                          STCRegular.copyWith(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    // const SizedBox(height: 2), // Spacing if needed
                                                    Text(
                                                      item.name ?? 'No Name',
                                                      style:
                                                          STCRegular.copyWith(
                                                              fontSize: 13),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    // const SizedBox(height: 2), // Spacing if needed
                                                    Text(
                                                      item.description ??
                                                          'No desc',
                                                      style:
                                                          STCRegular.copyWith(
                                                        fontSize: 11,
                                                        color: Theme.of(context)
                                                            .dividerColor
                                                            .withOpacity(.5),
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Get.find<ItemController>()
                                                        .itemDirectlyAddToCart(
                                                            item, context,
                                                            inStore: true,
                                                            isCampaign: false);
                                                  },
                                                  child: Align(
                                                    // Align the icon to the center bottom of its allocated space
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 4.0),
                                                      // Add some space above the icon
                                                      child: Icon(
                                                        Icons.add,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )

                        // ? ListView.builder(
                        //     // Now it's safer to use '!' because of the checks above
                        //     itemCount: storeController
                        //         .selectedSubCategory!.items!.length,
                        //     shrinkWrap: true,
                        //     scrollDirection: Axis.horizontal,
                        //     physics: const BouncingScrollPhysics(),
                        //     itemBuilder: (context, index) {
                        //       // It's also good practice to access the item from the checked variable
                        //       Item item = storeController
                        //           .selectedSubCategory!.items![index];
                        //       return Container(
                        //         width: 110,
                        //         // Give horizontal list items a fixed width
                        //         margin: const EdgeInsets.symmetric(
                        //           horizontal: 4,
                        //         ),
                        //         // Add some margin
                        //         // padding: const EdgeInsets.symmetric(horizontal: 8),
                        //         decoration: BoxDecoration(
                        //           color: Theme.of(context).cardColor,
                        //           // Changed color for better visibility
                        //           borderRadius: BorderRadius.circular(8),
                        //         ),
                        //         child: Card(
                        //           elevation: .1,
                        //           shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(6),
                        //           ),
                        //           child: Column(
                        //             crossAxisAlignment:
                        //                 CrossAxisAlignment.center,
                        //             mainAxisAlignment:
                        //                 MainAxisAlignment.spaceBetween,
                        //             children: [
                        //               CustomImage(
                        //                 image: item.imageFullUrl.toString(),
                        //                 height: 80,
                        //                 width: 100,
                        //                 fit: BoxFit.cover,
                        //               ),
                        //               Padding(
                        //                 padding: const EdgeInsets.symmetric(
                        //                     horizontal: 2.0),
                        //                 child: Column(
                        //                   crossAxisAlignment: ltr
                        //                       ? CrossAxisAlignment.start
                        //                       : CrossAxisAlignment.end,
                        //                   children: [
                        //                     Align(
                        //                       alignment: ltr
                        //                           ? Alignment.topLeft
                        //                           : Alignment.topRight,
                        //                       child: Text(
                        //                         PriceConverter.convertPrice(
                        //                                 item.price) ??
                        //                             'No Name',
                        //                         // Handle if item.name can be null
                        //
                        //                         style: STCRegular.copyWith(
                        //                           fontSize: 12,
                        //                           fontWeight:
                        //                               FontWeight.bold,
                        //                         ),
                        //                         maxLines: 1,
                        //                         overflow:
                        //                             TextOverflow.ellipsis,
                        //                         textAlign: TextAlign.left,
                        //                       ),
                        //                     ),
                        //                     Align(
                        //                       alignment: ltr
                        //                           ? Alignment.topLeft
                        //                           : Alignment.topRight,
                        //                       child: Text(
                        //                         item.name ?? 'No Name',
                        //                         // Handle if item.name can be null
                        //
                        //                         style: STCRegular.copyWith(
                        //                           fontSize: 13,
                        //                         ),
                        //                         maxLines: 1,
                        //                         overflow:
                        //                             TextOverflow.ellipsis,
                        //                         textAlign: TextAlign.center,
                        //                       ),
                        //                     ),
                        //                     Align(
                        //                       alignment: ltr
                        //                           ? Alignment.topLeft
                        //                           : Alignment.topRight,
                        //                       child: Text(
                        //                         item.description ??
                        //                             'No desc',
                        //                         // Handle if item.name can be null
                        //
                        //                         style: STCRegular.copyWith(
                        //                           fontSize: 11,
                        //                           color: Theme.of(context)
                        //                               .dividerColor
                        //                               .withOpacity(.5),
                        //                         ),
                        //                         maxLines: 2,
                        //                         overflow:
                        //                             TextOverflow.ellipsis,
                        //                         textAlign: TextAlign.center,
                        //                       ),
                        //                     ),
                        //                   ],
                        //                 ),
                        //               ),
                        //               Icon(
                        //                 Icons.add,
                        //                 color: Theme.of(context)
                        //                     .primaryColor,
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //   )
                        : Center(
                            // Show a message or a different UI when there are no items
                            child: Text(
                              storeController.selectedSubCategory == null
                                  ? 'No subcategory selected.'
                                  : (storeController
                                                  .selectedSubCategory!.items ==
                                              null ||
                                          storeController.selectedSubCategory!
                                              .items!.isEmpty)
                                      ? 'No items in this subcategory.'
                                      : 'Loading items...',
                              // Or some other placeholder
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ],
                  // ),
                ),
              )
            : SizedBox(),
      );
    });
  }
}*/
