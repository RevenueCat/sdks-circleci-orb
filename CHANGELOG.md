# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.7.1](https://github.com/RevenueCat/sdks-circleci-orb/compare/v4.7.0...v4.7.1) (2026-10-30)


### Chores

* **deps:** update mise to v2026.10.23 ([#103](https://github.com/RevenueCat/sdks-circleci-orb/issues/103)) ([f5858db](https://github.com/RevenueCat/sdks-circleci-orb/commit/f5858db24d0aa5196a3e57b1af36e46c31bfb952))

## [4.7.0](https://github.com/RevenueCat/sdks-circleci-orb/compare/v4.6.2...v4.7.0) (2026-10-08)

### Changed

- `danger`, `automatic-bump`, `tag-current-branch`, `merge-release-pr`, `enable-auto-merge-release-pr` and `insert-changelog-latest-in-main-if-needed`: bump default `ruby_version` from `3.2.0` to `3.3.0`, since fastlane will require Ruby >= 3.3. Consumers can still override `ruby_version` explicitly. ([#96](https://github.com/RevenueCat/sdks-circleci-orb/pull/96))

## [4.6.2](https://github.com/RevenueCat/sdks-circleci-orb/compare/v4.6.1...v4.6.2) (2026-09-22)

### Fixed

- `install-gem-dependencies`: retry `bundle install` once after removing `vendor/bundle` when it fails. A restored gem cache can hold a git-sourced gem whose checkout lacks the pinned revision, which bundler reports as `fatal: Could not parse object` and never recovers from, leaving every run on that cache key failing until the cache is invalidated by hand. ([#93](https://github.com/RevenueCat/sdks-circleci-orb/pull/93))

## [4.6.1](https://github.com/RevenueCat/sdks-circleci-orb/compare/v4.6.0...v4.6.1) (2026-08-21)

### Fixed

- `install-mise-tools`: include the OS version in the mise cache key. `arch` covers the OS and CPU but not its version, so a toolchain built on one macOS executor could restore onto another running a different macOS. The cached toolchain holds native binaries linked against the OS they were built on, so a Ruby built under macOS 15.3 and restored onto 13.2 left its gems failing to load, reported as `bundle install` failures and "extensions are not built". ([#88](https://github.com/RevenueCat/sdks-circleci-orb/pull/88))
- `install-mise`: write `~/.mise_platform` so callers can key caches on the OS version. ([#88](https://github.com/RevenueCat/sdks-circleci-orb/pull/88))

## [4.6.0](https://github.com/RevenueCat/sdks-circleci-orb/compare/v4.5.1...v4.6.0) (2026-08-13)

### Added

- `install-mise-tools`: `cache` parameter (default `true`) caches `~/.local/share/mise` between runs, so warm jobs no longer download toolchains from their upstream suppliers. Keyed on architecture, mise version, tool selection and both mise config files; a change to any of them misses and the job downloads as it does today. Ignored when `locked` is false. Set to `false` where restoring the toolset costs more than downloading it. ([#86](https://github.com/RevenueCat/sdks-circleci-orb/pull/86))
- `install-mise-tools`: `cache_prefix` parameter (default `v1`) to invalidate every mise cache. ([#86](https://github.com/RevenueCat/sdks-circleci-orb/pull/86))
- `install-mise`: write `~/.mise_version` so callers can key caches on the mise version. ([#86](https://github.com/RevenueCat/sdks-circleci-orb/pull/86))

### Changed

- `install-mise-tools`: `project_root` default changed from `""` to `"."` so the mise config files can be checksummed into the cache key; behavior is unchanged. ([#86](https://github.com/RevenueCat/sdks-circleci-orb/pull/86))

## [4.5.1](https://github.com/RevenueCat/sdks-circleci-orb/compare/v4.5.0...v4.5.1) (2026-07-20)

### Fixed

- `install-mise-tools`: `hooks: false` (the default) now sets `MISE_NO_HOOKS=1`, so project `[hooks]` such as postinstall no longer run on every install. ([#80](https://github.com/RevenueCat/sdks-circleci-orb/pull/80))

## [4.5.0](https://github.com/RevenueCat/sdks-circleci-orb/compare/v4.4.0...v4.5.0) (2026-07-17)

### Changed

- `automatic-bump` and `danger`: bump default `ruby_version` from `3.1.2` to `3.2.0`, matching the other release jobs. The 3.1.2 default no longer satisfies gems that require Ruby >= 3.2, causing Bundler to backtrack to unbuildable gem versions (e.g. `nokogiri 1.6.8.1`). Consumers can still override `ruby_version` explicitly. ([#81](https://github.com/RevenueCat/sdks-circleci-orb/pull/81))

## [4.4.0](https://github.com/RevenueCat/sdks-circleci-orb/compare/v4.3.1...v4.4.0) (2026-07-10)

### Added

- `install-mise-tools`: `tools` parameter (comma-separated string, default `""`) installs a subset by name from the consumer's `mise.toml` (e.g. `tools: node,yarn`); empty installs all tools. ([#78](https://github.com/RevenueCat/sdks-circleci-orb/pull/78))
- `install-mise-tools`: `hooks` parameter (default `false`) enables mise experimental mode when project-level `[hooks]` postinstall must run. ([#78](https://github.com/RevenueCat/sdks-circleci-orb/pull/78))
- `install-mise-tools`: `project_root` parameter cd's to the directory containing `mise.toml` before installing. ([#78](https://github.com/RevenueCat/sdks-circleci-orb/pull/78))

## [4.3.1](https://github.com/RevenueCat/sdks-circleci-orb/compare/v4.3.0...v4.3.1) (2026-07-08)

### Fixed

- `install-gem-dependencies`: include the architecture and Ruby version in the gem cache key so jobs running on different Rubies no longer collide on a single immutable key (which previously forced repeated `bundle install` reinstalls). Also add a partial-restore fallback key so a `Gemfile.lock` change reuses the previous bundle and installs only the delta. ([#77](https://github.com/RevenueCat/sdks-circleci-orb/pull/77))

## [4.3.0](https://github.com/RevenueCat/sdks-circleci-orb/compare/v4.2.0...v4.3.0) (2026-07-07)

### Added

- `install-mise-tools`: `locked` parameter (default `true`) runs `mise install --locked` so CI does not rewrite `mise.lock`. ([#76](https://github.com/RevenueCat/sdks-circleci-orb/pull/76))

### Changed

- `install-mise`: bump pinned mise to v2026.7.0 (lockfile write fixes with `--locked`). ([#76](https://github.com/RevenueCat/sdks-circleci-orb/pull/76))

## [4.2.0](https://github.com/RevenueCat/sdks-circleci-orb/compare/v4.1.0...v4.2.0) (2026-07-07)

### Added

- `install-mise-tools`: installs mise and all tools from the repository's `mise.toml`, including postinstall hooks; sets `JAVA_HOME` when java is configured. ([#75](https://github.com/RevenueCat/sdks-circleci-orb/pull/75))

## [4.1.0](https://github.com/RevenueCat/sdks-circleci-orb/compare/v4.0.0...v4.1.0) (2026-06-19)

### Added

- `update-error-codes`: nudge an `update-error-codes` PR that has stayed open for over a day with a comment mentioning `@RevenueCat/coresdk`. ([#71](https://github.com/RevenueCat/sdks-circleci-orb/pull/71))

## Earlier releases

See [GitHub Releases](https://github.com/RevenueCat/sdks-circleci-orb/releases) for versions before 4.1.0.
