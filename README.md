# Orb Template

<!---
[![CircleCI Build Status](https://circleci.com/gh/<organization>/<project-name>.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/<organization>/<project-name>) [![CircleCI Orb Version](https://badges.circleci.com/orbs/<namespace>/<orb-name>.svg)](https://circleci.com/orbs/registry/orb/<namespace>/<orb-name>) [![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/<organization>/<project-name>/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

--->

A project template for Orbs.

This repository is designed to be automatically ingested and modified by the CircleCI CLI's `orb init` command.

_**Edit this area to include a custom title and description.**_

---

## Resources

[CircleCI Orb Registry Page](https://circleci.com/orbs/registry/orb/<namespace>/<orb-name>) - The official registry page of this orb for all versions, executors, commands, and jobs described.

[CircleCI Orb Docs](https://circleci.com/docs/2.0/orb-intro/#section=configuration) - Docs for using, creating, and publishing CircleCI Orbs.

### How to Contribute

We welcome [issues](https://github.com/<organization>/<project-name>/issues) to and [pull requests](https://github.com/<organization>/<project-name>/pulls) against this repository!

### How to Publish An Update

PR titles must follow [Conventional Commits](https://conventionalcommits.org/) (checked by the `PR title` workflow), since they become the squash-merge commit message.

[release-please](https://github.com/googleapis/release-please) keeps a release PR open that bumps the version and updates `CHANGELOG.md` from the merged commits. Merging it tags `vX.Y.Z`, which triggers the publishing pipeline on CircleCI.

`feat` releases a minor version; `fix`, `perf`, `revert`, `chore` and `docs` release a patch. `ci`, `build`, `refactor`, `test` and `style` do not trigger a release. A `!` after the type (e.g. `feat!:`) releases a major version.
