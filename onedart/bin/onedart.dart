import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:onedart/icoembed.dart'; // Ensure this matches your package name

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('output',
        abbr: 'o', help: 'Output binary name', defaultsTo: 'onedart_bin.exe')
    ..addOption('icon',
        abbr: 'i', help: 'Path to the .ico file for the application icon')
    ..addOption('target-os',
        help: 'Target OS (Cross-compile to Linux)', allowed: ['linux'])
    ..addOption('target-arch',
        help: 'Target architecture',
        allowed: ['x64', 'arm64', 'arm', 'riscv64'])
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show this help menu');

  final ArgResults results;
  try {
    results = parser.parse(arguments);
  } catch (e) {
    print('❌ Error: ${e.toString()}');
    exit(1);
  }

  if (results['help'] || results.rest.isEmpty) {
    print('🚀 OneDart: Compile Dart to a standalone EXE\n');
    print('Usage: onedart <input.dart> [options]');
    print(parser.usage);
    return;
  }

  final inputPath = results.rest.first;
  final outputPath = results['output'] as String;
  final iconPath = results['icon'] as String?;

  // 1. Build the compilation command
  final List<String> compileArgs = [
    'compile',
    'exe',
    inputPath,
    '-o',
    outputPath,
  ];

  if (results['target-os'] != null) {
    compileArgs.add('--target-os=${results['target-os']}');
  }
  if (results['target-arch'] != null) {
    compileArgs.add('--target-arch=${results['target-arch']}');
  }

  // 2. Run the Dart compiler
  print('🔨 Compiling ${p.basename(inputPath)} into a standalone binary...');

  final result = await Process.run('dart', compileArgs);

  if (result.exitCode != 0) {
    print('❌ Compilation failed:');
    print(result.stderr);
    exit(result.exitCode);
  }

  print('✅ Binary created: ${p.absolute(outputPath)}');

  // 3. Handle Icon Embedding (Windows Only)
  if (iconPath != null) {
    if (Platform.isWindows) {
      await IcoEmbed.embed(
        exePath: p.absolute(outputPath),
        iconPath: p.absolute(iconPath),
      );
    } else {
      print('ℹ️  Icon embedding skipped: Supported on Windows only.');
    }
  }
}
