import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget buildComboBox({
  required BuildContext context,
  required String hint,
  required List<String> options,
  required String selectedValue,
  required ValueChanged<String> onSelected,
  double? width,
}) {
  final allOptions = ['All', ...options];
  final displayValue = selectedValue.isEmpty ? 'All' : selectedValue;
  final textController = TextEditingController(text: displayValue);

  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).cardTheme.color,
      // border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color:
            Theme.of(context).cardTheme.surfaceTintColor ?? Colors.grey[300]!,
      ),
    ),
    child: SizedBox(
      height: 35,
      width: width,
      child: Autocomplete<String>(
        fieldViewBuilder:
            (context, textEditingController, focusNode, onFieldSubmitted) {
          return ValueListenableBuilder<TextEditingValue>(
            valueListenable: textEditingController,
            builder: (context, value, _) {
              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  suffixIcon: value.text.isNotEmpty && value.text != 'All'
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            textEditingController.clear();
                            onSelected('');
                          },
                        )
                      : const Icon(Icons.arrow_drop_down, size: 24),
                ),
                style: const TextStyle(fontSize: 10),
              );
            },
          );
        },
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return allOptions;
          }
          return allOptions.where((option) => option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase()));
        },
        onSelected: (String selection) {
          textController.text = selection == 'All' ? '' : selection;
          onSelected(selection == 'All' ? '' : selection);
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              color: Theme.of(context).cardTheme.color,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 200,
                ),
                child: SizedBox(
                  width: width ?? 200,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final option = options.elementAt(index);
                      final isSelected = option == 'All'
                          ? selectedValue.isEmpty
                          : option == selectedValue;

                      return ListTile(
                        title: Text(
                          option,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        minVerticalPadding: 12,
                        dense: true,
                        trailing: isSelected
                            ? const Icon(Icons.check, size: 16)
                            : null,
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
