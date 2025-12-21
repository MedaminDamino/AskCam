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
import 'package:google_fonts/google_fonts.dart';

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
          title: const Text('Delete saved word?'),
          content: Text('Remove "${word.text}" from your saved words?'),
          actions: [
            TextButton(
              onPressed: ButtonFeedbackService.wrap(
                dialogContext,
                () => Navigator.pop(dialogContext, false),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: ButtonFeedbackService.wrap(
                dialogContext,
                () => Navigator.pop(dialogContext, true),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;
    try {
      await SavedWordsService.instance.deleteWord(word.id);
      if (!mounted) return;
      _showSnackBar('Deleted.');
    } catch (e, stackTrace) {
      debugPrint('Delete saved word failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      _showSnackBar('Failed to delete. Please try again.');
    }
  }

  void _copyWord(SavedWord word) {
    Clipboard.setData(ClipboardData(text: word.text));
    _showSnackBar('Copied to clipboard.');
  }

  void _copyHistory(HistoryItem item) {
    Clipboard.setData(ClipboardData(text: item.extractedText));
    _showSnackBar('Copied to clipboard.');
  }

  Future<void> _confirmDeleteHistory(HistoryItem item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete history item?'),
          content: const Text('Remove this extraction from history?'),
          actions: [
            TextButton(
              onPressed: ButtonFeedbackService.wrap(
                dialogContext,
                () => Navigator.pop(dialogContext, false),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: ButtonFeedbackService.wrap(
                dialogContext,
                () => Navigator.pop(dialogContext, true),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (shouldDelete != true) return;
    try {
      await HistoryService.instance.deleteHistoryItem(item.id);
      if (!mounted) return;
      _showSnackBar('Deleted.');
    } catch (e, stackTrace) {
      debugPrint('Delete history failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      _showSnackBar('Failed to delete. Please try again.');
    }
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Just now';
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
          title: Text(
            'History',
            style: GoogleFonts.poppins(
              color: colors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: IconThemeData(color: colors.onBackground),
          actions: const [
            ThemeToggleButton(),
          ],
          bottom: TabBar(
            labelColor: colors.primary,
            unselectedLabelColor: colors.onSurfaceVariant,
            indicatorColor: colors.primary,
            tabs: const [
              Tab(text: 'History'),
              Tab(text: 'Saved Words'),
            ],
          ),
        ),
        body: SafeArea(
          child: user == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline,
                            size: 48, color: colors.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text(
                          'Please login to view history.',
                          style: GoogleFonts.poppins(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: ButtonFeedbackService.wrap(
                            context,
                            () {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                Routes.login,
                                (route) => false,
                              );
                            },
                          ),
                          child: const Text('Go to Login'),
                        ),
                      ],
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                'Unable to load history.',
                style: GoogleFonts.poppins(
                  color: colors.onSurfaceVariant,
                ),
              ),
            );
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Text(
                'No history yet.',
                style: GoogleFonts.poppins(
                  color: colors.onSurfaceVariant,
                ),
              ),
            );
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              final preview = item.extractedText.trim().isEmpty
                  ? 'No extracted text'
                  : item.extractedText.trim();
              final shortPreview =
                  preview.length > 160 ? '${preview.substring(0, 160)}...' : preview;
              return InkWell(
                onTap: ButtonFeedbackService.wrap(
                  context,
                  () => _copyHistory(item),
                ),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shortPreview,
                              style: GoogleFonts.poppins(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatDate(item.createdAt),
                              style: GoogleFonts.poppins(
                                color: colors.onSurfaceVariant,
                                fontSize: 12,
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search saved words',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: colors.surfaceVariant.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
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
                      'Unable to load saved words.',
                      style: GoogleFonts.poppins(
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
                  return Center(
                    child: Text(
                      'No saved words yet.',
                      style: GoogleFonts.poppins(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return InkWell(
                      onTap: ButtonFeedbackService.wrap(
                        context,
                        () => _copyWord(item),
                      ),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: colors.outlineVariant,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.text,
                                    style: GoogleFonts.poppins(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _formatDate(item.createdAt),
                                    style: GoogleFonts.poppins(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 12,
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
