import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileManager {
  static const String _keyCompanyName = 'company_name';

  static Future<String> getCompanyName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCompanyName) ?? 'Şirketim';
  }

  static Future<void> setCompanyName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCompanyName, name);
  }
}

Future<String?> showProfileDialog(BuildContext context) async {
  final currentName = await ProfileManager.getCompanyName();
  final controller = TextEditingController(text: currentName);

  return await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Şirket Bilgileri'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Şirket Adınız',
          border: OutlineInputBorder(),
          helperText: 'PDF raporlarında kullanılacak',
        ),
        autofocus: true,
      ),
      actions: [
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
          child: const Text('Kaydet'),
        ),
      ],
    ),
  );
}