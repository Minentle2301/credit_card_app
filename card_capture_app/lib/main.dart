// lib/main.dart
import 'package:flutter/material.dart';
import 'models/credit_card.dart';
import 'services/storage_service.dart';
import 'services/card_utils.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

void main() {
  runApp(CreditCardApp());
}

class CreditCardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Capture',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: CardHomePage(),
    );
  }
}

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cardNumber = _cardNumberCtl.text.replaceAll(RegExp(r'\s+'), '');
    final cvv = _cvvCtl.text;
    final country = _countryCtl.text.trim();
    final cardType = CardUtils.inferCardType(cardNumber);

    // Check banned
    final bannedLower = _bannedCountries.map((e) => e.toLowerCase()).toList();
    if (bannedLower.contains(country.toLowerCase())) {
      _showSnack('Issuing country is banned.');
      return;
    }

    // Luhn
    if (!CardUtils.luhnCheck(cardNumber)) {
      _showSnack('Card number failed validation (Luhn).');
      return;
    }

    // CVV
    if (!CardUtils.validateCVV(cvv, cardType)) {
      _showSnack('CVV does not match expected length for $cardType.');
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
      _showSnack('This card was already captured (duplicate).');
      return;
    }

    await _loadAll();
    _formKey.currentState!.reset();
    _cardNumberCtl.clear();
    _cvvCtl.clear();
    _countryCtl.clear();
    setState(() => _inferredType = 'Unknown');
    _showSnack('Card saved locally.');
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _openSettings() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => SettingsPage(storage: _storage)));
    await _loadAll();
  }

  // optional: card scanning integration example (pseudo)
  Future<void> _scanCard() async {
    // If you add card_scanner and platform setup, you can implement scanning.
    // Example pseudo-code:
    /*
    final details = await CardScanner.scanCard();
    if (details != null) {
      setState(() {
        _cardNumberCtl.text = details.cardNumber; // pre-populate
        _inferredType = CardUtils.inferCardType(details.cardNumber);
      });
    }
    */
    _showSnack('Scanning not configured. See README to enable scanner.');
  }

  String _maskNumber(String n) {
    final only = n.replaceAll(RegExp(r'\s+'), '');
    if (only.length <= 4) return only;
    final last4 = only.substring(only.length - 4);
    return '**** **** **** $last4';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Capture'),
        actions: [
          IconButton(onPressed: _openSettings, icon: Icon(Icons.settings)),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _cardNumberCtl,
                    decoration: InputDecoration(
                      labelText: 'Card Number',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.credit_card),
                        onPressed: _scanCard,
                        tooltip: 'Scan card (optional)',
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Enter card number';
                      final digits = v.replaceAll(RegExp(r'\D'), '');
                      if (digits.length < 12) return 'Too short to be a card';
                      if (!CardUtils.luhnCheck(digits))
                        return 'Card number invalid';
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Inferred card type: $_inferredType'),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _cvvCtl,
                          decoration: InputDecoration(labelText: 'CVV'),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Enter CVV';
                            final cardType = _inferredType;
                            if (!CardUtils.validateCVV(v, cardType))
                              return 'CVV seems invalid for $cardType';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _countryCtl,
                    decoration: InputDecoration(labelText: 'Issuing Country'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Enter issuing country';
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text('Validate & Save'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child:
                  _cards.isEmpty
                      ? Center(child: Text('No captured cards this session.'))
                      : ListView.builder(
                        itemCount: _cards.length,
                        itemBuilder: (context, idx) {
                          final c = _cards[idx];
                          return Card(
                            child: ListTile(
                              title: Text(
                                '${c.cardType} • ${_maskNumber(c.cardNumber)}',
                              ),
                              subtitle: Text(
                                'Country: ${c.issuingCountry}  • Saved: ${c.createdAt.toLocal()}',
                              ),
                              trailing: Text('${c.cvv}'),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Already in list')));
      return;
    }
    _banned.add(text);
    await widget.storage.saveBannedCountries(_banned);
    _newCtl.clear();
    setState(() {});
  }

  Future<void> _removeAt(int i) async {
    _banned.removeAt(i);
    await widget.storage.saveBannedCountries(_banned);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings - Banned Countries')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newCtl,
                    decoration: InputDecoration(
                      labelText: 'Add banned country (exact name)',
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(onPressed: _addCountry, child: Text('Add')),
              ],
            ),
            SizedBox(height: 12),
            Expanded(
              child:
                  _banned.isEmpty
                      ? Center(child: Text('No banned countries configured.'))
                      : ListView.builder(
                        itemCount: _banned.length,
                        itemBuilder: (context, idx) {
                          return ListTile(
                            title: Text(_banned[idx]),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _removeAt(idx),
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
