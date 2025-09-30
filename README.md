# Card Capture (Flutter) — assignment sample

## What it does
- Admins can submit card details: Card Number, Card Type (inferred), CVV, Issuing Country
- Inferred card type auto-updates as card number is typed
- Banned countries list is configurable under Settings
- Cards that pass Luhn & CVV checks and are from non-banned countries are saved to local storage
- Prevents duplicate card entries
- Optional: card scanning placeholder (commented) — integrate `card_scanner` for full scanning

## How to run
1. Create a new Flutter project
2. Replace lib/ with provided files
3. Add dependencies to `pubspec.yaml`:
   - shared_preferences
   - optionally card_scanner if enabling scanning
4. `flutter pub get`
5. Run on device/emulator: `flutter run`

## Security notes
This sample stores full card numbers and CVV locally for the assignment. **Do not** do this in production. Follow PCI-DSS and use tokenization & encryption.

## Extending
- Use `hive` or `sqflite` for richer storage
- Use ISO country codes instead of raw names
- Add masking/encryption, backend tokenization
- Add unit tests for `CardUtils` functions

