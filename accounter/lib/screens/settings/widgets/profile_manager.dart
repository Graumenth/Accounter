import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../main.dart';
import '../../../constants/app_colors.dart';

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
      required String darkModeLabel,
      required String languageLabel,
    }) async {
  final currentName = await ProfileManager.getCompanyName();
  final currentLogo = await ProfileManager.getCompanyLogo();
  final controller = TextEditingController(text: currentName);
  String? logoPath = currentLogo;

  final prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('theme_mode') ?? false;
  String currentLocale = prefs.getString('locale') ?? 'tr';
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return await showDialog<String>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        title: Text(
          companyInfoLabel,
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: yourCompanyNameLabel,
                  border: const OutlineInputBorder(),
                  helperText: usedInPdfReportsLabel,
                ),
                autofocus: true,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                companyLogoLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
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
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                    borderRadius: AppRadius.lgRadius,
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  child: logoPath != null && File(logoPath!).existsSync()
                      ? ClipRRect(
                    borderRadius: AppRadius.lgRadius,
                    child: Image.file(
                      File(logoPath!),
                      fit: BoxFit.cover,
                    ),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 40,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        addLogoLabel,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
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
                  icon: Icon(
                    Icons.delete,
                    color: isDark ? AppColors.darkError : AppColors.error,
                  ),
                  label: Text(
                    removeLogoLabel,
                    style: TextStyle(
                      color: isDark ? AppColors.darkError : AppColors.error,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              Divider(color: isDark ? AppColors.darkDivider : AppColors.divider),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    darkModeLabel,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        isDarkMode = value;
                      });
                      MyApp.of(context)?.toggleTheme(value);
                    },
                    activeTrackColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                languageLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          currentLocale = 'tr';
                        });
                        MyApp.of(context)?.setLocale('tr');
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: currentLocale == 'tr'
                            ? (isDark ? AppColors.darkPrimary : AppColors.primary).withValues(alpha: 0.1)
                            : null,
                        foregroundColor: currentLocale == 'tr'
                            ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                            : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        side: BorderSide(
                          color: currentLocale == 'tr'
                              ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                              : (isDark ? AppColors.darkBorder : AppColors.border),
                        ),
                      ),
                      child: const Text('Türkçe'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          currentLocale = 'en';
                        });
                        MyApp.of(context)?.setLocale('en');
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: currentLocale == 'en'
                            ? (isDark ? AppColors.darkPrimary : AppColors.primary).withValues(alpha: 0.1)
                            : null,
                        foregroundColor: currentLocale == 'en'
                            ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                            : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        side: BorderSide(
                          color: currentLocale == 'en'
                              ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                              : (isDark ? AppColors.darkBorder : AppColors.border),
                        ),
                      ),
                      child: const Text('English'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              cancelLabel,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context, name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(saveLabel),
          ),
        ],
      ),
    ),
  );
}