# empirical water

A native SwiftUI app for iPhone, iPad, and Mac that calculates empirical water
concentrate recipes for coffee and tea. Supports iOS/iPadOS 17+ and macOS 14+,
including the 26 releases, with no third-party app dependencies.

Written by [Erik Gomez](https://github.com/erikng), based on
[Blossom Rain](https://github.com/erikng/Blossom-Rain).

## Building and running

Open `Darwin/empiricalwater.xcodeproj` in Xcode 16 or later (Swift 6), select
**empiricalwater**, and choose **My Mac**, an iPhone/iPad simulator, or a device.
Use Xcode 26 or later for the 26 SDKs. Physical-device and distribution builds
require your Apple signing credentials.

The app target compiles `Sources/empiricalwater/` directly. Identity, version,
deployment targets, and signing settings live in `Darwin/empiricalwater.xcconfig`.
The bundle identifier and effective version remain `com.empiricalwater.app` and
`1.0.9` (build 1); increment the version/build before submitting a release.
The Mac app uses native SwiftUI/AppKit, with resizable independent recipe
windows and Settings available from the toolbar or Command-comma.

Build the iOS Simulator app from the repository root:

```sh
xcodebuild -project Darwin/empiricalwater.xcodeproj -scheme empiricalwater \
  -configuration Debug -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath .build/iOS-Simulator CODE_SIGNING_ALLOWED=NO build
```

Build the universal native Mac app (Apple silicon and Intel):

```sh
xcodebuild -project Darwin/empiricalwater.xcodeproj -scheme empiricalwater \
  -configuration Debug -destination 'generic/platform=macOS' \
  -derivedDataPath .build/macOS CODE_SIGNING_ALLOWED=NO build
```

Check the iOS Release build:

```sh
xcodebuild -project Darwin/empiricalwater.xcodeproj -scheme empiricalwater \
  -configuration Release -destination 'generic/platform=iOS' \
  -derivedDataPath .build/iOS-Release CODE_SIGNING_ALLOWED=NO build
```

These commands build unsigned local artifacts. Mac sandboxing and hardened
runtime are configured for signed builds. The optional Fastlane setup in
`Darwin/fastlane/` handles iOS distribution.

## Current recipes

The presets were refreshed from the current **Water Calculator** in the
[empirical water User Guide](https://empiricalwater.com/pages/user-guide) on
September 12, 2026. The older instructions farther down that page are explicitly
deprecated and sometimes disagree with the calculator; the app follows the
current calculator.

The app includes all 12 presets: six Glacial, five Spring, and Aviary Filter.
This includes Glacial Acidity++ and Spring Espresso. Aviary is credited to
Christopher Feran and uses the current concentrate (batch 5 or later, or no
batch number). Aquifer and Snowmelt were unimplemented zero-value placeholders
and are no longer offered.

Buffer density now varies by profile: Glacial 1.022, Spring 1.032, and Aviary
1.049 g/mL. Extraction booster uses 1.024 g/mL. Hardness and zero TDS water use
the calculator's 1 g/mL approximation. The US gallon conversion is 3785.41 mL.
Every concentrate displaces an equal volume of zero TDS water, so the selected
batch volume is the final volume. Mass and volume are not interchanged when
calculating dilution. Values are rounded only for display.

Current presets contain no extraction booster. The existing optional booster
setting now reveals an adjustment control that starts at zero; a positive dose
is labeled an adjusted recipe and reduces dilution water accordingly. The app
also shows the calculator's predicted GH, KH, and TDS. Existing measurement,
dark-mode, and compact-header preferences keep their stored keys.

## Source provenance and verification

`Reference/EmpiricalWater/recipes.json` saves the extracted constants, source
URL, retrieval date, original page SHA-256, and reference-calculator SHA-256.
`Reference/EmpiricalWater/calculator.cjs` preserves the upstream numeric constants
and calculation block with a small adapter for testing. These references are
not bundled with the app, and the app does not execute JavaScript or need a
network connection for calculations.

With Xcode and Node.js installed, run:

```sh
python3 scripts/verify-recipes.py
```

The offline checks compile the production calculator and state in Swift 6 mode
for macOS 14, treating compiler warnings as errors. They execute the saved
JavaScript independently and compare 12,288 cases: every preset, three volume
units, four booster doses, and all 16 combinations of per-ingredient measurement
preferences. Additional checks cover literal regression examples, final-volume
conservation, unsupported recipes, invalid/overflowing inputs, and independent
window state.

For future refreshes, download the guide and locate the script containing
`PROFILES`, `BOOSTER`, and `render()`. Compare its constants and arithmetic with
the saved reference and `Recipes.swift` / `RecipeCalculator.swift`; update the
source date and hashes together. Keep stable recipe raw values and preference
keys. Re-run recipe verification and all three platform builds. Compiler
availability checks at the deployment minimums do not replace runtime checks
on older OS installations.

## SwiftUI and OS compatibility

Window-owned, main-actor Observation replaces mutable global state. Models and
calculations are separate from the view; volume and result sections observe
only the input they need. Recipe/unit identity is stable and no longer allocates
UUIDs during rendering. Native forms, pickers, scalable text, and system colors
adapt to the platform and accessibility settings.

All used APIs are available at iOS 17 and macOS 14. Platform-specific navigation
and window settings are conditionally compiled. Standard controls adopt the
system appearance on OS 26 when built with the 26 SDK; no exclusive OS-26 API
or compatibility fallback is required.

Apple guidance used for the migration:

- [Migrating to Observation](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)
- [Configuring a multiplatform app](https://developer.apple.com/documentation/xcode/configuring-a-multiplatform-app-target)
- [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)
