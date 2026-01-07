import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';

// import 'package:sixam_mart/helper/route_helper.dart'; // For navigating on success
import 'dart:developer';

import 'package:sixam_mart/util/app_constants.dart';

class TranzilaWebPaymentScreen extends StatefulWidget {
  final String orderID;

  const TranzilaWebPaymentScreen({
    super.key,
    required this.orderID,
  });

  @override
  State<TranzilaWebPaymentScreen> createState() =>
      _TranzilaWebPaymentScreenState();
}

class _TranzilaWebPaymentScreenState extends State<TranzilaWebPaymentScreen> {
  InAppWebViewController? _webViewController;
  late final Uri _paymentUrl;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _paymentUrl = Uri.parse(
        '${AppConstants.baseUrl}/payment/tranzila/pay?order_id=${widget.orderID}');
    log('Payment URL: $_paymentUrl');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "complete_payment".tr,
        backButton: true,
      ),
      // AppBar(
      //   title: const Text('Complete Payment'),
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back_ios_new_rounded),
      //     onPressed: () {
      //       // Optional: Show a confirmation dialog before canceling payment
      //       Get.back();
      //     },
      //   ),
      // ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri.uri(_paymentUrl)),
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: true,
              // This is key for intercepting navigation
              javaScriptEnabled: true,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStart: (controller, url) {
              log('WebView: Page started loading: $url');
              setState(() {
                _progress = 0;
              });

              // 2. Listen for the success or failure URL to navigate away
              // IMPORTANT: Adjust these URLs to match what Tranzila redirects to
              const String successUrlIdentifier = '/payment/tranzila/success'; // Example
              const String failureUrlIdentifier = '/payment/tranzila/fail'; // Example

              if (url.toString().contains(successUrlIdentifier)) {
                log('Payment Successful, redirecting to Order Success Screen.');
                // Use offNamed to prevent user from going back to the payment page
                // Get.offNamed(RouteHelper.getOrderSuccessRoute(widget.orderID));

                // Stop the webview from actually loading the success page
                controller.stopLoading();
              } else if (url.toString().contains(failureUrlIdentifier)) {
                log('Payment Failed, navigating back.');
                Get.back(); // Go back to the checkout screen
                // You might want to show a "Payment Failed" snackbar or dialog here

                // Stop the webview from actually loading the failure page
                controller.stopLoading();
              }
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                _progress = progress / 100;
              });
            },
            onLoadStop: (controller, url) {
              log('WebView: Page finished loading: $url');
            },
            onLoadError: (controller, url, code, message) {
              log('WebView: Error loading $url, Error: $message');
              // Optionally show an error message to the user
            },
          ),

          // Show a progress indicator at the top
          if (_progress < 1.0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(value: _progress),
            ),
        ],
      ),
    );
  }
}
