// I created this service to handle persistent storage of cards and banned countries.
// I used shared_preferences package for simple key-value storage on device.
// This service abstracts storage details from the rest of the app.

import 'package:shared_preferences/shared_preferences.dart';
import '../models/credit_card.dart';

class StorageService {
  // I defined keys for storing cards and banned countries in shared preferences.
  static const _cardsKey = 'captured_cards';
  static const _bannedCountriesKey = 'banned_countries';

  // I implemented loadCards to asynchronously load saved cards from storage.
  // It returns an empty list if no cards are saved or on error.
  Future<List<CreditCardModel>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cardsKey);
    if (jsonString == null) return [];
    try {
      // I decode the JSON string to a list of CreditCardModel objects.
      return CreditCardModel.listFromJsonString(jsonString);
    } catch (_) {
      // I catch errors silently and return empty list to avoid crashes.
      return [];
    }
  }

  // I implemented saveCards to save a list of cards as a JSON string.
  // This overwrites the existing saved cards.
  Future<void> saveCards(List<CreditCardModel> cards) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cardsKey, CreditCardModel.listToJsonString(cards));
  }

  // I implemented loadBannedCountries to load the list of banned countries.
  // Returns empty list if none saved.
  Future<List<String>> loadBannedCountries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_bannedCountriesKey);
    if (list == null) {
      // default empty list; you can seed defaults here
      return <String>[];
    }
    return list;
  }

  // I implemented saveBannedCountries to save the list of banned countries.
  Future<void> saveBannedCountries(List<String> countries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_bannedCountriesKey, countries);
  }

  // I added a convenience method to add a card only if it doesn't already exist.
  // This prevents duplicate cards from being saved.
  Future<bool> addCardIfNotDuplicate(CreditCardModel card) async {
    final cards = await loadCards();
    final exists = cards.any((c) => c.cardNumber == card.cardNumber);
    if (exists) return false;
    cards.add(card);
    await saveCards(cards);
    return true;
  }
}
