import 'package:flareline/pages/toast/toast_helper.dart';
import 'package:flutter/material.dart';

class SimpleAnnotationDialog extends StatefulWidget {
  final String year;
  final double initialValue;
  final String initialText;
  final bool isEditing;
  final Function(double)? onValueChanged;

  const SimpleAnnotationDialog({
    required this.year,
    required this.initialValue,
    required this.initialText,
    this.isEditing = false,
    this.onValueChanged,
    super.key,
  });

  @override
  State<SimpleAnnotationDialog> createState() => _SimpleAnnotationDialogState();
}

class _SimpleAnnotationDialogState extends State<SimpleAnnotationDialog> {
  late TextEditingController _textController;
  late double _currentValue;
  late TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _textController = TextEditingController(text: widget.initialText);
    _valueController =
        TextEditingController(text: _currentValue.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _textController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      insetPadding: isDesktop
          ? EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.2, vertical: 48)
          : const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 600 : double.infinity,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isEditing ? 'Edit Annotation' : 'Add Annotation',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close,
                        color: colorScheme.onSurface.withOpacity(0.6)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 18,
                        color: colorScheme.onSurface.withOpacity(0.7)),
                    const SizedBox(width: 8),
                    Text('Year: ${widget.year}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.8),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Value (kg)',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withOpacity(0.8),
                  )),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: isDesktop ? 3 : 1,
                    child: TextField(
                      controller: _valueController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceVariant.withOpacity(0.4),
                        suffixText: 'kg',
                        suffixStyle: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final newValue =
                            double.tryParse(value) ?? _currentValue;
                        if (newValue != _currentValue) {
                          setState(() {
                            _currentValue = newValue;
                          });
                          widget.onValueChanged?.call(newValue);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'increment',
                        onPressed: () => _adjustValue(1000),
                        backgroundColor: colorScheme.primaryContainer,
                        elevation: 0,
                        child: Icon(Icons.add,
                            color: colorScheme.onPrimaryContainer),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'decrement',
                        onPressed: () => _adjustValue(-1000),
                        backgroundColor: colorScheme.primaryContainer,
                        elevation: 0,
                        child: Icon(Icons.remove,
                            color: colorScheme.onPrimaryContainer),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Annotation',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withOpacity(0.8),
                  )),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceVariant.withOpacity(0.4),
                  hintText: widget.isEditing
                      ? 'Edit your annotation'
                      : 'Enter annotation description',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
                style: textTheme.bodyLarge,
                maxLines: isDesktop ? 4 : 2,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.isEditing)
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'delete': true,
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Delete'),
                    ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.outline),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () {
                      if (_textController.text.isEmpty) {
                        ToastHelper.showSuccessToast(
                            'Please enter annotation text', context);

                        return;
                      }
                      Navigator.pop(context, {
                        'text': _textController.text,
                        'value': _currentValue,
                        'isEditing': widget.isEditing,
                      });
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: Colors.white, // This sets the text color
                    ),
                    child: Text(widget.isEditing ? 'Update' : 'Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _adjustValue(double amount) {
    final newValue =
        (_currentValue + amount).clamp(0, double.infinity) as double;
    setState(() {
      _currentValue = newValue;
      _valueController.text = newValue.toStringAsFixed(0);
    });
    widget.onValueChanged?.call(newValue);
  }
}
