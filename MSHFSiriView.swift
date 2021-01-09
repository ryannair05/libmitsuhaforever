import UIKit

final public class MSHFSiriView: MSHFView {

    private var waveLayer = MSHFJelloLayer()
    private var rWaveLayer = MSHFJelloLayer()
    private var subwaveLayer = MSHFJelloLayer()
    private var rSubwaveLayer = MSHFJelloLayer()
    private var subSubwaveLayer = MSHFJelloLayer()
    private var rSubSubwaveLayer =  MSHFJelloLayer()

    override public func initializeWaveLayers() {
        rSubSubwaveLayer.frame = bounds
        rSubwaveLayer.frame = rSubSubwaveLayer.frame
        rWaveLayer.frame = rSubwaveLayer.frame
        subSubwaveLayer.frame = rWaveLayer.frame
        subwaveLayer.frame = subSubwaveLayer.frame
        waveLayer.frame = rWaveLayer.frame

        layer.addSublayer(waveLayer)
        layer.addSublayer(rWaveLayer)
        layer.addSublayer(subwaveLayer)
        layer.addSublayer(rSubwaveLayer)
        layer.addSublayer(subSubwaveLayer)
        layer.addSublayer(rSubSubwaveLayer)

        waveLayer.zPosition = 0
        rWaveLayer.zPosition = 0
        subwaveLayer.zPosition = -1
        rSubwaveLayer.zPosition = -1
        subSubwaveLayer.zPosition = -2
        rSubSubwaveLayer.zPosition = -2

        configureDisplayLink()
        resetWaveLayers()

        waveLayer.shouldAnimate = true
        subwaveLayer.shouldAnimate = true
        subSubwaveLayer.shouldAnimate = true
        rWaveLayer.shouldAnimate = true
        rSubwaveLayer.shouldAnimate = true
        rSubSubwaveLayer.shouldAnimate = true
    }

    private func midPointForPoints(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }

    private func controlPointForPoints(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        var controlPoint = midPointForPoints(p1, p2)
        let diffY = abs(p2.y - controlPoint.y)

        if p1.y < p2.y {
            controlPoint.y += diffY
        } else if p1.y > p2.y {
            controlPoint.y -= diffY
        }

        return controlPoint
    }

    override public func resetWaveLayers() {
        let path = createPath(
            withPoints: points,
            pointCount: 0,
            in: bounds)
    
        NSLog("[libmitsuha]: Resetting Wave Layers...")
    
        waveLayer.path = path
        rWaveLayer.path = path
        subwaveLayer.path = path
        rSubwaveLayer.path = path
        subSubwaveLayer.path = path
        rSubSubwaveLayer.path = path
    }

    override public func updateWave(_ waveColor: UIColor, subwaveColor: UIColor) {
        updateWave(waveColor, subwaveColor: subwaveColor, subSubwaveColor: subwaveColor)
    }
        
    override public func updateWave(_ waveColor: UIColor, subwaveColor: UIColor, subSubwaveColor: UIColor) {
        self.waveColor = waveColor
        self.subwaveColor = subwaveColor
        self.subSubwaveColor = subSubwaveColor
        waveLayer.fillColor = waveColor.cgColor
        rWaveLayer.fillColor = waveColor.cgColor
        subwaveLayer.fillColor = subwaveColor.cgColor
        rSubwaveLayer.fillColor = subwaveColor.cgColor
        subSubwaveLayer.fillColor = subSubwaveColor.cgColor
        rSubSubwaveLayer.fillColor = subSubwaveColor.cgColor

        waveLayer.compositingFilter = "screenBlendMode"
        rWaveLayer.compositingFilter = "screenBlendMode"
        subwaveLayer.compositingFilter = "screenBlendMode"
        rSubwaveLayer.compositingFilter = "screenBlendMode"
        subSubwaveLayer.compositingFilter = "screenBlendMode"
        rSubSubwaveLayer.compositingFilter = "screenBlendMode"
    }

    override public func redraw() {
        super.redraw()

        let path = createPath(
            withPoints: points,
            pointCount: numberOfPoints,
            in: bounds)
        let scale = CATransform3DMakeScale(1, -1, 1)
        let translate = CATransform3DMakeTranslation(0, waveOffset - (bounds.size.height - waveOffset), 0)
        let transform = CATransform3DConcat(scale, translate)

        waveLayer.path = path
        rWaveLayer.path = path
        rWaveLayer.transform = transform

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            self.subwaveLayer.path = path
            self.rSubwaveLayer.path = path
            self.rSubwaveLayer.transform = transform
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.subSubwaveLayer.path = path
            self.rSubSubwaveLayer.path = path
            self.rSubSubwaveLayer.transform = transform
        })
    }

    override public func setSampleData(_ data: UnsafeMutablePointer<Float>, length: Int32) {
        super.setSampleData(data, length: length)

        points[numberOfPoints - 1].x = bounds.size.width
        points[numberOfPoints - 1].y = waveOffset
        points[0].y = points[numberOfPoints - 1].y
    }


    private func createPath(withPoints points: UnsafeMutablePointer<CGPoint>?, pointCount: Int, in rect: CGRect) -> CGPath {
        if pointCount > 0 {
            let path = UIBezierPath()
            // path.move(to: CGPoint(x: 0, y: frame.size.height))
            path.move(to: CGPoint(x: 0, y: waveOffset))

            var p1 = self.points[0]

            path.addLine(to: p1)
            for i in 0..<numberOfPoints {
                let p2 = self.points[i]
                let midPoint = midPointForPoints(p1, p2)

                path.addQuadCurve(to: midPoint, controlPoint: controlPointForPoints(midPoint, p1))
                path.addQuadCurve(to: p2, controlPoint: controlPointForPoints(midPoint, p2))

                p1 = self.points[i]
            }
            // path.addLine(to: CGPoint(x: frame.size.width,y: frame.size.height))
            path.addLine(to: CGPoint(x: frame.size.width, y: waveOffset))
            // path.addLine(to: CGPoint(x: 0, y: frame.size.height))
            path.addLine(to: CGPoint(x: 0, y: waveOffset))
            let convertedPath = path.cgPath
            return convertedPath.copy()!
        }
        else {
            let pixelFixer: CGFloat = bounds.size.width / CGFloat(numberOfPoints)

            if cachedNumberOfPoints != numberOfPoints {
                free(self.points)
                self.points = unsafeBitCast(malloc(MemoryLayout<CGPoint>.size * numberOfPoints), to: UnsafeMutablePointer<CGPoint>.self)
                cachedNumberOfPoints = numberOfPoints
                for i in 0..<numberOfPoints {
                    self.points[i].x = CGFloat(i) * pixelFixer
                    self.points[i].y = waveOffset //self.bounds.size.height/2;
                }
                self.points[numberOfPoints - 1].x = bounds.size.width
                self.points[numberOfPoints - 1].y = waveOffset
                self.points[0].y = waveOffset
            }
            return createPath(withPoints: self.points,
                                pointCount: numberOfPoints,
                                in: bounds)
        }
    }
}
