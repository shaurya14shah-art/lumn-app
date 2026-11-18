# Lumn

Lumn is a native macOS ambient lighting application that reacts to your system audio and screen contents. It creates a subtle, dynamic glow on the edges of your screen, bringing your audio-visual experience to life.

## Features

- **System Audio Reactive:** Uses **ScreenCaptureKit** to efficiently capture system audio and translate it into dynamic ambient lighting effects.
- **Native macOS Experience:** Built entirely with **SwiftUI** for a smooth, native UI that integrates seamlessly with macOS.
- **Menu Bar Extra:** A lightweight, quickly accessible popover from the menu bar to toggle effects, adjust intensity, and change base colors on the fly.
- **Advanced Settings Window:** Manage display-specific configurations, adjust performance settings (e.g., pause on battery), and fine-tune effect parameters like opacity, blur radius, and color palettes.
- **Efficient Performance:** Leverages the modern `ScreenCaptureKit` API to ensure low CPU/GPU overhead while capturing audio and visualizing it.

## Architecture

Lumn is structured around modern macOS development best practices:

- **UI & Lifecycle (`SwiftUI`):** Utilizes `MenuBarExtra` for the status bar popover and a standard `Settings` scene for comprehensive preferences, conforming to the macOS Human Interface Guidelines.
- **Audio & Screen Capture (`ScreenCaptureKit`):** Uses SCK via `AudioCaptureEngine` to obtain real-time audio sample data.
- **State Management:** Reactive data flow driven by `@AppStorage` and `@Observable` / Combine to synchronize changes instantly across the menu bar popover, settings window, and the ambient overlay windows.
- **Window Management:** Custom borderless overlays (`WindowManager`) render the glowing effects directly over the screen edges without interfering with user interaction.

## Requirements

- **macOS:** 13.0 (Ventura) or newer (required for the advanced ScreenCaptureKit APIs)
- **Swift:** 6.0+
- **Xcode:** 16+ (or Swift Package Manager)

## Build and Run

Lumn uses the Swift Package Manager for dependency and target management.

### Using the Terminal

1. Clone or download this repository.
2. Navigate to the project directory:
   ```bash
   cd LumnApp
   ```
3. Build the executable:
   ```bash
   swift build
   ```
4. Run the application:
   ```bash
   swift run
   ```

*Note: Since the app utilizes `ScreenCaptureKit`, macOS may prompt you for Screen Recording permissions upon the first launch.*

### Using Xcode

1. Open Xcode and select **File > Open**.
2. Select the `LumnApp` folder (which contains the `Package.swift` file).
3. Select your local Mac as the target destination.
4. Hit **Run** (`Cmd + R`).

## Permissions

For Lumn to function correctly, it requires the **Screen Recording** permission. This allows `ScreenCaptureKit` to capture system audio and screen content.
- Go to **System Settings > Privacy & Security > Screen Recording**.
- Toggle on the switch for **Lumn**.
