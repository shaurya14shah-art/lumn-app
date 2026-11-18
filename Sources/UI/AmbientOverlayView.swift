import SwiftUI

public struct AmbientOverlayView: View {
    @ObservedObject public var state: AppState
    
    public init(state: AppState) {
        self.state = state
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                if state.isAmbientLightingEnabled {
                    let data = state.frameData
                    
                    // Factor in UI intensity (0-100)
                    let intensityFactor = state.intensity / 100.0
                    
                    // Default to faint cyan/blue if no audio
                    let r = max(data.red, 0.05)
                    let g = max(data.green, 0.2)
                    let b = max(data.blue, 0.3)
                    let baseColor = Color(red: r, green: g, blue: b)
                    
                    // Ensure minimum opacity so it doesn't disappear
                    let audioBrightness = max(data.brightness, 0.3)
                    let opacity = min(audioBrightness * 2.0, 1.0) * intensityFactor
                    let glowColor = baseColor.opacity(opacity)
                    
                    let thickness: CGFloat = 150
                    
                    // Top Edge
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [glowColor, Color.clear]), startPoint: .top, endPoint: .bottom))
                        .frame(height: thickness)
                        .position(x: geometry.size.width / 2, y: thickness / 2)
                    
                    // Bottom Edge
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [glowColor, Color.clear]), startPoint: .bottom, endPoint: .top))
                        .frame(height: thickness)
                        .position(x: geometry.size.width / 2, y: geometry.size.height - thickness / 2)
                    
                    // Left Edge
                    let leftOpacity = min(max(data.red * 2.0, 0.3), 1.0) * intensityFactor
                    let leftColor = baseColor.opacity(leftOpacity)
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [leftColor, Color.clear]), startPoint: .leading, endPoint: .trailing))
                        .frame(width: thickness)
                        .position(x: thickness / 2, y: geometry.size.height / 2)
                    
                    // Right Edge
                    let rightOpacity = min(max(data.blue * 2.0, 0.3), 1.0) * intensityFactor
                    let rightColor = baseColor.opacity(rightOpacity)
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [rightColor, Color.clear]), startPoint: .trailing, endPoint: .leading))
                        .frame(width: thickness)
                        .position(x: geometry.size.width - thickness / 2, y: geometry.size.height / 2)
                }
            }
            .blur(radius: CGFloat(state.blurRadius))
            .ignoresSafeArea()
        }
        .allowsHitTesting(false)
        .background(Color.clear)
    }
}
