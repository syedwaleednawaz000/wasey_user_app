import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class FilterView extends StatelessWidget {
  final StoreController storeController;

  const FilterView({super.key, required this.storeController});

  @override
  Widget build(BuildContext context) {
    final String filterType = storeController.filterType;
    return storeController.storeModel != null
        ? PopupMenuButton(
            padding: EdgeInsets.zero,
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 'all',
                  child: Container(
                    width: double.infinity,
                    padding: filterType == 'all'
                        ? const EdgeInsets.symmetric(horizontal: 6)
                        : null,
                    color: filterType == 'all'
                        ? Theme.of(context).primaryColor
                        : null,
                    child: Text('all'.tr,
                        style: STCMedium.copyWith(
                          color: filterType == 'all'
                              ? Theme.of(context).textTheme.bodyLarge!.color
                              : Theme.of(context).disabledColor,
                        )),
                  ),
                ),
                PopupMenuItem(
                  value: 'take_away',
                  child: Container(
                    width: double.infinity,
                    padding: filterType == 'take_away'
                        ? const EdgeInsets.symmetric(horizontal: 6)
                        : null,
                    color: filterType == 'take_away'
                        ? Theme.of(context).primaryColor
                        : null,
                    child: Text('take_away'.tr,
                        style: STCMedium.copyWith(
                          color: filterType == 'take_away'
                              ? Theme.of(context).textTheme.bodyLarge!.color
                              : Theme.of(context).disabledColor,
                        )),
                  ),
                ),
                PopupMenuItem(
                  value: 'delivery',
                  child: Container(
                    width: double.infinity,
                    padding: filterType == 'delivery'
                        ? const EdgeInsets.symmetric(horizontal: 6)
                        : null,
                    color: filterType == 'delivery'
                        ? Theme.of(context).primaryColor
                        : null,
                    child: Text('delivery'.tr,
                        style: STCMedium.copyWith(
                          color: filterType == 'delivery'
                              ? Theme.of(context).textTheme.bodyLarge!.color
                              : Theme.of(context).disabledColor,
                        )),
                  ),
                ),
              ];
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                Dimensions.radiusSmall,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withAlpha((0.3 * 255).toInt()),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child: Icon(
                  Icons.filter_list,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            onSelected: (dynamic value) => storeController.setFilterType(value),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                border: Border.all(color: Theme.of(context).disabledColor),
              ),
              child: Icon(Icons.filter_list,
                  color: Theme.of(context).disabledColor),
            ),
          );
  }
}
