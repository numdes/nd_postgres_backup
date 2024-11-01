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

## [0.3.2] - 2024-11-01

### Added

- Add monthly backup routine
- Add disable of hourly backups

### Changed

- Default value for WEEKLY_BACKUP_LIMIT

## [0.3.0] - 2024-01-09

### Added

- Add publish decription to Docker Hub from README.md 
- Add jq to container build 
- Add abilty to change alias for S3 connection. Variable `S3_ALIAS`
- Add docker-compose [example](compose-example/docker-compose.yml)
- Add `crontab` file for managing schedule
- Add retention functionallity 

### Removed

- Remove Go-Cron, replace it with standard cron
- Cut notifications for hourly backups

### Changed

- Replace manual backup routine logic. To start manual backup run container without S3_BUCKET variable. See [README](README.md)
- Change S3 storage directory from `${S3_BUCKET}/${POSTGRES_DB}` to `${S3_BUCKET}/${backup_path}`
- Rename notification scripts. Add `.sh` extention


### Braking changes
- Removed:
  - `SCHEDULE` - variable was used by Go-Cron
  - `HEALTHCHECK_PORT` - variable was used by Go-Cron

## [0.2.2] - 2023-08-25
- Make docker-entrypoint.sh to easy manual run
- Fix bug with `S3_OBJECT_PATH` var

## [0.2.1] - 2023-08-25
- Added var `S3_OBJECT_PATH` to define the path to the backup file in the bucket

## [0.2.0] - 2023-08-25
- refactoring and verification
### Braking changes
- Renamed:
  - `S3_ACCESS_KEY_ID` -> `S3_ACCESS_KEY`
  - `S3_SECRET_ACCESS_KEY` -> `S3_SECRET_KEY`

## [0.1.0] - 2023-08-03
- Backup Postgres DB
- Send back up to S3
- Notify users by telegram or private messaging system