import SwiftUI
import Combine

@MainActor
public class AppState: ObservableObject {
    @Published public var frameData: VisualFrameData = VisualFrameData()
    
    // User Preferences (Persisted)
    @AppStorage("isAmbientLightingEnabled") public var isAmbientLightingEnabled: Bool = true
    @AppStorage("intensity") public var intensity: Double = 50.0
    @AppStorage("blurRadius") public var blurRadius: Double = 20.0
    @AppStorage("lightingMode") public var lightingMode: LightingMode = .audioSync
    @AppStorage("launchAtLogin") public var launchAtLogin: Bool = false
    @AppStorage("pauseOnBattery") public var pauseOnBattery: Bool = false
    
    public enum LightingMode: String, CaseIterable, Identifiable {
        case staticColor = "Static"
        case breathing = "Breathing"
        case audioSync = "Audio Sync"
        case screenSync = "Screen Sync"
        
        public var id: String { self.rawValue }
    }
    
    public init() {}
    
    public func updateFrameData(_ newData: VisualFrameData) {
        self.frameData = newData
    }
}
