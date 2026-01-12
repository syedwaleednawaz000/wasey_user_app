import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/checkout/domain/models/delivery_charges_data_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class CitySelectorWidget extends StatelessWidget {
  final CheckoutController checkoutController;

  const CitySelectorWidget({
    super.key,
    required this.checkoutController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (checkoutController.deliveryChargesList.isEmpty ||
          checkoutController.orderType != "delivery") {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
            ),
            child: Text(
              "select_delivery_city".tr,
              style: STCMedium,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            width: double.infinity,
            child: ListView.builder(
              itemCount: checkoutController.deliveryChargesList.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
              ),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final DeliveryChargeData chargeItem =
                    checkoutController.deliveryChargesList[index];
                final bool isSelected = checkoutController
                        .currentSelectedDeliveryChargesData.value?.id ==
                    chargeItem.id;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () {
                      checkoutController.toggleSelectedChargesCity(chargeItem);
                    },
                    child: Chip(
                      backgroundColor: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).cardColor,
                      labelPadding: isSelected
                          ? const EdgeInsets.only(left: 8, right: 4)
                          : const EdgeInsets.symmetric(horizontal: 12),
                      label: Text(
                        chargeItem.city,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      avatar: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              size: 18,
                              color: Colors.white,
                            )
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
