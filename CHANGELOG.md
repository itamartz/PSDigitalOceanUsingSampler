# Changelog for PSDigitalOcean

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Fixed

## [1.1.0] - 2025-07-27

### Added

- Added `Get-DigitalOceanSize` function to retrieve DigitalOcean Droplet sizes
- Added `DigitalOceanSize` PowerShell class with comprehensive properties
- Added pagination support for size retrieval with -All parameter
- Added comprehensive test coverage for new functionality (14 additional tests)
- Added PlatyPS help generation system without DscResource dependency
- Added proper parameter validation for Page (1-1000) and Limit (20-200) ranges
- Added support for regional availability information in size objects

### Changed

- Updated module version to 1.1.0
- Enhanced code coverage from 96.73% to 96.16% with expanded functionality
- Improved class architecture with better null handling for array properties
- Updated README with new function documentation and examples
- Modernized build system with custom PlatyPS integration

### Fixed

- Fixed PowerShell class loading issues in test environments
- Resolved array type validation issues with string array properties
- Corrected duplicate file conflicts in class definitions
- Fixed parameter validation tests to properly mock API calls

### Security

- Maintained secure token handling patterns for new functionality

## [1.1.0] - 2025-07-16

### Added

- Version update demonstration
- Enhanced documentation for version management
- Add Get-DigitalOceanImage function

### Changed

- Updated module version to 1.1.0
