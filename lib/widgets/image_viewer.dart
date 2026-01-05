import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';
import '../services/text_detector.dart';

class ImageViewer extends StatefulWidget {
  final String? localImagePath;
  final String? imageUrl;
  final String title;
  final bool enableTextDetection;

  const ImageViewer({
    super.key,
    this.localImagePath,
    this.imageUrl,
    required this.title,
    this.enableTextDetection = false,
  }) : assert(
          localImagePath != null || imageUrl != null,
          'Provide either a local image path or an image URL',
        );

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  final TransformationController _controller = TransformationController();
  final TextDetectorService _textDetector = TextDetectorService();
  bool _isLoading = false;
  String? _downloadedPath;
  bool _isDownloading = false;

  @override
  void dispose() {
    _controller.dispose();
    _textDetector.dispose();
    super.dispose();
  }

  Future<void> _detectText() async {
    try {
      final localPath = await _ensureLocalPath();
      if (localPath == null) {
        throw Exception('Unable to access image for text detection');
      }

      setState(() {
        _isLoading = true;
      });

      final detectedTexts = await _textDetector.detectText(localPath);
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
                      Icon(
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
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.text_snippet_outlined,
                                  size: 48,
                                  color: AppConstants.textDisabledColor,
                                ),
                                const SizedBox(
                                    height: AppConstants.spacingSmall),
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
                            separatorBuilder: (_, __) => Divider(
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
                                      style: TextStyle(
                                        color: AppConstants.textPrimaryColor,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
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

  Future<String?> _ensureLocalPath() async {
    if (widget.localImagePath != null &&
        File(widget.localImagePath!).existsSync()) {
      return widget.localImagePath!;
    }

    if (_downloadedPath != null && File(_downloadedPath!).existsSync()) {
      return _downloadedPath;
    }

    if (widget.imageUrl == null) {
      return null;
    }

    try {
      setState(() {
        _isDownloading = true;
      });

      final response = await http.get(Uri.parse(widget.imageUrl!));
      if (response.statusCode != 200) {
        throw Exception('Download failed with status ${response.statusCode}');
      }

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/viewer_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      _downloadedPath = filePath;
      return _downloadedPath;
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
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
                onPressed: _isDownloading ? null : _detectText,
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
                    child: _buildImageWidget(),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading || _isDownloading)
            Container(
              color: AppConstants.backgroundColor.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppConstants.primaryColor,
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    Text(
                      _isDownloading
                          ? 'Preparing image...'
                          : 'Extracting text...',
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

  Widget _buildImageWidget() {
    if (widget.localImagePath != null) {
      return Image.file(
        File(widget.localImagePath!),
        fit: BoxFit.contain,
        errorBuilder: _errorBuilder,
      );
    }

    return Image.network(
      widget.imageUrl!,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: _errorBuilder,
    );
  }

  Widget _errorBuilder(BuildContext context, Object error, StackTrace? stack) {
    return Container(
      width: 200,
      height: 200,
      color: AppConstants.cardColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 64,
            color: AppConstants.textDisabledColor,
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            'Image not available',
            style: TextStyle(
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
