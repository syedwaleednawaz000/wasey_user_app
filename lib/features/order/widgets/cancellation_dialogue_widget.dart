import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class CancellationDialogueWidget extends StatelessWidget {
  final int? orderId;
  final String? contactNumber;
  const CancellationDialogueWidget(
      {super.key, required this.orderId, this.contactNumber});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      title: Text(
        ' إلغاء الطلب',
        style: STCMedium.copyWith(
          fontSize: Dimensions.fontSizeLarge,
          color: Theme.of(context).primaryColor,
        ),
      ),
      content: Text(
        'هل أنت متأكد أنك تريد إلغاء هذا الطلب؟',
        style: STCRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'لا',
            style: STCMedium.copyWith(color: Theme.of(context).disabledColor),
          ),
        ),
        TextButton(
          onPressed: () async {
            final orderController = Get.find<OrderController>();
            // هنا بنستخدم سبب افتراضي بالعربي
            String cancelReason = 'تم الإلغاء من قبل المستخدم';

            bool success =
                await orderController.cancelOrder(orderId, cancelReason);
            if (success) {
              orderController.trackOrder(orderId.toString(), null, true,
                  contactNumber: contactNumber);
              Get.back();
            }
          },
          child: Text(
            'نعم',
            style:
                STCMedium.copyWith(color: Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }
}
