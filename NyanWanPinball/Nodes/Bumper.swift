import SpriteKit

class Bumper: SKNode {

    static let physicsCategory: UInt32 = 0x1 << 2

    let scoreValue: Int
    let radius: CGFloat
    private(set) var hitCount = 0

    static let hitsToTriggerEvent = 10

    init(radius: CGFloat = 22, score: Int = 100) {
        self.radius     = radius
        self.scoreValue = score
        super.init()
        name = "bumper"
        setupVisual()
        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Visual

    private func setupVisual() {
        // 外輪（光る縁）
        let outer = SKShapeNode(circleOfRadius: radius)
        outer.fillColor   = SKColor(red: 0.9, green: 0.2, blue: 0.5, alpha: 1.0)
        outer.strokeColor = SKColor(red: 1.0, green: 0.6, blue: 0.8, alpha: 1.0)
        outer.lineWidth   = 3
        outer.name        = "bumperOuter"
        outer.zPosition   = 3
        addChild(outer)

        // 内丸（明るい）
        let inner = SKShapeNode(circleOfRadius: radius * 0.55)
        inner.fillColor   = SKColor(red: 1.0, green: 0.5, blue: 0.7, alpha: 1.0)
        inner.strokeColor = .clear
        inner.name        = "bumperInner"
        inner.zPosition   = 4
        addChild(inner)

        // スコアラベル
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text      = "+\(scoreValue)"
        label.fontSize  = 10
        label.fontColor = .white
        label.verticalAlignmentMode   = .center
        label.horizontalAlignmentMode = .center
        label.name      = "bumperLabel"
        label.zPosition = 5
        addChild(label)
    }

    // MARK: - Physics

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.categoryBitMask    = Bumper.physicsCategory
        physicsBody?.contactTestBitMask = Ball.physicsCategory
        physicsBody?.collisionBitMask   = Ball.physicsCategory
        physicsBody?.isDynamic          = false
        physicsBody?.restitution        = 1.3   // 強めに弾き返す
        physicsBody?.friction           = 0.0
    }

    // MARK: - Hit

    @discardableResult
    func onHit() -> Int {
        hitCount += 1
        flashEffect()
        showScorePop()
        return scoreValue
    }

    private func flashEffect() {
        guard let outer = childNode(withName: "bumperOuter") as? SKShapeNode,
              let inner = childNode(withName: "bumperInner") as? SKShapeNode
        else { return }

        let origOuter = outer.fillColor
        let origInner = inner.fillColor

        outer.fillColor = .white
        inner.fillColor = .yellow

        let restore = SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.run {
                outer.fillColor = origOuter
                inner.fillColor = origInner
            }
        ])

        // バウンスアニメ
        let bounce = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.06),
            SKAction.scale(to: 1.0, duration: 0.06)
        ])
        run(SKAction.group([restore, bounce]))
    }

    private func showScorePop() {
        let pop = SKLabelNode(fontNamed: "AvenirNext-Bold")
        pop.text      = "+\(scoreValue)"
        pop.fontSize  = 15
        pop.fontColor = .yellow
        pop.position  = CGPoint(x: 0, y: radius + 8)
        pop.zPosition = 20
        addChild(pop)
        pop.run(SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 25, duration: 0.5),
                SKAction.fadeOut(withDuration: 0.5)
            ]),
            SKAction.removeFromParent()
        ]))
    }

    var reachedEventThreshold: Bool { hitCount >= Bumper.hitsToTriggerEvent }

    func resetHitCount() { hitCount = 0 }
}
