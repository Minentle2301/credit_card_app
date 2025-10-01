// lib/main.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'models/credit_card.dart';
import 'services/storage_service.dart';
import 'services/card_utils.dart';
import 'services/card_scanner_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CreditCardApp());
}

class CreditCardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CardVault Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[50],
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: LoginPage(),
    );
  }
}

// ---------------- LOGIN PAGE WITH OTP ----------------
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtl = TextEditingController();
  final _otpCtl = TextEditingController();

  bool _otpRequested = false;
  String _generatedOtp = "";
  bool _isLoading = false;

  void _requestOtp() async {
    if (_userCtl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter your phone or email first"),
          backgroundColor: Colors.orange.shade400,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _generatedOtp = "123456";
      _otpRequested = true;
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("🔐 OTP sent: $_generatedOtp (demo mode)"),
        backgroundColor: Colors.teal.shade400,
      ),
    );
  }

  void _verifyOtp() async {
    if (_otpCtl.text == _generatedOtp) {
      setState(() => _isLoading = true);
      await Future.delayed(Duration(milliseconds: 500));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CardHomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Invalid OTP - Please try again"),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade50,
              Colors.teal.shade50,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 8,
              shadowColor: Colors.deepPurple.withOpacity(0.2),
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.deepPurple, Colors.teal],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.fingerprint,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        "Welcome to CardVault",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Secure Digital Wallet",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      SizedBox(height: 32),
                      TextFormField(
                        controller: _userCtl,
                        decoration: InputDecoration(
                          labelText: "Phone or Email",
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Colors.deepPurple.shade400,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      SizedBox(height: 20),
                      if (_otpRequested) ...[
                        TextFormField(
                          controller: _otpCtl,
                          decoration: InputDecoration(
                            labelText: "Enter 6-digit OTP",
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.teal.shade400,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Demo OTP: 123456",
                          style: TextStyle(
                            color: Colors.teal.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      SizedBox(height: 32),
                      if (_isLoading)
                        CircularProgressIndicator(color: Colors.deepPurple)
                      else if (!_otpRequested)
                        ElevatedButton(
                          onPressed: _requestOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          child: Text("Send OTP"),
                        ),
                      if (_otpRequested && !_isLoading)
                        ElevatedButton(
                          onPressed: _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                          child: Text("Verify & Continue"),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- SCANNER PAGE ----------------
class ScannerPage extends StatefulWidget {
  final Function(Map<String, String>) onCardScanned;

  ScannerPage({required this.onCardScanned});

  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  late CardScannerService _scannerService;
  bool _isInitialized = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _scannerService = CardScannerService();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await _scannerService.initializeCamera();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initialize camera: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _scanCard() async {
    if (_isScanning) return;

    setState(() => _isScanning = true);

    try {
      final cardDetails = await _scannerService.scanCard();

      if (cardDetails.isNotEmpty) {
        widget.onCardScanned(cardDetails);
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No card details found. Try again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scanning failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isScanning = false);
    }
  }

  @override
  void dispose() {
    _scannerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Credit Card'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body:
          !_isInitialized
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CameraPreview(
                            _scannerService.cameraController,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Position card in frame and ensure text is clear',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        _isScanning
                            ? CircularProgressIndicator()
                            : ElevatedButton.icon(
                              onPressed: _scanCard,
                              icon: Icon(Icons.camera_alt),
                              label: Text('Scan Card'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                minimumSize: Size(double.infinity, 50),
                              ),
                            ),
                        SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}

// ---------------- CARD HOME PAGE ----------------
class CardHomePage extends StatefulWidget {
  @override
  _CardHomePageState createState() => _CardHomePageState();
}

class _CardHomePageState extends State<CardHomePage> {
  final _storage = StorageService();
  final _formKey = GlobalKey<FormState>();
  final _cardNumberCtl = TextEditingController();
  final _cvvCtl = TextEditingController();
  final _countryCtl = TextEditingController();
  String _inferredType = 'Unknown';
  List<CreditCardModel> _cards = [];
  List<String> _bannedCountries = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _cardNumberCtl.addListener(() {
      final inferred = CardUtils.inferCardType(_cardNumberCtl.text);
      setState(() => _inferredType = inferred);
    });
  }

  Future<void> _loadAll() async {
    final cards = await _storage.loadCards();
    final banned = await _storage.loadBannedCountries();
    setState(() {
      _cards = cards;
      _bannedCountries = banned;
    });
  }

  Future<void> _scanCard() async {
    final result = await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(
        builder:
            (context) => ScannerPage(
              onCardScanned: (details) {
                Navigator.of(context).pop(details);
              },
            ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      if (result['cardNumber'] != null) {
        _cardNumberCtl.text = result['cardNumber']!;
        final inferred = CardUtils.inferCardType(_cardNumberCtl.text);
        setState(() => _inferredType = inferred);
      }

      if (result['cvv'] != null) {
        _cvvCtl.text = result['cvv']!;
      }

      _showSnack('✅ Card details scanned successfully!', Colors.green);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final cardNumber = _cardNumberCtl.text.replaceAll(RegExp(r'\s+'), '');
    final cvv = _cvvCtl.text;
    final country = _countryCtl.text.trim();
    final cardType = CardUtils.inferCardType(cardNumber);

    final bannedLower = _bannedCountries.map((e) => e.toLowerCase()).toList();
    if (bannedLower.contains(country.toLowerCase())) {
      _showSnack('🚫 Issuing country "$country" is banned.', Colors.orange);
      setState(() => _isSubmitting = false);
      return;
    }

    if (!CardUtils.luhnCheck(cardNumber)) {
      _showSnack('❌ Card number failed validation check.', Colors.red);
      setState(() => _isSubmitting = false);
      return;
    }

    if (!CardUtils.validateCVV(cvv, cardType)) {
      _showSnack('❌ Invalid CVV for $cardType card.', Colors.red);
      setState(() => _isSubmitting = false);
      return;
    }

    final card = CreditCardModel(
      cardNumber: cardNumber,
      cardType: cardType,
      cvv: cvv,
      issuingCountry: country,
      createdAt: DateTime.now(),
    );

    final added = await _storage.addCardIfNotDuplicate(card);
    if (!added) {
      _showSnack('⚠️ This card was already captured.', Colors.orange);
      setState(() => _isSubmitting = false);
      return;
    }

    await _loadAll();
    _formKey.currentState!.reset();
    _cardNumberCtl.clear();
    _cvvCtl.clear();
    _countryCtl.clear();
    setState(() {
      _inferredType = 'Unknown';
      _isSubmitting = false;
    });
    _showSnack('✅ Card saved securely!', Colors.teal);
  }

  void _showSnack(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _openSettings() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => SettingsPage(storage: _storage)));
    await _loadAll();
  }

  String _maskNumber(String n) {
    final only = n.replaceAll(RegExp(r'\s+'), '');
    if (only.length <= 4) return only;
    final last4 = only.substring(only.length - 4);
    return '**** **** **** $last4';
  }

  IconData _getCardIcon(String type) {
    switch (type.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_score;
      case 'amex':
        return Icons.diamond;
      default:
        return Icons.payment;
    }
  }

  Color _getCardColor(String type) {
    switch (type.toLowerCase()) {
      case 'visa':
        return Colors.blue.shade400;
      case 'mastercard':
        return Colors.red.shade400;
      case 'amex':
        return Colors.green.shade400;
      default:
        return Colors.deepPurple.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.credit_card, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text(
              'CardVault',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade800,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        actions: [
          IconButton(
            onPressed: _openSettings,
            icon: Icon(Icons.settings, color: Colors.deepPurple.shade600),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        "Add New Card",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade800,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _cardNumberCtl,
                        decoration: InputDecoration(
                          labelText: 'Card Number',
                          prefixIcon: Icon(
                            Icons.credit_card,
                            color: Colors.deepPurple.shade400,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.qr_code_scanner,
                              color: Colors.teal.shade400,
                            ),
                            onPressed: _scanCard,
                            tooltip: 'Scan card',
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Please enter card number';
                          final digits = v.replaceAll(RegExp(r'\D'), '');
                          if (digits.length < 12)
                            return 'Card number too short';
                          if (!CardUtils.luhnCheck(digits))
                            return 'Invalid card number';
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _getCardColor(_inferredType).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getCardColor(
                              _inferredType,
                            ).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCardIcon(_inferredType),
                              size: 16,
                              color: _getCardColor(_inferredType),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Detected: $_inferredType',
                              style: TextStyle(
                                color: _getCardColor(_inferredType),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cvvCtl,
                              decoration: InputDecoration(
                                labelText: 'CVV',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: Colors.deepPurple.shade400,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Enter CVV';
                                if (!CardUtils.validateCVV(v, _inferredType))
                                  return 'Invalid CVV length';
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _countryCtl,
                              decoration: InputDecoration(
                                labelText: 'Issuing Country',
                                prefixIcon: Icon(
                                  Icons.flag_outlined,
                                  color: Colors.deepPurple.shade400,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Enter country';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child:
                            _isSubmitting
                                ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Saving...'),
                                  ],
                                )
                                : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.save_alt),
                                    SizedBox(width: 8),
                                    Text('Save Card Securely'),
                                  ],
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'My Cards',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade800,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_cards.length}',
                    style: TextStyle(
                      color: Colors.deepPurple.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Expanded(
              child:
                  _cards.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.credit_card_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No cards saved yet',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Add your first card above!',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: _cards.length,
                        itemBuilder: (context, idx) {
                          final c = _cards[idx];
                          final cardColor = _getCardColor(c.cardType);
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                            child: ListTile(
                              leading: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: cardColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getCardIcon(c.cardType),
                                  color: cardColor,
                                ),
                              ),
                              title: Text(
                                '${c.cardType} • ${_maskNumber(c.cardNumber)}',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Country: ${c.issuingCountry}',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'Added: ${c.createdAt.toLocal().toString().split(' ')[0]}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'CVV: ${c.cvv}',
                                  style: TextStyle(
                                    fontFamily: 'Monospace',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- SETTINGS PAGE ----------------
class SettingsPage extends StatefulWidget {
  final StorageService storage;
  SettingsPage({required this.storage});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<String> _banned = [];
  final _newCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await widget.storage.loadBannedCountries();
    setState(() => _banned = list);
  }

  Future<void> _addCountry() async {
    final text = _newCtl.text.trim();
    if (text.isEmpty) return;
    if (_banned.any((c) => c.toLowerCase() == text.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ "$text" is already in the list'),
          backgroundColor: Colors.orange.shade400,
        ),
      );
      return;
    }
    _banned.add(text);
    await widget.storage.saveBannedCountries(_banned);
    _newCtl.clear();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ "$text" added to banned countries'),
        backgroundColor: Colors.teal.shade400,
      ),
    );
  }

  Future<void> _removeAt(int i) async {
    final removed = _banned[i];
    _banned.removeAt(i);
    await widget.storage.saveBannedCountries(_banned);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🗑️ "$removed" removed from banned countries'),
        backgroundColor: Colors.red.shade400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Security Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple.shade800,
        elevation: 2,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.do_not_disturb_on,
                          color: Colors.orange.shade400,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Banned Countries',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple.shade800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Cards from these countries will be rejected',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newCtl,
                            decoration: InputDecoration(
                              labelText: 'Add banned country',
                              prefixIcon: Icon(
                                Icons.public_off,
                                color: Colors.deepPurple.shade400,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            onSubmitted: (_) => _addCountry(),
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.deepPurple, Colors.purple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: _addCountry,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Add'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child:
                  _banned.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: Colors.green.shade400,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No countries banned',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'All countries are allowed',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: _banned.length,
                        itemBuilder: (context, idx) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                            child: ListTile(
                              leading: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.block,
                                  color: Colors.orange.shade600,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                _banned[idx],
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red.shade400,
                                ),
                                onPressed: () => _removeAt(idx),
                                tooltip: 'Remove',
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
