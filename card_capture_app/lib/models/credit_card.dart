import 'dart:convert';

class CreditCardModel {
  final String cardNumber; // store full number per requirement
  final String cardType;
  final String cvv;
  final String issuingCountry;
  final DateTime createdAt;

  CreditCardModel({
    required this.cardNumber,
    required this.cardType,
    required this.cvv,
    required this.issuingCountry,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'cardNumber': cardNumber,
    'cardType': cardType,
    'cvv': cvv,
    'issuingCountry': issuingCountry,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CreditCardModel.fromJson(Map<String, dynamic> json) =>
      CreditCardModel(
        cardNumber: json['cardNumber'] as String,
        cardType: json['cardType'] as String,
        cvv: json['cvv'] as String,
        issuingCountry: json['issuingCountry'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  static List<CreditCardModel> listFromJsonString(String jsonString) {
    final decoded = json.decode(jsonString) as List<dynamic>;
    return decoded
        .map((e) => CreditCardModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJsonString(List<CreditCardModel> list) {
    final mapped = list.map((e) => e.toJson()).toList();
    return json.encode(mapped);
  }
}
