import 'dart:io';

void main(List<String> args) {
  final pubspecFile = File('pubspec.yaml');
  final content = pubspecFile.readAsStringSync();

  final versionRegex = RegExp(r'version:\s*(\d+\.\d+\.\d+)\+(\d+)');
  final match = versionRegex.firstMatch(content);

  if (match != null) {
    final versionName = match.group(1);
    final buildNumber = int.parse(match.group(2)!) + 1;
    final newVersion = 'version: $versionName+$buildNumber';

    final newContent = content.replaceFirst(versionRegex, newVersion);
    pubspecFile.writeAsStringSync(newContent);

    print('✅ Build number increased to: $buildNumber');
    print('📦 New version: $versionName+$buildNumber');
  }
}