import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:url_launcher/url_launcher.dart';

class TextDetectorService {
  final _textRecognizer = TextRecognizer();

  Future<List<String>> detectText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFile(File(imagePath));
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final List<String> textLines = [];
      for (final TextBlock block in recognizedText.blocks) {
        for (final TextLine line in block.lines) {
          final text = line.text.trim();
          if (text.isNotEmpty) {
            textLines.add(text);
          }
        }
      }

      return textLines;
    } catch (e) {
      throw Exception('Failed to detect text: ${e.toString()}');
    }
  }

  Future<void> searchTextOnGoogle(String text) async {
    try {
      final Uri url = Uri.parse(
          'https://www.google.com/search?q=${Uri.encodeComponent(text)}');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch search for: $text');
      }
    } catch (e) {
      throw Exception('Failed to search text: ${e.toString()}');
    }
  }

  Future<bool> isTextRecognitionAvailable() async {
    try {
      // Test if text recognition is available by trying to create a recognizer
      final testRecognizer = TextRecognizer();
      testRecognizer.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
