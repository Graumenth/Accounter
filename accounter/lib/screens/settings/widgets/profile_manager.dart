import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ProfileManager {
  static const String _keyCompanyName = 'company_name';
  static const String _keyCompanyLogo = 'company_logo';

  static Future<String> getCompanyName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCompanyName) ?? 'Şirketim';
  }

  static Future<void> setCompanyName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCompanyName, name);
  }

  static Future<String?> getCompanyLogo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCompanyLogo);
  }

  static Future<void> setCompanyLogo(String logoPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCompanyLogo, logoPath);
  }

  static Future<void> clearCompanyLogo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCompanyLogo);
  }

  static Future<String?> pickAndSaveLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
    );

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'company_logo${path.extension(pickedFile.path)}';
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

      await setCompanyLogo(savedImage.path);
      return savedImage.path;
    }
    return null;
  }
}

Future<String?> showProfileDialog(
    BuildContext context, {
      required String companyInfoLabel,
      required String yourCompanyNameLabel,
      required String usedInPdfReportsLabel,
      required String companyLogoLabel,
      required String addLogoLabel,
      required String removeLogoLabel,
      required String cancelLabel,
      required String saveLabel,
    }) async {
  final currentName = await ProfileManager.getCompanyName();
  final currentLogo = await ProfileManager.getCompanyLogo();
  final controller = TextEditingController(text: currentName);
  String? logoPath = currentLogo;

  return await showDialog<String>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(companyInfoLabel),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: yourCompanyNameLabel,
                  border: const OutlineInputBorder(),
                  helperText: usedInPdfReportsLabel,
                ),
                autofocus: true,
              ),
              const SizedBox(height: 20),
              Text(
                companyLogoLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final newLogoPath = await ProfileManager.pickAndSaveLogo();
                  if (newLogoPath != null) {
                    setState(() {
                      logoPath = newLogoPath;
                    });
                  }
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: logoPath != null && File(logoPath!).existsSync()
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(logoPath!),
                      fit: BoxFit.cover,
                    ),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[600]),
                      const SizedBox(height: 8),
                      Text(
                        addLogoLabel,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              if (logoPath != null && File(logoPath!).existsSync())
                TextButton.icon(
                  onPressed: () async {
                    await ProfileManager.clearCompanyLogo();
                    setState(() {
                      logoPath = null;
                    });
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: Text(removeLogoLabel, style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context, name);
            },
            child: Text(saveLabel),
          ),
        ],
      ),
    ),
  );
}