import UIKit

@objc (MSHFDotView) final public class MSHFDotView: MSHFView {

  internal var barSpacing: CGFloat = 5
  private var redDots: CALayer?
  private var greenDots: CALayer?
  private var blueDots: CALayer?
  private var cachedNumberOfPoints = 0

  override internal func initializeWaveLayers() {
    if siriEnabled {
        redDots = CALayer()
        greenDots = CALayer()
        blueDots = CALayer()

        layer.addSublayer(redDots!)
        layer.addSublayer(greenDots!)
        layer.addSublayer(blueDots!)

        redDots!.zPosition = 0
        greenDots!.zPosition = -1
        blueDots!.zPosition = -2
    }
    resetWaveLayers()
    configureDisplayLink()
  }

  override internal func resetWaveLayers() {
    var width = (frame.size.width - barSpacing) / CGFloat(numberOfPoints)
    var barWidth = width - barSpacing
    if width <= 0 {
        width = 1
    }
    if barWidth <= 0 {
        barWidth = 1
    }

    if !siriEnabled {
        self.layer.sublayers = nil

        for i in 0..<numberOfPoints {
            let layer = CALayer()
            layer.cornerRadius = barWidth / 2.0
            layer.frame = CGRect(x: CGFloat(CGFloat(i) * width) + barSpacing, y: 0, width: barWidth, height: barWidth)
            layer.backgroundColor = waveColor?.cgColor
            self.layer.addSublayer(layer)
        }
    } else {
        redDots?.sublayers = nil
        greenDots?.sublayers = nil
        blueDots?.sublayers = nil

        for r in 0..<numberOfPoints {
          let layer = CALayer()
          layer.cornerRadius = barWidth / 2.0
          layer.frame = CGRect(x: CGFloat(CGFloat(r) * width) + barSpacing, y: 0, width: barWidth, height: barWidth)
          layer.backgroundColor = waveColor?.cgColor
          redDots?.addSublayer(layer)
        }

         for g in 0..<numberOfPoints {
          let layer = CALayer()
          layer.cornerRadius = barWidth / 2.0
          layer.frame = CGRect(x: CGFloat(CGFloat(g) * width) + barSpacing, y: 0, width: barWidth, height: barWidth)
          layer.backgroundColor = waveColor?.cgColor
          greenDots?.addSublayer(layer)
        }

        for b in 0..<numberOfPoints {
          let layer = CALayer()
          layer.cornerRadius = barWidth / 2.0
          layer.frame = CGRect(x: CGFloat(CGFloat(b) * width) + barSpacing, y: 0, width: barWidth, height: barWidth)
          layer.backgroundColor = waveColor?.cgColor
          blueDots?.addSublayer(layer) 
        }
      }

      cachedNumberOfPoints = numberOfPoints
    }

  @objc override public func updateWave(_ waveColor: UIColor, subwaveColor: UIColor) {
    self.waveColor = waveColor
    layer.sublayers?.forEach { layer in
        layer.backgroundColor = waveColor.cgColor
    }
  }

  @objc override public func updateWave(_ waveColor: UIColor, subwaveColor: UIColor, subSubwaveColor: UIColor) {
    if redDots == nil || greenDots == nil || blueDots == nil {
        initializeWaveLayers()
    }
    self.waveColor = waveColor
    self.subwaveColor = subwaveColor
    self.subSubwaveColor = subSubwaveColor

    redDots!.compositingFilter = "screenBlendMode"
    greenDots!.compositingFilter = "screenBlendMode"
    blueDots!.compositingFilter = "screenBlendMode"

    for layer in redDots!.sublayers ?? [] {
        layer.backgroundColor = waveColor.cgColor
    }
    for layer in greenDots!.sublayers ?? [] {
        layer.backgroundColor = subwaveColor.cgColor
    }
    for layer in blueDots!.sublayers ?? [] {
        layer.backgroundColor = subSubwaveColor.cgColor
    } 
  }

  override internal func redraw() {
    super.redraw()

    if cachedNumberOfPoints != numberOfPoints {
        resetWaveLayers()
    }

    var width = (frame.size.width - barSpacing) / CGFloat(numberOfPoints)
    var barWidth = width - barSpacing
    if width <= 0 {
        width = 1
    }
    if barWidth <= 0 {
        barWidth = 1
    }

    if !siriEnabled {
      var i = 0

        layer.sublayers?.forEach { layer in
          if points[i].y.isNaN {
              points[i].y = 0
          }

          layer.frame = CGRect(
              x: CGFloat(CGFloat(i) * width) + barSpacing,
              y: points[i].y,
              width: barWidth,
              height: barWidth)
          i += 1
      }
    }
    else {
      var r = 0
      var g = 0
      var b = 0

      for layer in redDots?.sublayers ?? [] {
          if points[r].y.isNaN {
              points[r].y = 0
          }

          layer.frame = CGRect(
              x: CGFloat(CGFloat(r) * width) + barSpacing,
              y: points[r].y,
              width: barWidth,
              height: barWidth)
          r += 1
      }

      for layer in greenDots?.sublayers ?? [] {
            layer.frame = CGRect(
                x: CGFloat(g) * width + self.barSpacing,
                y: self.points[g].y,
                width: barWidth,
                height: barWidth)
        g += 1
      }
      for layer in blueDots?.sublayers ?? [] {
            layer.frame = CGRect(
                x: CGFloat(b) * width + self.barSpacing,
                y: self.points[b].y,
                width: barWidth,
                height: barWidth)
        b += 1
      }
    }
  }
}
