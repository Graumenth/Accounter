import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../models/item.dart';

Future<dynamic> showItemDialog(BuildContext context, {Item? item}) async {
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
        title: Text(isEdit ? 'Ürünü Düzenle' : 'Yeni Ürün'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Ürün Adı',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Fiyat (TL)',
                  border: OutlineInputBorder(),
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
                      title: const Text('Renk Seç'),
                      content: SingleChildScrollView(
                        child: BlockPicker(
                          pickerColor: selectedColor,
                          onColorChanged: (color) {
                            Navigator.pop(context, color);
                          },
                        ),
                      ),
                    ),
                  );
                  if (color != null) {
                    setState(() => selectedColor = color);
                  }
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Renk Seç'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (isEdit)
            TextButton(
              onPressed: () => Navigator.pop(context, 'delete'),
              child: const Text('Sil', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty &&
                  priceController.text.trim().isNotEmpty) {
                final price = double.tryParse(priceController.text.trim());
                if (price != null) {
                  Navigator.pop(context, {
                    'name': nameController.text.trim(),
                    'priceCents': (price * 100).toInt(),
                    'color': '#${selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
                  });
                }
              }
            },
            child: Text(isEdit ? 'Kaydet' : 'Ekle'),
          ),
        ],
      ),
    ),
  );
}