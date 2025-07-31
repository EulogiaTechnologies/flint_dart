// File: hot.dart
import 'dart:io';

void main(List<String> args) {
  final rootPath = args.isNotEmpty ? args[0] : 'bin';
  hot(rootPath);
}

void hot(String rootPath) async {
  Process? server;

  Future<void> startServer() async {
    print('[HOT] Starting server...');
    server = await Process.start('dart', ['run', '$rootPath/server.dart']);
    server!.stdout.transform(SystemEncoding().decoder).listen(stdout.write);
    server!.stderr.transform(SystemEncoding().decoder).listen(stderr.write);
  }

  void restartServer() {
    print('[HOT] Restarting server...');
    server?.kill(ProcessSignal.sigkill);
    startServer();
  }

  final foldersToWatch = ['lib', 'bin', 'example', 'routes', 'controllers'];

  for (final dir in foldersToWatch) {
    final directory = Directory(dir);
    if (directory.existsSync()) {
      directory.watch(recursive: true).listen((event) {
        if (event.type == FileSystemEvent.modify &&
            event.path.endsWith('.dart')) {
          restartServer();
        }
      });
    }
  }

  await startServer();
}
