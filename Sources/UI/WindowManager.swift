import AppKit
import SwiftUI

@MainActor
public class WindowManager: ObservableObject {
    public static let shared = WindowManager()
    
    private var overlayPanels: [CGDirectDisplayID: NSPanel] = [:]
    
    public init() {}
    
    public func start(with state: AppState) {
        for screen in NSScreen.screens {
            guard let displayID = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID else {
                continue
            }
            
            if overlayPanels[displayID] == nil {
                let panel = createOverlayPanel(for: screen)
                let overlayView = AmbientOverlayView(state: state)
                let hostingView = NSHostingView(rootView: overlayView)
                
                // Ensure the hosting view is transparent
                hostingView.wantsLayer = true
                hostingView.layer?.backgroundColor = NSColor.clear.cgColor
                
                panel.contentView = hostingView
                overlayPanels[displayID] = panel
                
                panel.orderFront(nil)
            }
        }
    }
    
    private func createOverlayPanel(for screen: NSScreen) -> NSPanel {
        let panel = NSPanel(
            contentRect: screen.frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.ignoresMouseEvents = true
        panel.level = .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        
        // Size the panel to cover the full screen
        panel.setFrame(screen.frame, display: true)
        
        return panel
    }
    
    public func destroyOverlays() {
        for panel in overlayPanels.values {
            panel.close()
        }
        overlayPanels.removeAll()
    }
}
