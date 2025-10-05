import 'dart:io';

import '../command.dart';
import '../command_result.dart';
import '../install/profile.dart';
import '../terminal.dart';
import '../version.dart';

class VersionCommand extends PuroCommand {
  VersionCommand() {
    argParser.addFlag(
      'plain',
      negatable: false,
      help: 'Print just the version to stdout and exit',
    );
    argParser.addFlag('release', negatable: false, hide: true);
  }

  @override
  String get name => 'version';

  @override
  String get description => 'Prints version information';

  @override
  bool get allowUpdateCheck => false;

  @override
  Future<CommandResult> run() async {
    final plain = argResults!['plain'] as bool;
    final puroVersion = await PuroVersion.of(scope);
    if (plain) {
      Terminal.of(scope).flushStatus();
      await stderr.flush();
      stdout.write('${puroVersion.semver}');
      await runner.exitPuro(0);
    }
    final externalMessage = await detectExternalFlutterInstallations(
      scope: scope,
    );
    final updateMessage = await checkIfUpdateAvailable(
      scope: scope,
      runner: runner,
      alwaysNotify: true,
    );
    return BasicMessageResult.list([
      if (externalMessage != null) externalMessage,
      if (updateMessage != null) updateMessage,
      CommandMessage(
        'Puro ${puroVersion.semver} '
        '(${puroVersion.type.name}/${puroVersion.target.name})\n'
        'Dart ${Platform.version}',
        type: CompletionType.info,
      ),
    ]);
  }
}
