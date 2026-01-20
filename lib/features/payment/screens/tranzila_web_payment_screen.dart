// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// // // import 'package:get/get.dart';
// // // import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
// // //
// // // // import 'package:sixam_mart/helper/route_helper.dart'; // For navigating on success
// // // import 'dart:developer';
// // //
// // // import 'package:sixam_mart/util/app_constants.dart';
// // //
// // // import '../../../helper/route_helper.dart';
// // //
// // // class TranzilaWebPaymentScreen extends StatefulWidget {
// // //   final String orderID;
// // //
// // //   const TranzilaWebPaymentScreen({
// // //     super.key,
// // //     required this.orderID,
// // //   });
// // //
// // //   @override
// // //   State<TranzilaWebPaymentScreen> createState() =>
// // //       _TranzilaWebPaymentScreenState();
// // // }
// // //
// // // class _TranzilaWebPaymentScreenState extends State<TranzilaWebPaymentScreen> {
// // //   InAppWebViewController? _webViewController;
// // //   late final Uri _paymentUrl;
// // //   double _progress = 0;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _paymentUrl = Uri.parse(
// // //         '${AppConstants.baseUrl}/payment/tranzila/pay?order_id=${widget.orderID}');
// // //     log('Payment URL: $_paymentUrl');
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     void handleBackNavigation() {
// // //       log("Back navigation action initiated. Showing confirmation dialog.");
// // //
// // //       Get.dialog(
// // //         Dialog(
// // //           shape:
// // //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// // //           child: Padding(
// // //             padding: const EdgeInsets.all(16.0),
// // //             child: Column(
// // //               mainAxisSize: MainAxisSize.min,
// // //               children: [
// // //                 Text(
// // //                   "are_you_sure_you_want_to_go_back".tr,
// // //                   style: const TextStyle(
// // //                     fontWeight: FontWeight.bold,
// // //                     fontSize: 16,
// // //                   ),
// // //                   textAlign: TextAlign.center,
// // //                 ),
// // //                 const SizedBox(height: 20),
// // //                 Row(
// // //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// // //                   children: [
// // //                     TextButton(
// // //                       onPressed: () {
// // //                         Get.back(); // Just closes the dialog
// // //                       },
// // //                       child: Text(
// // //                         "cancel".tr,
// // //                         style:
// // //                             TextStyle(color: Theme.of(context).disabledColor),
// // //                       ),
// // //                     ),
// // //
// // //                     // The "Back to Home" button
// // //                     ElevatedButton(
// // //                       style: ElevatedButton.styleFrom(
// // //                         backgroundColor: Theme.of(context).primaryColor,
// // //                         shape: RoundedRectangleBorder(
// // //                           borderRadius: BorderRadius.circular(8),
// // //                         ),
// // //                       ),
// // //                       onPressed: () {
// // //                         log("User confirmed. Redirecting to initial route.");
// // //                         // This is your original navigation logic
// // //                         Get.offAllNamed(RouteHelper.getInitialRoute());
// // //                       },
// // //                       child: Text(
// // //                         "back_to_home".tr,
// // //                         style: const TextStyle(color: Colors.white),
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //         barrierDismissible: true, // User can tap outside the dialog to cancel
// // //       );
// // //     }
// // //
// // //     return WillPopScope(
// // //       onWillPop: () async {
// // //         handleBackNavigation();
// // //         return false;
// // //       },
// // //       child: Scaffold(
// // //         appBar: CustomAppBar(
// // //           title: "complete_payment".tr,
// // //           backButton: true,
// // //           onBackPressed: handleBackNavigation,
// // //         ),
// // //         body: Stack(
// // //           children: [
// // //             InAppWebView(
// // //               initialUrlRequest: URLRequest(url: WebUri.uri(_paymentUrl)),
// // //               initialSettings: InAppWebViewSettings(
// // //                 useShouldOverrideUrlLoading: true,
// // //                 // This is key for intercepting navigation
// // //                 javaScriptEnabled: true,
// // //               ),
// // //               onWebViewCreated: (controller) {
// // //                 _webViewController = controller;
// // //               },
// // //               onLoadStart: (controller, url) {
// // //                 log('WebView: Page started loading: $url');
// // //                 setState(() {
// // //                   _progress = 0;
// // //                 });
// // //
// // //                 // 2. Listen for the success or failure URL to navigate away
// // //                 // IMPORTANT: Adjust these URLs to match what Tranzila redirects to
// // //                 const String successUrlIdentifier =
// // //                     '/payment/tranzila/success'; // Example
// // //                 const String failureUrlIdentifier =
// // //                     '/payment/tranzila/fail'; // Example
// // //
// // //                 if (url.toString().contains(successUrlIdentifier)) {
// // //                   log('Payment Successful, redirecting to Order Success Screen.');
// // //                   // Use offNamed to prevent user from going back to the payment page
// // //                   // Get.offNamed(RouteHelper.getOrderSuccessRoute(widget.orderID));
// // //
// // //                   // Stop the webview from actually loading the success page
// // //                   controller.stopLoading();
// // //                 } else if (url.toString().contains(failureUrlIdentifier)) {
// // //                   log('Payment Failed, navigating back.');
// // //                   Get.back(); // Go back to the checkout screen
// // //                   // You might want to show a "Payment Failed" snackbar or dialog here
// // //
// // //                   // Stop the webview from actually loading the failure page
// // //                   controller.stopLoading();
// // //                 }
// // //               },
// // //               onProgressChanged: (controller, progress) {
// // //                 setState(() {
// // //                   _progress = progress / 100;
// // //                 });
// // //               },
// // //               onLoadStop: (controller, url) {
// // //                 log('WebView: Page finished loading: $url');
// // //               },
// // //               onLoadError: (controller, url, code, message) {
// // //                 log('WebView: Error loading $url, Error: $message');
// // //                 // Optionally show an error message to the user
// // //               },
// // //             ),
// // //
// // //             // Show a progress indicator at the top
// // //             if (_progress < 1.0)
// // //               Positioned(
// // //                 top: 0,
// // //                 left: 0,
// // //                 right: 0,
// // //                 child: LinearProgressIndicator(value: _progress),
// // //               ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// // import 'package:flutter/material.dart';
// // import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// // import 'package:get/get.dart';
// // import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
// // import 'dart:developer';
// // import 'package:sixam_mart/util/app_constants.dart';
// // import '../../../helper/route_helper.dart';
// //
// // class TranzilaWebPaymentScreen extends StatefulWidget {
// //   final String orderID;
// //
// //   const TranzilaWebPaymentScreen({
// //     super.key,
// //     required this.orderID,
// //   });
// //
// //   @override
// //   State<TranzilaWebPaymentScreen> createState() =>
// //       _TranzilaWebPaymentScreenState();
// // }
// //
// // class _TranzilaWebPaymentScreenState extends State<TranzilaWebPaymentScreen> {
// //   InAppWebViewController? _webViewController;
// //   late final Uri _paymentUrl;
// //   double _progress = 0;
// //   bool _isLoading = true;
// //   String? _errorMessage;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //
// //     // Ensure the URL has the proper scheme
// //     String baseUrl = AppConstants.baseUrl;
// //     if (!baseUrl.startsWith('http://') && !baseUrl.startsWith('https://')) {
// //       baseUrl = 'https://$baseUrl';
// //     }
// //
// //     _paymentUrl = Uri.parse(
// //         '$baseUrl/payment/tranzila/pay?order_id=${widget.orderID}');
// //     log('Payment URL: $_paymentUrl');
// //   }
// //
// //   void handleBackNavigation() {
// //     log("Back navigation action initiated. Showing confirmation dialog.");
// //
// //     Get.dialog(
// //       Dialog(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //         child: Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Text(
// //                 "are_you_sure_you_want_to_go_back".tr,
// //                 style: const TextStyle(
// //                   fontWeight: FontWeight.bold,
// //                   fontSize: 16,
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),
// //               const SizedBox(height: 20),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                 children: [
// //                   TextButton(
// //                     onPressed: () {
// //                       Get.back();
// //                     },
// //                     child: Text(
// //                       "cancel".tr,
// //                       style: TextStyle(color: Theme.of(context).disabledColor),
// //                     ),
// //                   ),
// //                   ElevatedButton(
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Theme.of(context).primaryColor,
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                     ),
// //                     onPressed: () {
// //                       log("User confirmed. Redirecting to initial route.");
// //                       Get.offAllNamed(RouteHelper.getInitialRoute());
// //                     },
// //                     child: Text(
// //                       "back_to_home".tr,
// //                       style: const TextStyle(color: Colors.white),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //       barrierDismissible: true,
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return WillPopScope(
// //       onWillPop: () async {
// //         handleBackNavigation();
// //         return false;
// //       },
// //       child: Scaffold(
// //         appBar: CustomAppBar(
// //           title: "complete_payment".tr,
// //           backButton: true,
// //           onBackPressed: handleBackNavigation,
// //         ),
// //         body: Stack(
// //           children: [
// //             // Error message display
// //             if (_errorMessage != null)
// //               Center(
// //                 child: Padding(
// //                   padding: const EdgeInsets.all(20.0),
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Icon(
// //                         Icons.error_outline,
// //                         size: 64,
// //                         color: Theme.of(context).colorScheme.error,
// //                       ),
// //                       const SizedBox(height: 16),
// //                       Text(
// //                         'Failed to load payment page',
// //                         style: Theme.of(context).textTheme.titleLarge,
// //                         textAlign: TextAlign.center,
// //                       ),
// //                       const SizedBox(height: 8),
// //                       Text(
// //                         _errorMessage!,
// //                         style: Theme.of(context).textTheme.bodyMedium,
// //                         textAlign: TextAlign.center,
// //                       ),
// //                       const SizedBox(height: 24),
// //                       ElevatedButton(
// //                         onPressed: () {
// //                           setState(() {
// //                             _errorMessage = null;
// //                             _isLoading = true;
// //                           });
// //                           _webViewController?.reload();
// //                         },
// //                         child: const Text('Retry'),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               )
// //             else
// //               InAppWebView(
// //                 initialUrlRequest: URLRequest(url: WebUri.uri(_paymentUrl)),
// //                 initialSettings: InAppWebViewSettings(
// //                   javaScriptEnabled: true,
// //                   useShouldOverrideUrlLoading: true,
// //                   mediaPlaybackRequiresUserGesture: false,
// //                   allowsInlineMediaPlayback: true,
// //                   useHybridComposition: true, // Better rendering on Android
// //                   mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
// //                   // Useful for debugging
// //                   clearCache: false,
// //                 ),
// //                 onWebViewCreated: (controller) {
// //                   _webViewController = controller;
// //                   log('WebView created successfully');
// //                 },
// //                 onLoadStart: (controller, url) {
// //                   log('WebView: Page started loading: $url');
// //                   setState(() {
// //                     _progress = 0;
// //                     _isLoading = true;
// //                     _errorMessage = null;
// //                   });
// //
// //                   // Check for success or failure URLs
// //                   const String successUrlIdentifier = '/payment/tranzila/success';
// //                   const String failureUrlIdentifier = '/payment/tranzila/fail';
// //
// //                   if (url.toString().contains(successUrlIdentifier)) {
// //                     log('Payment Successful, redirecting to Order Success Screen.');
// //                     controller.stopLoading();
// //                     // Uncomment when ready:
// //                     // Get.offNamed(RouteHelper.getOrderSuccessRoute(widget.orderID));
// //                   } else if (url.toString().contains(failureUrlIdentifier)) {
// //                     log('Payment Failed, navigating back.');
// //                     controller.stopLoading();
// //                     Get.back();
// //                     Get.snackbar(
// //                       'Payment Failed',
// //                       'Your payment was not successful. Please try again.',
// //                       snackPosition: SnackPosition.BOTTOM,
// //                       backgroundColor: Colors.red,
// //                       colorText: Colors.white,
// //                     );
// //                   }
// //                 },
// //                 onProgressChanged: (controller, progress) {
// //                   setState(() {
// //                     _progress = progress / 100;
// //                   });
// //                 },
// //                 onLoadStop: (controller, url) async {
// //                   log('WebView: Page finished loading: $url');
// //                   setState(() {
// //                     _isLoading = false;
// //                   });
// //
// //                   // Debug: Log the page title
// //                   String? title = await controller.getTitle();
// //                   log('Page title: $title');
// //                 },
// //                 onLoadError: (controller, url, code, message) {
// //                   log('WebView: Error loading $url, Code: $code, Error: $message');
// //                   setState(() {
// //                     _isLoading = false;
// //                     _errorMessage = 'Error $code: $message';
// //                   });
// //                 },
// //                 onLoadHttpError: (controller, url, statusCode, description) {
// //                   log('WebView: HTTP Error loading $url, Status: $statusCode, Description: $description');
// //                   setState(() {
// //                     _isLoading = false;
// //                     _errorMessage = 'HTTP Error $statusCode: $description';
// //                   });
// //                 },
// //                 onConsoleMessage: (controller, consoleMessage) {
// //                   // Log JavaScript console messages for debugging
// //                   log('WebView Console [${consoleMessage.messageLevel}]: ${consoleMessage.message}');
// //                 },
// //               ),
// //
// //             // Loading indicator
// //             if (_isLoading && _errorMessage == null)
// //               Container(
// //                 color: Colors.white,
// //                 child: Center(
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       CircularProgressIndicator(
// //                         value: _progress > 0 ? _progress : null,
// //                       ),
// //                       const SizedBox(height: 16),
// //                       Text(
// //                         'Loading payment page...',
// //                         style: Theme.of(context).textTheme.bodyLarge,
// //                       ),
// //                       if (_progress > 0)
// //                         Padding(
// //                           padding: const EdgeInsets.only(top: 8.0),
// //                           child: Text(
// //                             '${(_progress * 100).toInt()}%',
// //                             style: Theme.of(context).textTheme.bodyMedium,
// //                           ),
// //                         ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //
// //             // Progress bar at the top
// //             if (_progress < 1.0 && _progress > 0 && _errorMessage == null)
// //               Positioned(
// //                 top: 0,
// //                 left: 0,
// //                 right: 0,
// //                 child: LinearProgressIndicator(
// //                   value: _progress,
// //                   backgroundColor: Colors.grey[200],
// //                   valueColor: AlwaysStoppedAnimation<Color>(
// //                     Theme.of(context).primaryColor,
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:get/get.dart';
// import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
// import 'dart:developer';
// import 'dart:async';
// import 'package:sixam_mart/util/app_constants.dart';
// import '../../../helper/route_helper.dart';
//
// class TranzilaWebPaymentScreen extends StatefulWidget {
//   final String orderID;
//
//   const TranzilaWebPaymentScreen({
//     super.key,
//     required this.orderID,
//   });
//
//   @override
//   State<TranzilaWebPaymentScreen> createState() =>
//       _TranzilaWebPaymentScreenState();
// }
//
// class _TranzilaWebPaymentScreenState extends State<TranzilaWebPaymentScreen> {
//   InAppWebViewController? _webViewController;
//   late final Uri _paymentUrl;
//   double _progress = 0;
//   bool _isLoading = true;
//   String? _errorMessage;
//   Timer? _timeoutTimer;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Ensure the URL has the proper scheme
//     String baseUrl = AppConstants.baseUrl;
//     if (!baseUrl.startsWith('http://') && !baseUrl.startsWith('https://')) {
//       baseUrl = 'https://$baseUrl';
//     }
//
//     _paymentUrl = Uri.parse(
//         '$baseUrl/payment/tranzila/pay?order_id=${widget.orderID}');
//     log('=== TRANZILA PAYMENT DEBUG ===');
//     log('Payment URL: $_paymentUrl');
//     log('Order ID: ${widget.orderID}');
//     log('Base URL: ${AppConstants.baseUrl}');
//
//     // Set a timeout for initial load
//     _startLoadTimeout();
//   }
//
//   void _startLoadTimeout() {
//     _timeoutTimer?.cancel();
//     _timeoutTimer = Timer(const Duration(seconds: 30), () {
//       if (_isLoading && mounted) {
//         log('WebView: Load timeout after 30 seconds');
//         setState(() {
//           _isLoading = false;
//           _errorMessage = 'Loading timeout. The payment page took too long to respond.';
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _timeoutTimer?.cancel();
//     super.dispose();
//   }
//
//   void handleBackNavigation() {
//     log("Back navigation action initiated. Showing confirmation dialog.");
//
//     Get.dialog(
//       Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 "are_you_sure_you_want_to_go_back".tr,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   TextButton(
//                     onPressed: () {
//                       Get.back();
//                     },
//                     child: Text(
//                       "cancel".tr,
//                       style: TextStyle(color: Theme.of(context).disabledColor),
//                     ),
//                   ),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Theme.of(context).primaryColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     onPressed: () {
//                       log("User confirmed. Redirecting to initial route.");
//                       Get.offAllNamed(RouteHelper.getInitialRoute());
//                     },
//                     child: Text(
//                       "back_to_home".tr,
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//       barrierDismissible: true,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         handleBackNavigation();
//         return false;
//       },
//       child: Scaffold(
//         appBar: CustomAppBar(
//           title: "complete_payment".tr,
//           backButton: true,
//           onBackPressed: handleBackNavigation,
//         ),
//         body: Stack(
//           children: [
//             // Error message display
//             if (_errorMessage != null)
//               Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.error_outline,
//                         size: 64,
//                         color: Theme.of(context).colorScheme.error,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'Failed to load payment page',
//                         style: Theme.of(context).textTheme.titleLarge,
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         _errorMessage!,
//                         style: Theme.of(context).textTheme.bodyMedium,
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 24),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           ElevatedButton(
//                             onPressed: () {
//                               setState(() {
//                                 _errorMessage = null;
//                                 _isLoading = true;
//                               });
//                               _startLoadTimeout();
//                               _webViewController?.reload();
//                             },
//                             child: const Text('Retry'),
//                           ),
//                           const SizedBox(width: 12),
//                           OutlinedButton(
//                             onPressed: () => Get.back(),
//                             child: const Text('Go Back'),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             else
//               InAppWebView(
//                 initialUrlRequest: URLRequest(url: WebUri.uri(_paymentUrl)),
//                 initialSettings: InAppWebViewSettings(
//                   javaScriptEnabled: true,
//                   useShouldOverrideUrlLoading: true,
//                   mediaPlaybackRequiresUserGesture: false,
//                   allowsInlineMediaPlayback: true,
//                   useHybridComposition: true,
//                   mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
//                   clearCache: false,
//                   // Additional debugging settings
//                   supportZoom: false,
//                   builtInZoomControls: false,
//                   displayZoomControls: false,
//                   // Disable caching for testing
//                   cacheEnabled: false,
//                 ),
//                 onWebViewCreated: (controller) {
//                   _webViewController = controller;
//                   log('WebView: Created successfully');
//                 },
//                 onLoadStart: (controller, url) {
//                   log('WebView: onLoadStart - $url');
//                   setState(() {
//                     _progress = 0;
//                     _errorMessage = null;
//                   });
//
//                   // Check for success or failure URLs
//                   const String successUrlIdentifier = '/payment/tranzila/success';
//                   const String failureUrlIdentifier = '/payment/tranzila/fail';
//
//                   if (url.toString().contains(successUrlIdentifier)) {
//                     log('Payment Successful, redirecting to Order Success Screen.');
//                     _timeoutTimer?.cancel();
//                     controller.stopLoading();
//                     // Uncomment when ready:
//                     // Get.offNamed(RouteHelper.getOrderSuccessRoute(widget.orderID));
//                   } else if (url.toString().contains(failureUrlIdentifier)) {
//                     log('Payment Failed, navigating back.');
//                     _timeoutTimer?.cancel();
//                     controller.stopLoading();
//                     Get.back();
//                     Get.snackbar(
//                       'Payment Failed',
//                       'Your payment was not successful. Please try again.',
//                       snackPosition: SnackPosition.BOTTOM,
//                       backgroundColor: Colors.red,
//                       colorText: Colors.white,
//                     );
//                   }
//                 },
//                 onProgressChanged: (controller, progress) {
//                   log('WebView: Progress - $progress%');
//                   setState(() {
//                     _progress = progress / 100;
//                   });
//                 },
//                 onLoadStop: (controller, url) async {
//                   log('WebView: onLoadStop - $url');
//                   _timeoutTimer?.cancel();
//
//                   setState(() {
//                     _isLoading = false;
//                   });
//
//                   // Debug: Get page info
//                   try {
//                     String? title = await controller.getTitle();
//                     String? html = await controller.getHtml();
//                     log('WebView: Page title - $title');
//                     log('WebView: HTML length - ${html?.length ?? 0} characters');
//
//                     // Check if the page is blank or has minimal content
//                     if (html == null || html.trim().isEmpty || html.length < 100) {
//                       log('WebView: WARNING - Page appears to be empty or very small');
//                       setState(() {
//                         _errorMessage = 'The payment page loaded but appears to be empty. Please check the backend.';
//                       });
//                     }
//                   } catch (e) {
//                     log('WebView: Error getting page info - $e');
//                   }
//                 },
//                 onLoadError: (controller, url, code, message) {
//                   log('WebView: onLoadError - Code: $code, Message: $message, URL: $url');
//                   _timeoutTimer?.cancel();
//                   setState(() {
//                     _isLoading = false;
//                     _errorMessage = 'Error $code: $message\n\nURL: $url';
//                   });
//                 },
//                 onLoadHttpError: (controller, url, statusCode, description) {
//                   log('WebView: onLoadHttpError - Status: $statusCode, Description: $description, URL: $url');
//                   _timeoutTimer?.cancel();
//                   setState(() {
//                     _isLoading = false;
//                     _errorMessage = 'HTTP Error $statusCode: $description\n\nURL: $url';
//                   });
//                 },
//                 onConsoleMessage: (controller, consoleMessage) {
//                   log('WebView Console [${consoleMessage.messageLevel}]: ${consoleMessage.message}');
//                 },
//                 onReceivedError: (controller, request, error) {
//                   log('WebView: onReceivedError - ${error.description}');
//                 },
//                 onReceivedHttpError: (controller, request, response) {
//                   log('WebView: onReceivedHttpError - Status: ${response.statusCode}');
//                 },
//               ),
//
//             // Loading indicator
//             if (_isLoading && _errorMessage == null)
//               Container(
//                 color: Colors.white,
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(
//                         value: _progress > 0 ? _progress : null,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'Loading payment page...',
//                         style: Theme.of(context).textTheme.bodyLarge,
//                       ),
//                       if (_progress > 0)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 8.0),
//                           child: Text(
//                             '${(_progress * 100).toInt()}%',
//                             style: Theme.of(context).textTheme.bodyMedium,
//                           ),
//                         ),
//                       const SizedBox(height: 24),
//                       // Show the URL being loaded
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 32.0),
//                         child: Text(
//                           _paymentUrl.toString(),
//                           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                             color: Colors.grey,
//                           ),
//                           textAlign: TextAlign.center,
//                           maxLines: 3,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//             // Progress bar at the top
//             if (_progress < 1.0 && _progress > 0 && _errorMessage == null && !_isLoading)
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 right: 0,
//                 child: LinearProgressIndicator(
//                   value: _progress,
//                   backgroundColor: Colors.grey[200],
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                     Theme.of(context).primaryColor,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/util/app_constants.dart';
import '../../../helper/route_helper.dart';

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
  bool _isLoading = true;
  String? _errorMessage;

  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();

    log('=========== TRANZILA INIT ===========');



    String baseUrl = AppConstants.baseUrl;
    if (!baseUrl.startsWith('http')) {
      baseUrl = 'https://$baseUrl';
    }

    _paymentUrl =
        Uri.parse('$baseUrl/payment/tranzila/pay?order_id=${widget.orderID}');

    log('Payment URL: $_paymentUrl');
    log('Order ID: ${widget.orderID}');
    log('Platform: ${Platform.operatingSystem}');
    log('====================================');

    _startLoadTimeout();
  }

  void _startLoadTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (_isLoading && mounted) {
        log('❌ WebView TIMEOUT (30s)');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Loading timeout. Payment gateway not responding.';
        });
      }
    });

  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void handleBackNavigation() {
    Get.dialog(
      AlertDialog(
        title: Text("are_you_sure_you_want_to_go_back".tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("cancel".tr),
          ),
          ElevatedButton(
            onPressed: () {
              Get.offAllNamed(RouteHelper.getInitialRoute());
            },
            child: Text("back_to_home".tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        handleBackNavigation();
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: "complete_payment".tr,
          backButton: true,
          onBackPressed: handleBackNavigation,
        ),
        body: Stack(
          children: [
            if (_errorMessage != null)
              _errorView()
            else
              _webView(),

            if (_isLoading && _errorMessage == null)
              _loadingView(),

            if (_progress < 1 && _progress > 0 && !_isLoading)
              LinearProgressIndicator(value: _progress),
          ],
        ),
      ),
    );
  }

  Widget _webView() {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri.uri(_paymentUrl)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        javaScriptCanOpenWindowsAutomatically: true,
        allowsInlineMediaPlayback: true,
        mediaPlaybackRequiresUserGesture: false,
        sharedCookiesEnabled: true,
        cacheEnabled: false,
        useShouldOverrideUrlLoading: true,

        // Force Safari UA (fixes many gateways)
        userAgent:
        "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) "
            "AppleWebKit/605.1.15 (KHTML, like Gecko) "
            "Version/17.0 Mobile/15E148 Safari/604.1",

        isInspectable: true, // iOS Web Inspector
      ),

      onWebViewCreated: (controller) async {
        _webViewController = controller;
        log('✅ WebView CREATED');
      },

      onLoadStart: (controller, url) {
        log('➡️ LOAD START: $url');
        setState(() {
          _progress = 0;
        });
      },

      onProgressChanged: (controller, progress) {
        log('⏳ Progress: $progress%');
        setState(() {
          _progress = progress / 100;
        });
      },

      onLoadStop: (controller, url) async {
        log('✅ LOAD STOP: $url');
        _timeoutTimer?.cancel();

        setState(() {
          _isLoading = false;
        });

        try {
          final title = await controller.getTitle();
          final html = await controller.getHtml();

          log('📄 Page title: $title');
          log('📄 HTML length: ${html?.length ?? 0}');

          if (html == null || html.length < 200) {
            log('⚠️ EMPTY / BLOCKED PAGE DETECTED');
            setState(() {
              _errorMessage =
              'Payment page loaded but content is empty (blocked by iOS).';
            });
          }
        } catch (e) {
          log('❌ HTML READ ERROR: $e');
        }

        const successUrl = '/payment/tranzila/success';
        const failUrl = '/payment/tranzila/fail';

        if (url.toString().contains(successUrl)) {
          log('🎉 PAYMENT SUCCESS');
          // Get.offNamed(RouteHelper.getOrderSuccessRoute(widget.orderID));
        }

        if (url.toString().contains(failUrl)) {
          log('❌ PAYMENT FAILED');
          Get.back();
        }
      },

      onLoadError: (controller, url, code, message) {
        log('❌ LOAD ERROR [$code]: $message');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error $code: $message';
        });
      },

      onLoadHttpError: (controller, url, statusCode, description) {
        log('❌ HTTP ERROR [$statusCode]: $description');
      },

      onConsoleMessage: (controller, msg) {
        log('🧩 JS CONSOLE: ${msg.message}');
      },

      shouldOverrideUrlLoading: (controller, nav) async {
        log('🔀 NAVIGATION: ${nav.request.url}');
        return NavigationActionPolicy.ALLOW;
      },
    );
  }

  Widget _loadingView() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            const Text('Loading payment page...'),
            const SizedBox(height: 8),
            Text(
              _paymentUrl.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Failed to load payment page',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _isLoading = true;
                });
                _startLoadTimeout();
                _webViewController?.reload();
              },
              child: const Text('Retry'),
            )
          ],
        ),
      ),
    );
  }
}
