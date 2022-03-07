import UIKit

extension CGPoint {
    func distance(from point: CGPoint) -> CGFloat {
        let distanceX = x.distance(to: point.x)
        let distanceY = y.distance(to: point.y)
        return (distanceX * distanceX) + (distanceY * distanceY)
    }
}
