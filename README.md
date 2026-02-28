# MindBloom — Apple Swift Student Challenge

MindBloom is an iOS mood-tracking app built with SwiftUI for the Apple Swift Student Challenge. It lets you log your daily mood, grow a visual flower garden that reflects your emotional journey, and practice box-breathing exercises.

## Platform Requirements

| Requirement | Details |
|---|---|
| **Operating System** | macOS 13 (Ventura) or later |
| **IDE** | Xcode 15 or later |
| **Target Device** | iPhone or iPad running iOS 17+, or the Xcode iOS Simulator |
| **Swift** | Swift 5.9+ (included with Xcode 15) |

## ⚠️ Windows is Not Supported

This project **cannot be run on Windows**. MindBloom is built with [SwiftUI](https://developer.apple.com/xcode/swiftui/), Apple's UI framework, which is only available on Apple platforms (iOS, macOS, watchOS, tvOS). Additionally, Xcode — the required IDE — is exclusive to macOS.

There is no workaround that allows running a SwiftUI iOS app natively on Windows.

## How to Run (macOS only)

1. **Install Xcode** from the [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835) or [Apple Developer Downloads](https://developer.apple.com/download/). Xcode 15 or later is required.

2. **Clone the repository:**
   ```bash
   git clone https://github.com/YENIGALLADHEERAJ/Apple-Swift-Student-Challenge.git
   cd Apple-Swift-Student-Challenge
   ```

3. **Open in Xcode:**
   - Double-click `Package.swift` in Finder, **or**
   - Run `open Package.swift` in Terminal, **or**
   - In Xcode, choose **File → Open** and select the `Package.swift` file.

4. **Choose a simulator or device:**
   - In the Xcode toolbar, select an **iPhone simulator** (e.g. iPhone 15, iOS 17) from the scheme/device picker.
   - Alternatively, connect a physical iPhone or iPad running iOS 17+ and select it as the run destination.

5. **Build and run:**
   - Press **⌘R** or click the **▶ Run** button in the Xcode toolbar.
   - The app will compile and launch in the selected simulator or on your device.

## Features

- 🌸 **Garden** — A living mood garden where each daily check-in plants a flower whose color and size reflect your mood.
- ✅ **Check In** — Log your mood level, select wellness factors (sleep, exercise, etc.), and add an optional note.
- 💨 **Breathe** — Guided 4-4-6-2 box-breathing exercise with an animated orb.
