import UIKit
import SpriteKit

class Slingshot: SKNode {

    static let physicsCategory: UInt32 = 0x1 << 6

    private let scoreValue = 50
    private let shape: SKShapeNode

    init(from start: CGPoint, to end: CGPoint, color: SKColor = .orange) {
        shape = SKShapeNode()
        super.init()

        name = "slingshot"

        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)

        shape.path        = path
        shape.strokeColor = color
        shape.lineWidth   = 8
        shape.lineCap     = .round
        addChild(shape)

        physicsBody = SKPhysicsBody(edgeFrom: start, to: end)
        physicsBody?.categoryBitMask    = Slingshot.physicsCategory
        physicsBody?.contactTestBitMask = Ball.physicsCategory
        physicsBody?.isDynamic          = false
        physicsBody?.restitution        = 0.9
        physicsBody?.friction           = 0.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult
    func onHit() -> Int {
        flashEffect()
        return scoreValue
    }

    private func flashEffect() {
        let original = shape.strokeColor
        shape.strokeColor = .yellow
        let restore = SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.run { [weak self] in self?.shape.strokeColor = original }
        ])
        shape.run(restore)
    }
}
