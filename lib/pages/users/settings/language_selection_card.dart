import 'package:flutter/material.dart';
import 'package:flareline/flutter_gen/app_localizations.dart';

class LanguageSelectionCard extends StatelessWidget {
  final bool isMobile;

  const LanguageSelectionCard({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.language_outlined, color: colors.primary),
                const SizedBox(width: 12),
                Text(
                  'Language',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Replace with your actual language selection widget
            // This is just a placeholder dropdown
            DropdownButtonFormField<String>(
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'es', child: Text('Spanish')),
                DropdownMenuItem(value: 'fr', child: Text('French')),
              ],
              onChanged: (value) {
                // Handle language change
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  // Save language preference
                },
                child: Text(AppLocalizations.of(context)!.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
