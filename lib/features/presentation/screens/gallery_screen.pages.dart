import 'package:askcam/features/gallery/data/gallery_repository.dart';
import 'package:askcam/features/gallery/domain/gallery_item.dart';
import 'package:askcam/features/presentation/widgets/theme_toggle_button.dart';
import 'package:askcam/core/services/button_feedback_service.dart';
import 'package:askcam/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:askcam/core/utils/l10n.dart';
import 'package:askcam/core/ui/app_button.dart';
import 'package:askcam/core/ui/app_radius.dart';
import 'package:askcam/core/ui/app_spacing.dart';
import 'package:askcam/core/ui/empty_state_widget.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    GalleryItem image,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.galleryDeleteTitle),
          content: Text(context.l10n.galleryDeleteMessage),
          actions: [
            TextButton(
              onPressed: ButtonFeedbackService.wrap(
                dialogContext,
                () => Navigator.pop(dialogContext, false),
              ),
              child: Text(context.l10n.actionCancel),
            ),
            TextButton(
              onPressed: ButtonFeedbackService.wrap(
                dialogContext,
                () => Navigator.pop(dialogContext, true),
              ),
              child: Text(context.l10n.actionDelete),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;
    try {
      await GalleryRepository.instance.deleteImage(image.id);
      if (context.mounted) {
        _showSnackBar(context, context.l10n.actionDeleted);
      }
    } catch (e, stackTrace) {
      debugPrint('Delete image failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (context.mounted) {
        _showSnackBar(context, context.l10n.actionDeleteFailed);
      }
    }
  }

  void _openPreview(BuildContext context, GalleryItem image) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(context).colorScheme;
        return Dialog(
          insetPadding: AppSpacing.all(AppSpacing.lg),
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: AppRadius.circular(AppRadius.lg),
            child: InteractiveViewer(
              child: Image.network(
                image.url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  color: colors.scrim,
                  padding: AppSpacing.all(AppSpacing.xl),
                  child: Text(
                    context.l10n.galleryImageLoadFailed,
                    style: TextStyle(color: colors.onSurface),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(context.l10n.galleryTitle),
        iconTheme: IconThemeData(color: colors.onBackground),
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: SafeArea(
        child: user == null
            ? EmptyStateWidget(
                icon: Icons.lock_outline,
                title: context.l10n.authLoginRequiredToViewGallery,
                message: context.l10n.authGoToLogin,
                action: AppButton.secondary(
                  label: context.l10n.authGoToLogin,
                  onPressed: ButtonFeedbackService.wrap(
                    context,
                    () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.login,
                        (route) => false,
                      );
                    },
                  ),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final crossAxisCount = width >= 900
                      ? 4
                      : width >= 600
                          ? 3
                          : 2;
                  return StreamBuilder<List<GalleryItem>>(
                    stream: GalleryRepository.instance.watchImages(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: colors.primary,
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            context.l10n.galleryLoadFailed,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                          ),
                        );
                      }

                      final items = snapshot.data ?? [];
                      if (items.isEmpty) {
                        return EmptyStateWidget(
                          icon: Icons.image_not_supported,
                          title: context.l10n.galleryEmpty,
                          message: context.l10n.galleryLoadFailed,
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          await Future<void>.delayed(
                            const Duration(milliseconds: 400),
                          );
                        },
                        child: GridView.builder(
                          padding: AppSpacing.all(AppSpacing.xl),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: AppSpacing.lg,
                            mainAxisSpacing: AppSpacing.lg,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return GestureDetector(
                              onTap: ButtonFeedbackService.wrap(
                                context,
                                () => _openPreview(context, item),
                              ),
                              onLongPress: ButtonFeedbackService.wrap(
                                context,
                                () => _confirmDelete(context, item),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: AppRadius.circular(AppRadius.lg),
                                    child: Image.network(
                                      item.url,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: AppSpacing.sm,
                                    right: AppSpacing.sm,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: colors.scrim.withOpacity(0.6),
                                        borderRadius:
                                            AppRadius.circular(AppRadius.sm),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 18,
                                        ),
                                        color: colors.onSurface,
                                        onPressed: ButtonFeedbackService.wrap(
                                          context,
                                          () => _confirmDelete(context, item),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
