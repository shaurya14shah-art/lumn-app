import Foundation
import ScreenCaptureKit
import AVFoundation
import Combine

public class AudioCaptureEngine: NSObject, SCStreamOutput, SCStreamDelegate {
    
    private var stream: SCStream?
    private let analyzer = AudioAnalyzer()
    
    // Publishers to stream analyzed data
    public let visualDataPublisher = PassthroughSubject<VisualFrameData, Never>()
    
    private let captureQueue = DispatchQueue(label: "com.lumn.AudioCaptureQueue")
    
    public override init() {
        super.init()
    }
    
    public func startCapture() async throws {
        let availableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
        
        guard let display = availableContent.displays.first else {
            throw AudioCaptureError.noDisplaysFound
        }
        
        let filter = SCContentFilter(display: display, excludingApplications: [], exceptingWindows: [])
        
        let config = SCStreamConfiguration()
        config.capturesAudio = true
        config.excludesCurrentProcessAudio = true // Exclude our own app's audio
        
        stream = SCStream(filter: filter, configuration: config, delegate: self)
        try stream?.addStreamOutput(self, type: .audio, sampleHandlerQueue: captureQueue)
        
        try await stream?.startCapture()
    }
    
    public func stopCapture() async throws {
        try stream?.removeStreamOutput(self, type: .audio)
        try await stream?.stopCapture()
        stream = nil
    }
    
    // MARK: - SCStreamOutput
    
    public func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .audio else { return }
        
        // Ensure the sample buffer contains audio data
        guard sampleBuffer.formatDescription?.mediaType == .audio else { return }
        
        if let pcmBuffer = AVAudioPCMBuffer(cmSampleBuffer: sampleBuffer) {
            if let visualData = analyzer.analyze(buffer: pcmBuffer) {
                // Dispatch to main thread for UI updates
                DispatchQueue.main.async {
                    self.visualDataPublisher.send(visualData)
                }
            }
        }
    }
    
    // MARK: - SCStreamDelegate
    
    public func stream(_ stream: SCStream, didStopWithError error: Error) {
        print("Stream stopped with error: \(error)")
    }
}

public enum AudioCaptureError: Error {
    case noDisplaysFound
}

// Extension to convert CMSampleBuffer to AVAudioPCMBuffer
extension AVAudioPCMBuffer {
    convenience init?(cmSampleBuffer: CMSampleBuffer) {
        guard let formatDescription = cmSampleBuffer.formatDescription,
              var streamBasicDescription = formatDescription.audioStreamBasicDescription else {
            return nil
        }
        guard let format = AVAudioFormat(streamDescription: &streamBasicDescription) else {
            return nil
        }
        
        let frameCount = AVAudioFrameCount(cmSampleBuffer.numSamples)
        
        // If there's no frames, we can't create a buffer
        guard frameCount > 0 else {
            return nil
        }
        
        self.init(pcmFormat: format, frameCapacity: frameCount)
        self.frameLength = frameCount
        
        let status = CMSampleBufferCopyPCMDataIntoAudioBufferList(
            cmSampleBuffer,
            at: 0,
            frameCount: Int32(frameCount),
            into: self.mutableAudioBufferList
        )
        
        if status != noErr {
            return nil
        }
    }
}
