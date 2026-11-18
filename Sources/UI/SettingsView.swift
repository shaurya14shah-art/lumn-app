import SwiftUI

public struct SettingsView: View {
    @ObservedObject var appState: AppState
    
    public init(appState: AppState) {
        self.appState = appState
    }
    
    public var body: some View {
        TabView {
            GeneralSettingsView(appState: appState)
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
            
            LightingSettingsView(appState: appState)
                .tabItem {
                    Label("Lighting", systemImage: "lightbulb.2")
                }
                
            DisplaysSettingsView()
                .tabItem {
                    Label("Displays", systemImage: "display")
                }
        }
        .frame(width: 450, height: 350)
    }
}

struct GeneralSettingsView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        Form {
            Section(header: Text("Startup")) {
                Toggle("Launch Lumn at login", isOn: $appState.launchAtLogin)
            }
            
            Section(header: Text("Performance / Battery")) {
                Toggle("Pause effect on battery power", isOn: $appState.pauseOnBattery)
            }
        }
        .padding()
    }
}

struct LightingSettingsView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        Form {
            Section(header: Text("Effect Options")) {
                Picker("Mode", selection: $appState.lightingMode) {
                    ForEach(AppState.LightingMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            Section(header: Text("Appearance")) {
                VStack(alignment: .leading) {
                    Text("Intensity: \(Int(appState.intensity))%")
                    Slider(value: $appState.intensity, in: 0...100)
                }
                
                VStack(alignment: .leading) {
                    Text("Blur Radius: \(Int(appState.blurRadius))")
                    Slider(value: $appState.blurRadius, in: 0...100)
                }
            }
        }
        .padding()
    }
}

struct DisplaysSettingsView: View {
    var body: some View {
        VStack {
            Text("Display configurations will go here.")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
