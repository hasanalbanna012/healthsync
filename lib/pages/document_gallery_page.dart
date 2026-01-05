import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_constants.dart';
import '../models/medical_document.dart';
import '../services/document_service.dart';
import '../widgets/image_viewer.dart';

class DocumentGalleryPage extends StatefulWidget {
  final MedicalDocumentType type;

  const DocumentGalleryPage({
    super.key,
    required this.type,
  });

  @override
  State<DocumentGalleryPage> createState() => _DocumentGalleryPageState();
}

class _DocumentGalleryPageState extends State<DocumentGalleryPage> {
  final DocumentService _documentService = DocumentService();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  String get _pageTitle => widget.type.title;

  Future<void> _showAddDialog() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add ${widget.type.singularLabel}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppConstants.textPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppConstants.spacingSmall),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
                child: Icon(Icons.camera_alt, color: AppConstants.primaryColor),
              ),
              title: const Text('Take Photo'),
              subtitle: const Text('Capture using camera'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(ImageSource.camera);
              },
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppConstants.spacingSmall),
                decoration: BoxDecoration(
                  color: AppConstants.accentColor.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
                child:
                    Icon(Icons.photo_library, color: AppConstants.accentColor),
              ),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select existing photo'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(ImageSource.gallery);
              },
            ),
            const SizedBox(height: AppConstants.spacingMedium),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to upload documents.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) return;

      setState(() => _isUploading = true);
      await _documentService.uploadDocument(type: widget.type, file: image);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.type.singularLabel} uploaded successfully'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _confirmDelete(MedicalDocument document) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${widget.type.singularLabel}?'),
        content: const Text('This will remove the file from cloud storage.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await _documentService.deleteDocument(
        user.uid,
        widget.type,
        document,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(_pageTitle),
        elevation: 0,
      ),
      body: user == null
          ? _buildSignedOutState()
          : StreamBuilder<List<MedicalDocument>>(
              stream: _documentService.watchDocuments(user.uid, widget.type),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _buildMessage(
                    'Failed to load documents',
                    snapshot.error.toString(),
                  );
                }

                final documents = snapshot.data ?? const [];
                if (documents.isEmpty) {
                  return _buildMessage(
                    'No ${widget.type.title.toLowerCase()} yet',
                    'Tap the + button to add your first ${widget.type.singularLabel.toLowerCase()}.',
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(AppConstants.spacingMedium),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppConstants.spacingMedium,
                    mainAxisSpacing: AppConstants.spacingMedium,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    return _DocumentCard(
                      document: document,
                      label:
                          '${widget.type.singularLabel} ${documents.length - index}',
                      enableTextDetection: widget.type.enableTextDetection,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ImageViewer(
                              imageUrl: document.downloadUrl,
                              title: widget.type.singularLabel,
                              enableTextDetection:
                                  widget.type.enableTextDetection,
                            ),
                          ),
                        );
                      },
                      onDelete: () => _confirmDelete(document),
                    );
                  },
                );
              },
            ),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton(
              onPressed: _isUploading ? null : _showAddDialog,
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              child: _isUploading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.add),
            ),
    );
  }

  Widget _buildMessage(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: AppConstants.textDisabledColor,
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppConstants.textSecondaryColor,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppConstants.textDisabledColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignedOutState() {
    return _buildMessage(
      'Sign in required',
      'Please sign in to view and upload your documents.',
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final MedicalDocument document;
  final String label;
  final bool enableTextDetection;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DocumentCard({
    required this.document,
    required this.label,
    required this.enableTextDetection,
    required this.onTap,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.borderRadiusMedium),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        document.downloadUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Icons.broken_image,
                            color: AppConstants.textDisabledColor,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Card(
                        margin: EdgeInsets.zero,
                        color: Colors.black.withValues(alpha: 0.4),
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: onDelete,
                          tooltip: 'Delete',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textPrimaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Uploaded ${_formatDate(document.dateAdded)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
