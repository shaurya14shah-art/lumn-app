import Foundation
import Accelerate
import AVFoundation

public class AudioAnalyzer {
    // FFT parameters
    private let fftSize: Int = 2048
    private let log2n: vDSP_Length
    private let setup: vDSP.FFT<DSPSplitComplex>
    
    private var sampleBuffer = [Float]()
    
    public init() {
        self.log2n = vDSP_Length(log2(Float(fftSize)))
        
        guard let setup = vDSP.FFT(log2n: log2n, radix: .radix2, ofType: DSPSplitComplex.self) else {
            fatalError("Failed to create vDSP FFT setup")
        }
        self.setup = setup
    }
    
    public func analyze(buffer: AVAudioPCMBuffer) -> VisualFrameData? {
        guard let channelData = buffer.floatChannelData?[0] else {
            return nil
        }
        
        let frameLength = Int(buffer.frameLength)
        let newSamples = UnsafeBufferPointer(start: channelData, count: frameLength)
        sampleBuffer.append(contentsOf: newSamples)
        
        // Prevent buffer from growing unbounded if analysis is paused or slow
        if sampleBuffer.count > fftSize * 4 {
            sampleBuffer.removeFirst(sampleBuffer.count - fftSize * 2)
        }
        
        guard sampleBuffer.count >= fftSize else {
            return nil // Need more samples
        }
        
        // Extract the oldest fftSize samples for processing
        var input = Array(sampleBuffer.prefix(fftSize))
        
        // Advance the buffer by frameLength (sliding window)
        // Ensure we don't remove more than we have
        let advanceCount = min(sampleBuffer.count, frameLength)
        sampleBuffer.removeFirst(advanceCount)
        
        // Apply Hann window
        var window = [Float](repeating: 0, count: fftSize)
        vDSP_hann_window(&window, vDSP_Length(fftSize), Int32(vDSP_HALF_WINDOW))
        vDSP_vmul(input, 1, window, 1, &input, 1, vDSP_Length(fftSize))
        
        // Perform FFT
        var real = [Float](repeating: 0.0, count: fftSize / 2)
        var imag = [Float](repeating: 0.0, count: fftSize / 2)
        
        var magnitudes = [Float](repeating: 0.0, count: fftSize / 2)
        
        real.withUnsafeMutableBufferPointer { realPtr in
            imag.withUnsafeMutableBufferPointer { imagPtr in
                var splitComplex = DSPSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)
                
                input.withUnsafeBytes { ptr in
                    let floatPtr = ptr.bindMemory(to: Float.self).baseAddress!
                    floatPtr.withMemoryRebound(to: DSPComplex.self, capacity: fftSize / 2) { complexPtr in
                        vDSP_ctoz(complexPtr, 2, &splitComplex, 1, vDSP_Length(fftSize / 2))
                    }
                }
                
                setup.forward(input: splitComplex, output: &splitComplex)
                
                // Calculate magnitudes
                vDSP_zvabs(&splitComplex, 1, &magnitudes, 1, vDSP_Length(fftSize / 2))
            }
        }
        
        // Normalize magnitudes
        var normalizedMagnitudes = [Float](repeating: 0.0, count: fftSize / 2)
        var scalingFactor = Float(2.0 / Float(fftSize))
        vDSP_vsmul(magnitudes, 1, &scalingFactor, &normalizedMagnitudes, 1, vDSP_Length(fftSize / 2))
        
        let sampleRate = Float(buffer.format.sampleRate)
        let binWidth = sampleRate / Float(fftSize)
        
        // Frequency bands mapping (Bass: 20-250Hz, Mid: 250-4000Hz, Treble: 4000-20000Hz)
        var bassSum: Float = 0
        var midSum: Float = 0
        var trebleSum: Float = 0
        
        var bassCount: Float = 0
        var midCount: Float = 0
        var trebleCount: Float = 0
        
        for i in 0..<(fftSize / 2) {
            let freq = Float(i) * binWidth
            let mag = normalizedMagnitudes[i]
            
            if freq >= 20 && freq < 250 {
                bassSum += mag
                bassCount += 1
            } else if freq >= 250 && freq < 4000 {
                midSum += mag
                midCount += 1
            } else if freq >= 4000 && freq < 20000 {
                trebleSum += mag
                trebleCount += 1
            }
        }
        
        let bassAvg = bassCount > 0 ? (bassSum / bassCount) : 0
        let midAvg = midCount > 0 ? (midSum / midCount) : 0
        let trebleAvg = trebleCount > 0 ? (trebleSum / trebleCount) : 0
        
        // Map to 0-1 scale (arbitrary multiplier based on typical volume levels, can be tuned)
        let sensitivity: Float = 50.0
        
        let r = min(1.0, Double(bassAvg * sensitivity))
        let g = min(1.0, Double(midAvg * sensitivity))
        let b = min(1.0, Double(trebleAvg * sensitivity))
        
        let brightness = max(r, max(g, b))
        
        return VisualFrameData(red: r, green: g, blue: b, brightness: brightness)
    }
}
