
import UIKit
import SpriteKit


// A link is what links two nodes on the screen
public class Link {
    
    public var node1: Node
    public var node2: Node
    public var length: CGFloat
    
    public init(node1: Node, node2: Node) {
        self.node1 = node1
        self.node2 = node2

        //pithagoryan theorem
        let dx = node1.circle.position.x - node2.circle.position.x
        let dy = node1.circle.position.y - node2.circle.position.y
        let dist = sqrt(dx*dx + dy*dy)

        //bring the nodes closer
        length = min(dist, 90)
    }

    func bounce() {
        let offset = getOffset()
        node1.circle.position.x += offset.x/4
        node1.circle.position.y += offset.y/4
        node2.circle.position.x -= offset.x/4
        node2.circle.position.y -= offset.y/4
    }

    func getOffset() -> (x: CGFloat, y: CGFloat) {
        let dx = node1.circle.position.x - node2.circle.position.x
        let dy = node1.circle.position.y - node2.circle.position.y
        let distance = sqrt(dx*dx + dy*dy)
        let difference = length - distance
        let fractionPerNode = difference/distance/2
        let offsetx = dx * fractionPerNode
        let offsety = dy * fractionPerNode
        return (x: offsetx, y: offsety)
    }
    
}
