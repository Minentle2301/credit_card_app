// I created this service to handle camera-based card scanning using OCR.
// It integrates with the camera plugin and Google ML Kit for text recognition.
// This allows users to capture card details by photographing the card.

import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:async';

class CardScannerService {
  // I declared a private CameraController to manage the camera feed.
  late CameraController _cameraController;
  // I used a flag to prevent multiple simultaneous scans.
  bool _isScanning = false;
  // I initialized a TextRecognizer for OCR functionality.
  final TextRecognizer _textRecognizer = TextRecognizer();

  // I implemented initializeCamera to set up the camera for scanning.
  // I selected the first available camera, typically the back camera.
  // I chose medium resolution for balance between quality and performance.
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

  // I implemented scanCard to capture an image and extract card details via OCR.
  // It prevents concurrent scans and handles errors gracefully.
  Future<Map<String, String>> scanCard() async {
    if (_isScanning) return {};
    _isScanning = true;

    try {
      // I captured a picture from the camera.
      final image = await _cameraController.takePicture();
      // I converted the image to an InputImage for ML Kit processing.
      final inputImage = InputImage.fromFilePath(image.path);
      // I processed the image to recognize text.
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      // I parsed the recognized text to extract structured card details.
      return _parseCardDetails(recognizedText.text);
    } catch (e) {
      print('Error scanning card: $e');
      return {};
    } finally {
      // I reset the scanning flag regardless of outcome.
      _isScanning = false;
    }
  }

  // I created _parseCardDetails to analyze OCR text and extract card information.
  // It processes line by line to identify different card elements.
  Map<String, String> _parseCardDetails(String text) {
    final lines = text.split('\n');
    Map<String, String> details = {};

    for (String line in lines) {
      final trimmedLine = line.trim();

      // I checked if the line contains a card number pattern.
      if (_isCardNumber(trimmedLine)) {
        details['cardNumber'] = _extractCardNumber(trimmedLine);
      }

      // I checked for expiry date patterns.
      if (_isExpiryDate(trimmedLine)) {
        details['expiry'] = _extractExpiryDate(trimmedLine);
      }

      // I looked for cardholder name patterns.
      if (_isCardholderName(trimmedLine)) {
        details['cardholder'] = trimmedLine;
      }

      // I checked for CVV patterns.
      if (_isCVV(trimmedLine)) {
        details['cvv'] = _extractCVV(trimmedLine);
      }
    }

    return details;
  }

  // I implemented _isCardNumber to validate if text resembles a card number.
  // It checks length and digit-only content.
  bool _isCardNumber(String text) {
    // Remove spaces and check if it's a potential card number
    final digits = text.replaceAll(RegExp(r'\s+'), '');
    return digits.length >= 12 &&
        digits.length <= 19 &&
        RegExp(r'^\d+$').hasMatch(digits);
  }

  // I implemented _extractCardNumber to clean and format the card number.
  // It removes non-digits and groups into 4-digit blocks for readability.
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

  // I implemented _isExpiryDate to detect expiry date patterns.
  // It looks for date formats or keywords like "valid thru".
  bool _isExpiryDate(String text) {
    return RegExp(r'(\d{1,2}\s*[/\\-]\s*\d{2,4})').hasMatch(text) ||
        RegExp(
          r'(valid\s+thru|expires?|expiry)',
          caseSensitive: false,
        ).hasMatch(text);
  }

  // I implemented _extractExpiryDate to parse and standardize expiry dates.
  // It converts various formats to MM/YYYY.
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

  // I implemented _isCardholderName to identify potential name lines.
  // It checks for multi-word text without digits.
  bool _isCardholderName(String text) {
    // Names typically don't contain digits and are 2+ words
    final words = text.split(' ');
    return words.length >= 2 &&
        !RegExp(r'\d').hasMatch(text) &&
        text.length > 5 &&
        text.length < 50;
  }

  // I implemented _isCVV to detect CVV patterns.
  // It looks for 3-4 digit sequences.
  bool _isCVV(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    return (digits.length == 3 || digits.length == 4) &&
        RegExp(r'^\d+$').hasMatch(digits);
  }

  // I implemented _extractCVV to extract the CVV digits.
  // It removes all non-digit characters.
  String _extractCVV(String text) {
    return text.replaceAll(RegExp(r'\D'), '');
  }

  // I provided a getter for the camera controller to access it from outside.
  CameraController get cameraController => _cameraController;

  // I implemented dispose to clean up resources.
  // This prevents memory leaks and camera conflicts.
  void dispose() {
    _cameraController.dispose();
    _textRecognizer.close();
  }
}
