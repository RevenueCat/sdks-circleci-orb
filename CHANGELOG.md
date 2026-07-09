# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- `install-gem-dependencies`: include the architecture and Ruby version in the gem cache key so jobs running on different Rubies no longer collide on a single immutable key (which previously forced repeated `bundle install` reinstalls). Also add a partial-restore fallback key so a `Gemfile.lock` change reuses the previous bundle and installs only the delta.
- `install-mise-tools`: installs mise and all tools from the repository's `mise.toml`, including postinstall hooks; sets `JAVA_HOME` when java is configured.
- `install-mise-tools`: `locked` parameter (default `true`) runs `mise install --locked` so CI does not rewrite `mise.lock`.
- `install-mise-tools`: `tools` parameter (string, default `""`) installs a subset by name from the consumer's `mise.toml` (e.g. `tools: node yarn`); empty installs all tools.
- `install-mise-tools`: `hooks` parameter (default `false`) enables mise experimental mode when project-level `[hooks]` postinstall must run.
- `install-mise-tools`: `project_root` parameter cd's to the directory containing `mise.toml` before installing.
- `install-mise`: bump pinned mise to v2026.7.0 (lockfile write fixes with `--locked`).
- Current development changes [ to be moved to release ]
- `update-error-codes`: nudge an `update-error-codes` PR that has stayed open for over a day with a comment mentioning `@RevenueCat/coresdk`.

## [1.0.0] - 2021-03-11

### Added

- Initial Release
- Added example and a prepare-android command

[1.0.0]: GITHUB TAG URL
