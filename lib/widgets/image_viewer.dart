import 'dart:io';
import 'package:flutter/material.dart';
import '../services/text_detector.dart';

class ImageViewer extends StatefulWidget {
  final String imagePath;
  final String title;
  final bool enableTextDetection;

  const ImageViewer({
    super.key,
    required this.imagePath,
    required this.title,
    this.enableTextDetection = false,
  });

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  final TransformationController _controller = TransformationController();
  final TextDetectorService _textDetector = TextDetectorService();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _textDetector.dispose();
    super.dispose();
  }

  Future<void> _detectText() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final detectedTexts = await _textDetector.detectText(widget.imagePath);
      if (!mounted) return;

      await showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detected Text',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (detectedTexts.isEmpty)
                const Text('No text detected')
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: detectedTexts.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(detectedTexts[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          _textDetector.searchTextOnGoogle(detectedTexts[index]);
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (widget.enableTextDetection)
            IconButton(
              icon: const Icon(Icons.text_fields),
              onPressed: _detectText,
            ),
        ],
      ),
      body: Stack(
        children: [
          InteractiveViewer(
            transformationController: _controller,
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.contain,
              height: double.infinity,
              width: double.infinity,
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}