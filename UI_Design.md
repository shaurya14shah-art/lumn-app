# Lumn - UI Component Breakdown

**App Concept**: A macOS ambient lighting app (Lumn) providing a subtle glow or effect on the screen edges or reacting to screen contents.

## 1. Menu Bar Extra (Status Bar Item)
The Menu Bar Extra provides a lightweight, easily accessible popover for the user to control the most critical functions of Lumn without opening the full settings application.

### Trigger Icon
- **SF Symbol**: `sun.max.circle` or `lightbulb.fill`
- **Behavior**: Appears standard (monochrome) when the effect is OFF, and tinted or highlighted when the effect is ON.

### Popover Layout (VStack)
A compact layout using SwiftUI `VStack` and `LabeledContent` or a small `Form` to maintain native macOS alignments.

* **Header**
  * `Text`: "Lumn" (Font: Headline)
  * `Text`: Status indicator (e.g., "Active" or "Paused")
* **Main Controls**
  * `Toggle`: "Enable Ambient Lighting" (Master switch)
* **Divider** (`Divider()`)
* **Lighting Adjustments**
  * `Slider`: "Intensity" (0 to 100). Flanked by `sun.min` and `sun.max` SF Symbols.
  * `ColorPicker`: "Base Color" (Allows quick selection of the ambient color).
  * `Picker` (Segmented Style): "Mode" (e.g., 'Static', 'Dynamic', 'Screen Sync').
* **Divider** (`Divider()`)
* **System Controls**
  * `Button`: "Preferences..." (Keyboard shortcut: `Cmd + ,`). Opens the Settings Window.
  * `Button`: "Quit Lumn" (Keyboard shortcut: `Cmd + Q`).

---

## 2. Settings Window
The Settings window is a standard macOS Settings scene. It uses a `TabView` to organize preferences logically, adhering to macOS Human Interface Guidelines.

### Window Setup
- **Style**: Standard macOS Settings Window.
- **Tabs**: General, Lighting, Advanced.

### Tab 1: General (`gearshape`)
Uses a SwiftUI `Form` to handle standard application settings.

* **Startup**
  * `Toggle`: "Launch Lumn at login"
* **Menu Bar**
  * `Toggle`: "Show icon in menu bar" (Requires an alternative way to open Settings if disabled, typically reopening the app).
* **Performance / Battery**
  * `Toggle`: "Pause effect on battery power" (To save energy on MacBooks).
  * `Toggle`: "Pause during full-screen apps" (To prevent distraction or performance hits during gaming/movies).

### Tab 2: Lighting (`lightbulb.2`)
Focuses on the visual aspects of the ambient lighting.

* **Effect Type (`Picker` - Menu Style)**
  * Options: `Static Color`, `Breathing`, `Screen Sync` (samples screen edges).
* **Color Settings (Conditional based on Effect Type)**
  * *If Static/Breathing*: `ColorPicker` for "Primary Color" and `ColorPicker` for "Secondary Color" (if gradient/breathing).
  * *If Screen Sync*: `Slider` for "Saturation Boost".
* **Effect Appearance**
  * `Slider`: "Intensity / Opacity" (0% - 100%)
  * `Slider`: "Spread / Blur Radius" (Controls how far into the screen the ambient glow reaches).

### Tab 3: Displays (`display`)
Manages behavior across multiple monitors.

* **Display List**
  * A `List` or `ForEach` showing connected displays.
  * Each row contains a `Toggle` to enable/disable the Lumn effect on that specific display.

---

## Technical Considerations (SwiftUI Implementation)
- **Menu Bar Extra**: Use `MenuBarExtra("Lumn", systemImage: "lightbulb.fill")` with `.menuBarExtraStyle(.window)` to allow a rich custom popover UI instead of a standard menu.
- **Settings**: Use `Settings { TabView { ... } }` in the App structure.
- **Controls**: Exclusively use native SwiftUI components (`Toggle`, `Slider`, `ColorPicker`, `Picker`, `Button`) to ensure standard macOS appearance, hover effects, and accessibility (VoiceOver support).
- **State Management**: Bind controls directly to `@AppStorage` for persistent, immediate effect updates without needing a complex database.
