import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sixam_mart/features/checkout/screens/order_successful_screen.dart';
import 'package:sixam_mart/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:flutter/services.dart';


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
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  bool _loading = false;
  bool _isDefaultCard = false;
  bool _showAddCardForm = false; // جديد: للتحكم في عرض نموذج الإضافة
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
      _savedCards = cardsJson.map((card) => Map<String, String>.from(json.decode(card))).toList();
      
      // تحديد البطاقة الافتراضية إذا كانت موجودة
      if (_savedCards.isNotEmpty) {
        final defaultCardIndex = _savedCards.indexWhere((card) => card['isDefault'] == 'true');
        if (defaultCardIndex != -1) {
          _selectedCardId = _savedCards[defaultCardIndex]['id'];
        } else {
          _selectedCardId = _savedCards[0]['id'];
        }
      }
    });
  }

  Future<void> _saveNewCard() async {
    final newCard = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'cardNumber': _cardNumberController.text.replaceAll(' ', ''),
      'expiryDate': _expiryController.text,
      'cardHolder': _nameController.text,
        'cvv': _cvvController.text, // أضف هذا
      'lastFour': _cardNumberController.text.replaceAll(' ', '').substring(_cardNumberController.text.length - 4),
      'isDefault': _isDefaultCard.toString(),
    };

    final prefs = await SharedPreferences.getInstance();
    List<String> cardsJson = prefs.getStringList('saved_cards') ?? [];
    cardsJson.add(json.encode(newCard));
    await prefs.setStringList('saved_cards', cardsJson);

    // إذا كانت البطاقة افتراضية، إلغاء Default من البطاقات الأخرى
    if (_isDefaultCard) {
      await _updateDefaultCard(newCard['id']!);
    }

    // إعادة تحميل البطاقات وإخفاء نموذج الإضافة
    await _loadSavedCards();
    setState(() {
      _showAddCardForm = false;
    });
  }

  Future<void> _updateDefaultCard(String cardId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cardsJson = prefs.getStringList('saved_cards') ?? [];
    
    for (int i = 0; i < cardsJson.length; i++) {
      final card = Map<String, String>.from(json.decode(cardsJson[i]));
      card['isDefault'] = (card['id'] == cardId).toString();
      cardsJson[i] = json.encode(card);
    }
    
    await prefs.setStringList('saved_cards', cardsJson);
    await _loadSavedCards(); // إعادة تحميل البطاقات بعد التحديث
  }

  Future<void> _processPayment({bool useSavedCard = false}) async {
    if (!useSavedCard && !_formKey.currentState!.validate()) return;

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

      if (useSavedCard) {
  final selectedCard = _savedCards.firstWhere((card) => card['id'] == _selectedCardId);
  paymentData.addAll({
    "card_number": selectedCard['cardNumber'],
    "expiry_date": selectedCard['expiryDate'],
    "card_holder": selectedCard['cardHolder'],
    "cvv": selectedCard['cvv'], // أضف هذا
  });
} else {
  paymentData.addAll({
    "card_number": _cardNumberController.text.replaceAll(' ', ''),
    "expiry_date": _expiryController.text,
    "cvv": _cvvController.text,
    "card_holder": _nameController.text,
  });
  await _saveNewCard();
}


      final url = Uri.parse("http://waseyapp.com/payment/paytabs/pay");
      // final url = Uri.parse("https://panel.jouanapp.com/payment/paytabs/pay");
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

  Widget _buildAddNewCardForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "إضافة بطاقة جديدة",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        TextFormField(
  controller: _cardNumberController,
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(
    labelText: "رقم البطاقة",
    prefixIcon: Icon(Icons.credit_card),
  ),
  inputFormatters: [
    // هذا الفورماتر يقوم بإضافة فراغ بعد كل 4 أرقام
    FilteringTextInputFormatter.digitsOnly,
    CardNumberInputFormatter(),
  ],
  validator: (value) => value!.replaceAll(' ', '').length < 16 ? "رقم البطاقة غير صالح" : null,
),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "CVV"),
                  validator: (value) => value!.length < 3 ? "CVV غير صالح" : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
  controller: _expiryController,
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(
    labelText: "تاريخ الانتهاء (MM/YY)",
  ),
  inputFormatters: [ExpiryDateInputFormatter()],
  validator: (value) {
    if (value == null || value.isEmpty) return 'ادخل تاريخ الانتهاء';
    if (!value.contains('/') || value.length != 5) return 'استخدم الصيغة MM/YY';
    return null;
  },
),

              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "اسم البطاقة (اختياري)"),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _isDefaultCard,
            onChanged: (val) => setState(() => _isDefaultCard = val),
            title: const Text("تعيين كالبطاقة الافتراضية"),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _showAddCardForm = false),
                  child: const Text("إلغاء"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () => _processPayment(useSavedCard: false),
                        child: const Text("حفظ والدفع"),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavedCardsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "البطاقات المحفوظة",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_savedCards.isEmpty)
          const Center(
            child: Text("لا توجد بطاقات محفوظة"),
          )
        else
          ..._savedCards.map((card) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: RadioListTile<String>(
                  value: card['id']!,
                  groupValue: _selectedCardId,
                  onChanged: (value) => setState(() => _selectedCardId = value),
                  title: Text("•••• •••• •••• ${card['lastFour']}"),
                  subtitle: Text("${card['cardHolder']} - ${card['expiryDate']}"),
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
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("دفع الآن"),
              ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () => setState(() => _showAddCardForm = true),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text("إضافة بطاقة جديدة"),
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
        appBar: AppBar(
          title: Text(_showAddCardForm ? "إضافة بطاقة جديدة" : "طريقة الدفع"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: _showAddCardForm ? _buildAddNewCardForm() : _buildSavedCardsList(),
          ),
        ),
      ),
    );
  }

  
}
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // إزالة أي فراغات موجودة
    String digitsOnly = newValue.text.replaceAll(' ', '');
    
    // إضافة فراغ بعد كل 4 أرقام
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i != 0 && i % 4 == 0) formatted += ' ';
      formatted += digitsOnly[i];
    }

    // إعادة القيمة الجديدة مع الحفاظ على موقع الكورسور
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String digitsOnly = newValue.text.replaceAll('/', '');

    // إضافة صفر إذا كتب المستخدم شهر برقم واحد
    if (digitsOnly.length == 1 && int.parse(digitsOnly) > 1) {
      digitsOnly = '0$digitsOnly';
    }

    // إضافة / بعد الرقمين
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2) formatted += '/';
      formatted += digitsOnly[i];
    }

    // تحديد مكان الكورسور
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
