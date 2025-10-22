import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../helper/route_helper.dart';
import '../../language/controllers/language_controller.dart';
import '../../splash/controllers/splash_controller.dart';

class SupportFabWidget extends StatelessWidget {
  const SupportFabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool ltr = Get.find<LocalizationController>().isLtr;
    String? supportPhoneNumber =
        Get.find<SplashController>().configModel!.phone ?? "";
    // String? supportEmail =
    //     Get.find<SplashController>().configModel!.email ?? "";
    // String? appAddress =
    //     Get.find<SplashController>().configModel!.address ?? "";
    // Helper function to launch URLs
    Future<void> _launchUrl(Uri url, {bool isMail = false}) async {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        Get.snackbar(
          'could_not_launch'.tr,
          isMail ? 'could_not_open_email'.tr : 'could_not_make_call'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }

    return SpeedDial(
      icon: Icons.support_agent,
      iconTheme: const IconThemeData(size: 40),
      activeIcon: Icons.close,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      visible: true,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      buttonSize: const Size(56.0, 56.0),
      childrenButtonSize: const Size(60.0, 60.0),
      spaceBetweenChildren: 8.0,
      elevation: 10,
      switchLabelPosition: ltr ? false : true,
      children: [
        // Live Chat Button
        SpeedDialChild(
          child: const Icon(Icons.chat_bubble_outline),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          label: 'live_chat_with_admin'.tr,
          labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.white,
              ),
          labelBackgroundColor: Colors.green,
          visible: true,
          onTap: () {
            Get.toNamed(RouteHelper.getConversationRoute());
          },
        ),

        // Email Button
        // SpeedDialChild(
        //   child: const Icon(Icons.email_outlined),
        //   backgroundColor: Colors.orange,
        //   foregroundColor: Colors.white,
        //   label: 'email_admin'.tr,
        //   labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
        //         color: Colors.white,
        //       ),
        //   labelBackgroundColor: Colors.orange,
        //   onTap: () {
        //     final Uri emailLaunchUri = Uri(
        //       scheme: 'mailto',
        //       path: supportEmail,
        //       query:
        //           'subject=Support Request&body=Hello Admin,', // Pre-fill subject and body
        //     );
        //     Get.dialog(
        //       AlertDialog(
        //         title: Text('compose_email'.tr),
        //         content: Text("${'email_open_app_message'.tr} $supportEmail."),
        //         actions: [
        //           TextButton(
        //               onPressed: () => Get.back(), child: Text('cancel'.tr)),
        //           TextButton(
        //             onPressed: () {
        //               Get.back();
        //               _launchUrl(emailLaunchUri, isMail: true);
        //             },
        //             child: Text('proceed'.tr),
        //           ),
        //         ],
        //       ),
        //     );
        //   },
        // ),

        // Call Button
        SpeedDialChild(
          child: const Icon(Icons.call_outlined),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          label: 'call_support'.tr,
          labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.white,
              ),
          labelBackgroundColor: Colors.blue,
          onTap: () {
            final Uri phoneLaunchUri =
                Uri(scheme: 'tel', path: supportPhoneNumber);
            Get.dialog(
              AlertDialog(
                title: Text('make_a_call'.tr),
                content:
                    Text("${'call_support_message'.tr} $supportPhoneNumber."),
                actions: [
                  TextButton(
                      onPressed: () => Get.back(), child: Text('cancel'.tr)),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      _launchUrl(phoneLaunchUri);
                    },
                    child: Text('call'.tr),
                  ),
                ],
              ),
            );
          },
        ),

        // Address Button (Disabled)
        // SpeedDialChild(
        //   child: const Icon(Icons.location_on_outlined),
        //   backgroundColor: Colors.grey,
        //   foregroundColor: Colors.white,
        //   label: appAddress,
        //   // Use address as the label
        //   labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
        //         color: Colors.white,
        //       ),
        //   labelBackgroundColor: Colors.grey,
        //   onTap: () {
        //     // This button is disabled, so tapping does nothing.
        //     // You can show a snackbar if you want.
        //     Get.snackbar(
        //       'our_address'.tr,
        //       appAddress,
        //       snackPosition: SnackPosition.BOTTOM,
        //     );
        //   },
        // ),
      ],
    );
  }
}
