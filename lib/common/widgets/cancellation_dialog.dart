import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class CancellationDialog extends StatelessWidget {
  final String icon;
  final String? title;
  final Function onYesPressed;
  final bool isLogOut;
  final Function? onNoPressed;
  const CancellationDialog(
      {super.key,
      required this.icon,
      this.title,
      required this.onYesPressed,
      this.isLogOut = false,
      this.onNoPressed});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: PointerInterceptor(
        child: SizedBox(
            width: 500,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Image.asset(
                    icon,
                    width: 50,
                    height: 50,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                title != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeLarge),
                        child: Text(
                          title!,
                          textAlign: TextAlign.center,
                          style: STCMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(height: 50),
                GetBuilder<OrderController>(builder: (orderController) {
                  return !orderController.isLoading
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              TextButton(
                                onPressed: () => onNoPressed != null
                                    ? onNoPressed!()
                                    : Get.back(),
                                style: TextButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .disabledColor
                                      .withAlpha((0.3 * 255).toInt()),
                                  minimumSize: const Size(80, 50),
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall)),
                                ),
                                child: Text(
                                  'no'.tr,
                                  textAlign: TextAlign.center,
                                  style: STCBold.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color),
                                ),
                              ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeLarge),
                              Container(
                                height: 50,
                                width: 80,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .error
                                        .withAlpha((.7 * 255).toInt()),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8))),
                                child: Center(
                                    child: Text(
                                  'yes'.tr,
                                  style: STCRegular.copyWith(
                                      color: Theme.of(context).cardColor),
                                )),
                              ),
                            ])
                      : const Center(child: CircularProgressIndicator());
                }),
              ]),
            )),
      ),
    );
  }
}
