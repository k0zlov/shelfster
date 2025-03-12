import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:watcher/watcher.dart';

Future<void> runServer({
  required String serverPath,
  String watchDirectory = 'lib',
  Duration debounceDuration = const Duration(seconds: 1),
}) async {
  bool firstStart = true;
  Process? serverProcess;
  Timer? reloadTimer;

  Future<void> startServer() async {
    final List<String> args = [serverPath];

    if (firstStart) {
      args.add('--first-start');
      firstStart = false;
    }

    serverProcess = await Process.start(
      'dart',
      args,
      mode: ProcessStartMode.detachedWithStdio,
    );

    serverProcess!.stdout.transform(utf8.decoder).listen(stdout.write);
    serverProcess!.stderr.transform(utf8.decoder).listen(stderr.write);
  }

  void stopServer() {
    if (serverProcess != null) {
      serverProcess!.kill(ProcessSignal.sigkill);
      serverProcess = null;
    }
  }

  await startServer();

  final watcher = DirectoryWatcher(watchDirectory);
  print('Watching "$watchDirectory" for changes...');

  await for (final _ in watcher.events) {
    reloadTimer?.cancel();
    reloadTimer = Timer(debounceDuration, () async {
      stopServer();
      print('Reloading...');
      await startServer();
    });
  }
}
