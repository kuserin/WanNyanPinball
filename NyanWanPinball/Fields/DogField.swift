import UIKit
import SpriteKit

/// 犬フィールド（Wan Stage）: 公園・昼の雰囲気。ボーンバンパー、ボールターゲット
class DogField: SKNode {

    static let bgColor = SKColor(red: 0.5, green: 0.75, blue: 0.95, alpha: 1.0)

    weak var parentScene: SKScene?

    init(in scene: SKScene) {
        self.parentScene = scene
        super.init()
        name = "dogField"
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

        // 太陽
        addSun(at: CGPoint(x: w * 0.8, y: h * 0.88))

        // 雲
        addCloud(at: CGPoint(x: w * 0.25, y: h * 0.85))
        addCloud(at: CGPoint(x: w * 0.65, y: h * 0.82))

        // 草地
        addGrass(sceneWidth: w, baseY: h * 0.08)

        // 木
        addTree(at: CGPoint(x: w * 0.15, y: h * 0.55))
        addTree(at: CGPoint(x: w * 0.85, y: h * 0.58))
    }

    private func addSun(at pos: CGPoint) {
        let sun = SKShapeNode(circleOfRadius: 22)
        sun.fillColor   = SKColor(red: 1.0, green: 0.9, blue: 0.1, alpha: 1.0)
        sun.strokeColor = .clear
        sun.position    = pos
        sun.zPosition   = -1
        addChild(sun)

        // 光線
        for i in 0..<8 {
            let angle = CGFloat(i) * (.pi / 4)
            let ray = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 26 * cos(angle), y: 26 * sin(angle)))
            path.addLine(to: CGPoint(x: 34 * cos(angle), y: 34 * sin(angle)))
            ray.path        = path
            ray.strokeColor = SKColor(red: 1.0, green: 0.9, blue: 0.1, alpha: 0.7)
            ray.lineWidth   = 3
            ray.lineCap     = .round
            ray.position    = pos
            ray.zPosition   = -1
            addChild(ray)
        }
    }

    private func addCloud(at pos: CGPoint) {
        let cloud = SKNode()
        cloud.position   = pos
        cloud.zPosition  = -1

        let offsets: [(CGFloat, CGFloat, CGFloat)] = [
            (0, 0, 18), (-20, -5, 14), (20, -5, 14), (-10, -10, 12), (10, -10, 12)
        ]
        for (x, y, r) in offsets {
            let circle = SKShapeNode(circleOfRadius: r)
            circle.fillColor   = .white
            circle.strokeColor = .clear
            circle.position    = CGPoint(x: x, y: y)
            cloud.addChild(circle)
        }
        addChild(cloud)

        // ゆっくり流れる
        let drift = SKAction.sequence([
            SKAction.moveBy(x: 15, y: 0, duration: 8),
            SKAction.moveBy(x: -15, y: 0, duration: 8)
        ])
        cloud.run(SKAction.repeatForever(drift))
    }

    private func addGrass(sceneWidth: CGFloat, baseY: CGFloat) {
        let grass = SKShapeNode(rectOf: CGSize(width: sceneWidth, height: 18))
        grass.fillColor   = SKColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 0.6)
        grass.strokeColor = .clear
        grass.position    = CGPoint(x: sceneWidth / 2, y: baseY)
        grass.zPosition   = -1
        addChild(grass)
    }

    private func addTree(at pos: CGPoint) {
        let tree = SKNode()
        tree.position  = pos
        tree.zPosition = -1

        // 幹
        let trunk = SKShapeNode(rectOf: CGSize(width: 10, height: 30))
        trunk.fillColor   = SKColor(red: 0.5, green: 0.3, blue: 0.1, alpha: 1.0)
        trunk.strokeColor = .clear
        trunk.position    = CGPoint(x: 0, y: -15)
        tree.addChild(trunk)

        // 葉
        let leaves = SKShapeNode(circleOfRadius: 22)
        leaves.fillColor   = SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
        leaves.strokeColor = .clear
        leaves.position    = CGPoint(x: 0, y: 10)
        tree.addChild(leaves)

        addChild(tree)
    }

    // MARK: - Ball Targets

    private func setupTargets(sceneSize: CGSize) {
        let w = sceneSize.width
        let h = sceneSize.height

        let positions: [CGPoint] = [
            CGPoint(x: w * 0.2, y: h * 0.55),
            CGPoint(x: w * 0.5, y: h * 0.58),
            CGPoint(x: w * 0.8, y: h * 0.55)
        ]

        for pos in positions {
            let target = BoneTarget(at: pos)
            addChild(target)
        }
    }
}

// MARK: - BoneTarget

private class BoneTarget: SKNode {

    private let label: SKLabelNode
    private(set) var isLit = false

    init(at pos: CGPoint) {
        label = SKLabelNode(text: "🦴")
        label.fontSize = 24
        super.init()
        position = pos
        name     = "boneTarget"
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
