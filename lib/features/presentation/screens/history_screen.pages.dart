import 'package:askcam/core/models/history_item.dart';
import 'package:askcam/core/models/saved_word.dart';
import 'package:askcam/core/services/history_service.dart';
import 'package:askcam/core/services/saved_words_service.dart';
import 'package:askcam/features/presentation/widgets/theme_toggle_button.dart';
import 'package:askcam/core/services/button_feedback_service.dart';
import 'package:askcam/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:askcam/core/utils/l10n.dart';
import 'package:askcam/core/ui/app_button.dart';
import 'package:askcam/core/ui/app_card.dart';
import 'package:askcam/core/ui/app_spacing.dart';
import 'package:askcam/core/ui/app_text_field.dart';
import 'package:askcam/core/ui/empty_state_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    final next = _searchController.text;
    if (next == _query) return;
    setState(() {
      _query = next;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _confirmDelete(SavedWord word) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.savedWordsDeleteTitle),
          content: Text(context.l10n.savedWordsDeleteMessage(word.text)),
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
      await SavedWordsService.instance.deleteWord(word.id);
      if (!mounted) return;
      _showSnackBar(context.l10n.actionDeleted);
    } catch (e, stackTrace) {
      debugPrint('Delete saved word failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      _showSnackBar(context.l10n.actionDeleteFailed);
    }
  }

  void _copyWord(SavedWord word) {
    Clipboard.setData(ClipboardData(text: word.text));
    _showSnackBar(context.l10n.actionCopied);
  }

  void _copyHistory(HistoryItem item) {
    Clipboard.setData(ClipboardData(text: item.extractedText));
    _showSnackBar(context.l10n.actionCopied);
  }

  Future<void> _confirmDeleteHistory(HistoryItem item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.historyDeleteTitle),
          content: Text(context.l10n.historyDeleteMessage),
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
      await HistoryService.instance.deleteHistoryItem(item.id);
      if (!mounted) return;
      _showSnackBar(context.l10n.actionDeleted);
    } catch (e, stackTrace) {
      debugPrint('Delete history failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      _showSnackBar(context.l10n.actionDeleteFailed);
    }
  }

  String _formatDate(DateTime? value) {
    if (value == null) return context.l10n.timeJustNow;
    final local = value.toLocal();
    final two = (int v) => v.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(context.l10n.historyTitle),
          iconTheme: IconThemeData(color: colors.onBackground),
          actions: const [
            ThemeToggleButton(),
          ],
          bottom: TabBar(
            labelColor: colors.primary,
            unselectedLabelColor: colors.onSurfaceVariant,
            indicatorColor: colors.primary,
            tabs: [
              Tab(text: context.l10n.historyTab),
              Tab(text: context.l10n.savedWordsTab),
            ],
          ),
        ),
        body: SafeArea(
          child: user == null
              ? EmptyStateWidget(
                  icon: Icons.lock_outline,
                  title: context.l10n.authLoginRequiredToViewHistory,
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
              : TabBarView(
                  children: [
                    _buildHistoryTab(colors),
                    _buildSavedWordsTab(colors),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHistoryTab(ColorScheme colors) {
    return Padding(
      padding: AppSpacing.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.md,
        bottom: AppSpacing.xl,
      ),
      child: StreamBuilder<List<HistoryItem>>(
        stream: HistoryService.instance.watchHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colors.primary),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                context.l10n.historyLoadFailed,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            );
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.history_rounded,
              title: context.l10n.historyEmpty,
              message: context.l10n.historyNoExtractedText,
            );
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final item = items[index];
              final preview = item.extractedText.trim().isEmpty
                  ? context.l10n.historyNoExtractedText
                  : item.extractedText.trim();
              final shortPreview =
                  preview.length > 160 ? '${preview.substring(0, 160)}...' : preview;
              return InkWell(
                onTap: ButtonFeedbackService.wrap(
                  context,
                  () => _copyHistory(item),
                ),
                child: AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.document_scanner_rounded,
                          color: colors.primary),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shortPreview,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              _formatDate(item.createdAt),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: colors.error),
                        onPressed: ButtonFeedbackService.wrap(
                          context,
                          () => _confirmDeleteHistory(item),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSavedWordsTab(ColorScheme colors) {
    return Padding(
      padding: AppSpacing.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.md,
        bottom: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _searchController,
            hintText: context.l10n.savedWordsSearchHint,
            prefixIcon: const Icon(Icons.search_rounded),
          ),
          SizedBox(height: AppSpacing.lg),
          Expanded(
            child: StreamBuilder<List<SavedWord>>(
              stream: SavedWordsService.instance.watchSavedWords(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: colors.primary,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      context.l10n.savedWordsLoadFailed,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                  );
                }

                final items = snapshot.data ?? [];
                final query = _query.trim().toLowerCase();
                final filtered = query.isEmpty
                    ? items
                    : items
                        .where(
                          (item) =>
                              item.text.toLowerCase().contains(query) ||
                              item.normalized.contains(query),
                        )
                        .toList();

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.bookmark_border,
                    title: context.l10n.savedWordsEmpty,
                    message: context.l10n.savedWordsSearchHint,
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return InkWell(
                      onTap: ButtonFeedbackService.wrap(
                        context,
                        () => _copyWord(item),
                      ),
                      child: AppCard(
                        child: Row(
                          children: [
                            Icon(Icons.bookmark_border, color: colors.primary),
                            SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.text,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  SizedBox(height: AppSpacing.xs),
                                  Text(
                                    _formatDate(item.createdAt),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: colors.error),
                              onPressed: ButtonFeedbackService.wrap(
                                context,
                                () => _confirmDelete(item),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
