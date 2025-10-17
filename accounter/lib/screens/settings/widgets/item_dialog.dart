import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../models/item.dart';

Future<dynamic> showItemDialog(
    BuildContext context, {
      Item? item,
      required String itemNameLabel,
      required String priceLabel,
      required String colorLabel,
      required String cancelLabel,
      required String saveLabel,
      String? deleteLabel,
    }) async {
  final nameController = TextEditingController(text: item?.name ?? '');
  final priceController = TextEditingController(
    text: item != null ? item.basePriceTL.toStringAsFixed(2) : '',
  );
  Color selectedColor = item != null
      ? Color(int.parse('0xFF${item.color.substring(1)}'))
      : const Color(0xFF38A169);

  final isEdit = item != null;

  return await showDialog<dynamic>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(isEdit ? '$saveLabel $itemNameLabel' : '$saveLabel $itemNameLabel'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: itemNameLabel,
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: priceLabel,
                  border: const OutlineInputBorder(),
                  prefixText: '₺ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final color = await showDialog<Color>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(colorLabel),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: selectedColor,
                          onColorChanged: (color) {
                            selectedColor = color;
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, selectedColor),
                          child: Text(saveLabel),
                        ),
                      ],
                    ),
                  );
                  if (color != null) {
                    setState(() => selectedColor = color);
                  }
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Center(
                    child: Text(
                      colorLabel,
                      style: TextStyle(
                        color: selectedColor.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (isEdit && deleteLabel != null)
            TextButton(
              onPressed: () => Navigator.pop(context, 'delete'),
              child: Text(deleteLabel, style: const TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              final price = double.tryParse(priceController.text);
              if (price == null) return;

              Navigator.pop(context, {
                'name': nameController.text.trim(),
                'priceCents': (price * 100).toInt(),
                'color': '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
              });
            },
            child: Text(saveLabel),
          ),
        ],
      ),
    ),
  );
}