import 'dart:io';

void main() {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('❌ pubspec.yaml bulunamadı!');
    exit(1);
  }

  final lines = pubspecFile.readAsLinesSync();
  final newLines = <String>[];
  bool updated = false;

  for (var line in lines) {
    if (line.startsWith('version:')) {
      final versionPart = line.split(':')[1].trim();
      final parts = versionPart.split('+');
      final versionName = parts[0];
      final buildNumber = int.parse(parts[1]);
      final newBuildNumber = buildNumber + 1;

      newLines.add('version: $versionName+$newBuildNumber');
      print('✅ Version: $versionName+$buildNumber → $versionName+$newBuildNumber');
      updated = true;
    } else {
      newLines.add(line);
    }
  }

  if (updated) {
    pubspecFile.writeAsStringSync(newLines.join('\n'));
    print('✅ pubspec.yaml güncellendi!');
  } else {
    print('❌ Version satırı bulunamadı!');
    exit(1);
  }
}