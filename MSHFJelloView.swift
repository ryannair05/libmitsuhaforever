import UIKit

final public class MSHFJelloView: MSHFView {

  private var waveLayer = MSHFJelloLayer()
  private var subwaveLayer = MSHFJelloLayer()
  private var subSubwaveLayer: MSHFJelloLayer?

  override public func initializeWaveLayers() {
    layer.sublayers = nil
    
    subwaveLayer.frame = bounds
    waveLayer.frame = subwaveLayer.frame

    layer.addSublayer(waveLayer)
    layer.addSublayer(subwaveLayer)

    waveLayer.zPosition = 0
    subwaveLayer.zPosition = -1

    if siriEnabled {
      subSubwaveLayer = MSHFJelloLayer()

      subSubwaveLayer!.frame = bounds

      layer.addSublayer(subSubwaveLayer!)

      subSubwaveLayer!.zPosition = -2
    }

    configureDisplayLink()
    resetWaveLayers()

    waveLayer.shouldAnimate = true
    subwaveLayer.shouldAnimate = true
    subSubwaveLayer?.shouldAnimate = true
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
      let path = createPath(withPoints: points, pointCount: 0, in: bounds)

      NSLog("[libmitsuha]: Resetting Wave Layers...")

      waveLayer.path = path
      subwaveLayer.path = path
      if siriEnabled {
          subSubwaveLayer!.path = path
      }
  }

  @objc override public func updateWave(_ waveColor: UIColor, subwaveColor: UIColor) {
      self.waveColor = waveColor
      self.subwaveColor = subwaveColor
      waveLayer.fillColor = waveColor.cgColor
      subwaveLayer.fillColor = subwaveColor.cgColor
  }
  
  @objc override public func updateWave(_ waveColor: UIColor, subwaveColor: UIColor, subSubwaveColor: UIColor)  {
      if subSubwaveLayer == nil {
          initializeWaveLayers()
      }

      self.waveColor = waveColor
      self.subwaveColor = subwaveColor
      self.subSubwaveColor = subSubwaveColor
      waveLayer.fillColor = waveColor.cgColor
      subwaveLayer.fillColor = subwaveColor.cgColor
      subSubwaveLayer!.fillColor = subSubwaveColor.cgColor
      waveLayer.compositingFilter = "screenBlendMode"
      subwaveLayer.compositingFilter = "screenBlendMode"
      subSubwaveLayer!.compositingFilter = "screenBlendMode"
  }

  override public func redraw() {
    super.redraw()

    let path = createPath(withPoints: points, pointCount: numberOfPoints, in: bounds)
    waveLayer.path = path

    DispatchQueue.main.asyncAfter(
        deadline: .now() + 0.25,
        execute: {
            self.subwaveLayer.path = path
      })
    if siriEnabled {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.50,
          execute: {
              self.subSubwaveLayer?.path = path
        })
    }
  }

  override public func setSampleData(_ data: UnsafeMutablePointer<Float>?, length: Int32) {
    super.setSampleData(data, length: length)

    points[numberOfPoints - 1].x = bounds.size.width
    points[numberOfPoints - 1].y = waveOffset
    points[0].y = points[numberOfPoints - 1].y
  }

  private func createPath(withPoints points: UnsafeMutablePointer<CGPoint>?, pointCount: Int, in rect: CGRect) -> CGPath {
    if pointCount > 0 {
      let path = UIBezierPath()
      path.move(to: CGPoint(x: 0, y: frame.size.height))

      var p1 = self.points[0]

      path.addLine(to: p1)

      for i in 0..<numberOfPoints {
          let p2 = self.points[i]
          let midPoint = midPointForPoints(p1, p2)

          path.addQuadCurve(to: midPoint, controlPoint: controlPointForPoints(midPoint, p1))
          path.addQuadCurve(to: p2, controlPoint: controlPointForPoints(midPoint, p2))

          p1 = self.points[i]
      }

      path.addLine(to: CGPoint(x: frame.size.width, y: frame.size.height))
      path.addLine(to: CGPoint(x: 0, y: frame.size.height))

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
