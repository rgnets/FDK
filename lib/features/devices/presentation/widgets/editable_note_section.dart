import 'package:flutter/material.dart';

/// A section widget for displaying and editing device notes.
/// Matches the ATT-FE-Tool's technician note section layout.
class EditableNoteSection extends StatelessWidget {
  const EditableNoteSection({
    required this.note,
    this.onEditNote,
    this.onClearNote,
    super.key,
  });

  /// The current note text, or null if no note exists.
  final String? note;

  /// Callback when the user wants to add or edit the note.
  final VoidCallback? onEditNote;

  /// Callback when the user wants to clear the note.
  final VoidCallback? onClearNote;

  bool get _hasNote => note != null && note!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.note_alt_outlined,
                  size: 20,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Technician Note',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Note content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _hasNote
                    ? theme.colorScheme.surfaceContainerHighest
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey[300]!,
                ),
              ),
              child: Text(
                _hasNote ? note! : 'No note added.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _hasNote ? null : Colors.grey[500],
                  fontStyle: _hasNote ? null : FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                // Add/Edit button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onEditNote,
                    icon: Icon(_hasNote ? Icons.edit : Icons.add),
                    label: Text(_hasNote ? 'Edit Note' : 'Add Note'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                // Clear button (only shows if note exists)
                if (_hasNote) ...[
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: onClearNote,
                    icon: const Icon(Icons.clear, color: Colors.red),
                    label: const Text(
                      'Clear',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
