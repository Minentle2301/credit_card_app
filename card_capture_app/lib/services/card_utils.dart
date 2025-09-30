// lib/services/card_utils.dart
class CardUtils {
  // Inference using common BIN prefixes / lengths
  static String inferCardType(String number) {
    final n = number.replaceAll(RegExp(r'\s+'), '');
    if (n.isEmpty) return 'Unknown';

    if (RegExp(r'^4').hasMatch(n)) {
      return 'Visa';
    }
    // MasterCard: 51-55, 2221-2720
    if (RegExp(r'^(5[1-5])').hasMatch(n) ||
        RegExp(
          r'^(222[1-9]|22[3-9]\d|2[3-6]\d{2}|27[01]\d|2720)',
        ).hasMatch(n)) {
      return 'MasterCard';
    }
    // American Express
    if (RegExp(r'^(34|37)').hasMatch(n)) {
      return 'American Express';
    }
    // Discover
    if (RegExp(r'^(6011|65|64[4-9]|622)').hasMatch(n)) {
      return 'Discover';
    }
    // Diners Club
    if (RegExp(r'^(36|38|30[0-5])').hasMatch(n)) {
      return 'Diners Club';
    }
    // JCB
    if (RegExp(r'^(35)').hasMatch(n)) {
      return 'JCB';
    }
    return 'Unknown';
  }

  // Luhn algorithm (digit-by-digit)
  static bool luhnCheck(String number) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return false;

    int sum = 0;
    final reversed = digits.split('').reversed.toList();

    for (int i = 0; i < reversed.length; i++) {
      int d = int.parse(reversed[i]);
      if (i % 2 == 1) {
        // double every second digit (since reversed, this corresponds to original's even positions from right)
        int doubled = d * 2;
        if (doubled > 9) doubled -= 9; // sum digits
        sum += doubled;
      } else {
        sum += d;
      }
    }
    return sum % 10 == 0;
  }

  static bool validateCVV(String cvv, String cardType) {
    final digits = cvv.replaceAll(RegExp(r'\D'), '');
    if (cardType == 'American Express') {
      return digits.length == 4;
    }
    return digits.length == 3;
  }
}
