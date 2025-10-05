import 'dart:io';

import 'package:file/file.dart';

import '../../models.dart';
import '../command.dart';
import '../command_result.dart';
import '../config.dart';
import '../env/env_shims.dart';
import '../install/bin.dart';
import '../install/profile.dart';
import '../logger.dart';
import '../version.dart';

class PuroInstallCommand extends PuroCommand {
  PuroInstallCommand() {
    argParser.addFlag(
      'force',
      help: 'Overwrite an existing puro installation, if any',
      negatable: false,
    );
    argParser.addFlag(
      'promote',
      help: 'Promotes a standalone executable to a full installation',
      negatable: false,
    );
    argParser.addFlag(
      'path',
      help: 'Whether or not to update the PATH automatically',
    );
    argParser.addOption(
      'profile',
      help:
          'Overrides the profile script puro appends to when updating the PATH',
    );
  }

  @override
  final name = 'install-puro';

  @override
  bool get hidden => true;

  @override
  final description = 'Finishes installation of the puro tool';

  @override
  bool get allowUpdateCheck => false;

  @override
  Future<CommandResult> run() async {
    final puroVersion = await PuroVersion.of(scope);
    final config = PuroConfig.of(scope);
    final log = PuroLogger.of(scope);

    final force = argResults!['force'] as bool;
    final promote = argResults!['promote'] as bool;
    final profileOverride = argResults!['profile'] as String?;
    final updatePath = argResults!.wasParsed('path')
        ? argResults!['path'] as bool
        : null;

    await ensurePuroInstalled(scope: scope, force: force, promote: promote);

    final PuroGlobalPrefsModel prefs = await updateGlobalPrefs(
      scope: scope,
      fn: (prefs) {
        if (profileOverride != null) prefs.profileOverride = profileOverride;
        if (updatePath != null) prefs.enableProfileUpdate = updatePath;
        if (runner.pubCacheOverride != null) {
          prefs.pubCacheDir = runner.pubCacheOverride!;
        }
        if (runner.flutterGitUrlOverride != null) {
          prefs.flutterGitUrl = runner.flutterGitUrlOverride!;
        }
        if (runner.engineGitUrlOverride != null) {
          prefs.engineGitUrl = runner.engineGitUrlOverride!;
        }
        if (runner.dartSdkGitUrlOverride != null) {
          prefs.dartSdkGitUrl = runner.dartSdkGitUrlOverride!;
        }
        if (runner.versionsJsonUrlOverride != null) {
          prefs.releasesJsonUrl = runner.versionsJsonUrlOverride!;
        }
        if (runner.flutterStorageBaseUrlOverride != null) {
          prefs.flutterStorageBaseUrl = runner.flutterStorageBaseUrlOverride!;
        }
        if (runner.shouldInstallOverride != null) {
          prefs.shouldInstall = runner.shouldInstallOverride!;
        }
        if (runner.legacyPubCache != null) {
          prefs.legacyPubCache = runner.legacyPubCache!;
        }
      },
    );

    log.d(() => 'prefs: ${prettyJsonEncoder.convert(prefs.toProto3Json())}');

    // Update the PATH by default if this is a distribution install.
    String? profilePath;
    var updatedWindowsRegistry = false;
    final homeDir = config.homeDir.path;
    if ((updatePath ?? false) ||
        ((puroVersion.type == PuroInstallationType.distribution || promote) &&
                !prefs.hasEnableProfileUpdate() ||
            prefs.enableProfileUpdate)) {
      if (Platform.isLinux || Platform.isMacOS) {
        final profile = await installProfileEnv(
          scope: scope,
          profileOverride: prefs.hasProfileOverride()
              ? prefs.profileOverride
              : null,
        );
        profilePath = profile?.path;
        if (profilePath != null && profilePath.startsWith(homeDir)) {
          profilePath = '~' + profilePath.substring(homeDir.length);
        }
      } else if (Platform.isWindows) {
        updatedWindowsRegistry = await tryUpdateWindowsPath(scope: scope);
      }
    }

    // Environment shims may have changed, update all of them to be safe
    config.envsDir.createSync(recursive: true);
    for (final envDir in config.envsDir.listSync().whereType<Directory>()) {
      if (envDir.basename == 'default') continue;
      final environment = config.getEnv(envDir.basename);
      if (!environment.flutterDir.childDirectory('.git').existsSync()) continue;
      await runOptional(scope, '`${environment.name}` post-upgrade', () async {
        await installEnvShims(scope: scope, environment: environment);
      });
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
      if (profilePath != null)
        CommandMessage(
          'Updated PATH in $profilePath, reopen your terminal or `source $profilePath` for it to take effect',
        ),
      if (updatedWindowsRegistry)
        CommandMessage(
          'Updated PATH in the Windows registry, reopen your terminal for it to take effect',
        ),
      CommandMessage(
        'Successfully installed Puro ${puroVersion.semver} to `${config.puroRoot.path}`',
      ),
    ]);
  }
}
