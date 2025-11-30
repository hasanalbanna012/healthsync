import 'dart:io';

import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
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
      await _showDetectedTextSheet(detectedTexts);
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppConstants.errorColor,
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

  Future<void> _showDetectedTextSheet(List<String> detectedTexts) async {
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: AppConstants.spacingLarge,
                right: AppConstants.spacingLarge,
                top: AppConstants.spacingLarge,
                bottom: MediaQuery.of(context).viewInsets.bottom +
                    AppConstants.spacingLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.text_fields,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(width: AppConstants.spacingSmall),
                      Text(
                        AppStrings.detectedText,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppConstants.textPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMedium),
                  Expanded(
                    child: detectedTexts.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.text_snippet_outlined,
                                  size: 48,
                                  color: AppConstants.textDisabledColor,
                                ),
                                SizedBox(height: AppConstants.spacingSmall),
                                Text(
                                  AppConstants.noTextDetectedMessage,
                                  style: TextStyle(
                                    color: AppConstants.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: detectedTexts.length,
                            separatorBuilder: (_, __) => const Divider(
                              color: AppConstants.dividerColor,
                            ),
                            itemBuilder: (context, index) => Container(
                              padding: const EdgeInsets.all(
                                  AppConstants.spacingSmall),
                              decoration: BoxDecoration(
                                color: AppConstants.cardColor,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusSmall,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      detectedTexts[index],
                                      style: const TextStyle(
                                        color: AppConstants.textPrimaryColor,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.search,
                                      color: AppConstants.accentColor,
                                    ),
                                    onPressed: () {
                                      _textDetector.searchTextOnGoogle(
                                          detectedTexts[index]);
                                    },
                                    tooltip: 'Search on Google',
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppConstants.primaryGradient,
          ),
        ),
        actions: [
          if (widget.enableTextDetection)
            Container(
              margin: const EdgeInsets.only(right: AppConstants.spacingSmall),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusSmall),
              ),
              child: IconButton(
                icon: const Icon(Icons.text_fields, color: Colors.white),
                onPressed: _detectText,
                tooltip: 'Extract Text',
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: AppConstants.backgroundColor,
            child: InteractiveViewer(
              transformationController: _controller,
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadiusSmall),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryColor.withValues(alpha: 0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadiusSmall),
                    child: Image.file(
                      File(widget.imagePath),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 200,
                          color: AppConstants.cardColor,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 64,
                                color: AppConstants.textDisabledColor,
                              ),
                              SizedBox(height: AppConstants.spacingSmall),
                              Text(
                                'Image not found',
                                style: TextStyle(
                                  color: AppConstants.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: AppConstants.backgroundColor.withValues(alpha: 0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppConstants.primaryColor,
                    ),
                    SizedBox(height: AppConstants.spacingMedium),
                    Text(
                      'Extracting text...',
                      style: TextStyle(
                        color: AppConstants.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
