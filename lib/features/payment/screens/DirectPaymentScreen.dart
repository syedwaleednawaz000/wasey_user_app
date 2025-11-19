import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/features/checkout/screens/order_successful_screen.dart';
import 'package:sixam_mart/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class DirectPaymentScreen extends StatefulWidget {
  final double amount;
  final String orderId;
  final int customerID;
  final String? orderType;
  final bool isCashOnDeliveryActive;
  final String? paymentMethod;
  final String guestID;
  final String? contactNumber;

  const DirectPaymentScreen({
    super.key,
    required this.amount,
    required this.orderId,
    required this.customerID,
    this.orderType,
    required this.isCashOnDeliveryActive,
    this.paymentMethod,
    required this.guestID,
    this.contactNumber,
  });

  @override
  State<DirectPaymentScreen> createState() => _DirectPaymentScreenState();
}

class _DirectPaymentScreenState extends State<DirectPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  // --- NEW: Controllers for Expiry Date ---
  final _yearController = TextEditingController();
  String? _selectedMonth;

  // --- END NEW ---

  bool _loading = false;
  bool _isDefaultCard = false;
  bool _showAddCardForm = false;
  List<Map<String, String>> _savedCards = [];
  String? _selectedCardId;

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
  }

  Future<void> _loadSavedCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = prefs.getStringList('saved_cards') ?? [];

    setState(() {
      _savedCards = cardsJson
          .map((card) => Map<String, String>.from(json.decode(card)))
          .toList();

      if (_savedCards.isNotEmpty) {
        final defaultCardIndex =
            _savedCards.indexWhere((card) => card['isDefault'] == 'true');
        if (defaultCardIndex != -1) {
          _selectedCardId = _savedCards[defaultCardIndex]['id'];
        } else {
          _selectedCardId = _savedCards[0]['id'];
        }
      }
    });
  }

  // --- MODIFIED: _saveNewCard method ---
  Future<void> _saveNewCard() async {
    // Combine month and year for saving
    final expiryDate = '$_selectedMonth/${_yearController.text.substring(2)}';

    final newCard = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'cardNumber': _cardNumberController.text.replaceAll('-', ''),
      'expiryDate': expiryDate, // Use combined date
      'cardHolder': _nameController.text,
      'cvv': _cvvController.text,
      'lastFour': _cardNumberController.text
          .replaceAll('-', '')
          .substring(_cardNumberController.text.length - 8),
      'isDefault': _isDefaultCard.toString(),
    };

    final prefs = await SharedPreferences.getInstance();
    List<String> cardsJson = prefs.getStringList('saved_cards') ?? [];
    cardsJson.add(json.encode(newCard));
    await prefs.setStringList('saved_cards', cardsJson);

    if (_isDefaultCard) {
      await _updateDefaultCard(newCard['id']!);
    }

    await _loadSavedCards();
    setState(() {
      _showAddCardForm = false;
      // Clear form fields
      _cardNumberController.clear();
      _cvvController.clear();
      _nameController.clear();
      _yearController.clear();
      _selectedMonth = null;
      _isDefaultCard = false;
    });
  }

  // --- END MODIFICATION ---

  Future<void> _updateDefaultCard(String cardId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cardsJson = prefs.getStringList('saved_cards') ?? [];

    for (int i = 0; i < cardsJson.length; i++) {
      final card = Map<String, String>.from(json.decode(cardsJson[i]));
      card['isDefault'] = (card['id'] == cardId).toString();
      cardsJson[i] = json.encode(card);
    }

    await prefs.setStringList('saved_cards', cardsJson);
    await _loadSavedCards();
  }

  // --- MODIFIED: _processPayment method ---
  Future<void> _processPayment({bool useSavedCard = false}) async {
    if (!useSavedCard) {
      if (!_formKey.currentState!.validate()) return;
    }

    setState(() => _loading = true);

    try {
      Map<String, dynamic> paymentData = {
        "order_id": widget.orderId,
        "customer_id": widget.customerID,
        "order_type": widget.orderType ?? '',
        "amount": widget.amount,
        "is_cod": widget.isCashOnDeliveryActive,
        "payment_method": widget.paymentMethod ?? 'card',
        "guest_id": widget.guestID,
        "contact_number": widget.contactNumber ?? '',
      };

      // Combine expiry date for new card payment
      final expiryDate = useSavedCard
          ? _savedCards
              .firstWhere((card) => card['id'] == _selectedCardId)['expiryDate']
          : '$_selectedMonth/${_yearController.text.substring(2)}';

      if (useSavedCard) {
        final selectedCard =
            _savedCards.firstWhere((card) => card['id'] == _selectedCardId);
        paymentData.addAll({
          "card_number": selectedCard['cardNumber'],
          "expiry_date": selectedCard['expiryDate'],
          "card_holder": selectedCard['cardHolder'],
          "cvv": selectedCard['cvv'],
        });
      } else {
        paymentData.addAll({
          "card_number": _cardNumberController.text.replaceAll('-', ''),
          "expiry_date": expiryDate,
          "cvv": _cvvController.text,
          "card_holder": _nameController.text,
        });
        await _saveNewCard();
      }

      final url = Uri.parse("${AppConstants.baseUrl}/payment/paytabs/pay");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(paymentData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == "success") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessfulScreen(
              orderID: widget.orderId,
              guestId: widget.guestID,
            ),
          ),
        );
      } else {
        _showPaymentFailedDialog();
      }
    } catch (e) {
      _showPaymentFailedDialog();
    }

    setState(() => _loading = false);
  }

  // --- END MODIFICATION ---

  void _showPaymentFailedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaymentFailedDialog(
        orderID: widget.orderId,
        orderAmount: widget.amount,
        maxCodOrderAmount: 5000,
        orderType: widget.orderType,
        isCashOnDelivery: widget.isCashOnDeliveryActive,
        guestId: widget.guestID,
      ),
    );
  }

  // --- MODIFIED: _buildAddNewCardForm widget ---
  Widget _buildAddNewCardForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "add_new_card".tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            "card_number".tr,
            style: STCRegular,
          ),
          TextFormField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              // enabled: true,
              filled: true,
              fillColor: Theme.of(context).disabledColor.withOpacity(.1),
              // labelText: "card_number".tr,
              hintText: "0000-0000-0000-0000",
              hintStyle: STCRegular.copyWith(
                color: Theme.of(context).disabledColor,
              ),
              prefixIcon: const Icon(Icons.credit_card),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CardNumberInputFormatter(),
            ],
            validator: (value) => value!.replaceAll('-', '').length < 16
                ? "invalid_card_number".tr
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            "enter_expiry_date".tr,
            style: STCRegular,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _selectedMonth,
                  hint: Text("select_month".tr),
                  style: STCRegular.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
                  isExpanded: false,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0XFFF0F1F4),
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  ),
                  items: List.generate(12, (index) {
                    final month = (index + 1).toString().padLeft(2, '0');
                    return DropdownMenuItem(value: month, child: Text(month));
                  }),
                  onChanged: (value) {
                    setState(() {
                      _selectedMonth = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? "select_month".tr : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: InputDecoration(
                      hintText: "year".tr,
                      hintStyle: STCRegular.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                      filled: true,
                      fillColor:
                          Theme.of(context).disabledColor.withOpacity(.1),
                      border: const OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "enter_year".tr;
                    }
                    if (value.length != 4) {
                      return "invalid_year".tr;
                    }
                    final int year = int.tryParse(value) ?? 0;
                    final int month = int.tryParse(_selectedMonth ?? '0') ?? 0;
                    final now = DateTime.now();

                    if (year < now.year ||
                        (year == now.year && month < now.month)) {
                      return "card_expired".tr;
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "CVV",
            style: STCRegular,
          ),
          TextFormField(
            controller: _cvvController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            decoration: InputDecoration(
              hintText: "CVV",
              hintStyle: STCRegular.copyWith(
                color: Theme.of(context).disabledColor,
              ),
              filled: true,
              fillColor: Theme.of(context).disabledColor.withOpacity(.1),
              border: const OutlineInputBorder(),
            ),
            validator: (value) => value!.length < 3 ? "invalid_cvv".tr : null,
          ),
          const SizedBox(height: 12),
          Text(
            "card_name_optional".tr,
            style: STCRegular,
          ),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).disabledColor.withOpacity(.1),
              hintText: "card_name_optional".tr,
              hintStyle: STCRegular.copyWith(
                color: Theme.of(context).disabledColor,
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _isDefaultCard,
            onChanged: (val) => setState(() => _isDefaultCard = val),
            title: Text("set_as_default_card".tr),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusSmall,
                      ),
                    ),
                    minimumSize: const Size(double.infinity, 55),
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                    elevation: 5,
                  ),
                  onPressed: () => setState(() => _showAddCardForm = false),
                  child: Text("cancel".tr),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSmall,
                            ),
                          ),
                          minimumSize: const Size(double.infinity, 55),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 3,
                        ),
                        onPressed: () => _processPayment(useSavedCard: false),
                        child: Text("save_and_pay".tr),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- END MODIFICATION ---

  Widget _buildSavedCardsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "saved_cards".tr,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_savedCards.isEmpty)
          Center(
            child: Text("no_saved_cards".tr),
          )
        else
          ..._savedCards.map((card) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: RadioListTile<String>(
                  value: card['id']!,
                  groupValue: _selectedCardId,
                  onChanged: (value) => setState(() => _selectedCardId = value),
                  title: Text("•••• •••• •••• ${card['lastFour']}"),
                  subtitle:
                      Text("${card['cardHolder']} - ${card['expiryDate']}"),
                  secondary: card['isDefault'] == 'true'
                      ? const Icon(Icons.star, color: Colors.amber)
                      : null,
                ),
              )),
        const SizedBox(height: 16),
        _loading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: _savedCards.isNotEmpty
                    ? () => _processPayment(useSavedCard: true)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text("pay_now".tr),
              ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () => setState(() => _showAddCardForm = true),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: Theme.of(context).primaryColor,
            ),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).primaryColor,
              ),
              borderRadius: BorderRadius.circular(
                Dimensions.radiusDefault,
              ),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text("add_new_card".tr),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_showAddCardForm) {
          setState(() => _showAddCardForm = false);
          return false;
        }
        _showPaymentFailedDialog();
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: _showAddCardForm ? "add_new_card".tr : "payment_method".tr,
          backButton: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: _showAddCardForm
                ? _buildAddNewCardForm()
                : _buildSavedCardsList(),
          ),
        ),
      ),
    );
  }
}

// These formatters can remain as they are
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String digitsOnly = newValue.text.replaceAll('-', '');
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i != 0 && i % 4 == 0) formatted += '-';
      formatted += digitsOnly[i];
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String digitsOnly = newValue.text.replaceAll('/', '');
    if (digitsOnly.length == 1 && int.parse(digitsOnly) > 1) {
      digitsOnly = '0$digitsOnly';
    }
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2) formatted += '/';
      formatted += digitsOnly[i];
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
// import 'package:sixam_mart/common/widgets/custom_text_field.dart';
// import 'dart:convert';
// import 'package:sixam_mart/features/checkout/screens/order_successful_screen.dart';
// import 'package:sixam_mart/features/checkout/widgets/payment_failed_dialog.dart';
// import 'package:flutter/services.dart';
// import 'package:sixam_mart/util/app_constants.dart';
//
// class DirectPaymentScreen extends StatefulWidget {
//   final double amount;
//   final String orderId;
//   final int customerID;
//   final String? orderType;
//   final bool isCashOnDeliveryActive;
//   final String? paymentMethod;
//   final String guestID;
//   final String? contactNumber;
//
//   const DirectPaymentScreen({
//     super.key,
//     required this.amount,
//     required this.orderId,
//     required this.customerID,
//     this.orderType,
//     required this.isCashOnDeliveryActive,
//     this.paymentMethod,
//     required this.guestID,
//     this.contactNumber,
//   });
//
//   @override
//   State<DirectPaymentScreen> createState() => _DirectPaymentScreenState();
// }
//
// class _DirectPaymentScreenState extends State<DirectPaymentScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _cardNumberController = TextEditingController();
//   final _expiryController = TextEditingController();
//   final _cvvController = TextEditingController();
//   final _nameController = TextEditingController();
//
//   bool _loading = false;
//   bool _isDefaultCard = false;
//   bool _showAddCardForm = false; // جديد: للتحكم في عرض نموذج الإضافة
//   List<Map<String, String>> _savedCards = [];
//   String? _selectedCardId;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSavedCards();
//   }
//
//   Future<void> _loadSavedCards() async {
//     final prefs = await SharedPreferences.getInstance();
//     final cardsJson = prefs.getStringList('saved_cards') ?? [];
//
//     setState(() {
//       _savedCards = cardsJson
//           .map((card) => Map<String, String>.from(json.decode(card)))
//           .toList();
//
//       // تحديد البطاقة الافتراضية إذا كانت موجودة
//       if (_savedCards.isNotEmpty) {
//         final defaultCardIndex =
//             _savedCards.indexWhere((card) => card['isDefault'] == 'true');
//         if (defaultCardIndex != -1) {
//           _selectedCardId = _savedCards[defaultCardIndex]['id'];
//         } else {
//           _selectedCardId = _savedCards[0]['id'];
//         }
//       }
//     });
//   }
//
//   Future<void> _saveNewCard() async {
//     final newCard = {
//       'id': DateTime.now().millisecondsSinceEpoch.toString(),
//       'cardNumber': _cardNumberController.text.replaceAll('-', ''),
//       'expiryDate': _expiryController.text,
//       'cardHolder': _nameController.text,
//       'cvv': _cvvController.text, // أضف هذا
//       'lastFour': _cardNumberController.text
//           .replaceAll('-', '')
//           .substring(_cardNumberController.text.length - 4),
//       'isDefault': _isDefaultCard.toString(),
//     };
//
//     final prefs = await SharedPreferences.getInstance();
//     List<String> cardsJson = prefs.getStringList('saved_cards') ?? [];
//     cardsJson.add(json.encode(newCard));
//     await prefs.setStringList('saved_cards', cardsJson);
//
//     // إذا كانت البطاقة افتراضية، إلغاء Default من البطاقات الأخرى
//     if (_isDefaultCard) {
//       await _updateDefaultCard(newCard['id']!);
//     }
//
//     // إعادة تحميل البطاقات وإخفاء نموذج الإضافة
//     await _loadSavedCards();
//     setState(() {
//       _showAddCardForm = false;
//     });
//   }
//
//   Future<void> _updateDefaultCard(String cardId) async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String> cardsJson = prefs.getStringList('saved_cards') ?? [];
//
//     for (int i = 0; i < cardsJson.length; i++) {
//       final card = Map<String, String>.from(json.decode(cardsJson[i]));
//       card['isDefault'] = (card['id'] == cardId).toString();
//       cardsJson[i] = json.encode(card);
//     }
//
//     await prefs.setStringList('saved_cards', cardsJson);
//     await _loadSavedCards(); // إعادة تحميل البطاقات بعد التحديث
//   }
//
//   Future<void> _processPayment({bool useSavedCard = false}) async {
//     if (!useSavedCard && !_formKey.currentState!.validate()) return;
//
//     setState(() => _loading = true);
//
//     try {
//       Map<String, dynamic> paymentData = {
//         "order_id": widget.orderId,
//         "customer_id": widget.customerID,
//         "order_type": widget.orderType ?? '',
//         "amount": widget.amount,
//         "is_cod": widget.isCashOnDeliveryActive,
//         "payment_method": widget.paymentMethod ?? 'card',
//         "guest_id": widget.guestID,
//         "contact_number": widget.contactNumber ?? '',
//       };
//
//       if (useSavedCard) {
//         final selectedCard =
//             _savedCards.firstWhere((card) => card['id'] == _selectedCardId);
//         paymentData.addAll({
//           "card_number": selectedCard['cardNumber'],
//           "expiry_date": selectedCard['expiryDate'],
//           "card_holder": selectedCard['cardHolder'],
//           "cvv": selectedCard['cvv'], // أضف هذا
//         });
//       } else {
//         paymentData.addAll({
//           "card_number": _cardNumberController.text.replaceAll(' ', ''),
//           "expiry_date": _expiryController.text,
//           "cvv": _cvvController.text,
//           "card_holder": _nameController.text,
//         });
//         await _saveNewCard();
//       }
//
//       // final url = Uri.parse("https://panel.jouanapp.com/payment/paytabs/pay");
//       final url = Uri.parse("${AppConstants.baseUrl}/payment/paytabs/pay");
//       print("paymentURI: ${url.toString()}");
//       print("paymentDataBody: ${paymentData.toString()}");
//
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(paymentData),
//       );
//
//       final data = jsonDecode(response.body);
//       print("response: $data");
//
//       if (response.statusCode == 200 && data["status"] == "success") {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => OrderSuccessfulScreen(
//               orderID: widget.orderId,
//               guestId: widget.guestID,
//             ),
//           ),
//         );
//       } else {
//         _showPaymentFailedDialog();
//       }
//     } catch (e) {
//       _showPaymentFailedDialog();
//     }
//
//     setState(() => _loading = false);
//   }
//
//   void _showPaymentFailedDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => PaymentFailedDialog(
//         orderID: widget.orderId,
//         orderAmount: widget.amount,
//         maxCodOrderAmount: 5000,
//         orderType: widget.orderType,
//         isCashOnDelivery: widget.isCashOnDeliveryActive,
//         guestId: widget.guestID,
//       ),
//     );
//   }
//
//   Widget _buildAddNewCardForm() {
//     return Form(
//       key: _formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "add_new_card".tr,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           TextFormField(
//             controller: _cardNumberController,
//             keyboardType: TextInputType.number,
//             decoration: InputDecoration(
//               labelText: "card_number".tr,
//               prefixIcon: const Icon(Icons.credit_card),
//             ),
//             inputFormatters: [
//               // هذا الفورماتر يقوم بإضافة فراغ بعد كل 4 أرقام
//               FilteringTextInputFormatter.digitsOnly,
//               CardNumberInputFormatter(),
//             ],
//             validator: (value) => value!.replaceAll('-', '').length < 16
//                 ? "invalid_card_number".tr
//                 : null,
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: TextFormField(
//                   controller: _cvvController,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(labelText: "CVV"),
//                   validator: (value) =>
//                       value!.length < 3 ? "invalid_cvv".tr : null,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: TextFormField(
//                   controller: _expiryController,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     labelText: "expiry_date".tr,
//                   ),
//                   inputFormatters: [ExpiryDateInputFormatter()],
//                   validator: (value) {
//                     if (value == null || value.isEmpty)
//                       return 'enter_expiry_date'.tr;
//                     if (!value.contains('/') || value.length != 5)
//                       return 'use_mm_yy_format'.tr;
//                     return null;
//                   },
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           TextFormField(
//             controller: _nameController,
//             decoration: InputDecoration(labelText: "card_name_optional".tr),
//           ),
//           const SizedBox(height: 12),
//           SwitchListTile(
//             value: _isDefaultCard,
//             onChanged: (val) => setState(() => _isDefaultCard = val),
//             title: Text("set_as_default_card".tr),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () => setState(() => _showAddCardForm = false),
//                   child: Text("cancel".tr),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _loading
//                     ? const Center(child: CircularProgressIndicator())
//                     : ElevatedButton(
//                         onPressed: () => _processPayment(useSavedCard: false),
//                         child: Text("save_and_pay".tr),
//                       ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSavedCardsList() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "saved_cards".tr,
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 16),
//         if (_savedCards.isEmpty)
//           Center(
//             child: Text("no_saved_cards".tr),
//           )
//         else
//           ..._savedCards.map((card) => Card(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 child: RadioListTile<String>(
//                   value: card['id']!,
//                   groupValue: _selectedCardId,
//                   onChanged: (value) => setState(() => _selectedCardId = value),
//                   title: Text("•••• •••• •••• ${card['lastFour']}"),
//                   subtitle:
//                       Text("${card['cardHolder']} - ${card['expiryDate']}"),
//                   secondary: card['isDefault'] == 'true'
//                       ? const Icon(Icons.star, color: Colors.amber)
//                       : null,
//                 ),
//               )),
//         const SizedBox(height: 16),
//         _loading
//             ? const Center(child: CircularProgressIndicator())
//             : ElevatedButton(
//                 onPressed: _savedCards.isNotEmpty
//                     ? () => _processPayment(useSavedCard: true)
//                     : null,
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 50),
//                 ),
//                 child: Text("pay_now".tr),
//               ),
//         const SizedBox(height: 20),
//         OutlinedButton(
//           onPressed: () => setState(() => _showAddCardForm = true),
//           style: OutlinedButton.styleFrom(
//             minimumSize: const Size(double.infinity, 50),
//           ),
//           child: Text("add_new_card".tr),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if (_showAddCardForm) {
//           setState(() => _showAddCardForm = false);
//           return false;
//         }
//         _showPaymentFailedDialog();
//         return false;
//       },
//       child: Scaffold(
//         appBar: CustomAppBar(
//           title: _showAddCardForm ? "add_new_card".tr : "payment_method".tr,
//           backButton: true,
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16),
//           child: SingleChildScrollView(
//             child: _showAddCardForm
//                 ? _buildAddNewCardForm()
//                 : _buildSavedCardsList(),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class CardNumberInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     // إزالة أي فراغات موجودة
//     String digitsOnly = newValue.text.replaceAll('-', '');
//
//     // إضافة فراغ بعد كل 4 أرقام
//     String formatted = '';
//     for (int i = 0; i < digitsOnly.length; i++) {
//       if (i != 0 && i % 4 == 0) formatted += '-';
//       formatted += digitsOnly[i];
//     }
//
//     // إعادة القيمة الجديدة مع الحفاظ على موقع الكورسور
//     return TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );
//   }
// }
//
// class ExpiryDateInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     String digitsOnly = newValue.text.replaceAll('/', '');
//
//     // إضافة صفر إذا كتب المستخدم شهر برقم واحد
//     if (digitsOnly.length == 1 && int.parse(digitsOnly) > 1) {
//       digitsOnly = '0$digitsOnly';
//     }
//
//     // إضافة / بعد الرقمين
//     String formatted = '';
//     for (int i = 0; i < digitsOnly.length; i++) {
//       if (i == 2) formatted += '/';
//       formatted += digitsOnly[i];
//     }
//
//     // تحديد مكان الكورسور
//     return TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );
//   }
// }
