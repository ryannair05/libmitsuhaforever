import QuartzCore

final internal class MSHFJelloLayer: CAShapeLayer {
    internal var shouldAnimate = false

    override func action(forKey event: String) -> CAAction? {
        if shouldAnimate && event == "path" {
            let animation = CABasicAnimation(keyPath: event)
            animation.duration = 0.15

            return animation
        }
        return super.action(forKey: event)
    }
}
