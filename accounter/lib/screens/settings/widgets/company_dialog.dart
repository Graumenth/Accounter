import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../models/company.dart';

Future<dynamic> showCompanyDialog(
    BuildContext context, {
      Company? company,
      required String companyNameLabel,
      required String colorLabel,
      required String cancelLabel,
      required String saveLabel,
      String? deleteLabel,
    }) async {
  final nameController = TextEditingController(text: company?.name ?? '');
  Color selectedColor = company != null
      ? Color(int.parse('0xFF${company.color.substring(1)}'))
      : const Color(0xFF38A169);

  final isEdit = company != null;

  return await showDialog<dynamic>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(isEdit ? '$saveLabel $companyNameLabel' : '$saveLabel $companyNameLabel'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: companyNameLabel,
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
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
              Navigator.pop(context, {
                'name': nameController.text.trim(),
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