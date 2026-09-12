This optional Fastlane configuration builds and distributes the iOS app.
Run these lanes from the `Darwin` directory with Fastlane installed and
your Apple signing credentials configured:

1. Update the metadata text files in metadata/en-US/
2. Add screenshots to screenshots/en-US
3. Download your App Store Connect API JSON file to apikey.json
4. Run `fastlane assemble` to build the app
5. Run `fastlane release` to submit a new release to the App Store

App identity, version numbers, and platform settings live in
`../empiricalwater.xcconfig`. Set a new version/build before submitting a
release. `AppStore.xcconfig` can supply distribution-specific overrides.
The native Mac app builds from the same Xcode project; these lanes only
submit the iOS release.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
