import Foundation

internal protocol MSHFAudioProcessingDelegate : class {
    func setSampleData(_ data: UnsafeMutablePointer<Float>?, length: Int32)
}