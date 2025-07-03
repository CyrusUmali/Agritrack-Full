import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget buildComboBox({
  required String hint,
  required List<String> options,
  required String selectedValue,
  required ValueChanged<String> onSelected,
  double? width,
  String? Function(String?)? validator,
}) {
  return SizedBox(
    height: 48,
    width: width,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Tooltip(
            message: hint,
            child: Autocomplete<String>(
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                if (selectedValue.isNotEmpty) {
                  textEditingController.text = selectedValue;
                }

                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    suffixIconConstraints: const BoxConstraints(
                      minHeight: 24,
                      minWidth: 24,
                    ),
                    suffixIcon: IconButton(
                      icon: selectedValue.isNotEmpty
                          ? const Icon(Icons.close, size: 20)
                          : const Icon(Icons.arrow_drop_down, size: 24),
                      onPressed: () {
                        if (selectedValue.isNotEmpty) {
                          // Clear the selection
                          textEditingController.clear();
                          onSelected('');
                          focusNode.unfocus();
                        }
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                );
              },
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return options;
                }
                return options.where((option) => option
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: onSelected,
              optionsViewBuilder: (context, onSelected, options) {
                const itemHeight = 48.0;
                const maxItemsToShow = 5;
                final maxHeight = itemHeight * maxItemsToShow;
                final actualHeight = options.length * itemHeight;

                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: width ?? MediaQuery.of(context).size.width,
                        maxHeight:
                            actualHeight > maxHeight ? maxHeight : actualHeight,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          final isSelected = option == selectedValue;

                          return InkWell(
                            onTap: () => onSelected(option),
                            child: Container(
                              height: itemHeight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      option,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check, size: 16),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}
