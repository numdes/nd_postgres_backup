<!--

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Stub:
## [Unreleased] - YYYY-MM-DD
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

-->

# nd_postgres_backup

## [0.2.1] - 2023-08-25
- refactoring and verification
### Braking changes
- Renamed:
  - `S3_ACCESS_KEY_ID` -> `S3_ACCESS_KEY`
  - `S3_SECRET_ACCESS_KEY` -> `S3_SECRET_KEY`

## [0.1.0] - 2023-08-03
- Backup Postgres DB
- Send back up to S3
- Notify users by telegram or private messaging system