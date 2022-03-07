import SpriteKit
import AVFoundation

public class Scene: SKScene {

    var childNodes: [Node] = []

    private let linkColor: UIColor
    private let maxNodeSize: CGFloat

    private let blackHole = SKShapeNode.init(circleOfRadius: 200)
    private let maximumDistance = CGFloat(150)

    private var selectedNode: Node?
    private var links: [Link] = []
    private var limit = CGSize()
    private var closestNode: Node?
    private var didSelect = false
    private var verseIndex: Int = 0
    private var alreadyAdded: Bool = false

    public init(size: CGSize, linkColor: UIColor, maxNodeSize: CGFloat) {
        self.linkColor = linkColor
        self.maxNodeSize = maxNodeSize
        super.init(size: size)

        setupBlackHole()

        limit = size
        backgroundColor = UIColor.white.withAlphaComponent(0.6)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: setups

    func setupBlackHole() {
        blackHole.fillColor = .black
        blackHole.position = CGPoint(x: self.frame.width/2, y: -150)
        addChild(blackHole)
    }

    // MARK: touches handling

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)

        let touchedNodes = childNodes.filter{ $0.paddingCircle.contains(location) }
        if let touchedNode = touchedNodes.first {
            childNodes.forEach {
                guard !$0.isRoot else { return }
                $0.audioNode.run(.stop())
            }

            didSelect = true
            selectedNode = touchedNode
            selectedNode?.reverb()
        }

        let shouldAddNewNode = !didSelect
        guard shouldAddNewNode else { return }

        closestNode = childNodes.first {
            let dx = $0.circle.position.x - location.x
            let dy = $0.circle.position.y - location.y
            let distance = sqrt(dx*dx + dy*dy)

            return /*$0.distance(from: location)*/distance < maximumDistance
        }

        addNode(at: location)
        closestNode = nil
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard didSelect else { return }
        let touch = touches.first!
        let location = touch.location(in: self)
        selectedNode?.circle.position = location
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        didSelect = false
        guard blackHole.contains(touches.first!.location(in: self)) else { return }
        selectedNode?.remove()
    }

    public func addNode(at location: CGPoint) {
        let newNode: Node

        if let closestNode = closestNode {
            newNode = Node(at: location, isRoot: false, verseIndex: closestNode.verseIndex, maxSize: maxNodeSize)
            addLink(node1: closestNode, node2: newNode)
        } else {
            verseIndex += 1
            if verseIndex == 4 { verseIndex = 0 }
            newNode = Node(at: location, verseIndex: verseIndex, maxSize: maxNodeSize)
        }

        childNodes.append(newNode)
        addChild(newNode.circle)
        addChild(newNode.paddingCircle)

        if newNode.isRoot {
            newNode.reverb()
        }
    }

    public func addLink(node1: Node, node2: Node) {
        let link = Link(node1: node1, node2: node2, color: linkColor)
        closestNode?.childNodes.append(node2)
        links.append(link)
        addChild(link.line)
    }

    public override func update(_ currentTime: TimeInterval) {
        updateNodes()
        updateLinks()
    }

    public func updateNodes() {
        childNodes.forEach {
            if blackHole.contains($0.circle.position) {
                $0.remove()
            } else {
                $0.move(inside: limit)
            }
        }
    }

    public func updateLinks() {
        links.forEach { $0.bounce() }
    }

}
