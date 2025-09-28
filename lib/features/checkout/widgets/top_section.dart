import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart/features/checkout/widgets/guest_create_account.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/common/models/config_model.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_dropdown.dart';
import 'package:sixam_mart/features/cart/widgets/delivery_option_button_widget.dart';
import 'package:sixam_mart/features/checkout/widgets/coupon_section.dart';
import 'package:sixam_mart/features/checkout/widgets/delivery_instruction_view.dart';
import 'package:sixam_mart/features/checkout/widgets/delivery_section.dart';
import 'package:sixam_mart/features/checkout/widgets/deliveryman_tips_section.dart';
import 'package:sixam_mart/features/checkout/widgets/partial_pay_view.dart';
import 'package:sixam_mart/features/checkout/widgets/payment_section.dart';
import 'package:sixam_mart/features/checkout/widgets/time_slot_section.dart';
import 'package:sixam_mart/features/checkout/widgets/web_delivery_instruction_view.dart';
import 'package:sixam_mart/features/store/widgets/camera_button_sheet_widget.dart';
import 'dart:io';
import 'package:sixam_mart/features/checkout/widgets/note_prescription_section.dart';

import '../domain/models/delivery_charges_data_model.dart';

class TopSection extends StatelessWidget {
  final CheckoutController checkoutController;
  final double charge;
  final double deliveryCharge;
  final List<DropdownItem<int>> addressList;
  final bool tomorrowClosed;
  final bool todayClosed;
  final Module? module;
  final double price;
  final double discount;
  final double addOns;
  final int? storeId;
  final List<AddressModel> address;
  final List<CartModel?>? cartList;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  final double total;
  final bool isOfflinePaymentActive;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  final JustTheController tooltipController1;
  final JustTheController tooltipController2;
  final JustTheController dmTipsTooltipController;
  final TextEditingController guestPasswordController;
  final TextEditingController guestConfirmPasswordController;
  final FocusNode guestPasswordNode;
  final FocusNode guestConfirmPasswordNode;
  final double variationPrice;
  final String deliveryChargeForView;
  final double badWeatherCharge;
  final double extraChargeForToolTip;

  const TopSection({
    super.key,
    required this.deliveryCharge,
    required this.charge,
    required this.tomorrowClosed,
    required this.todayClosed,
    required this.price,
    required this.discount,
    required this.addOns,
    required this.addressList,
    required this.checkoutController,
    this.module,
    this.storeId,
    required this.address,
    required this.cartList,
    required this.isCashOnDeliveryActive,
    required this.isDigitalPaymentActive,
    required this.isWalletActive,
    required this.total,
    required this.isOfflinePaymentActive,
    required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController,
    required this.guestNumberNode,
    required this.guestEmailController,
    required this.guestEmailNode,
    required this.tooltipController1,
    required this.tooltipController2,
    required this.dmTipsTooltipController,
    required this.guestPasswordController,
    required this.guestConfirmPasswordController,
    required this.guestPasswordNode,
    required this.guestConfirmPasswordNode,
    required this.variationPrice,
    required this.deliveryChargeForView,
    required this.badWeatherCharge,
    required this.extraChargeForToolTip,
  });

  @override
  Widget build(BuildContext context) {
    bool takeAway = (checkoutController.orderType == 'take_away');
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();

    return Container(
      decoration: ResponsiveHelper.isDesktop(context)
          ? BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)
              ],
            )
          : null,
      child: Column(children: [
        storeId != null
            ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context)
                            .primaryColor
                            .withAlpha((0.05 * 255).toInt()),
                        blurRadius: 10)
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeSmall),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text('your_prescription'.tr, style: STCMedium),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        JustTheTooltip(
                          backgroundColor: Colors.black87,
                          controller: tooltipController1,
                          preferredDirection: AxisDirection.right,
                          tailLength: 14,
                          tailBaseWidth: 20,
                          content: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('prescription_tool_tip'.tr,
                                style:
                                    STCRegular.copyWith(color: Colors.white)),
                          ),
                          child: InkWell(
                            onTap: () => tooltipController1.showTooltip(),
                            child: const Icon(Icons.info_outline),
                          ),
                        ),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount:
                              checkoutController.pickedPrescriptions.length + 1,
                          padding: const EdgeInsets.only(
                              bottom: Dimensions.paddingSizeExtraSmall),
                          itemBuilder: (context, index) {
                            XFile? file = index ==
                                    checkoutController
                                        .pickedPrescriptions.length
                                ? null
                                : checkoutController.pickedPrescriptions[index];
                            if (index < 5 &&
                                index ==
                                    checkoutController
                                        .pickedPrescriptions.length) {
                              return InkWell(
                                onTap: () {
                                  if (ResponsiveHelper.isDesktop(context) ||
                                      GetPlatform.isIOS) {
                                    checkoutController.pickPrescriptionImage(
                                        isRemove: false, isCamera: false);
                                  } else {
                                    Get.bottomSheet(
                                        const CameraButtonSheetWidget());
                                  }
                                },
                                child: DottedBorder(
                                  color: Theme.of(context).primaryColor,
                                  strokeWidth: 1,
                                  strokeCap: StrokeCap.butt,
                                  dashPattern: const [5, 5],
                                  padding: const EdgeInsets.all(0),
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(
                                      Dimensions.radiusDefault),
                                  child: Container(
                                    height: 98,
                                    width: 98,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall),
                                    ),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.cloud_upload,
                                              color: Theme.of(context)
                                                  .disabledColor,
                                              size: 32),
                                          Text(
                                            'upload_your_prescription'.tr,
                                            style: STCRegular.copyWith(
                                                color: Theme.of(context)
                                                    .disabledColor,
                                                fontSize:
                                                    Dimensions.fontSizeSmall),
                                            textAlign: TextAlign.center,
                                          ),
                                        ]),
                                  ),
                                ),
                              );
                            }
                            return file != null
                                ? Container(
                                    margin: const EdgeInsets.only(
                                        right: Dimensions.paddingSizeSmall),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall),
                                    ),
                                    child: DottedBorder(
                                      color: Theme.of(context).primaryColor,
                                      strokeWidth: 1,
                                      strokeCap: StrokeCap.butt,
                                      dashPattern: const [5, 5],
                                      padding: const EdgeInsets.all(0),
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(
                                          Dimensions.radiusDefault),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Stack(children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusDefault),
                                            child: GetPlatform.isWeb
                                                ? Image.network(
                                                    file.path,
                                                    width: 98,
                                                    height: 98,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.file(
                                                    File(file.path),
                                                    width: 98,
                                                    height: 98,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: InkWell(
                                              onTap: () => checkoutController
                                                  .removePrescriptionImage(
                                                      index),
                                              child: const Padding(
                                                padding: EdgeInsets.all(
                                                    Dimensions
                                                        .paddingSizeSmall),
                                                child: Icon(
                                                    Icons.delete_forever,
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                  )
                                : const SizedBox();
                          },
                        ),
                      ),
                    ]),
              )
            : const SizedBox(),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        // delivery option
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context)
                      .primaryColor
                      .withAlpha((0.05 * 255).toInt()),
                  blurRadius: 10)
            ],
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
              vertical: Dimensions.paddingSizeSmall),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('delivery_type'.tr, style: STCMedium),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              storeId != null
                  ? DeliveryOptionButtonWidget(
                      value: 'delivery',
                      title: 'home_delivery'.tr,
                      charge: deliveryCharge,
                      //charge,
                      isFree: checkoutController.store!.freeDelivery,
                      fromWeb: true,
                      total: total,
                      deliveryChargeForView: deliveryChargeForView,
                      badWeatherCharge: badWeatherCharge,
                      extraChargeForToolTip: extraChargeForToolTip,
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        Get.find<SplashController>()
                                        .configModel!
                                        .homeDeliveryStatus ==
                                    1 &&
                                checkoutController.store!.delivery!
                            ? DeliveryOptionButtonWidget(
                                value: 'delivery',
                                title: 'home_delivery'.tr,
                                charge:
                                    checkoutController.orderType == "delivery"
                                        ? deliveryCharge
                                        : 0.00,
                                isFree: checkoutController.store!.freeDelivery,
                                fromWeb: true,
                                total: total,
                                deliveryChargeForView:
                                    checkoutController.orderType == "delivery"
                                        ? deliveryChargeForView
                                        : "free".tr,
                                badWeatherCharge: badWeatherCharge,
                                extraChargeForToolTip: extraChargeForToolTip,
                              )
                            : const SizedBox(),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Get.find<SplashController>()
                                        .configModel!
                                        .takeawayStatus ==
                                    1 &&
                                checkoutController.store!.takeAway!
                            ? DeliveryOptionButtonWidget(
                                value: 'take_away',
                                title: 'take_away'.tr,
                                charge: deliveryCharge,
                                isFree: true,
                                fromWeb: true,
                                total: total,
                                deliveryChargeForView: deliveryChargeForView,
                                badWeatherCharge: badWeatherCharge,
                                extraChargeForToolTip: extraChargeForToolTip,
                              )
                            : const SizedBox(),
                      ]),
                    ),
              checkoutController.orderType == "delivery"
                  ? Obx(() {
                      // <-- Add Obx here to listen to controller's reactive variables
                      return checkoutController.deliveryChargesList.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                Text("delivery_charge".tr, style: STCMedium),
                                SizedBox(
                                  // color: Colors.green,
                                  height: 70,
                                  width: double.infinity,
                                  child: ListView.builder(
                                      itemCount: checkoutController
                                          .deliveryChargesList.length,
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      // padding: const EdgeInsets.symmetric(
                                      //     horizontal: 4),
                                      physics: const BouncingScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final DeliveryChargeData chargeItem =
                                            checkoutController
                                                .deliveryChargesList[index];
                                        final bool isSelected = checkoutController
                                                .currentSelectedDeliveryChargesData
                                                .value
                                                ?.id ==
                                            chargeItem.id;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: InkWell(
                                            onTap: () {
                                              // ALWAYS allow tap
                                              checkoutController
                                                  .toggleSelectedChargesCity(
                                                      chargeItem);
                                            },
                                            child: Chip(
                                              backgroundColor: isSelected
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                  : Theme.of(context)
                                                      .chipTheme
                                                      .backgroundColor,
                                              // Use theme default if not selected
                                              labelPadding: isSelected
                                                  ? const EdgeInsets.only(
                                                      left: 8,
                                                      right:
                                                          4) // Adjust padding for icon
                                                  : null,
                                              label: Text(
                                                chargeItem.city,
                                                style: TextStyle(
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.color, // Adjust for theme
                                                ),
                                              ),
                                              // Conditionally add a check icon if selected
                                              avatar: isSelected
                                                  ? const Icon(
                                                      Icons.check,
                                                      size: 16,
                                                      color: Colors.white,
                                                    )
                                                  : null,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  // Or your preferred chip shape
                                                  side: BorderSide(
                                                    color: isSelected
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Colors.grey,
                                                    // Example border
                                                    width: 1,
                                                  )),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            )
                          : const SizedBox.shrink();
                    })
                  : const SizedBox.shrink()
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        /*///Delivery_fee
        !takeAway && !isGuestLoggedIn ? Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('${'delivery_charge'.tr}: '),
          Text(
            checkoutController.store!.freeDelivery! ? 'free'.tr
                : checkoutController.distance != -1 ? PriceConverter.convertPrice(charge) : 'calculating'.tr,
            textDirection: TextDirection.ltr,
          ),
        ])) : const SizedBox(),
        SizedBox(height: !takeAway && !isGuestLoggedIn ? Dimensions.paddingSizeLarge : 0),*/

        ///delivery section
        DeliverySection(
          checkoutController: checkoutController,
          address: address,
          addressList: addressList,
          guestNameTextEditingController: guestNameTextEditingController,
          guestNumberTextEditingController: guestNumberTextEditingController,
          guestNumberNode: guestNumberNode,
          guestEmailController: guestEmailController,
          guestEmailNode: guestEmailNode,
        ),

        SizedBox(
            height: !takeAway
                ? isDesktop
                    ? Dimensions.paddingSizeLarge
                    : Dimensions.paddingSizeSmall
                : 0),

        ///delivery instruction
        !takeAway
            ? isDesktop
                ? const WebDeliveryInstructionView()
                : const DeliveryInstructionView()
            : const SizedBox(),
        SizedBox(
            height: !takeAway
                ? isDesktop
                    ? Dimensions.paddingSizeLarge
                    : Dimensions.paddingSizeSmall
                : 0),

        ///Create Account with existing info

        isGuestLoggedIn &&
                Get.find<SplashController>()
                    .configModel!
                    .centralizeLoginSetup!
                    .manualLoginStatus!
            ? GuestCreateAccount(
                guestPasswordController: guestPasswordController,
                guestConfirmPasswordController: guestConfirmPasswordController,
                guestPasswordNode: guestPasswordNode,
                guestConfirmPasswordNode: guestConfirmPasswordNode,
              )
            : const SizedBox(),
        SizedBox(
            height: isGuestLoggedIn &&
                    Get.find<SplashController>()
                        .configModel!
                        .centralizeLoginSetup!
                        .manualLoginStatus!
                ? Dimensions.paddingSizeSmall
                : 0),

        /// Time Slot
        TimeSlotSection(
          storeId: storeId,
          checkoutController: checkoutController,
          cartList: cartList,
          tooltipController2: tooltipController2,
          tomorrowClosed: tomorrowClosed,
          todayClosed: todayClosed,
          module: module,
        ),
        NoteAndPrescriptionSection(
            checkoutController: checkoutController, storeId: storeId),

        /// Coupon..
        !isDesktop && !isGuestLoggedIn
            ? CouponSection(
                storeId: storeId,
                checkoutController: checkoutController,
                total: total,
                price: price,
                discount: discount,
                addOns: addOns,
                deliveryCharge: deliveryCharge,
                variationPrice: variationPrice,
              )
            : const SizedBox(),

        ///DmTips..
        DeliveryManTipsSection(
          takeAway: takeAway,
          tooltipController3: dmTipsTooltipController,
          totalPrice: total,
          onTotalChange: (double price) => total + price,
          storeId: storeId,
        ),

        ///Payment..
        Container(
          decoration: isDesktop
              ? const BoxDecoration()
              : BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context)
                            .primaryColor
                            .withAlpha((0.05 * 255).toInt()),
                        blurRadius: 10)
                  ],
                ),
          padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeLarge,
              horizontal: Dimensions.paddingSizeLarge),
          child: Column(children: [
            PaymentSection(
              storeId: storeId,
              isCashOnDeliveryActive: isCashOnDeliveryActive,
              isDigitalPaymentActive: isDigitalPaymentActive,
              isWalletActive: isWalletActive,
              total: total,
              checkoutController: checkoutController,
              isOfflinePaymentActive: isOfflinePaymentActive,
            ),
            SizedBox(height: isGuestLoggedIn ? 0 : Dimensions.paddingSizeLarge),
            !isDesktop && !isGuestLoggedIn
                ? PartialPayView(
                    totalPrice: total, isPrescription: storeId != null)
                : const SizedBox(),
          ]),
        ),
        SizedBox(height: isDesktop ? Dimensions.paddingSizeLarge : 0),
      ]),
    );
  }
}
