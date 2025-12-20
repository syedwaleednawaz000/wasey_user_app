import 'dart:developer';

import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart/common/widgets/custom_tool_tip_widget.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/images.dart';
import '../../dashboard/controllers/delivery_working_hours_schedule_controller.dart';

class DeliveryOptionButtonWidget extends StatefulWidget {
  final String value;
  final String title;
  final double? charge;
  final bool? isFree;
  final bool fromWeb;
  final bool isNewUI;
  final double total;
  final String deliveryChargeForView;
  final double badWeatherCharge;
  final double extraChargeForToolTip;

  const DeliveryOptionButtonWidget(
      {super.key,
      required this.value,
      required this.title,
      required this.charge,
      required this.isFree,
      this.fromWeb = false,
      this.isNewUI = false,
      required this.total,
      required this.deliveryChargeForView,
      required this.badWeatherCharge,
      required this.extraChargeForToolTip});

  @override
  State<DeliveryOptionButtonWidget> createState() =>
      _DeliveryOptionButtonWidgetState();
}

class _DeliveryOptionButtonWidgetState
    extends State<DeliveryOptionButtonWidget> {
  @override
  void initState() {
    super.initState();

    // Schedule the logic to run after the first frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Check if TimeSlotController is registered, if not register it
      if (!Get.isRegistered<TimeSlotController>()) {
        Get.lazyPut(() => TimeSlotController(apiClient: Get.find()));
      }
      
      // 1. Get controller instances once.
      final checkoutController = Get.find<CheckoutController>();
      final timeSlotController = Get.find<TimeSlotController>();
      final splashController = Get.find<SplashController>();

      bool isDeliveryActive = true; // Assume delivery is active by default.
      await timeSlotController.fetchTimeSlots();
      // 3. Check the delivery system status from the fetched time slots.
      if (timeSlotController.timeSlot != null) {
        isDeliveryActive =
            timeSlotController.timeSlot!.deliverySlotSystemEnabled ?? true;
      }

      // 4. Determine the correct order type based on all conditions.
      // This logic is now much cleaner and easier to read.
      bool canDeliver = splashController.configModel!.homeDeliveryStatus == 1 &&
          checkoutController.store!.delivery! &&
          isDeliveryActive;

      String orderType = canDeliver ? 'delivery' : 'take_away';

      // 5. Set the order type. This is now safe to call.
      checkoutController.setOrderType(orderType, notify: true);
      log("Initial order type set to: $orderType");
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //
  //   bool? _isDeliveryActive;
  //
  //   //For new incorporation if delivery is off then not show delivery in screen
  //   if (Get.find<TimeSlotController>().timeSlot != null) {
  //     _isDeliveryActive =
  //         Get.find<TimeSlotController>().timeSlot!.deliverySlotSystemEnabled;
  //     if (!_isDeliveryActive) {
  //       Get.find<CheckoutController>().setOrderType("take_away");
  //       log("order type Set to take_away");
  //     }
  //   } else {
  //     Get.find<TimeSlotController>().fetchTimeSlots();
  //     if (Get.find<TimeSlotController>().timeSlot != null) {
  //       _isDeliveryActive =
  //           Get.find<TimeSlotController>().timeSlot!.deliverySlotSystemEnabled;
  //       if (!_isDeliveryActive) {
  //         Get.find<CheckoutController>().setOrderType("take_away");
  //         log("order type Set to take_away");
  //       }
  //     }
  //   }
  //
  //   Future.delayed(const Duration(milliseconds: 200), () {
  //     Get.find<CheckoutController>().setOrderType(
  //         ((Get.find<SplashController>().configModel!.homeDeliveryStatus == 1 &&
  //             Get.find<CheckoutController>().store!.delivery!) &&
  //             !_isDeliveryActive!)
  //             ? 'delivery'
  //             : 'take_away',
  //         notify: true);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(
      builder: (checkoutController) {
        bool select = checkoutController.orderType == widget.value;
        return widget.isNewUI
            ? InkWell(
                onTap: () {
                  checkoutController.setOrderType(widget.value);
                  checkoutController.setInstruction(-1);

                  if (checkoutController.orderType == 'take_away') {
                    if (checkoutController.isPartialPay) {
                      double tips = 0;
                      try {
                        tips =
                            double.parse(checkoutController.tipController.text);
                      } catch (_) {}
                      checkoutController.checkBalanceStatus(
                          widget.total, widget.charge! + tips);
                    }
                  } else {
                    if (checkoutController.isPartialPay) {
                      checkoutController.changePartialPayment();
                    } else {
                      checkoutController.setPaymentMethod(-1);
                    }
                  }
                },
                child: Container(
                    decoration: BoxDecoration(
                      color: select
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).disabledColor.withOpacity(.2),
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusDefault,
                      ),
                      border: Border.all(
                        color: select
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor.withOpacity(.3),
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      left: Dimensions.paddingSizeSmall,
                      right: Dimensions.paddingSizeSmall,
                      bottom: Dimensions.paddingSizeExtraSmall,
                      top: 0,
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          widget.value == "delivery"
                              ? CustomAssetImageWidget(
                                  height: 85,
                                  fit: BoxFit.fitHeight,
                                  select
                                      ? Images.deliveryClicked
                                      : Images.deliveryNotClicked)
                              : CustomAssetImageWidget(
                                  height: 85,
                                  fit: BoxFit.fitHeight,
                                  select
                                      ? Images.pickupClicked
                                      : Images.pickupNotClicked),
                          Text(
                            widget.title,
                            style: STCMedium.copyWith(
                              fontSize: 16, // ← تم تكبير الخط هنا
                              fontWeight: select ? FontWeight.bold : null,
                              color: select
                                  ? Colors.white
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color!
                                      .withOpacity(.5),
                            ),
                          ),
                        ])),
              )
            : InkWell(
                onTap: () {
                  checkoutController.setOrderType(widget.value);
                  checkoutController.setInstruction(-1);

                  if (checkoutController.orderType == 'take_away') {
                    if (checkoutController.isPartialPay) {
                      double tips = 0;
                      try {
                        tips =
                            double.parse(checkoutController.tipController.text);
                      } catch (_) {}
                      checkoutController.checkBalanceStatus(
                          widget.total, widget.charge! + tips);
                    }
                  } else {
                    if (checkoutController.isPartialPay) {
                      checkoutController.changePartialPayment();
                    } else {
                      checkoutController.setPaymentMethod(-1);
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: select
                        ? widget.fromWeb
                            ? Theme.of(context)
                                .primaryColor
                                .withAlpha((0.1 * 255).toInt())
                            : Theme.of(context).cardColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    border: Border.all(
                        color: select
                            ? Theme.of(context).primaryColor
                            : Colors.transparent),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall,
                      vertical: Dimensions.paddingSizeExtraSmall),
                  child: Row(
                    children: [
                      Radio(
                        value: widget.value,
                        groupValue: checkoutController.orderType,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (String? value) {
                          checkoutController.setOrderType(value);
                        },
                        activeColor: Theme.of(context).primaryColor,
                        visualDensity:
                            const VisualDensity(horizontal: -3, vertical: -3),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.title,
                                style: STCMedium.copyWith(
                                    fontSize: 20, // ← تم تكبير الخط هنا
                                    color: select
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color)),
                            Row(children: [
                              Text(
                                  widget.value == 'delivery'
                                      ? '${'charge'.tr}: +${widget.deliveryChargeForView}'
                                      : 'free'.tr,
                                  style: STCMedium.copyWith(
                                      fontSize: 20,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color)),
                              const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall),
                              widget.deliveryChargeForView !=
                                          PriceConverter.convertPrice(0) &&
                                      widget.value == 'delivery' &&
                                      checkoutController.extraCharge != null &&
                                      (widget.deliveryChargeForView != '0') &&
                                      widget.extraChargeForToolTip > 0
                                  ? CustomToolTip(
                                      message:
                                          '${'this_charge_include_extra_vehicle_charge'.tr} ${PriceConverter.convertPrice(widget.extraChargeForToolTip)} ${widget.badWeatherCharge > 0 ? '${'and_bad_weather_charge'.tr} ${PriceConverter.convertPrice(widget.badWeatherCharge)}' : ''}',
                                      preferredDirection: AxisDirection.right,
                                      child: const Icon(Icons.info,
                                          color: Colors.blue, size: 14),
                                    )
                                  : const SizedBox(),
                            ]),
                          ]),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
//
// class DeliveryOptionButtonWidget extends StatefulWidget {
//   final String value;
//   final String title;
//   final double? charge;
//   final bool? isFree;
//   final bool fromWeb;
//   final double total;
//   final String deliveryChargeForView;
//   final double badWeatherCharge;
//   final double extraChargeForToolTip;
//   const DeliveryOptionButtonWidget(
//       {super.key,
//       required this.value,
//       required this.title,
//       required this.charge,
//       required this.isFree,
//       this.fromWeb = false,
//       required this.total,
//       required this.deliveryChargeForView,
//       required this.badWeatherCharge,
//       required this.extraChargeForToolTip});
//
//   @override
//   State<DeliveryOptionButtonWidget> createState() =>
//       _DeliveryOptionButtonWidgetState();
// }
//
// class _DeliveryOptionButtonWidgetState
//     extends State<DeliveryOptionButtonWidget> {
//   @override
//   void initState() {
//     super.initState();
//
//     Future.delayed(const Duration(milliseconds: 200), () {
//       Get.find<CheckoutController>().setOrderType(
//           Get.find<SplashController>().configModel!.homeDeliveryStatus == 1 &&
//                   Get.find<CheckoutController>().store!.delivery!
//               ? 'delivery'
//               : 'take_away',
//           notify: true);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<CheckoutController>(
//       builder: (checkoutController) {
//         bool select = checkoutController.orderType == widget.value;
//
//         return InkWell(
//           onTap: () {
//             checkoutController.setOrderType(widget.value);
//             checkoutController.setInstruction(-1);
//
//             if (checkoutController.orderType == 'take_away') {
//               if (checkoutController.isPartialPay) {
//                 double tips = 0;
//                 try {
//                   tips = double.parse(checkoutController.tipController.text);
//                 } catch (_) {}
//                 checkoutController.checkBalanceStatus(
//                     widget.total, widget.charge! + tips);
//               }
//             } else {
//               if (checkoutController.isPartialPay) {
//                 checkoutController.changePartialPayment();
//               } else {
//                 checkoutController.setPaymentMethod(-1);
//               }
//             }
//           },
//           child: Container(
//             decoration: BoxDecoration(
//               color: select
//                   ? widget.fromWeb
//                       ? Theme.of(context).primaryColor.withAlpha((0.1 * 255).toInt())
//                       : Theme.of(context).cardColor
//                   : Colors.transparent,
//               borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//               border: Border.all(
//                   color: select
//                       ? Theme.of(context).primaryColor
//                       : Colors.transparent),
//             ),
//             padding: const EdgeInsets.symmetric(
//                 horizontal: Dimensions.paddingSizeSmall,
//                 vertical: Dimensions.paddingSizeExtraSmall),
//             child: Row(
//               children: [
//                 Radio(
//                   value: widget.value,
//                   groupValue: checkoutController.orderType,
//                   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                   onChanged: (String? value) {
//                     checkoutController.setOrderType(value);
//                   },
//                   activeColor: Theme.of(context).primaryColor,
//                   visualDensity:
//                       const VisualDensity(horizontal: -3, vertical: -3),
//                 ),
//                 const SizedBox(width: Dimensions.paddingSizeSmall),
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Text(widget.title,
//                       style: STCMedium.copyWith(
//                            fontSize: 20, // ← تم تكبير الخط هنا
//                           color: select
//                               ? Theme.of(context).primaryColor
//                               : Theme.of(context).textTheme.bodyMedium!.color)),
//                   Row(children: [
//                     Text(
//                         widget.value == 'delivery'
//                             ? '${'charge'.tr}: +${widget.deliveryChargeForView}'
//                             : 'free'.tr,
//                         style: STCMedium.copyWith(
//                             fontSize: 20,
//                             color:
//                                 Theme.of(context).textTheme.bodyMedium!.color)),
//                     const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//                     widget.deliveryChargeForView !=
//                                 PriceConverter.convertPrice(0) &&
//                             widget.value == 'delivery' &&
//                             checkoutController.extraCharge != null &&
//                             (widget.deliveryChargeForView != '0') &&
//                             widget.extraChargeForToolTip > 0
//                         ? CustomToolTip(
//                             message:
//                                 '${'this_charge_include_extra_vehicle_charge'.tr} ${PriceConverter.convertPrice(widget.extraChargeForToolTip)} ${widget.badWeatherCharge > 0 ? '${'and_bad_weather_charge'.tr} ${PriceConverter.convertPrice(widget.badWeatherCharge)}' : ''}',
//                             preferredDirection: AxisDirection.right,
//                             child: const Icon(Icons.info,
//                                 color: Colors.blue, size: 14),
//                           )
//                         : const SizedBox(),
//                   ]),
//                 ]),
//                 const SizedBox(width: Dimensions.paddingSizeSmall),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
