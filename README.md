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

The app target compiles `Sources/empiricalwater/` directly. Base identity, version,
deployment, and signing settings live in `Darwin/empiricalwater.xcconfig`.
Target-specific overrides in the Xcode project take precedence over that file.
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
Run builds sequentially, adding `-jobs 2` to limit compiler concurrency. A generic
iOS destination compiles for both iPhone and iPad without launching a simulator.

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

## Custom recipes

Choose **Custom Recipe** in the **Recipe** picker. Select hardness and buffer
concentrates independently from Glacial, Spring, and Aviary, then adjust hardness,
buffer, and extraction booster using sliders or decimal input. The starting
mixture uses the website's custom defaults: 50 mL Glacial hardness and no buffer
or booster per liter.

Inputs are **mL of concentrate per liter of finished water**. The existing
**Brew Volume** controls scale the recipe for milliliters, liters, or US gallons.
Concentrates must total no more than 1,000 mL/L; zero TDS water fills the remainder.
The ingredient amounts and predicted GH, KH, and TDS update while editing.
Output respects each ingredient's grams/mL preference and the selected buffer's
density. A custom recipe's booster is always included and shown, independently
of the optional booster control for published presets.

Enter a name and optional multiline description below the results, then choose
**Save Recipe**. Saved recipes appear in the picker. Use **Recipe Actions** in
the toolbar to edit or delete one; deletion asks for confirmation. Save/Cancel
stay at the bottom even when input is invalid. Cancel restores the previous
recipe without changing saved data, and edits preserve recipe identity.

This follows the current Blossom Rain editor, including its actual-value slider
snapping, decimal input, single keyboard **Done** button, multiline notes that
do not submit the form, and Return/Escape actions. Typed precision survives
saving and reopening a recipe. Notes display as plain text.

**Default Recipe** in settings chooses Published Recipes or a saved recipe for
new brewing windows and app launches. Recipes persist locally in the
`customRecipes.v1` user-defaults entry; there is no network sync. Windows share
the saved library while keeping their own selections, volume, and unsaved drafts.
Deleting a custom default restores Published Recipes. Duplicate names and invalid
doses cannot overwrite recipes; unreadable saved data is reported and preserved.

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
window state. Another 5,184 comparisons exercise the saved calculator's Custom
branch with all nine hardness/buffer concentrate pairs, decimal doses, booster,
zero-mineral recipes, all units, and all measurement combinations. Feature checks
cover save/reload, defaults, edit/cancel, multiline notes, deletion, duplicate names,
independent windows, corrupt data, locale input, slider snapping, and typed precision.

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
