import Accelerate

@objc final internal class MSHFAudioProcessing : NSObject {

    private var bufferLog2 : UInt = 0
    private var fftSetup: FFTSetup!
    private var window: [Float] = [Float](repeating: 0.0, count: 0)
    private var numberOfFrames: UInt = 0
    private var fftNormFactor: Float = 0.0
    private var numberOfFramesOver2 : UInt = 0
    @objc internal var fft : Bool = false
    private var output: COMPLEX_SPLIT!
    private var out: UnsafeMutablePointer<Float>!
    internal var delegate: MSHFAudioProcessingDelegate?

    internal init(bufferSize: UInt) {
        numberOfFrames = bufferSize
        numberOfFramesOver2 = numberOfFrames / 2
        fftNormFactor = -1.0 / 256.0

        let outReal = unsafeBitCast(malloc(MemoryLayout<Float>.size * Int(numberOfFramesOver2)), to: UnsafeMutablePointer<Float>.self)
        let outImaginary = unsafeBitCast(malloc(MemoryLayout<Float>.size * Int(numberOfFramesOver2)), to: UnsafeMutablePointer<Float>.self)
        out = unsafeBitCast(malloc(MemoryLayout<Float>.size * Int(numberOfFramesOver2)), to: UnsafeMutablePointer<Float>.self)
        output = COMPLEX_SPLIT(realp: outReal, imagp: outImaginary)

        bufferLog2 = UInt(round(log2(Double(numberOfFrames))))
        fftSetup = vDSP_create_fftsetup(bufferLog2, FFTRadix(kFFTRadix2))
        window = [Float](repeating: 0.0, count: Int(numberOfFrames))

        vDSP_hann_window(&window, numberOfFrames, Int32(vDSP_HANN_NORM))
    }

    internal func process(_ data: UnsafeMutablePointer<Float>, withLength length: Int) {
        if delegate == nil {
            return
        }
        if fft && length == Int(numberOfFrames) {
            vDSP_vmul(data, 1, window, 1, data, 1, numberOfFrames)
            data.withMemoryRebound(to: DSPComplex.self, capacity: Int(numberOfFramesOver2)) { (dataPointer) -> Void in
                vDSP_ctoz(dataPointer, 2, &output, 1, numberOfFramesOver2)
            }
            vDSP_fft_zrip(fftSetup, &output, 1, bufferLog2, FFTDirection(FFT_FORWARD))
            vDSP_zvabs(&output, 1, out, 1, numberOfFramesOver2)
            vDSP_vsmul(out, 1, &fftNormFactor, out, 1, numberOfFramesOver2)
            delegate!.setSampleData(out, length: Int(numberOfFramesOver2) / 8)
        } else {
            delegate!.setSampleData(data, length: length)
        }
    }
}