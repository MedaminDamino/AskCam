import 'dart:io';
import 'package:askcam/core/services/button_feedback_service.dart';
import 'package:askcam/features/presentation/widgets/theme_toggle_button.dart';
import 'package:askcam/features/presentation/settings/settings_controller.dart';
import 'package:askcam/features/presentation/screens/result_flow_args.dart';
import 'package:askcam/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:askcam/core/utils/l10n.dart';
import 'package:askcam/core/ui/app_button.dart';
import 'package:askcam/core/ui/app_radius.dart';
import 'package:askcam/core/ui/app_spacing.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String _lastSource = 'camera';
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isLoading = true);
    _lastSource = source == ImageSource.camera ? 'camera' : 'gallery';

    try {
      final settings = context.read<SettingsController>();
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (image != null) {
        final File originalFile = File(image.path);
        final File outputFile = settings.autoEnhanceImages
            ? await _compressImage(originalFile)
            : originalFile;

        setState(() {
          _selectedImage = outputFile;
          _isLoading = false;
        });
        _animController.forward(from: 0);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar(
        context.l10n.cameraPickImageError(e.toString()),
      );
    }
  }

  Future<File> _compressImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) return file;

      if (image.width > 1920 || image.height > 1920) {
        image = img.copyResize(image, width: 1920);
        debugPrint('Image resized to fit 1920px');
      }

      final compressed = img.encodeJpg(image, quality: 85);
      final tempDir = Directory.systemTemp;
      final compressedFile = File(
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await compressedFile.writeAsBytes(compressed);

      return compressedFile;
    } catch (e) {
      debugPrint('Compression failed: $e');
      return file;
    }
  }

  void _showErrorSnackBar(String message) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  void _clearImage() {
    setState(() => _selectedImage = null);
    _animController.reverse();
  }

  void _scanText() {
    if (_selectedImage != null) {
      Navigator.pushNamed(
        context,
        Routes.textRecognition,
        arguments: ExtractResultArgs(
          imageFile: _selectedImage!,
          source: _lastSource,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.onBackground),
          onPressed: ButtonFeedbackService.wrap(
            context,
            () => Navigator.pop(context),
          ),
        ),
        title: Text(l10n.cameraTitle),
        centerTitle: true,
        actions: [
          if (_selectedImage != null)
            IconButton(
              icon: Icon(Icons.delete_outline, color: colors.error),
              onPressed: ButtonFeedbackService.wrap(context, _clearImage),
              tooltip: l10n.cameraClearImage,
            ),
          const ThemeToggleButton(),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: colors.primary),
              )
            : _selectedImage == null
                ? const _EmptyState()
                : _ImagePreview(
                    image: _selectedImage!,
                    scale: _scaleAnimation,
                  ),
      ),
      bottomNavigationBar: _selectedImage == null
          ? _CaptureActions(
              onGallery: () => _pickImage(ImageSource.gallery),
              onCamera: () => _pickImage(ImageSource.camera),
            )
          : _ScanAction(onScan: _scanText),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: AppSpacing.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppSpacing.xxl + AppSpacing.xxl,
              height: AppSpacing.xxl + AppSpacing.xxl,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    colors.primary.withOpacity(0.2),
                    colors.secondary.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.photo_camera_outlined,
                size: AppSpacing.xxl,
                color: colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.xxl),
            Text(
              l10n.cameraNoImageSelected,
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              l10n.cameraEmptyHint,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final File image;
  final Animation<double> scale;

  const _ImagePreview({
    required this.image,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = AppRadius.circular(AppRadius.xl);
    return ScaleTransition(
      scale: scale,
      child: SingleChildScrollView(
        padding: AppSpacing.all(AppSpacing.lg),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: colors.primary.withOpacity(0.2),
                blurRadius: AppSpacing.xl,
                spreadRadius: AppSpacing.xs,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              children: [
                Image.file(
                  image,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: AppSpacing.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          colors.scrim.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: colors.primary),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            context.l10n.cameraImageCaptured,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: colors.onPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CaptureActions extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  const _CaptureActions({
    required this.onGallery,
    required this.onCamera,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: AppSpacing.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: AppSpacing.lg,
          top: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: l10n.cameraGallery,
                onPressed: ButtonFeedbackService.wrap(context, onGallery),
                icon: const Icon(Icons.photo_library_rounded),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton.primary(
                label: l10n.cameraCamera,
                onPressed: ButtonFeedbackService.wrap(context, onCamera),
                icon: const Icon(Icons.camera_alt_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanAction extends StatelessWidget {
  final VoidCallback onScan;

  const _ScanAction({required this.onScan});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: AppSpacing.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: AppSpacing.lg,
          top: AppSpacing.sm,
        ),
        child: AppButton.primary(
          label: l10n.cameraScanWithAi,
          onPressed: ButtonFeedbackService.wrap(context, onScan),
          icon: const Icon(Icons.document_scanner_rounded),
        ),
      ),
    );
  }
}
