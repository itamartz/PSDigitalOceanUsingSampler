# Changelog for PSDigitalOcean

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

 - **New Function**: `Remove-DigitalOceanDroplet` - Delete a single Droplet by ID or
   all Droplets by tag with ShouldProcess support, robust error handling, and
   verbose tracing.

### Changed

### Fixed

## [1.7.0] - 2025-08-10

### Added

- **New Function**: `Remove-DigitalOceanVolume` - Comprehensive volume deletion function with dual deletion methods
  - Support for deletion by Volume ID or by Name+Region combination
  - ShouldProcess support with high-impact confirmation for safe operations
  - Comprehensive error handling with detailed API error response parsing
  - URL encoding for all parameters to handle special characters
  - Verbose logging for operation tracking and debugging
  - Parameter aliases (Id for VolumeId, VolumeName for Name) for user convenience
- **35 Unit Tests** for `Remove-DigitalOceanVolume` covering all scenarios including edge cases
- **Real API Integration Testing** with successful validation using actual DigitalOcean volumes
- **Enhanced Test Coverage** increased from 95.89% to 96.03% with 599 total tests

### Changed

- Updated module description to include volume management capabilities
- Enhanced README.md with new function documentation and updated statistics
- Added Volume class to the list of supported PowerShell classes

## [1.6.1] - 2025-08-10

### Fixed

- Enhanced error handling in `New-DigitalOceanVolume` with detailed API error response parsing
- Resolved API integration issues for volume creation operations
- Improved error messages to show actual DigitalOcean API responses

### Changed

- Updated development guidelines with integration testing requirements for non-GET functions
- Enhanced documentation for `New-DigitalOceanDroplet` parameter help

## [1.6.0] - 2025-08-10

### Added

- Added new `New-DigitalOceanVolume` function for creating new volumes
- Enhanced `Get-DigitalOceanVolume` function with comprehensive error handling
  and edge case coverage
- Support for creating volumes from snapshots using the FromSnapshot parameter set
- Advanced filesystem configuration with ext4 and xfs support
- Volume creation validation with proper parameter set restrictions
- ShouldProcess support (-WhatIf and -Confirm) for volume creation operations
- Extensive unit test coverage achieving 97.51% code coverage
- Comprehensive error handling for API failures, malformed data, and edge cases
- Enhanced pagination tests for thorough volume retrieval validation

### Changed

- Improved Get-DigitalOceanVolume test coverage from 83.13% to 97.51%
- Enhanced error handling and malformed data processing
- Updated module version to 1.6.0

### Fixed

- Fixed pagination logic edge cases in Get-DigitalOceanVolume
- Resolved test coverage gaps for error scenarios
- Improved URL encoding for special characters in API parameters

## [1.5.0] - 2025-08-07

### Added

- Added new `Get-DigitalOceanVolume` function with comprehensive volume
  management capabilities
- Support for volume retrieval by ID using the ById parameter set
- Support for volume retrieval by name using the ByName parameter set  
- Support for volume listing with pagination using the List parameter set
- Support for retrieving all volumes using the All parameter set
- Regional filtering support for volume operations
- URL encoding for special characters in volume IDs, names, and region parameters
- Comprehensive test coverage with 11 new unit tests for volume functionality
- PowerShell class DigitalOceanVolume with proper property mapping and methods

### Changed

- Updated module version to 1.5.0
- Increased test count from 471 to 517 tests (+46 tests)
- Maintained 97% code coverage with new volume functionality

### Fixed

- Fixed PSScriptAnalyzer trailing whitespace issues in Get-DigitalOceanVolume function

## [1.4.0] - 2025-08-07

### Added

- Significantly improved code coverage from 93.04% to 98.95% through
  comprehensive testing
- Added 8 new targeted tests for DigitalOceanDroplet class constructor edge cases
- Added tests to cover if-else logic branches in size, image, and networks
  property handling
- Added PSCustomObject input testing to achieve complete constructor coverage

### Changed

- Enhanced test suite with 3 additional test cases for complete code coverage
- Improved DigitalOceanDroplet class testing with null property handling scenarios
- Updated test methodology to use PSCustomObject inputs for triggering specific
  code paths

### Fixed

- Fixed uncovered lines in DigitalOceanDroplet constructor (lines 166, 187-192,
  210-211)
- Resolved hashtable vs PSCustomObject input behavior in class constructors
- Improved edge case handling for null and missing properties in object
  construction

## [1.3.0] - 2025-08-07

### Added

- Added `DigitalOceanVPC` PowerShell class with comprehensive VPC property structure
- Added class-based architecture support for VPC (Virtual Private Cloud) resources
- Enhanced `Get-DigitalOceanVPC` function to return strongly-typed  
  DigitalOceanVPC objects
- Added comprehensive unit tests for DigitalOceanVPC class (27 test cases)

### Changed

- Updated `Get-DigitalOceanVPC` function to use class-based output instead of PSObject
- Enhanced VPC function documentation with Pascal case property examples
- Improved test coverage and consistency across all VPC-related functionality

### Fixed

- Fixed VPC function tests to properly expect class-based objects
- Corrected property naming consistency (Pascal case) in VPC examples and documentation

## [1.2.0] - 2025-08-07

### Added

- Added `DigitalOceanDroplet` PowerShell class with comprehensive 21-property structure
- Added `New-DigitalOceanDroplet` function to create DigitalOcean Droplets
- Enhanced class-based architecture with strongly-typed object returns
- Added comprehensive error handling and parameter validation

### Changed

- Refactored all functions to return strongly-typed class objects instead of PSObjects
- Enhanced SSH key parameter handling with flexible type support
- Improved null response handling across all functions

### Fixed

- Fixed parameter binding conflicts in SSH key validation
- Fixed array type validation in test environment
- Fixed trailing whitespace PSScriptAnalyzer violations

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

- Updated module version to 1.2.0
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
