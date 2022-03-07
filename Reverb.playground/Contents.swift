/*:
 # Reverb
 
 Graphs, colors and melodies mixed together as a single interactive experience.
 
 Start touching the screen!
 
 - Experiment:
    - Proximity has an effect, distance has another
    - You can destroy nodes with the black hole
    - The more nodes on the scene, greater is the reverb
    - Note that the reverb follows the graph structure
 */

var linkColor: UIColor = .black
var maxNodeSize: CGFloat = 30

//#-hidden-code
import UIKit
import SpriteKit
import PlaygroundSupport
import CoreGraphics

let size: CGFloat = 600
let view = SKView(frame: CGRect(x: 0, y: 0, width: size, height: size))
let scene = Scene(
    size: CGSize(width: size, height: size),
    linkColor: linkColor,
    maxNodeSize: maxNodeSize
)
scene.scaleMode = .aspectFill
view.presentScene(scene)

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = view
//#-end-hidden-code
