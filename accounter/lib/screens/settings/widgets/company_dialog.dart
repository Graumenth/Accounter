import 'package:flutter/material.dart';
import '../../../models/company.dart';

Future<String?> showCompanyDialog(BuildContext context, {Company? company}) async {
  final controller = TextEditingController(text: company?.name ?? '');
  final isEdit = company != null;

  return await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(isEdit ? 'Şirketi Düzenle' : 'Yeni Şirket'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Şirket Adı',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
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
            if (controller.text.trim().isNotEmpty) {
              Navigator.pop(context, controller.text.trim());
            }
          },
          child: Text(isEdit ? 'Kaydet' : 'Ekle'),
        ),
      ],
    ),
  );
}