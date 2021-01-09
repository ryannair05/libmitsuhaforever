import UIKit

final public class MSHFLineView: MSHFView {

    internal var lineThickness: CGFloat = 5.0 {
        didSet(thickness) {
            waveLayer.lineWidth = thickness
            subwaveLayer?.lineWidth = thickness
            subSubwaveLayer?.lineWidth = thickness
        }
    }
    private var waveLayer =  MSHFJelloLayer()
    private var subwaveLayer: MSHFJelloLayer?
    private var subSubwaveLayer: MSHFJelloLayer?

    override public func initializeWaveLayers() {
        layer.sublayers = nil

        waveLayer.frame = bounds

        ({ self.lineThickness = lineThickness })()

        layer.addSublayer(waveLayer)

        waveLayer.zPosition = 0
        waveLayer.lineWidth = 5
        waveLayer.fillColor = UIColor.clear.cgColor

        if siriEnabled {
            subwaveLayer = MSHFJelloLayer()
            subSubwaveLayer = MSHFJelloLayer()

            subSubwaveLayer!.frame = waveLayer.frame
            subwaveLayer!.frame = subSubwaveLayer!.frame

            layer.addSublayer(subwaveLayer!)
            layer.addSublayer(subSubwaveLayer!)

            subwaveLayer!.zPosition = -1
            subSubwaveLayer!.zPosition = -2
            subwaveLayer!.lineWidth = 5
            subSubwaveLayer!.lineWidth = 5
            subwaveLayer!.fillColor = UIColor.clear.cgColor
            subSubwaveLayer!.fillColor = UIColor.clear.cgColor
        }

        configureDisplayLink()
        resetWaveLayers()

        waveLayer.shouldAnimate = true
        subwaveLayer?.shouldAnimate = true
        subSubwaveLayer?.shouldAnimate = true
    }

    override public func resetWaveLayers() {
        let path = createPath(
            withPoints: points,
            pointCount: 0,
            in: bounds)

        NSLog("[libmitsuha]: Resetting Wave Layers...")

        waveLayer.path = path
        if siriEnabled {
            subwaveLayer!.path = path
            subSubwaveLayer!.path = path
        }
    }

    @objc override public func updateWave(_ waveColor: UIColor, subwaveColor: UIColor) {
        self.waveColor = waveColor
        self.subwaveColor = subwaveColor
        self.waveLayer.strokeColor = waveColor.cgColor
    }

    @objc override public func updateWave(_ waveColor: UIColor, subwaveColor: UIColor, subSubwaveColor: UIColor) {
        if subwaveLayer == nil || subSubwaveLayer == nil {
            initializeWaveLayers()
        }
        self.waveColor = waveColor
        self.subwaveColor = subwaveColor
        self.subSubwaveColor = subSubwaveColor
        waveLayer.strokeColor = waveColor.cgColor
        subwaveLayer!.strokeColor = subwaveColor.cgColor
        subSubwaveLayer!.strokeColor = subSubwaveColor.cgColor
        waveLayer.compositingFilter = "screenBlendMode"
        subwaveLayer!.compositingFilter = "screenBlendMode"
        subSubwaveLayer!.compositingFilter = "screenBlendMode"
    }

    override public func redraw() {
        super.redraw()

        let path = createPath(withPoints: points,pointCount: numberOfPoints, in: bounds)
        waveLayer.path = path

        if siriEnabled {
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.25,
                execute: {
                    self.subwaveLayer?.path = path
            })
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.5,
                execute: {
                    self.subSubwaveLayer?.path = path
            })
        }
    }

    override public func setSampleData(_ data: UnsafeMutablePointer<Float>!, length: Int32) {
        super.setSampleData(data, length: length)

        points[numberOfPoints - 1].x = bounds.size.width
        points[numberOfPoints - 1].y = waveOffset
        points[0].y = points[numberOfPoints - 1].y
    }
    
    private func createPath(withPoints points: UnsafeMutablePointer<CGPoint>?, pointCount: Int, in rect: CGRect) -> CGPath {
        if pointCount > 0 {
            let path = UIBezierPath()

            path.move(to: self.points[0])

            for i in 0..<numberOfPoints {
                path.addLine(to: self.points[i])
            }

            let convertedPath = path.cgPath

            return convertedPath.copy()!
        } else {
            let pixelFixer: CGFloat = bounds.size.width / CGFloat(numberOfPoints)

            if cachedNumberOfPoints != numberOfPoints {
                free(self.points)
                self.points = unsafeBitCast(malloc(MemoryLayout<CGPoint>.size * numberOfPoints), to: UnsafeMutablePointer<CGPoint>.self)
                cachedNumberOfPoints = numberOfPoints

                for i in 0..<numberOfPoints {
                    self.points[i].x = CGFloat(i) * pixelFixer
                    self.points[i].y = waveOffset // self.bounds.size.height/2;
                }

                self.points[numberOfPoints - 1].x = bounds.size.width
                self.points[numberOfPoints - 1].y = waveOffset
                self.points[0].y = self.points[numberOfPoints - 1].y // self.bounds.size.height/2;
            }
            return createPath(withPoints: self.points, pointCount: numberOfPoints,in: bounds)
        }
    }
}
