import Foundation
import CoreGraphics

public struct VisualFrameData {
    /// Normalized value for the red channel (Bass frequencies)
    public var red: Double
    /// Normalized value for the green channel (Mid frequencies)
    public var green: Double
    /// Normalized value for the blue channel (Treble frequencies)
    public var blue: Double
    
    /// Global intensity / amplitude of the audio
    public var brightness: Double
    
    public init(red: Double = 0, green: Double = 0, blue: Double = 0, brightness: Double = 0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.brightness = brightness
    }
}
