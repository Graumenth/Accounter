import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../models/company.dart';

Future<Map<String, dynamic>?> showCompanyDialog(BuildContext context, {Company? company}) async {
  final nameController = TextEditingController(text: company?.name ?? '');
  Color selectedColor = company != null
      ? Color(int.parse('0xFF${company.color.substring(1)}'))
      : const Color(0xFF2563EB);

  final isEdit = company != null;

  return await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(isEdit ? 'Şirketi Düzenle' : 'Yeni Şirket'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Şirket Adı',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
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
              onPressed: () => Navigator.pop(context, {'action': 'delete'}),
              child: const Text('Sil', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.pop(context, {
                  'name': nameController.text.trim(),
                  'color': '#${selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
                });
              }
            },
            child: Text(isEdit ? 'Kaydet' : 'Ekle'),
          ),
        ],
      ),
    ),
  );
}