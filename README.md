# Simple QR

Simple QR is a small native macOS app for generating QR codes from text or links. Everything is processed locally: entered content is not uploaded anywhere.

## Features

- Live QR code preview
- PNG export
- Medium (`M`) error correction
- Native SwiftUI interface
- No third-party dependencies or network access

## Requirements

- macOS 14 or later
- Xcode 26.6 or later

## Run the app

1. Clone the repository.
2. Open `Simple QR.xcodeproj` in Xcode.
3. Select the **Simple QR** scheme and **My Mac** destination.
4. Press **⌘R**.

Enter text or a URL, check the preview, and click **Save as PNG…** (or press **⌘S**) to export the QR code.

## Build from the command line

```sh
xcodebuild \
  -project "Simple QR.xcodeproj" \
  -scheme "Simple QR" \
  -configuration Release \
  -destination "platform=macOS" \
  build
```

If `xcodebuild` points to Command Line Tools instead of Xcode, switch the active developer directory first:

```sh
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

## Privacy

The application works offline and has no incoming or outgoing network entitlement. It only requests access to a location selected explicitly in the system save dialog.

## Tech stack

- Swift
- SwiftUI and AppKit
- Core Image (`CIQRCodeGenerator`)

## License

No license has been added yet. Until one is provided, all rights are reserved by the repository owner.
