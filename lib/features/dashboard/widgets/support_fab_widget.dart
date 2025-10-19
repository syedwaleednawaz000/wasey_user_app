import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart' as FlutterToast;
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportFabWidget extends StatelessWidget {
  const SupportFabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const String supportPhoneNumber = '+972537279686';
    const String supportEmail = 'admin@waseyapp.com';
    const String appAddress = "71 St, Kafr Manda, Israel";
    // Helper function to launch URLs
    Future<void> _launchUrl(Uri url, {bool isMail = false}) async {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        Get.snackbar(
          'Could Not Launch',
          isMail ? 'Could not open email app.' : 'Could not make a call.',
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
      children: [
        // Live Chat Button
        SpeedDialChild(
          child: const Icon(Icons.chat_bubble_outline),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          label: 'Live Chat with Admin',
          labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.white,
              ),
          labelBackgroundColor: Colors.green,
          onTap: () {
            // TODO: Navigate to your live chat screen here
            Get.snackbar(
              'Coming Soon',
              'Live chat functionality will be implemented here.',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),

        // Email Button
        SpeedDialChild(
          child: const Icon(Icons.email_outlined),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          label: 'Email Admin',
          labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.white,
              ),
          labelBackgroundColor: Colors.orange,
          onTap: () {
            final Uri emailLaunchUri = Uri(
              scheme: 'mailto',
              path: supportEmail,
              query:
                  'subject=Support Request&body=Hello Admin,', // Pre-fill subject and body
            );
            Get.dialog(
              AlertDialog(
                title: const Text('Compose Email'),
                content: Text(
                    'This will open your email app to compose a message to $supportEmail.'),
                actions: [
                  TextButton(
                      onPressed: () => Get.back(), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      _launchUrl(emailLaunchUri, isMail: true);
                    },
                    child: const Text('Proceed'),
                  ),
                ],
              ),
            );
          },
        ),

        // Call Button
        SpeedDialChild(
          child: const Icon(Icons.call_outlined),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          label: 'Call Support',
          labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.white,
              ),
          labelBackgroundColor: Colors.blue,
          onTap: () {
            final Uri phoneLaunchUri =
                Uri(scheme: 'tel', path: supportPhoneNumber);
            Get.dialog(
              AlertDialog(
                title: const Text('Make a Call'),
                content: Text(
                    'This will make a phone call to support at $supportPhoneNumber.'),
                actions: [
                  TextButton(
                      onPressed: () => Get.back(), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      _launchUrl(phoneLaunchUri);
                    },
                    child: const Text('Call'),
                  ),
                ],
              ),
            );
          },
        ),

        // Address Button (Disabled)
        SpeedDialChild(
          child: const Icon(Icons.location_on_outlined),
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          label: appAddress,
          // Use address as the label
          labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.white,
              ),
          labelBackgroundColor: Colors.grey,
          onTap: () {
            // This button is disabled, so tapping does nothing.
            // You can show a snackbar if you want.
            Get.snackbar(
              'Our Address',
              appAddress,
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      ],
    );
  }
}
