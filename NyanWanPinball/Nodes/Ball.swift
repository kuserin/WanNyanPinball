import SpriteKit

class Ball: SKNode {

    static let radius: CGFloat = 14
    static let physicsCategory: UInt32 = 0x1 << 0

    override init() {
        super.init()
        name = "ball"
        setupVisual()
        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupVisual() {
        let circle = SKShapeNode(circleOfRadius: Ball.radius)
        circle.fillColor   = SKColor(white: 0.88, alpha: 1)
        circle.strokeColor = SKColor(white: 0.55, alpha: 1)
        circle.lineWidth   = 1.5
        circle.zPosition   = 10
        addChild(circle)

        // ハイライト
        let highlight = SKShapeNode(circleOfRadius: Ball.radius * 0.35)
        highlight.fillColor   = SKColor(white: 1.0, alpha: 0.7)
        highlight.strokeColor = .clear
        highlight.position    = CGPoint(x: -Ball.radius * 0.3, y: Ball.radius * 0.35)
        highlight.zPosition   = 11
        addChild(highlight)
    }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: Ball.radius)
        physicsBody?.categoryBitMask    = Ball.physicsCategory
        physicsBody?.contactTestBitMask = Bumper.physicsCategory | PhysicsCategory.drain | PhysicsCategory.slingshot
        physicsBody?.collisionBitMask   = 0xFFFFFFFF
        physicsBody?.restitution        = 0.65
        physicsBody?.friction           = 0.05
        physicsBody?.linearDamping      = 0.02
        physicsBody?.angularDamping     = 0.1
        physicsBody?.mass               = 1.0
        physicsBody?.isDynamic          = true
        physicsBody?.allowsRotation     = true
        physicsBody?.usesPreciseCollisionDetection = true
    }
}
