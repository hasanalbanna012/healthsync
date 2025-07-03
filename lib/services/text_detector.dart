import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:url_launcher/url_launcher.dart';

class TextDetectorService {
  final _textRecognizer = TextRecognizer();

  Future<List<String>> detectText(String imagePath) async {
    final inputImage = InputImage.fromFile(File(imagePath));
    final recognizedText = await _textRecognizer.processImage(inputImage);
    
    List<String> textBlocks = [];
    for (TextBlock block in recognizedText.blocks) {
      textBlocks.add(block.text);
    }
    
    return textBlocks;
  }

  Future<void> searchTextOnGoogle(String text) async {
    final Uri url = Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
