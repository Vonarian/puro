## Unreleased

* Added the `prepare` command to pre-download Flutter artifacts for an environment

## 1.4.11

* Bug fixes
* Added `-d` flag to `puro ls` to show dart versions

## 1.4.10

* Bug fixes

## 1.4.9

* Bug fixes

## 1.4.8

* Bug fixes
* Support for newer versions of Flutter that use the monorepo

## 1.4.7

* Bug fixes

## 1.4.6

* Bug fixes

## 1.4.5

* Bug fixes

## 1.4.4

* Bug fixes

## 1.4.3

* Absolutely nothing, the `+1` of the previous release broke CloudFront lol

## 1.4.2+1

* Bug fixes

## 1.4.2

* Bug fixes
* Unused caches are now cleaned up automatically

## 1.4.1

* Bug fixes
* Added the `build-shell` command to open a shell for building the Flutter engine manually
* Added the `--projects`/`-p` flag to `ls` to show which projects are using each environment

## 1.4.0

* Bug fixes
* Added support for versioned environments, you can now `puro use <version>` to switch to a specific version instead of
  creating one manually

## 1.3.8

* Bug fixes

## 1.3.7

* Bug fixes
* The `ls` command now has a separate indicator for the global default
* The `create` and `upgrade` commands now recognize tags without an official release

## 1.3.6

* Bug fixes
* Now using 7zip to speed up engine unzipping on Windows
* Added 'downgrade' as an alias for the 'upgrade' command
* Added the `rename` command
* The `rm` command now warns if known projects are using the environment

## 1.3.5

* Bug fixes

## 1.3.4

* Bug fixes

## 1.3.3

* Bug fixes

## 1.3.2

* Bug fixes

## 1.3.1

* Bug fixes

## 1.3.0

* Bug fixes
* Added the `uninstall-puro` command

## 1.2.6

* Bug fixes

## 1.2.5

* Bug fixes

## 1.2.4

* Added the `--extra` option to to `eval`
* Added the `repl` command

## 1.2.3

* Bug fixes

## 1.2.2

* Bug fixes

## 1.2.1

* Bug fixes
* Added package support to eval

## 1.2.0

* Bug fixes
* Added the `eval` command

## 1.1.13

* Bug fixes

## 1.1.12

* Bug fixes

## 1.1.11

* Bug fixes
* Added support for Google storage mirrors with FLUTTER_STORAGE_BASE_URL
* Added the `engine prepare` command
* Added the `engine build-env` command

## 1.1.10

* Bug fixes

## 1.1.9

* Bug fixes

## 1.1.8

* Bug fixes

## 1.1.7

* Bug fixes
* Added global configuration for bash/zsh profiles
* Improved Windows installer

## 1.1.6

* Bug fixes

## 1.1.5

* Bug fixes

## 1.1.4

* Bug fixes
* Improved installing puro inside symlinks and non-standard paths

## 1.1.3

* Bug fixes
* Added support for older versions of Flutter

## 1.1.2

* Bug fixes

## 1.1.1

* Bug fixes

## 1.1.0

* Bug fixes
* Added the `ls-versions` command
* Added the `gc` command

## 1.0.1

* Bug fixes
* Better support for standalone and pub installs

## 1.0.0

* Bug fixes
* First stable release

## 0.6.1

* Fix small issue with upgrades

## 0.6.0

* Bug fixes
* Added automatic update checks
* Changed the default pub root to ~/.puro/shared/pub_cache
* Upgrades now infer the branch
* Added the `--fork` option to `puro create`

## 0.5.0

* Bug fixes
* Added the `pub` command
* Added the `upgrade-puro` command
* Added dart/flutter shims to .puro/bin
* Improved bash/zsh profile updating mechanism
* Added the hidden `install-puro` command
* Added PATH conflict detection to the `version` command

## 0.4.1

* Bug fixes
* Added the `--global` flag to `puro use` to set the default environment
* Implemented default environments

## 0.4.0

* Bug fixes
* Performance improvements
* Added the `upgrade` command for upgrading environments
* Added the `--vscode` and `--intellij` flags to `puro use` which override whether their configs are generated
* Added the `version` command

## 0.3.0

* Bug fixes

## 0.2.0

* Bug fixes
* Performance improvements

## 0.1.0

* Added progress bars
* Added puro as an executable

## 0.0.1

Initial version
