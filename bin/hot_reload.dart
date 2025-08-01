// File: bin/hot_reload.dart
import 'dart:io';
import 'dart:convert';

void main() => runHotReload();

Future<void> runHotReload() async {
  final entryFile = File('lib/main.dart');

  // Validate entry point
  if (!await _validateEntryPoint(entryFile)) {
    exit(1);
  }

  Process? server;

  Future<void> startServer() async {
    print('🔥 Starting FlintDart server...');
    try {
      server = await Process.start('dart', ['run', 'lib/main.dart']);
      _pipeProcessOutput(server!);
    } catch (e) {
      stderr.writeln('❌ Failed to start server: $e');
      exit(1);
    }
  }

  void restartServer() {
    print('\n🔄 Restarting server...');
    server?.kill();
    startServer();
  }

  // Watch relevant directories
  _setupFileWatchers(restartServer);

  // Handle CTRL+C
  ProcessSignal.sigint.watch().listen((_) {
    print('\n🛑 Stopping hot reload...');
    server?.kill();
    exit(0);
  });

  await startServer();
}

bool _validateEntryPoint(File entryFile) {
  if (!entryFile.existsSync()) {
    stderr.writeln('❌ Error: lib/main.dart not found');
    stderr.writeln('Please ensure your project has a lib/main.dart file');
    return false;
  }

  final content = entryFile.readAsStringSync();
  if (!content.contains('void main()') && !content.contains('void main(')) {
    stderr.writeln('❌ Error: lib/main.dart must contain a main() function');
    return false;
  }

  return true;
}

void _setupFileWatchers(Function restartCallback) {
  const watchDirs = ['lib', 'routes', 'controllers', 'models'];

  for (final dir in watchDirs.where((d) => Directory(d).existsSync())) {
    Directory(dir).watch(recursive: true).listen((event) {
      if (event.type == FileSystemEvent.modify &&
          event.path.endsWith('.dart') &&
          !event.path.contains('.g.dart')) {
        restartCallback();
      }
    });
  }
}

void _pipeProcessOutput(Process process) {
  process.stdout
      .transform(utf8.decoder)
      .listen((data) => stdout.write('[APP] $data'));

  process.stderr
      .transform(utf8.decoder)
      .listen((data) => stderr.write('[APP ERROR] $data'));

  process.exitCode.then((code) {
    if (code != 0) {
      stderr.writeln('💥 Server crashed with exit code $code');
    }
  });
}
