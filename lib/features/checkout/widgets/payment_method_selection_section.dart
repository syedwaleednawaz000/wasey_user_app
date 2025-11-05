import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart/features/checkout/widgets/payment_method_button.dart';
import '../../../common/widgets/custom_snackbar.dart';
import '../../../helper/auth_helper.dart';
import '../../../helper/responsive_helper.dart';
import '../../../util/images.dart';
import '../../payment/widgets/offline_payment_button.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../splash/controllers/splash_controller.dart';
import '../controllers/checkout_controller.dart';

class PaymentMethodSelectionSection extends StatefulWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isOfflinePaymentActive;
  final bool isWalletActive;
  final int? storeId;
  final double totalPrice;

  const PaymentMethodSelectionSection(
      {super.key,
      required this.isCashOnDeliveryActive,
      required this.isDigitalPaymentActive,
      required this.isWalletActive,
      required this.storeId,
      required this.totalPrice,
      required this.isOfflinePaymentActive});

  @override
  State<PaymentMethodSelectionSection> createState() =>
      _PaymentMethodSelectionSectionState();
}

class _PaymentMethodSelectionSectionState
    extends State<PaymentMethodSelectionSection> {
  bool canSelectWallet = true;
  bool notHideCod = true;
  bool notHideWallet = true;
  bool notHideDigital = true;
  final JustTheController tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      print(
          '=====digital payments : ${Get.find<SplashController>().configModel!.activePaymentMethodList!}');
    }

    if (!AuthHelper.isGuestLoggedIn()) {
      double walletBalance =
          Get.find<ProfileController>().userInfoModel!.walletBalance!;
      if (walletBalance < widget.totalPrice) {
        canSelectWallet = false;
      }
      if (Get.find<CheckoutController>().isPartialPay) {
        notHideWallet = false;
        if (Get.find<SplashController>().configModel!.partialPaymentMethod! ==
            'cod') {
          notHideCod = true;
          notHideDigital = false;
        } else if (Get.find<SplashController>()
                .configModel!
                .partialPaymentMethod! ==
            'digital_payment') {
          notHideCod = false;
          notHideDigital = true;
        } else if (Get.find<SplashController>()
                .configModel!
                .partialPaymentMethod! ==
            'both') {
          notHideCod = true;
          notHideDigital = true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return           SizedBox(
      height: 85,
      width: double.infinity,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child:
        GetBuilder<CheckoutController>(builder: (checkoutController) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isCashOnDeliveryActive && notHideCod)
                PaymentMethodButton(
                  paymentImagePath: Images.codIcon,
                  paymentName: 'cash'.tr,
                  isSelected: checkoutController.paymentMethodIndex == 0,
                  onTap: () {
                    checkoutController.setPaymentMethod(0);
                  },
                ),

              if (widget.storeId == null &&
                  widget.isWalletActive &&
                  notHideWallet &&
                  isLoggedIn)
                PaymentMethodButton(
                  paymentImagePath: Images.partialWallet,
                  paymentName: 'pay_via_wallet'.tr,
                  isSelected: checkoutController.paymentMethodIndex == 1,
                  onTap: () {
                    if (canSelectWallet) {
                      checkoutController.setPaymentMethod(1);
                    } else if (checkoutController.isPartialPay) {
                      showCustomSnackBar(
                          'you_can_not_user_wallet_in_partial_payment'
                              .tr);
                      Get.back();
                    } else {
                      showCustomSnackBar(
                          'your_wallet_have_not_sufficient_balance'.tr);
                      Get.back();
                    }
                  },
                ),

              // Digital Payments (from a list)
              if (widget.storeId == null &&
                  widget.isDigitalPaymentActive &&
                  notHideDigital)
                Row(
                  children: Get.find<SplashController>()
                      .configModel!
                      .activePaymentMethodList!
                      .map((paymentMethod) {
                    bool isSelected =
                        checkoutController.paymentMethodIndex == 2 &&
                            paymentMethod.getWay! ==
                                checkoutController.digitalPaymentName;
                    return PaymentMethodButton(
                      paymentName: paymentMethod.getWayTitle,
                      paymentImagePath: paymentMethod.getWayImageFullUrl,
                      isNetworkImage: true,
                      isSelected: isSelected,
                      onTap: () {
                        checkoutController.setPaymentMethod(2);
                        checkoutController.changeDigitalPaymentName(
                            paymentMethod.getWay!);
                      },
                    );
                  }).toList(),
                ),

              // Offline Payments
              OfflinePaymentButton(
                isSelected: checkoutController.paymentMethodIndex == 3,
                offlineMethodList: checkoutController.offlineMethodList,
                isOfflinePaymentActive: widget.isOfflinePaymentActive,
                onTap: () {
                  checkoutController.setPaymentMethod(3);
                },
                checkoutController: checkoutController,
                tooltipController: tooltipController,
              ),
            ],
          );
        }),
      ),
    );
  }
}
