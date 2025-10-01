// lib/services/card_scanner_service.dart
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:async';

class CardScannerService {
  late CameraController _cameraController;
  bool _isScanning = false;
  final TextRecognizer _textRecognizer = TextRecognizer();

  // I'm initializing the camera for card scanning
  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController.initialize();
  }

  // I'm processing the camera image to extract card information
  Future<Map<String, String>> scanCard() async {
    if (_isScanning) return {};
    _isScanning = true;

    try {
      final image = await _cameraController.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      // I'm parsing the recognized text to extract card details
      return _parseCardDetails(recognizedText.text);
    } catch (e) {
      print('Error scanning card: $e');
      return {};
    } finally {
      _isScanning = false;
    }
  }

  // I'm parsing the OCR text to extract card number, expiry, etc.
  Map<String, String> _parseCardDetails(String text) {
    final lines = text.split('\n');
    Map<String, String> details = {};

    for (String line in lines) {
      final trimmedLine = line.trim();

      // I'm looking for card numbers (groups of 4 digits)
      if (_isCardNumber(trimmedLine)) {
        details['cardNumber'] = _extractCardNumber(trimmedLine);
      }

      // I'm looking for expiry dates (MM/YY or MM/YYYY format)
      if (_isExpiryDate(trimmedLine)) {
        details['expiry'] = _extractExpiryDate(trimmedLine);
      }

      // I'm looking for cardholder names (typically contains alphabetic characters)
      if (_isCardholderName(trimmedLine)) {
        details['cardholder'] = trimmedLine;
      }

      // I'm looking for CVV (3-4 digit numbers)
      if (_isCVV(trimmedLine)) {
        details['cvv'] = _extractCVV(trimmedLine);
      }
    }

    return details;
  }

  bool _isCardNumber(String text) {
    // Remove spaces and check if it's a potential card number
    final digits = text.replaceAll(RegExp(r'\s+'), '');
    return digits.length >= 12 &&
        digits.length <= 19 &&
        RegExp(r'^\d+$').hasMatch(digits);
  }

  String _extractCardNumber(String text) {
    // Extract and format card number
    final digits = text.replaceAll(RegExp(r'\D'), '');
    // Format as groups of 4 digits for better readability
    final formatted =
        digits
            .replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)} ')
            .trim();
    return formatted;
  }

  bool _isExpiryDate(String text) {
    return RegExp(r'(\d{1,2}\s*[/\\-]\s*\d{2,4})').hasMatch(text) ||
        RegExp(
          r'(valid\s+thru|expires?|expiry)',
          caseSensitive: false,
        ).hasMatch(text);
  }

  String _extractExpiryDate(String text) {
    final match = RegExp(r'(\d{1,2})\s*[/\\-]\s*(\d{2,4})').firstMatch(text);
    if (match != null) {
      final month = match.group(1)!.padLeft(2, '0');
      final year = match.group(2)!;
      // Convert 2-digit year to 4-digit
      final fullYear = year.length == 2 ? '20$year' : year;
      return '$month/$fullYear';
    }
    return '';
  }

  bool _isCardholderName(String text) {
    // Names typically don't contain digits and are 2+ words
    final words = text.split(' ');
    return words.length >= 2 &&
        !RegExp(r'\d').hasMatch(text) &&
        text.length > 5 &&
        text.length < 50;
  }

  bool _isCVV(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    return (digits.length == 3 || digits.length == 4) &&
        RegExp(r'^\d+$').hasMatch(digits);
  }

  String _extractCVV(String text) {
    return text.replaceAll(RegExp(r'\D'), '');
  }

  CameraController get cameraController => _cameraController;

  void dispose() {
    _cameraController.dispose();
    _textRecognizer.close();
  }
}
