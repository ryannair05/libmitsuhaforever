import UIKit

@objc (MSHFBarView) final public class MSHFBarView: MSHFView {

    @objc internal var barCornerRadius: CGFloat = 0
    @objc internal var barSpacing: CGFloat = 0
    private var redBars: CALayer?
    private var greenBars: CALayer?
    private var blueBars: CALayer?
    private var cachedNumberOfPoints = 0

    override internal func initializeWaveLayers() {
        if siriEnabled {
            redBars = CALayer()
            greenBars = CALayer()
            blueBars = CALayer()

            layer.addSublayer(redBars!)
            layer.addSublayer(greenBars!)
            layer.addSublayer(blueBars!)

            redBars!.zPosition = 0
            greenBars!.zPosition = -1
            blueBars!.zPosition = -2
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
                layer.cornerRadius = barCornerRadius
                layer.frame = CGRect(
                    x: CGFloat(CGFloat(i) * width) + barSpacing,
                    y: 0,
                    width: barWidth,
                    height: frame.size.height)
                layer.backgroundColor = waveColor?.cgColor
                self.layer.addSublayer(layer)
            }
        }
      else {
        redBars!.sublayers = nil
        greenBars!.sublayers = nil
        blueBars!.sublayers = nil

        for r in 0..<numberOfPoints {
            let layer = CALayer()
            layer.cornerRadius = barCornerRadius
            layer.frame = CGRect(
                x: CGFloat(CGFloat(r) * width) + barSpacing,
                y: 0,
                width: barWidth,
                height: frame.size.height)
            layer.backgroundColor = waveColor?.cgColor
            redBars!.addSublayer(layer)
        }

        for g in 0..<numberOfPoints {
            let layer = CALayer()
            layer.cornerRadius = barCornerRadius
            layer.frame = CGRect(
                x: CGFloat(CGFloat(g) * width) + barSpacing,
                y: 0,
                width: barWidth,
                height: frame.size.height)
            layer.backgroundColor = subwaveColor?.cgColor
            greenBars!.addSublayer(layer)
        }

        for b in 0..<numberOfPoints {
            let layer = CALayer()
            layer.cornerRadius = barCornerRadius
            layer.frame = CGRect(
                x: CGFloat(CGFloat(b) * width) + barSpacing,
                y: 0,
                width: barWidth,
                height: frame.size.height)
            layer.backgroundColor = subSubwaveColor?.cgColor
            blueBars!.addSublayer(layer)
        }
      } 
      cachedNumberOfPoints = numberOfPoints
    }

   @objc override public func updateWaveColor(_ waveColor: UIColor,
        subwaveColor: UIColor) {
        self.waveColor = waveColor
        layer.sublayers?.forEach { layer in
            layer.backgroundColor = waveColor.cgColor
        }
    }

    @objc override public func updateWaveColor(_ waveColor: UIColor, subwaveColor: UIColor, subSubwaveColor: UIColor) {
        if redBars == nil || greenBars == nil || blueBars == nil {
            initializeWaveLayers()
        }

        self.waveColor = waveColor
        self.subwaveColor = subwaveColor
        self.subSubwaveColor = subSubwaveColor

        redBars!.compositingFilter = "screenBlendMode"
        greenBars!.compositingFilter = "screenBlendMode"
        blueBars!.compositingFilter = "screenBlendMode"

        for layer in redBars!.sublayers ?? [] {
            layer.backgroundColor = waveColor.cgColor
        }
        for layer in greenBars!.sublayers ?? [] {
            layer.backgroundColor = subwaveColor.cgColor
        }
        for layer in blueBars!.sublayers ?? [] {
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
                var barHeight: CGFloat = frame.size.height - points[i].y
                if barHeight <= 0 {
                    barHeight = 1
                }

                layer.frame = CGRect(
                    x: CGFloat(CGFloat(i) * width) + barSpacing,
                    y: points[i].y,
                    width: barWidth,
                    height: barHeight)
                i += 1
            }
        }
        else {
            var r = 0
            var g = 0
            var b = 0

            redBars?.sublayers!.forEach { layer in
                var barHeight: CGFloat = frame.size.height - points[r].y
                if barHeight <= 0 {
                    barHeight = 1
                }

                layer.frame = CGRect(
                    x: CGFloat(CGFloat(r) * width) + barSpacing,
                    y: points[r].y,
                    width: barWidth,
                    height: barHeight)
                r += 1
            }

            greenBars?.sublayers!.forEach { layer in
                var barHeight: CGFloat = self.frame.size.height - self.points[g].y
                if barHeight <= 0 {
                    barHeight = 1
                }
                layer.frame = CGRect(
                    x: CGFloat(g) * width + self.barSpacing,
                    y: self.points[g].y,
                    width: barWidth,
                    height: barHeight)
              g += 1
            }
            blueBars?.sublayers!.forEach { layer in
                var barHeight: CGFloat = self.frame.size.height - self.points[b].y
                if barHeight <= 0 {
                    barHeight = 1
                }

                layer.frame = CGRect(x: CGFloat(b) * width + self.barSpacing, y: self.points[b].y, width: barWidth, height: barHeight)
                b += 1
            }
        }
    }
}