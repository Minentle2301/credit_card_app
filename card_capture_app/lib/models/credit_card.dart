// I created this file to define the data model for credit cards in my app.
// Using a class with final fields ensures immutability, which is good for data integrity.
// I imported dart:convert for JSON serialization, as I need to store and load cards from storage.

import 'dart:convert';

// I defined CreditCardModel as a class to represent a credit card entity.
// This encapsulates all the necessary fields for a card in my application.
class CreditCardModel {
  // I stored the full card number as required by the app's functionality.
  // Even though it's sensitive, I handle masking in the UI for security.
  final String cardNumber;

  // I included cardType to identify the card brand like Visa or Mastercard.
  // This helps in validation and UI representation.
  final String cardType;

  // I stored the CVV for completeness, but I obscure it in the UI.
  // This field is essential for card validation logic.
  final String cvv;

  // I added issuingCountry to track where the card was issued.
  // This is used for banned country checks in my validation logic.
  final String issuingCountry;

  // I included createdAt to timestamp when the card was added.
  // This provides audit information and helps in sorting or displaying cards.
  final DateTime createdAt;

  // I used a constructor with required parameters to ensure all fields are provided.
  // This prevents incomplete card objects from being created.
  CreditCardModel({
    required this.cardNumber,
    required this.cardType,
    required this.cvv,
    required this.issuingCountry,
    required this.createdAt,
  });

  // I implemented toJson to convert the object to a map for serialization.
  // This is necessary for storing the card in shared preferences as JSON.
  Map<String, dynamic> toJson() => {
    'cardNumber': cardNumber,
    'cardType': cardType,
    'cvv': cvv,
    'issuingCountry': issuingCountry,
    'createdAt': createdAt.toIso8601String(),
  };

  // I created a factory constructor fromJson to recreate the object from JSON.
  // This handles deserialization when loading from storage.
  factory CreditCardModel.fromJson(Map<String, dynamic> json) =>
      CreditCardModel(
        cardNumber: json['cardNumber'] as String,
        cardType: json['cardType'] as String,
        cvv: json['cvv'] as String,
        issuingCountry: json['issuingCountry'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  // I added a static method to convert a JSON string to a list of cards.
  // This is useful for bulk loading from storage.
  static List<CreditCardModel> listFromJsonString(String jsonString) {
    // I decoded the JSON string to a list of dynamic objects.
    final decoded = json.decode(jsonString) as List<dynamic>;
    // I mapped each item to a CreditCardModel using the fromJson factory.
    return decoded
        .map((e) => CreditCardModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // I added a static method to convert a list of cards to a JSON string.
  // This is used for saving the list to storage.
  static String listToJsonString(List<CreditCardModel> list) {
    // I mapped each card to its JSON representation.
    final mapped = list.map((e) => e.toJson()).toList();
    // I encoded the list to a JSON string.
    return json.encode(mapped);
  }
}
