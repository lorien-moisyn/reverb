import SpriteKit

// A link is what links two nodes on the screen
public class Link {
    
    public var node1: Node
    public var node2: Node
    public var length: CGFloat

    var path: CGMutablePath
    var line: SKShapeNode

    public init(node1: Node, node2: Node, color: UIColor) {
        self.node1 = node1
        self.node2 = node2

        path = CGMutablePath()
        path.move(to: node1.circle.position)
        path.addLine(to: node2.circle.position)
        line = SKShapeNode(path: path)
        line.strokeColor = color

        let distance = node1.distance(from: node2)
        length = min(distance, 90)
    }

    public func update() {
        path = CGMutablePath()
        path.move(to: node1.circle.position)
        path.addLine(to: node2.circle.position)
        line.path = path
    }

    func bounce() {
        let offset = getOffset()
        node1.circle.position.x += offset.x/4
        node1.circle.position.y += offset.y/4
        node2.circle.position.x -= offset.x/4
        node2.circle.position.y -= offset.y/4

        update()
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
