// I created this utility class to handle credit card validation and type inference.
// It's a static class because I don't need instances; all methods are utility functions.
// This keeps the code organized and reusable across my app.

class CardUtils {
  // I implemented inferCardType to determine the card brand from the number.
  // I used common BIN (Bank Identification Number) prefixes for accuracy.
  // This helps in UI representation and specific validation rules.
  static String inferCardType(String number) {
    // I cleaned the input by removing spaces for consistent processing.
    final n = number.replaceAll(RegExp(r'\s+'), '');
    // I returned 'Unknown' for empty inputs to handle edge cases.
    if (n.isEmpty) return 'Unknown';

    // I checked for Visa cards starting with 4.
    if (RegExp(r'^4').hasMatch(n)) {
      return 'Visa';
    }
    // I handled MasterCard ranges: 51-55 and 2221-2720.
    // I used two regex patterns for clarity and accuracy.
    if (RegExp(r'^(5[1-5])').hasMatch(n) ||
        RegExp(
          r'^(222[1-9]|22[3-9]\d|2[3-6]\d{2}|27[01]\d|2720)',
        ).hasMatch(n)) {
      return 'MasterCard';
    }
    // I checked for American Express starting with 34 or 37.
    if (RegExp(r'^(34|37)').hasMatch(n)) {
      return 'American Express';
    }
    // I handled Discover cards with various prefixes.
    if (RegExp(r'^(6011|65|64[4-9]|622)').hasMatch(n)) {
      return 'Discover';
    }
    // I checked for Diners Club with specific prefixes.
    if (RegExp(r'^(36|38|30[0-5])').hasMatch(n)) {
      return 'Diners Club';
    }
    // I checked for JCB cards starting with 35.
    if (RegExp(r'^(35)').hasMatch(n)) {
      return 'JCB';
    }
    // I returned 'Unknown' for unrecognized prefixes.
    return 'Unknown';
  }

  // I implemented the Luhn algorithm for card number validation.
  // This is the standard checksum method used by most credit cards.
  // It ensures the number is mathematically valid.
  static bool luhnCheck(String number) {
    // I extracted only digits from the input for processing.
    final digits = number.replaceAll(RegExp(r'\D'), '');
    // I returned false for empty digit strings.
    if (digits.isEmpty) return false;

    // I initialized sum to accumulate the checksum.
    int sum = 0;
    // I reversed the digits for easier processing from right to left.
    final reversed = digits.split('').reversed.toList();

    // I iterated through each digit with its position.
    for (int i = 0; i < reversed.length; i++) {
      // I parsed the digit to an integer.
      int d = int.parse(reversed[i]);
      // I doubled every second digit (odd indices in reversed list).
      if (i % 2 == 1) {
        int doubled = d * 2;
        // I subtracted 9 if doubled exceeds 9 (equivalent to summing digits).
        if (doubled > 9) doubled -= 9;
        // I added the doubled value to the sum.
        sum += doubled;
      } else {
        // I added undoubled digits directly.
        sum += d;
      }
    }
    // I checked if the sum is divisible by 10 for validity.
    return sum % 10 == 0;
  }

  // I created validateCVV to check CVV length based on card type.
  // American Express uses 4 digits, others use 3.
  // This ensures proper security code validation.
  static bool validateCVV(String cvv, String cardType) {
    // I extracted only digits from the CVV input.
    final digits = cvv.replaceAll(RegExp(r'\D'), '');
    // I checked for American Express requiring 4 digits.
    if (cardType == 'American Express') {
      return digits.length == 4;
    }
    // I defaulted to 3 digits for other card types.
    return digits.length == 3;
  }
}
