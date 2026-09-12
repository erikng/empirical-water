# Native SwiftUI migration

## Scope and design

Replace the cross-platform build with one native Xcode app target for iPhone,
iPad, and Mac. Keep the existing bundle identifier, version, signing team,
iOS 17 minimum, macOS 14 minimum, and stored preference keys. Follow the
direct-source build and independent upstream-calculator verification used by
the neighboring Blossom Rain repository. Work is local and uncommitted.

The recipe source is the current Water Calculator at
https://empiricalwater.com/pages/user-guide, retrieved September 12, 2026.
The lower section is explicitly deprecated and disagrees with the calculator.
Use the 12 calculator presets, its concentrate densities, US gallon conversion,
and dilution arithmetic. Aquifer and Snowmelt had only zero-valued placeholders
and have no published presets in this calculator; remove them from selection.

## Implementation and verification

- Save the recipe constants, numerical calculator excerpt, retrieval date,
  and source hashes under `Reference/EmpiricalWater/`.
- Reproduce the old spring-espresso and buffer/dilution errors before editing.
- Add offline comparisons that execute the saved JavaScript and compile the
  production Swift calculator. Cover every preset, all three units, each
  measurement preference combination, optional booster doses, invalid inputs,
  and independent session state.
- Split `Structs.swift` into immutable recipes/units, a pure calculator, and
  a main-actor Observation state model. SwiftUI owns state per recipe window.
- Retain optional booster controls, starting at zero because current presets
  contain no booster; clearly label positive doses as recipe adjustments.
- Use native adaptive forms/pickers, scalable text, accessible controls,
  platform-specific window/settings scenes, and safe app-version lookup.
- Compile source files directly in Xcode; remove the package/plugin/Android
  infrastructure and obsolete publishing instructions. Add native Mac icons,
  sandbox/hardened-runtime configuration, and keep the existing iOS scheme.
- Build Debug iOS Simulator and universal macOS targets plus Release iOS.
  Run available simulator and native-Mac launch checks. Compiler checks at
  deployment minimums do not substitute for runtime tests on older systems.

## Apple guidance

- https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro
- https://developer.apple.com/documentation/xcode/configuring-a-multiplatform-app-target
- https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass

Use system SwiftUI controls for the current OS appearance. No OS-26-only API
is needed; the same implementation remains available on the declared minimums.

## Verification results — September 12, 2026

- Passed 12,288 comparisons against the saved upstream calculator, plus
  literal regression, input-validation, volume-conservation, and state checks.
- Passed final Debug builds for iOS Simulator and native macOS, and Release
  for iOS, using Xcode 26.0.1 with Swift warnings treated as errors.
- Verified the Mac binary contains arm64 and x86_64, uses the macOS 26 SDK,
  and retains macOS 14 minimum deployment. The iOS binary uses the iOS 26 SDK
  and retains iOS 17 minimum deployment with both iPhone and iPad families.
- Launched the native app on macOS 26.5.2 and inspected its rendered window.
  Fixed accessibility grouping and verified each ingredient/mineral row
  exposes its own label and value.
- iPhone/iPad runtime validation could not finish: simulators remained in
  first-boot system migration, and bounded app-install attempts timed out.
  Older OS runtimes were not installed. Build/availability checks are not
  evidence of runtime testing on those systems.
- Automatic tool review blocked menu clicks and the Settings shortcut because
  their safety status could not be determined; those interactions remain
  unverified. Distribution signing and store submission were not performed.
- Project/plist validation, Fastlane Ruby syntax, and diff whitespace checks
  passed. The only build-tool warning was unused App Intents metadata extraction.

Detailed local build logs and the Mac screenshot are in `.build/validation/`.

## Custom recipes — September 12, 2026

Added the custom editor using the current Blossom Rain `CustomRecipeEditor`,
`RecipesTab`, `RecipeLibrary`, and feature checks as the UX reference. Concentrate
selection and doses are specific to empirical water; doses are stored in mL/L
and scaled by the existing volume controls. See the README's Custom recipes
section for use, persistence, keyboard behavior, and cancellation.

The saved upstream calculator reference remains unchanged. A test adapter now
executes its Custom arithmetic with independent hardness and buffer profiles.
Passed 12,288 preset and 5,184 custom recipe comparisons, plus editing, storage,
default/deletion, invalid-input, precision, and multiwindow checks.

Final iPhone/iPad Release and universal native Mac Debug builds passed with
Swift warnings treated as errors. Builds ran sequentially with `-jobs 2`;
no simulators or app UI were launched for this change. Interactive testing is
left to the user as requested. The deployment minimums remain iOS 17/macOS 14.
Final logs: `.build/validation/custom-iOS-Release-final.log` and
`.build/validation/custom-macOS-final.log`.
