import SwiftUI
import AppKit
import Combine

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var cancellable: AnyCancellable?
    let audioEngine = AudioCaptureEngine()
    let windowManager = WindowManager.shared
    let state = AppState()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        cancellable = audioEngine.visualDataPublisher
            .sink { [weak self] data in
                self?.state.updateFrameData(data)
            }
            
        windowManager.start(with: state)
        
        Task {
            do {
                try await audioEngine.startCapture()
            } catch {
                print("Failed to start capture: \(error)")
            }
        }
    }
}

@main
struct LumnApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        MenuBarExtra("Lumn", systemImage: delegate.state.isAmbientLightingEnabled ? "lightbulb.fill" : "sun.max.circle") {
            MenuBarView(appState: delegate.state)
        }
        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsView(appState: delegate.state)
        }
    }
}
