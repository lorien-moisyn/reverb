import SpriteKit
import AVFoundation


public class Scene: SKScene {

    public let maximumDistance = CGFloat(120)
    
    public var childNodes: [Node] = []
    public var selectedNode = Node(at: CGPoint.zero, isRoot: true, verseIndex: 0)
    public let blackHole = SKShapeNode.init(circleOfRadius: 200)
    public var links: [Link] = []
    public var limit = CGSize()
    public var closeNode: Node?
    public var didSelect = false
    public var verseIndex: Int = 0
    public var alreadyAdded: Bool = false

    public override init(size: CGSize) {
        super.init(size: size)
        
        setupListener()
        setupBlackHole()
        
        limit = size
        backgroundColor = UIColor.white.withAlphaComponent(0.6)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: setups

    func setupListener() {
        //the sound is louder at the center
        let center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        let myListener = SKShapeNode.init(circleOfRadius: 0)
        myListener.position = center
        addChild(myListener)
        listener = myListener
    }

    func setupBlackHole() {
        blackHole.fillColor = .black
        blackHole.position = CGPoint(x: self.frame.width/2, y: -150)
        addChild(blackHole)
    }
    

    // MARK: touches handling
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)

        guard !childNodes.isEmpty else {
            addNode(at: location)
            return
        }

        let touchedNodes = childNodes.filter{ $0.paddingCircle.contains(location) }
        if let touchedNode = touchedNodes.first {
            didSelect = true
            selectedNode = touchedNode
            selectedNode.reverb()
        }

        guard !didSelect else { return }
        
        childNodes.forEach {
            let dx = $0.circle.position.x - location.x
            let dy = $0.circle.position.y - location.y
            let distance = sqrt(dx*dx + dy*dy)
            
            if distance < maximumDistance {
                closeNode = $0
                addNode(at: location)
                alreadyAdded = true
                closeNode = nil
            }
        }

        guard !alreadyAdded else {
            alreadyAdded = false
            return
        }
        addNode(at: location)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard didSelect else { return }
        let touch = touches.first!
        let location = touch.location(in: self)
        selectedNode.circle.position = location
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        didSelect = false
        guard blackHole.contains(touches.first!.location(in: self)) else { return }
        selectedNode.remove()
    }
    
    public func addNode(at location: CGPoint) {
        let newNode: Node
        if let closeNode = closeNode {
            newNode = Node(at: location, isRoot: false, verseIndex: closeNode.verseIndex)
            addLink(node1: closeNode, node2: newNode)
        } else {
            verseIndex += 1
            if verseIndex == 4 { verseIndex = 0 }
            newNode = Node(at: location, verseIndex: verseIndex)
        }
        childNodes.append(newNode)
        addChild(newNode.circle)
        addChild(newNode.paddingCircle)
        newNode.reverb()
    }
    
    public func addLink(node1: Node, node2: Node) {
        let link = Link(node1: node1, node2: node2)
        closeNode?.childNodes.append(node2)
        links.append(link)
    }
    
    public override func update(_ currentTime: TimeInterval) {
        updateNodes()
        updateLinks()
    }
    
    public func updateNodes() {
        for node in childNodes {
            guard !blackHole.contains(node.circle.position) else {
                node.remove()
                return
            }
            node.move(inside: limit)
        }
    }

    public func updateLinks() {
        links.forEach { $0.bounce() }
    }

}
