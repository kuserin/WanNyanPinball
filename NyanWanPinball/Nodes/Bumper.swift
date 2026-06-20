import UIKit
import SpriteKit

class Bumper: SKSpriteNode {

    static let physicsCategory: UInt32 = 0x1 << 2

    private let scoreValue: Int
    private let label: SKLabelNode

    // 点灯カウント（バンパーを一定数叩くとキャラクター出現）
    private(set) var hitCount = 0
    static let hitsToTriggerEvent = 10

    init(radius: CGFloat = 24, score: Int = 100) {
        self.scoreValue = score

        label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "●"
        label.fontSize = radius * 1.4
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center

        let size = CGSize(width: radius * 2, height: radius * 2)
        super.init(texture: nil, color: .clear, size: size)

        name = "bumper"
        addChild(label)
        setupPhysics(radius: radius)
        updateAppearance(active: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPhysics(radius: CGFloat) {
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.categoryBitMask    = Bumper.physicsCategory
        physicsBody?.contactTestBitMask = Ball.physicsCategory
        physicsBody?.collisionBitMask   = Ball.physicsCategory
        physicsBody?.isDynamic          = false
        physicsBody?.restitution        = 1.2   // 弾き返す力
        physicsBody?.friction           = 0.0
    }

    // MARK: - Hit

    @discardableResult
    func onHit() -> Int {
        hitCount += 1
        flashEffect()
        return scoreValue
    }

    private func flashEffect() {
        let flash = SKAction.sequence([
            SKAction.run { [weak self] in self?.updateAppearance(active: true) },
            SKAction.wait(forDuration: 0.12),
            SKAction.run { [weak self] in self?.updateAppearance(active: false) }
        ])
        run(flash)

        // スコアポップアップ
        let pop = SKLabelNode(fontNamed: "AvenirNext-Bold")
        pop.text = "+\(scoreValue)"
        pop.fontSize = 14
        pop.fontColor = .yellow
        pop.position = CGPoint(x: 0, y: size.height / 2 + 8)
        addChild(pop)
        pop.run(SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 20, duration: 0.4),
                SKAction.fadeOut(withDuration: 0.4)
            ]),
            SKAction.removeFromParent()
        ]))
    }

    private func updateAppearance(active: Bool) {
        label.fontColor = active ? .white : .systemPink
        if active {
            let glow = SKAction.sequence([
                SKAction.scale(to: 1.15, duration: 0.06),
                SKAction.scale(to: 1.0,  duration: 0.06)
            ])
            label.run(glow)
        }
    }

    var reachedEventThreshold: Bool {
        hitCount >= Bumper.hitsToTriggerEvent
    }

    func resetHitCount() {
        hitCount = 0
    }
}
