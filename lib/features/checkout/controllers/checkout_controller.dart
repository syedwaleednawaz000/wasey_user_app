import 'dart:convert';
import 'dart:developer';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/checkout/domain/models/distance_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/payment/domain/models/offline_method_model.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/checkout/domain/models/timeslote_model.dart';
import 'package:sixam_mart/features/checkout/domain/services/checkout_service_interface.dart';
import 'package:sixam_mart/features/checkout/widgets/order_successfull_dialog.dart';
import 'package:sixam_mart/features/checkout/widgets/partial_pay_dialog_widget.dart';
import 'package:sixam_mart/features/home/screens/home_screen.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:universal_html/html.dart' as html;

import '../../../common/models/module_model.dart';
import '../../payment/screens/DirectPaymentScreen.dart';
import '../../payment/screens/tranzila_web_payment_screen.dart';
import '../domain/models/delivery_charges_data_model.dart';

class CheckoutController extends GetxController implements GetxService {
  final CheckoutServiceInterface checkoutServiceInterface;

  CheckoutController({required this.checkoutServiceInterface});

  final TextEditingController couponController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController streetNumberController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController floorController = TextEditingController();
  final TextEditingController tipController = TextEditingController();
  final FocusNode streetNode = FocusNode();
  final FocusNode houseNode = FocusNode();
  final FocusNode floorNode = FocusNode();

  String? countryDialCode =
      Get.find<AuthController>().getUserCountryCode().isNotEmpty
          ? Get.find<AuthController>().getUserCountryCode()
          : CountryCode.fromCountryCode(
                      Get.find<SplashController>().configModel!.country!)
                  .dialCode ??
              Get.find<LocalizationController>().locale.countryCode;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  AddressModel? _guestAddress;

  AddressModel? get guestAddress => _guestAddress;

  int? _mostDmTipAmount;

  int? get mostDmTipAmount => _mostDmTipAmount;

  String _preferableTime = '';

  String get preferableTime => _preferableTime;

  List<OfflineMethodModel>? _offlineMethodList;

  List<OfflineMethodModel>? get offlineMethodList => _offlineMethodList;

  bool _isPartialPay = false;

  bool get isPartialPay => _isPartialPay;

  double _tips = 0.0;

  double get tips => _tips;

  int _selectedTips = 0;

  int get selectedTips => _selectedTips;

  Store? _store;

  Store? get store => _store;

  int? _addressIndex = 0;

  int? get addressIndex => _addressIndex;

  XFile? _orderAttachment;

  XFile? get orderAttachment => _orderAttachment;

  Uint8List? _rawAttachment;

  Uint8List? get rawAttachment => _rawAttachment;

  bool _acceptTerms = true;

  bool get acceptTerms => _acceptTerms;

  int _paymentMethodIndex = -1;

  int get paymentMethodIndex => _paymentMethodIndex;

  int _selectedDateSlot = 0;

  int get selectedDateSlot => _selectedDateSlot;

  int _selectedTimeSlot = 0;

  int get selectedTimeSlot => _selectedTimeSlot;

  double? _distance;

  double? get distance => _distance;

  List<TimeSlotModel>? _timeSlots;

  List<TimeSlotModel>? get timeSlots => _timeSlots;

  List<TimeSlotModel>? _allTimeSlots;

  List<TimeSlotModel>? get allTimeSlots => _allTimeSlots;

  List<XFile> _pickedPrescriptions = [];

  List<XFile> get pickedPrescriptions => _pickedPrescriptions;

  double? _extraCharge;

  double? get extraCharge => _extraCharge;

  String? _orderType = 'delivery';

  String? get orderType => _orderType;

  double _viewTotalPrice = 0;

  double? get viewTotalPrice => _viewTotalPrice;

  int _selectedOfflineBankIndex = 0;

  int get selectedOfflineBankIndex => _selectedOfflineBankIndex;

  int _selectedInstruction = -1;

  int get selectedInstruction => _selectedInstruction;

  bool _isDmTipSave = false;

  bool get isDmTipSave => _isDmTipSave;

  String? _digitalPaymentName;

  String? get digitalPaymentName => _digitalPaymentName;

  bool _canShowTipsField = false;

  bool get canShowTipsField => _canShowTipsField;

  bool _isExpanded = false;

  bool get isExpanded => _isExpanded;

  bool _isExpand = false;

  bool get isExpand => _isExpand;

  // --- Properties for Delivery Charges ---
  var deliveryChargesList = <DeliveryChargeData>[].obs;
  var isLoadingDeliveryCharges = false.obs;
  var currentActiveModuleId =
      Rxn<int>(); // To hold and react to module ID changes
  var currentSelectedDeliveryChargesData =
      Rxn<DeliveryChargeData>(); // To hold and react to module ID changes

  void toggleSelectedChargesCity(DeliveryChargeData cityId) {
    currentSelectedDeliveryChargesData.value = cityId;
    log("currentSelectedDeliveryChargesId.value: ${cityId}");
    update();
  }

  // --- METHOD TO FETCH DELIVERY CHARGES DIRECTLY ---
  Future<void> fetchDeliveryChargesDirectly() async {
    isLoadingDeliveryCharges.value = true;
    deliveryChargesList.clear(); // Clear previous data

    // log("gettingModuleIdFromShares");
    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    log("gettingModuleIdFromShares");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String moduleIdString = '1'; // Default value if not found or error

    try {
      // Attempt to get the stored module ID string
      String? storedValue = sharedPreferences
          .getString(AppConstants.moduleId); // Use a temporary variable

      if (storedValue != null && storedValue.isNotEmpty) {
        // Here, we assume storedValue is just the ID, like "1", "2", etc.
        // If it was meant to be a full JSON object for ModuleModel, then the storing logic is the issue.
        // For now, let's assume it's just the ID string.

        // Attempt to parse the stored value as the ID of a ModuleModel
        // This part seems to be the source of your confusion and the error.
        // If AppConstants.moduleId stores the *JSON string of a ModuleModel*:
        try {
          ModuleModel module = ModuleModel.fromJson(jsonDecode(storedValue));
          moduleIdString = module.id.toString();
          log("Module ID successfully parsed from ModuleModel JSON: $moduleIdString");
        } catch (e) {
          // This catch block means 'storedValue' was NOT a valid JSON for ModuleModel.
          // It might be just the ID string itself.
          log("Could not parse stored value as ModuleModel JSON. Assuming it's the ID string itself. Error: $e");
          // Validate if 'storedValue' can be an integer ID directly
          if (int.tryParse(storedValue) != null) {
            moduleIdString = storedValue; // Use it directly
            log("Using stored value directly as module ID string: $moduleIdString");
          } else {
            log("Stored value '$storedValue' is not a valid ID string. Using default '$moduleIdString'.");
            // moduleIdString remains '1' (default)
          }
        }
      } else {
        log("Module ID key ('${AppConstants.moduleId}') not found in SharedPreferences or is empty, using default '$moduleIdString'.");
      }
    } catch (e) {
      log("Error accessing SharedPreferences or processing module ID: $e. Using default '$moduleIdString'.");
      // moduleIdString remains '1' (default)
    }

    log("Final moduleIdString to be used for API call: $moduleIdString");

    try {
      // Get the ApiClient instance (assuming it's registered with GetX)
      // String? moduleIdString = '1';
      // moduleIdString = (ModuleModel.fromJson(
      //       jsonDecode(sharedPreferences.getString(AppConstants.moduleId)!),
      //     ).id)
      //         .toString() ??
      //     '1';
      // log("moduleIdString ${moduleIdString}");
      final ApiClient apiClient = Get.find<ApiClient>();

      final response = await apiClient.getData(
        AppConstants.deliveryChargesUri,
        query: {'module_id': moduleIdString},
      );

      if (response.statusCode == 200 && response.body != null) {
        DeliveryChargesResponse deliveryChargesResponse =
            DeliveryChargesResponse.fromJson(response.body);
        log("=========ResponseData");
        log(response.body.toString());

        if (deliveryChargesResponse.success) {
          // deliveryChargesList.assignAll(deliveryChargesResponse.data);
          // deliveryChargesList.assignAll(deliveryChargesResponse.data);
          List<DeliveryChargeData> filteredData = deliveryChargesResponse.data
              .where((chargeData) =>
                  chargeData.moduleId == int.parse(moduleIdString!))
              .toList();
          if (deliveryChargesResponse.data.isNotEmpty &&
              filteredData.isNotEmpty) {
            // currentSelectedDeliveryChargesData.value =
            //     deliveryChargesResponse.data[0];
            deliveryChargesList.assignAll(filteredData);
            // Optionally, set the first item of the filtered list as selected
            currentSelectedDeliveryChargesData.value = filteredData[0];
          } else {
            print(
                "CheckoutController: No delivery charges found for module ID: $moduleIdString");
            // Optionally: Get.snackbar('Info', 'No delivery charges available for this selection.');
          }
        } else {
          // API call was successful (200) but the 'success' flag in response is false
          String errorMessage =
              response.body['message'] ?? 'Fetching delivery charges failed.';
          print("CheckoutController: API indicated failure: $errorMessage");
          Get.snackbar('Error', errorMessage);
        }
      } else {
        // HTTP error (statusCode not 200)
        print(
            "CheckoutController: Failed to fetch delivery charges. Status: ${response.statusCode}, Message: ${response.statusText}");
        Get.snackbar('Error', 'Server error: Could not load delivery charges.');
      }
    } catch (e) {
      print(
          "CheckoutController: Exception while fetching delivery charges: $e");
      Get.snackbar('Error', 'An unexpected error occurred. Please try again.');
    } finally {
      isLoadingDeliveryCharges.value = false;
    }
  }

  Future<void> initCheckoutData(int? storeId) async {
    Get.find<CouponController>().removeCouponData(false);
    clearPrevData();
    _paymentMethodIndex = 0;

    _store = await Get.find<StoreController>()
        .getStoreDetails(Store(id: storeId), false);
    initializeTimeSlot(_store!);
    fetchDeliveryChargesDirectly();
  }

  void showTipsField() {
    _canShowTipsField = !_canShowTipsField;
    update();
  }

  Future<void> addTips(double tips) async {
    _tips = tips;
    update();
  }

  void expandedUpdate(bool status) {
    _isExpanded = status;
    update();
  }

  void setPaymentMethod(int index, {bool isUpdate = true}) {
    _paymentMethodIndex = index;
    if (isUpdate) {
      update();
    }
  }

  void changeDigitalPaymentName(String name, {bool willUpdate = true}) {
    _digitalPaymentName = name;
    if (willUpdate) {
      update();
    }
  }

  void setOrderType(String? type, {bool notify = true}) {
    _orderType = type;
    if (notify) {
      update();
    }
  }

  void changePartialPayment({bool isUpdate = true}) {
    _isPartialPay = !_isPartialPay;
    if (isUpdate) {
      update();
    }
  }

  void setAddressIndex(int? index) {
    _addressIndex = index;
    update();
  }

  void setGuestAddress(AddressModel? address, {bool isUpdate = true}) {
    _guestAddress = address;
    if (isUpdate) {
      update();
    }
  }

  Future<void> getDmTipMostTapped() async {
    _mostDmTipAmount = await checkoutServiceInterface.getDmTipMostTapped();
    update();
  }

  void setPreferenceTimeForView(String time, {bool isUpdate = true}) {
    _preferableTime = time;
    if (isUpdate) {
      update();
    }
  }

  Future<void> getOfflineMethodList() async {
    _offlineMethodList = null;
    _offlineMethodList = await checkoutServiceInterface.getOfflineMethodList();
    update();
  }

  void updateTips(int index, {bool notify = true}) {
    _selectedTips = index;
    if (_selectedTips == 0 || _selectedTips == 5) {
      _tips = 0;
    } else {
      _tips = double.parse(AppConstants.tips[index]);
    }
    if (notify) {
      update();
    }
  }

  void saveSharedPrefDmTipIndex(String i) {
    checkoutServiceInterface.saveSharedPrefDmTipIndex(i);
  }

  String getSharedPrefDmTipIndex() {
    return checkoutServiceInterface.getSharedPrefDmTipIndex();
  }

  void setTotalAmount(double amount) {
    _viewTotalPrice = amount;
  }

  void clearPrevData() {
    _addressIndex = 0;
    _acceptTerms = true;
    _paymentMethodIndex = -1;
    _selectedDateSlot = 0;
    _selectedTimeSlot = 0;
    _distance = null;
    _orderAttachment = null;
    _rawAttachment = null;
  }

  Future<void> initializeTimeSlot(Store store) async {
    _timeSlots = await checkoutServiceInterface.initializeTimeSlot(store,
        Get.find<SplashController>().configModel!.scheduleOrderSlotDuration!);
    _allTimeSlots = await checkoutServiceInterface.initializeTimeSlot(store,
        Get.find<SplashController>().configModel!.scheduleOrderSlotDuration!);

    _validateSlot(_allTimeSlots!, 0, store.orderPlaceToScheduleInterval,
        notify: false);
  }

  void _validateSlot(List<TimeSlotModel> slots, int dateIndex, int? interval,
      {bool notify = true}) {
    _timeSlots = checkoutServiceInterface.validateTimeSlot(
        slots,
        dateIndex,
        interval,
        Get.find<SplashController>()
            .configModel!
            .moduleConfig!
            .module!
            .orderPlaceToScheduleInterval!);

    if (notify) {
      update();
    }
  }

  void pickPrescriptionImage(
      {required bool isRemove, required bool isCamera}) async {
    if (isRemove) {
      _pickedPrescriptions = [];
    } else {
      XFile? xFile = await ImagePicker().pickImage(
          source: isCamera ? ImageSource.camera : ImageSource.gallery,
          imageQuality: 50);
      if (xFile != null) {
        _pickedPrescriptions.add(xFile);
      }
      update();
    }
  }

  void removePrescriptionImage(int index) {
    _pickedPrescriptions.removeAt(index);
    update();
  }

  bool isStoreClosed(bool today, int? active, List<Schedules>? schedules) {
    return Get.find<StoreController>().isStoreClosed(today, active, schedules);
  }

  bool isStoreOpenNow(int? active, List<Schedules>? schedules) {
    return Get.find<StoreController>().isStoreOpenNow(active, schedules);
  }

  Future<double?> getDistanceInKM(LatLng originLatLng, LatLng destinationLatLng,
      {bool isDuration = false, bool fromDashboard = false}) async {
    _distance = -1;
    Response response = await checkoutServiceInterface.getDistanceInMeter(
        originLatLng, destinationLatLng);
    try {
      if (response.statusCode == 200 && response.body['status'] == 'OK') {
        if (isDuration) {
          _distance = DistanceModel.fromJson(response.body)
                  .rows![0]
                  .elements![0]
                  .duration!
                  .value! /
              3600;
        } else {
          _distance = DistanceModel.fromJson(response.body)
                  .rows![0]
                  .elements![0]
                  .distance!
                  .value! /
              1000;
        }
      } else {
        if (!isDuration) {
          _distance = Geolocator.distanceBetween(
                originLatLng.latitude,
                originLatLng.longitude,
                destinationLatLng.latitude,
                destinationLatLng.longitude,
              ) /
              1000;
        }
      }
    } catch (e) {
      if (!isDuration) {
        _distance = Geolocator.distanceBetween(
                originLatLng.latitude,
                originLatLng.longitude,
                destinationLatLng.latitude,
                destinationLatLng.longitude) /
            1000;
      }
    }
    if (!fromDashboard) {
      await _getExtraCharge(_distance);
    }
    update();
    return _distance;
  }

  Future<double?> _getExtraCharge(double? distance) async {
    _extraCharge = null;
    _extraCharge = await checkoutServiceInterface.getExtraCharge(distance);
    return _extraCharge;
  }

  Future<bool> checkBalanceStatus(double totalPrice, double discount) async {
    totalPrice = (totalPrice - discount);
    if (isPartialPay) {
      changePartialPayment();
    }
    setPaymentMethod(-1);
    if ((Get.find<ProfileController>().userInfoModel!.walletBalance! <
            totalPrice) &&
        (Get.find<ProfileController>().userInfoModel!.walletBalance! != 0.0)) {
      Get.dialog(
        PartialPayDialogWidget(isPartialPay: true, totalPrice: totalPrice),
        useSafeArea: false,
      );
    } else {
      Get.dialog(
        PartialPayDialogWidget(isPartialPay: false, totalPrice: totalPrice),
        useSafeArea: false,
      );
    }
    update();
    return true;
  }

  void selectOfflineBank(int index, {bool canUpdate = true}) {
    _selectedOfflineBankIndex = index;
    if (canUpdate) {
      update();
    }
  }

  void setInstruction(int index) {
    if (_selectedInstruction == index) {
      _selectedInstruction = -1;
    } else {
      _selectedInstruction = index;
    }
    update();
  }

  void toggleDmTipSave() {
    _isDmTipSave = !_isDmTipSave;
    update();
  }

  void stopLoader({bool canUpdate = true}) {
    _isLoading = false;
    if (canUpdate) {
      update();
    }
  }

  Future<String> placeOrder(
      PlaceOrderBodyModel placeOrderBody,
      int? zoneID,
      double amount,
      double? maximumCodOrderAmount,
      bool fromCart,
      bool isCashOnDeliveryActive,
      List<XFile>? orderAttachment,
      {bool isOfflinePay = false}) async {
    List<MultipartBody>? multiParts = [];
    for (XFile file in orderAttachment!) {
      multiParts.add(MultipartBody('order_attachment[]', file));
    }
    _isLoading = true;
    update();
    String orderID = '';
    String userID = '';
    Response response =
        await checkoutServiceInterface.placeOrder(placeOrderBody, multiParts);
    _isLoading = false;
    if (response.statusCode == 200) {
      String? message = response.body['message'];
      orderID = response.body['order_id'].toString();
      if (response.body['user_id'] != null) {
        userID = response.body['user_id'].toString();
      }

      if (!isOfflinePay) {
        callback(
            true,
            message,
            orderID,
            zoneID,
            amount,
            maximumCodOrderAmount,
            fromCart,
            isCashOnDeliveryActive,
            placeOrderBody.contactPersonNumber!,
            userID);
      } else {
        Get.find<CartController>().getCartDataOnline();
      }
      _orderAttachment = null;
      _rawAttachment = null;
      if (kDebugMode) {
        print('-------- Order placed successfully $orderID ----------');
      }
    } else {
      if (!isOfflinePay) {
        callback(
            false,
            response.statusText,
            '-1',
            zoneID,
            amount,
            maximumCodOrderAmount,
            fromCart,
            isCashOnDeliveryActive,
            placeOrderBody.contactPersonNumber,
            userID);
      } else {
        showCustomSnackBar(response.statusText);
      }
    }
    update();

    return orderID;
  }

  Future<void> placePrescriptionOrder(
      int? storeId,
      int? zoneID,
      double? distance,
      String address,
      String longitude,
      String latitude,
      String note,
      List<XFile> orderAttachment,
      String dmTips,
      String deliveryInstruction,
      double orderAmount,
      double maxCodAmount,
      bool fromCart,
      bool isCashOnDeliveryActive) async {
    List<MultipartBody> multiParts = [];
    for (XFile file in orderAttachment) {
      multiParts.add(MultipartBody('order_attachment[]', file));
    }
    _isLoading = true;
    update();
    Response response = await checkoutServiceInterface.placePrescriptionOrder(
        storeId,
        distance,
        address,
        longitude,
        latitude,
        note,
        multiParts,
        dmTips,
        deliveryInstruction);
    _isLoading = false;
    if (response.statusCode == 200) {
      String? message = response.body['message'];
      String orderID = response.body['order_id'].toString();
      callback(true, message, orderID, zoneID, orderAmount, maxCodAmount,
          fromCart, isCashOnDeliveryActive, null, '');
      _orderAttachment = null;
      _rawAttachment = null;
      if (kDebugMode) {
        print('-------- Order placed successfully $orderID ----------');
      }
    } else {
      callback(false, response.statusText, '-1', zoneID, orderAmount,
          maxCodAmount, fromCart, isCashOnDeliveryActive, null, '');
    }
    update();
  }

  void callback(
      bool isSuccess,
      String? message,
      String orderID,
      int? zoneID,
      double amount,
      double? maximumCodOrderAmount,
      bool fromCart,
      bool isCashOnDeliveryActive,
      String? contactNumber,
      String userID) async {
    if (isSuccess) {
      if (fromCart) {
        Get.find<CartController>().clearCartList();
      }
      setGuestAddress(null);
      if (!Get.find<OrderController>().showBottomSheet) {
        Get.find<OrderController>().showRunningOrders(canUpdate: false);
      }
      if (isDmTipSave) {
        saveSharedPrefDmTipIndex(selectedTips.toString());
      }
      stopLoader(canUpdate: false);
      HomeScreen.loadData(true);

      // if (paymentMethodIndex == 2) {
      //   if (GetPlatform.isWeb) {
      //     // Get.back();
      //     await Get.find<AuthController>().saveGuestNumber(contactNumber ?? '');
      //     String? hostname = html.window.location.hostname;
      //     String protocol = html.window.location.protocol;
      //     String selectedUrl;
      //     selectedUrl =
      //         '${AppConstants.baseUrl}/payment-mobile?order_id=$orderID&&customer_id=${Get.find<ProfileController>().userInfoModel?.id ?? (userID.isNotEmpty ? userID : AuthHelper.getGuestId())}'
      //         '&payment_method=$digitalPaymentName&payment_platform=web&&callback=$protocol//$hostname${RouteHelper.orderSuccess}?id=$orderID&status=';
      //
      //     html.window.open(selectedUrl, "_self");
      //   } else {
      //     Get.offNamed(RouteHelper.getPaymentRoute(
      //       orderID,
      //       Get.find<ProfileController>().userInfoModel?.id ??
      //           (userID.isNotEmpty ? int.parse(userID) : 0),
      //       orderType,
      //       amount,
      //       isCashOnDeliveryActive,
      //       digitalPaymentName,
      //       guestId: userID.isNotEmpty ? userID : AuthHelper.getGuestId(),
      //       contactNumber: contactNumber,
      //     ));
      //   }
      // }
      if (paymentMethodIndex == 2) {
        // if (digitalPaymentName != null && digitalPaymentName!.isNotEmpty) {
        //   if (digitalPaymentName!.toLowerCase() == 'tranzila') {
        //     log("Digital payment is Tranzila, navigating to WebView screen.");
        //     Get.to(() => TranzilaWebPaymentScreen(orderID: orderID));
        //   }
        // } else {
          Get.to(() => DirectPaymentScreen(
                orderId: orderID,
                customerID: Get.find<ProfileController>().userInfoModel?.id ??
                    (userID.isNotEmpty ? int.parse(userID) : 0),
                orderType: orderType,
                amount: amount,
                isCashOnDeliveryActive: isCashOnDeliveryActive,
                paymentMethod: digitalPaymentName,
                guestID: userID.isNotEmpty ? userID : AuthHelper.getGuestId(),
                contactNumber: contactNumber,
              ));
        // }
      } else {
        double total = ((amount / 100) *
            Get.find<SplashController>()
                .configModel!
                .loyaltyPointItemPurchasePoint!);
        if (AuthHelper.isLoggedIn()) {
          Get.find<AuthController>().saveEarningPoint(total.toStringAsFixed(0));
        }
        if (ResponsiveHelper.isDesktop(Get.context) &&
            AuthHelper.isLoggedIn()) {
          Get.offNamed(RouteHelper.getInitialRoute());
          Future.delayed(
              const Duration(seconds: 2),
              () => Get.dialog(Center(
                  child: SizedBox(
                      height: 350,
                      width: 500,
                      child: OrderSuccessfulDialog(orderID: orderID)))));
        } else {
          Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID, contactNumber,
              createAccount: _isCreateAccount));
        }
      }
      clearPrevData();
      Get.find<CouponController>().removeCouponData(false);
      updateTips(
        getSharedPrefDmTipIndex().isNotEmpty
            ? int.parse(getSharedPrefDmTipIndex())
            : 0,
        notify: false,
      );
    } else {
      showCustomSnackBar(message);
    }
  }

  void toggleExpand() {
    _isExpand = !_isExpand;
    update();
  }

  void updateTimeSlot(int index) {
    _selectedTimeSlot = index;
    update();
  }

  void updateDateSlot(int index, int? interval) {
    _selectedDateSlot = index;
    if (_allTimeSlots != null) {
      validateSlot(_allTimeSlots!, index, interval);
    }
    update();
  }

  void validateSlot(List<TimeSlotModel> slots, int dateIndex, int? interval,
      {bool notify = true}) {
    _timeSlots = [];
    DateTime now = DateTime.now();
    if (Get.find<SplashController>()
        .configModel!
        .moduleConfig!
        .module!
        .orderPlaceToScheduleInterval!) {
      now = now.add(Duration(minutes: interval!));
    }
    int day = 0;
    if (dateIndex == 0) {
      day = DateTime.now().weekday;
    } else {
      day = DateTime.now().add(const Duration(days: 1)).weekday;
    }
    if (day == 7) {
      day = 0;
    }
    for (var slot in slots) {
      if (day == slot.day &&
          (dateIndex == 0 ? slot.endTime!.isAfter(now) : true)) {
        _timeSlots!.add(slot);
      }
    }
    if (notify) {
      update();
    }
  }

  bool _isCreateAccount = false;

  bool get isCreateAccount => _isCreateAccount;

  void toggleCreateAccount({bool willUpdate = true}) {
    _isCreateAccount = !_isCreateAccount;
    if (willUpdate) {
      update();
    }
  }
}
