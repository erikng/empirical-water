# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Custom recipes with independent hardness and buffer concentrates, optional booster,
  live dilution/mineral results, and batch-volume scaling.
- Local recipe saving, multiline notes, editing, cancellation, confirmed deletion,
  and default selection, following the current Blossom Rain editor.
- Custom-recipe verification across all concentrate pairs and measurement settings.

### Changes
- Native SwiftUI builds for iPhone, iPad, and Mac, with no third-party app dependencies.
- Removed Android and transpiler build infrastructure.
- Swift 6 and window-local Observation state; existing preferences are retained.
- Refreshed all 12 published Water Calculator presets on September 12, 2026,
  including Glacial Acidity++, Spring Espresso, and Aviary Filter.
- Corrected concentrate densities, US gallon conversion, and final-volume dilution.
- Optional extraction booster starts at zero and is labeled as a recipe adjustment.
- Removed the unimplemented Aquifer and Snowmelt placeholder selections.
- Native Mac settings, adaptive controls, and mineral profile readouts.
- iOS 17 and macOS 14 minimums remain supported.

## [1.0.9] - 2024-11-23
### Changes
- Recipes have been updated to match website changes
  - spring light/medium/dark roast
  - glacial light roast
- "snowmelt" added but currently non functional
- Built on Xcode 16.1

## [1.0.8] - 2024-10-02
### Changes
- Extraction Booster is now off by default

## [1.0.7] - 2024-09-12
### Changes
- Reduced maximum liters to 10 (from 20)
- Increased minimum liters to 1 (from 0)
- Increased minimum millileters to 100 (from 0)
- Increased maximum gallons to 10 (from 5)

### Fixed
- Milliliter slider accuracy

### Added
- Liter slider now allows 250ml adjustments

## [1.0.6] - 2024-09-11
### Fixed
- Milliliter typos

## [1.0.5] - 2024-09-11
### Changes
- Added "chevron.up.chevron.down" SFSymbols for v1.0.4 buttons

### Added
- Milliliters is now supported for custom brew batches
- Minimal Button Toggle for v1.0.4 button style

## [1.0.4] - 2024-09-10
### Changes
- Built with Xcode 16 RC and latest Swift 5 SDK

### Added
- Force Dark Mode Toggle

## [1.0.3] - 2024-09-10
### Changes
- Redesigned the main portion of the UI

## [1.0.2] - 2024-09-08
### Added
- New volumetric toggle options for each recipe

## [1.0.1] - 2024-09-04
### Fixed
- Sets application language to English

## [1.0.0] - 2024-09-03
### Added
- Initial release
