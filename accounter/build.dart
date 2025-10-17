import 'dart:io';

void main(List<String> args) async {
  print('🔨 Build başlatılıyor...\n');

  print('📦 Versiyon güncelleniyor...');
  final versionResult = await Process.run('dart', ['run', 'tool/version_bump.dart']);
  print(versionResult.stdout);
  if (versionResult.exitCode != 0) {
    print(versionResult.stderr);
    exit(1);
  }

  final buildType = args.isNotEmpty ? args[0] : 'apk';

  print('\n🚀 Flutter build başlıyor...');

  List<String> buildArgs;
  if (buildType == 'apk') {
    buildArgs = ['build', 'apk', '--split-per-abi'];
  } else if (buildType == 'appbundle') {
    buildArgs = ['build', 'appbundle'];
  } else {
    print('❌ Geçersiz build tipi. Kullanım: dart run build.dart [apk|appbundle]');
    exit(1);
  }

  final buildResult = await Process.run('flutter', buildArgs);
  print(buildResult.stdout);
  if (buildResult.exitCode != 0) {
    print(buildResult.stderr);
    exit(1);
  }

  print('\n✅ Build tamamlandı!');
  print('📂 Dosyalar: build/app/outputs/');
}