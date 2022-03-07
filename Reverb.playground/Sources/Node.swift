import SpriteKit
import UIKit
import AVFoundation


public class Node {

    // MARK: Physical properties

    var circle: SKShapeNode = SKShapeNode()
    var paddingCircle: SKShapeNode = SKShapeNode()

    let bounceStrenght: CGFloat = 0.5
    let friction: CGFloat = 1.01

    enum Axis {
        case x
        case y
    }

    enum Direction: Int, CaseIterable {
        case positive = 1
        case negative = -1

        static func randomValue() -> CGFloat {
            CGFloat(Self.allCases.randomElement()?.rawValue ?? 1)
        }
    }

    // MARK: Data structure properties

    public var isRoot: Bool = true
    public var childNodes: [Node] = []

    // MARK: Visual and sound properties

    public var audioNode: SKAudioNode = SKAudioNode()
    public var verseIndex: Int = 0
    public var soundsDict: [SKColor: String] = [
        .red: "lo-a.m4a",
        .blue: "lo-b.m4a",
        .yellow: "lo-c.m4a",
        .pink: "lo-d.m4a",
        .gray: "percussao1.m4a"
    ]

    let minLeafRadius: CGFloat = 15
    let maxLeafRadius: CGFloat = 70
    let rootRadius: CGFloat = 20

    let leafAnimationDuration = Double(0.76)
    let leafInterval = Double(1.1)
    let rootInterval = Double(1)

    // MARK: - Init

    public init(at touch: CGPoint, isRoot: Bool = true, verseIndex: Int) {
        self.isRoot = isRoot
        self.verseIndex = verseIndex

        let color = soundsDict.keys.first!

        setupCircle(at: touch, with: color, isRoot: isRoot)
        setupAudioNode(for: color, isRoot: isRoot)
    }

    // MARK: - Setups

    func setupCircle(at touch: CGPoint, with color: SKColor, isRoot: Bool) {
        let leafRadius = CGFloat.random(in: minLeafRadius...maxLeafRadius)
        let radius = isRoot ? rootRadius : leafRadius
        circle = SKShapeNode(circleOfRadius: radius)
        circle.fillColor = isRoot ? .gray : color
        circle.strokeColor = isRoot ? color : .white
        circle.lineWidth = isRoot ? 6 : 1

        let paddingRadius = CGFloat(max(radius, maxLeafRadius))
        paddingCircle = SKShapeNode(circleOfRadius: paddingRadius)
        paddingCircle.fillColor = UIColor.clear
        paddingCircle.lineWidth = 0

        circle.position = CGPoint(x: touch.x, y: touch.y)
        paddingCircle.position = circle.position
    }

    func setupAudioNode(for color: SKColor, isRoot: Bool) {
        let fileName = isRoot ? soundsDict[.gray]! : soundsDict[color]!
        audioNode = SKAudioNode.init(fileNamed: fileName)
        audioNode.isPositional = true
        audioNode.autoplayLooped = isRoot ? true : false
        if !isRoot {
            audioNode.run(.changeVolume(to: 0.65, duration: 0))
        }
        circle.addChild(audioNode)
    }

    // MARK: - Physical movement

    /// A "previous position" is forged with a random value, which can be 1 point further in a random direction, so the circle enters in the scene as if it was continuing a movement.
    private lazy var previousPosition: CGPoint = {
        let previousX = circle.position.x + Direction.randomValue()
        let previousY = circle.position.y + Direction.randomValue()
        return CGPoint(x: previousX, y: previousY)
    }()

    private func speed(for axis: Axis) -> CGFloat {
        let distance: CGFloat = {
            switch axis {
            case .x:
                return (circle.position.x - previousPosition.x)
            case .y:
                return (circle.position.y - previousPosition.y)
            }
        }()
        return distance / friction
    }

    /// Update position acording to the speed and the direction.
    func move(inside size: CGSize) {
        let xSpeed = speed(for: .x)
        let ySpeed = speed(for: .y)

        previousPosition = circle.position

        circle.position.x += xSpeed
        circle.position.y += ySpeed

        bounceIfNeeded(size: size)

        paddingCircle.position = circle.position
    }

    /// If the node reaches the limit, be it in x or y, this method changes the direction and decreases the speed.
    /// If it's the case, `previousPosition` becomes what would actually be the next position if there was no bounce, but considering a smaller speed due to the "energy loss", and the `circle.position` changes to what would be the previous position.
    private func bounceIfNeeded(size: CGSize) {
        bounceIfNeededInX(width: size.width)
        bounceIfNeededInY(height: size.height)
    }

    private func bounceIfNeededInX(width: CGFloat) {
        guard didReachTrailingLimit(width: width) || didReachLeadingLimit() else {
            return
        }

        let positionBeforeBounce = circle.position

        if didReachTrailingLimit(width: width) {
            circle.position.x = width
        } else if didReachLeadingLimit() {
            circle.position.x = 0
        }

        let xSpeed = speed(for: .x) * bounceStrenght
        previousPosition.x = positionBeforeBounce.x + xSpeed
    }

    private func bounceIfNeededInY(height: CGFloat) {
        guard didReachBottomLimit(height: height) || didReachTopLimit() else {
            return
        }

        let positionBeforeBounce = circle.position

        if didReachBottomLimit(height: height) {
            circle.position.y = height
        } else if didReachTopLimit() {
            circle.position.x = 0
        }

        let ySpeed = speed(for: .y) * bounceStrenght
        previousPosition.y = positionBeforeBounce.y + ySpeed
    }

    private func didReachTrailingLimit(width: CGFloat) -> Bool {
        circle.position.x > width
    }

    private func didReachLeadingLimit() -> Bool {
        circle.position.x < 0
    }

    private func didReachBottomLimit(height: CGFloat) -> Bool {
        circle.position.y > height
    }

    private func didReachTopLimit() -> Bool {
        circle.position.y < 0
    }

    // MARK: - Sound handling

    func reverb() {
        stopAllSounds()
        animateShape()
        audioNode.run(.play())

        // wait the beat to be concluded and than repeat for each child node
        DispatchQueue.main.asyncAfter(deadline: .now() + (isRoot ? 0 : 1.1*leafInterval)) {
            self.childNodes.forEach { $0.reverb() }
        }
    }

    func stopAllSounds() {
        audioNode.run(.stop())
        for node in childNodes { node.audioNode.run(.stop()) }
        circle.removeAllActions()
    }


    // MARK: - Visual

    private func animateShape() {
        let action = isRoot ? rootAnimation() : leafAnimation()
        circle.run(action)
    }

    private func rootAnimation() -> SKAction {
        .sequence([
            .wait(forDuration: 0.1),
            .repeatForever(
                .sequence(scaleAnimation(1.3))
            )
        ])
    }

    private func leafAnimation() -> SKAction {
        .sequence(
            // first animation
            scaleAnimation(2.6)

            +

            // a softer animation while the melody lasts
            [SKAction.repeat(.sequence(scaleAnimation(1.5)), count: 5)]
        )
    }

    private func scaleAnimation(_ scale: CGFloat) -> [SKAction] {
        [
            .scale(to: scale, duration: 0.1 * leafAnimationDuration),
            .scale(to: 1, duration: 0.9 * leafAnimationDuration)
        ]
    }

    func remove() {
        fade()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            self.paddingCircle.removeFromParent()
            self.audioNode.removeFromParent()
            self.circle.removeFromParent()
        }
    }

    func fade() {
        let parent = self.circle.parent as! Scene
        parent.childNodes = parent.childNodes.filter{ $0 !== self }
        circle.run(.scale(to: 0, duration: 3))
        paddingCircle.run(.scale(to: 0, duration: 3))
        audioNode.run(.changePlaybackRate(to: 0, duration: 3))
        audioNode.run(.changeVolume(to: 0, duration: 3))
    }
}
