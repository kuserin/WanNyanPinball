import UIKit
import SpriteKit

/// 猫フィールド（Nyan Stage）: 室内・夜の雰囲気。毛玉バンパー、魚ターゲット
class CatField: SKNode {

    static let bgColor = SKColor(red: 0.05, green: 0.03, blue: 0.12, alpha: 1.0)

    weak var parentScene: SKScene?

    init(in scene: SKScene) {
        self.parentScene = scene
        super.init()
        name = "catField"
        setupDecorations(sceneSize: scene.size)
        setupTargets(sceneSize: scene.size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Decorations

    private func setupDecorations(sceneSize: CGSize) {
        let w = sceneSize.width
        let h = sceneSize.height

        // 月（右上）
        addMoon(at: CGPoint(x: w * 0.8, y: h * 0.88))

        // 星
        for _ in 0..<12 {
            let star = SKLabelNode(text: "★")
            star.fontSize = CGFloat.random(in: 6...12)
            star.fontColor = .white.withAlphaComponent(CGFloat.random(in: 0.3...0.8))
            star.position = CGPoint(x: CGFloat.random(in: 20...w - 20),
                                    y: CGFloat.random(in: h * 0.5...h * 0.92))
            addChild(star)
            // 点滅アニメ
            let blink = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.2, duration: Double.random(in: 0.8...2.0)),
                SKAction.fadeAlpha(to: 0.8, duration: Double.random(in: 0.8...2.0))
            ])
            star.run(SKAction.repeatForever(blink))
        }

        // 窓（背景装飾）
        addWindow(at: CGPoint(x: w * 0.15, y: h * 0.75), size: CGSize(width: 36, height: 48))
        addWindow(at: CGPoint(x: w * 0.82, y: h * 0.70), size: CGSize(width: 36, height: 48))
    }

    private func addMoon(at pos: CGPoint) {
        let moon = SKShapeNode(circleOfRadius: 18)
        moon.fillColor   = SKColor(red: 1.0, green: 0.95, blue: 0.7, alpha: 1.0)
        moon.strokeColor = .clear
        moon.position    = pos
        moon.zPosition   = -1
        addChild(moon)

        // 満月グロー
        let glow = SKShapeNode(circleOfRadius: 24)
        glow.fillColor   = SKColor(red: 1.0, green: 0.95, blue: 0.7, alpha: 0.15)
        glow.strokeColor = .clear
        glow.position    = pos
        glow.zPosition   = -2
        addChild(glow)
    }

    private func addWindow(at pos: CGPoint, size: CGSize) {
        let window = SKShapeNode(rectOf: size, cornerRadius: 4)
        window.fillColor   = SKColor(red: 0.9, green: 0.85, blue: 0.5, alpha: 0.3)
        window.strokeColor = SKColor(red: 0.6, green: 0.5, blue: 0.3, alpha: 0.8)
        window.lineWidth   = 2
        window.position    = pos
        window.zPosition   = -1
        addChild(window)
    }

    // MARK: - Fish Targets

    private func setupTargets(sceneSize: CGSize) {
        let w = sceneSize.width
        let h = sceneSize.height

        let fishPositions: [CGPoint] = [
            CGPoint(x: w * 0.2, y: h * 0.55),
            CGPoint(x: w * 0.5, y: h * 0.58),
            CGPoint(x: w * 0.8, y: h * 0.55)
        ]

        for pos in fishPositions {
            let fish = FishTarget(at: pos)
            addChild(fish)
        }
    }
}

// MARK: - FishTarget

private class FishTarget: SKNode {

    private let label: SKLabelNode
    private(set) var isLit = false

    init(at pos: CGPoint) {
        label = SKLabelNode(text: "🐟")
        label.fontSize = 24
        super.init()
        position = pos
        name     = "fishTarget"
        addChild(label)
        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: 14)
        physicsBody?.categoryBitMask    = 0x1 << 7
        physicsBody?.contactTestBitMask = Ball.physicsCategory
        physicsBody?.isDynamic          = false
        physicsBody?.restitution        = 0.6
    }

    func hit() {
        isLit = true
        let bounce = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.08),
            SKAction.scale(to: 1.0, duration: 0.08)
        ])
        label.run(bounce)
    }

    func reset() {
        isLit = false
    }
}
