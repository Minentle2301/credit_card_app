// lib/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/credit_card.dart';

class StorageService {
  static const _cardsKey = 'captured_cards';
  static const _bannedCountriesKey = 'banned_countries';

  Future<List<CreditCardModel>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cardsKey);
    if (jsonString == null) return [];
    try {
      return CreditCardModel.listFromJsonString(jsonString);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCards(List<CreditCardModel> cards) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cardsKey, CreditCardModel.listToJsonString(cards));
  }

  Future<List<String>> loadBannedCountries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_bannedCountriesKey);
    if (list == null) {
      // default empty list; you can seed defaults here
      return <String>[];
    }
    return list;
  }

  Future<void> saveBannedCountries(List<String> countries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_bannedCountriesKey, countries);
  }

  // convenience: add card if not duplicate
  Future<bool> addCardIfNotDuplicate(CreditCardModel card) async {
    final cards = await loadCards();
    final exists = cards.any((c) => c.cardNumber == card.cardNumber);
    if (exists) return false;
    cards.add(card);
    await saveCards(cards);
    return true;
  }
}
