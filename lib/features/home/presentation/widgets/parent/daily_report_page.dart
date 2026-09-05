import 'package:flutter/material.dart';

class DailyReportPage extends StatefulWidget {
  const DailyReportPage({super.key});

  @override
  State<DailyReportPage> createState() => _DailyReportPageState();
}

class _DailyReportPageState extends State<DailyReportPage> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _sendNote() {
    final note = _noteController.text.trim();

    if (note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a note first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note sent to teacher.'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _noteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),

          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // =====================================================
                    // BACK BUTTON
                    // =====================================================

                    SizedBox(
                      height: 42,

                      child: Material(
                        color: Colors.transparent,

                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),

                          onTap: () => Navigator.pop(context),

                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),

                            child: Row(
                              mainAxisSize: MainAxisSize.min,

                              children: [
                                Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 17,
                                  color: colors.primary,
                                ),

                                const SizedBox(width: 6),

                                Text(
                                  'Back',
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),

                    // =====================================================
                    // HEADER
                    // =====================================================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [
                        Expanded(
                          child: Text(
                            'Daily Report',

                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: colors.onSurface,
                            ),
                          ),
                        ),

                        StatusPill(
                          text: 'Saved',
                          backgroundColor: colors.primaryContainer,
                          textColor: colors.onPrimaryContainer,
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Today, Sep 4',

                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // =====================================================
                    // MEALS
                    // =====================================================
                    const ReportItem(
                      title: 'MEALS & SNACKS',
                      values: ['Ate Most'],
                    ),

                    const SizedBox(height: 26),

                    // =====================================================
                    // NAP
                    // =====================================================
                    const ReportItem(title: 'NAP TIME', values: ['Short Nap']),

                    const SizedBox(height: 26),

                    // =====================================================
                    // MOOD
                    // =====================================================
                    const ReportItem(
                      title: 'MOOD & BEHAVIOR',
                      values: ['Happy', 'Playful'],
                    ),

                    const SizedBox(height: 26),

                    // =====================================================
                    // HEALTH
                    // =====================================================
                    const ReportItem(
                      title: 'HEALTH & HYGIENE',
                      values: ['No Concerns'],
                    ),

                    const SizedBox(height: 32),

                    // =====================================================
                    // NOTE TO TEACHER
                    // =====================================================
                    Text(
                      'NOTE TO TEACHER',

                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        letterSpacing: 0.8,
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,

                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(14),

                        border: Border.all(
                          color: colors.outlineVariant,
                          width: 1,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),

                      child: TextField(
                        controller: _noteController,

                        minLines: 4,
                        maxLines: 6,

                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,

                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          height: 1.4,
                          color: colors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),

                        decoration: InputDecoration(
                          hintText: 'Write a note to the teacher...',

                          hintStyle: TextStyle(
                            color: colors.onSurfaceVariant.withValues(
                              alpha: 0.65,
                            ),
                            fontSize: 13,
                          ),

                          border: InputBorder.none,

                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,

                          fillColor: Colors.transparent,

                          contentPadding: const EdgeInsets.all(15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =====================================================
                    // SEND NOTE BUTTON
                    // =====================================================
                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: FilledButton.icon(
                        onPressed: _sendNote,

                        icon: const Icon(Icons.send_rounded, size: 18),

                        label: const Text(
                          'Send Note',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,

                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// REPORT ITEM
// ============================================================================

class ReportItem extends StatelessWidget {
  final String title;
  final List<String> values;

  const ReportItem({super.key, required this.title, required this.values});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          title,

          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 11,
            letterSpacing: 0.8,
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,

          children: values.map((value) {
            return StatusPill(
              text: value,
              backgroundColor: colors.secondaryContainer,
              textColor: colors.onSecondaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ============================================================================
// STATUS PILL
// ============================================================================

class StatusPill extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const StatusPill({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),

      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        text,

        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
