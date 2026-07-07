# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- `install-mise-tools`: installs mise and all tools from the repository's `mise.toml`, including postinstall hooks; sets `JAVA_HOME` when java is configured.
- `install-mise-tools`: `locked` parameter (default `true`) runs `mise install --locked` so CI does not rewrite `mise.lock`.
- Current development changes [ to be moved to release ]
- `update-error-codes`: nudge an `update-error-codes` PR that has stayed open for over a day with a comment mentioning `@RevenueCat/coresdk`.

## [1.0.0] - 2021-03-11

### Added

- Initial Release
- Added example and a prepare-android command

[1.0.0]: GITHUB TAG URL
