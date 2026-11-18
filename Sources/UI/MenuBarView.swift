import SwiftUI

public struct MenuBarView: View {
    @ObservedObject var appState: AppState
    
    public init(appState: AppState) {
        self.appState = appState
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Lumn")
                    .font(.headline)
                Spacer()
                Text(appState.isAmbientLightingEnabled ? "Active" : "Paused")
                    .foregroundColor(appState.isAmbientLightingEnabled ? .green : .secondary)
                    .font(.subheadline)
            }
            .padding(.bottom, 5)
            
            Toggle("Enable Ambient Lighting", isOn: $appState.isAmbientLightingEnabled)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Intensity")
                HStack {
                    Image(systemName: "sun.min")
                    Slider(value: $appState.intensity, in: 0...100)
                    Image(systemName: "sun.max")
                }
            }
            
            Picker("Mode", selection: $appState.lightingMode) {
                ForEach(AppState.LightingMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Divider()
            
            if #available(macOS 14.0, *) {
                SettingsLink {
                    Text("Preferences...")
                }
                .keyboardShortcut(",", modifiers: .command)
            } else {
                Button("Preferences...") {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
            
            Button("Quit Lumn") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
        .padding()
        .frame(width: 350)
    }
}
