import Foundation

@objc (MSHFAudioProcessingDelegate) public protocol MSHFAudioProcessingDelegate: NSObjectProtocol {
    func setSampleData(_ data: UnsafeMutablePointer<Float>?, length: Int32)
}