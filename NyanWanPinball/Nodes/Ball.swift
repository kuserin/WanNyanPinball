import UIKit
import SpriteKit

class Ball: SKSpriteNode {

    static let radius: CGFloat = 14

    private static let categoryBitmask: UInt32 = 0x1 << 0

    static var physicsCategory: UInt32 { categoryBitmask }

    init() {
        let texture = Ball.makeTexture()
        super.init(texture: texture, color: .clear, size: CGSize(width: Ball.radius * 2, height: Ball.radius * 2))
        name = "ball"
        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func makeTexture() -> SKTexture {
        let size = CGSize(width: radius * 2, height: radius * 2)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            // ベースカラー（銀色）
            UIColor.lightGray.setFill()
            ctx.cgContext.fillEllipse(in: rect)
            // ハイライト
            UIColor.white.withAlphaComponent(0.6).setFill()
            let highlight = CGRect(x: size.width * 0.25, y: size.height * 0.55,
                                   width: size.width * 0.25, height: size.height * 0.2)
            ctx.cgContext.fillEllipse(in: highlight)
        }
        return SKTexture(image: image)
    }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: Ball.radius)
        physicsBody?.categoryBitMask    = Ball.physicsCategory
        physicsBody?.contactTestBitMask = Bumper.physicsCategory | Flipper.physicsCategory
        physicsBody?.collisionBitMask   = 0xFFFFFFFF
        physicsBody?.restitution        = 0.6
        physicsBody?.friction           = 0.1
        physicsBody?.linearDamping      = 0.05
        physicsBody?.angularDamping     = 0.3
        physicsBody?.mass               = 1.0
        physicsBody?.isDynamic          = true
        physicsBody?.allowsRotation     = true
        physicsBody?.usesPreciseCollisionDetection = true
    }

    func launch(from position: CGPoint, velocity: CGVector = CGVector(dx: 0, dy: 600)) {
        self.position = position
        physicsBody?.velocity = velocity
    }
}
