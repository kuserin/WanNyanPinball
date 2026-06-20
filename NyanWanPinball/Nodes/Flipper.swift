import UIKit
import SpriteKit

enum FlipperSide {
    case left, right
}

class Flipper: SKSpriteNode {

    static let physicsCategory: UInt32 = 0x1 << 1

    private let side: FlipperSide
    private var joint: SKPhysicsJointPin?

    // 角度（ラジアン）
    private let restAngle: CGFloat
    private let activeAngle: CGFloat

    init(side: FlipperSide) {
        self.side = side

        let width: CGFloat  = 90
        let height: CGFloat = 20

        switch side {
        case .left:
            restAngle   = -CGFloat.pi / 6    // -30°（下がった状態）
            activeAngle =  CGFloat.pi / 5    //  36°（上がった状態）
        case .right:
            restAngle   =  CGFloat.pi + CGFloat.pi / 6   // 210°
            activeAngle =  CGFloat.pi - CGFloat.pi / 5   // 144°
        }

        let texture = Flipper.makeTexture(width: width, height: height, side: side)
        super.init(texture: texture, color: .clear, size: CGSize(width: width, height: height))

        name = side == .left ? "flipperLeft" : "flipperRight"
        setupPhysics(width: width, height: height)
        zRotation = restAngle
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func makeTexture(width: CGFloat, height: CGFloat, side: FlipperSide) -> SKTexture {
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let path = UIBezierPath()
            if side == .left {
                // 左フリッパー：左端が軸、右端が広い
                path.move(to: CGPoint(x: 0, y: height / 2))
                path.addLine(to: CGPoint(x: width, y: height / 2 + 4))
                path.addLine(to: CGPoint(x: width, y: height / 2 - 4))
                path.addLine(to: CGPoint(x: 0, y: height / 2 - height / 3))
                path.close()
            } else {
                // 右フリッパー：右端が軸、左端が広い
                path.move(to: CGPoint(x: width, y: height / 2))
                path.addLine(to: CGPoint(x: 0, y: height / 2 + 4))
                path.addLine(to: CGPoint(x: 0, y: height / 2 - 4))
                path.addLine(to: CGPoint(x: width, y: height / 2 - height / 3))
                path.close()
            }
            UIColor.systemOrange.setFill()
            path.fill()
            UIColor.white.withAlphaComponent(0.3).setFill()
            ctx.cgContext.fillEllipse(in: CGRect(x: 2, y: height * 0.3, width: 8, height: 8))
        }
        return SKTexture(image: image)
    }

    private func setupPhysics(width: CGFloat, height: CGFloat) {
        // 台形に近い形の物理ボディ
        let points: [CGPoint]
        if side == .left {
            points = [
                CGPoint(x: -width / 2, y:  height / 6),
                CGPoint(x:  width / 2, y:  height / 3),
                CGPoint(x:  width / 2, y: -height / 3),
                CGPoint(x: -width / 2, y: -height / 6)
            ]
        } else {
            points = [
                CGPoint(x:  width / 2, y:  height / 6),
                CGPoint(x: -width / 2, y:  height / 3),
                CGPoint(x: -width / 2, y: -height / 3),
                CGPoint(x:  width / 2, y: -height / 6)
            ]
        }
        var mutable = points
        physicsBody = SKPhysicsBody(polygonFrom: CGPath.polygon(from: &mutable))
        physicsBody?.categoryBitMask    = Flipper.physicsCategory
        physicsBody?.contactTestBitMask = Ball.physicsCategory
        physicsBody?.collisionBitMask   = Ball.physicsCategory
        physicsBody?.isDynamic          = true
        physicsBody?.affectedByGravity  = false
        physicsBody?.mass               = 100
        physicsBody?.restitution        = 0.1
        physicsBody?.friction           = 0.2
    }

    // MARK: - Attach to scene via pin joint

    func attach(to scene: SKScene) {
        scene.addChild(self)
        guard let physicsWorld = scene.physicsWorld as? SKPhysicsWorld? else { return }

        let anchorPoint: CGPoint
        if side == .left {
            anchorPoint = CGPoint(x: position.x - (size.width / 2) * cos(restAngle),
                                  y: position.y - (size.width / 2) * sin(restAngle))
        } else {
            anchorPoint = CGPoint(x: position.x + (size.width / 2) * cos(CGFloat.pi - restAngle),
                                  y: position.y - (size.width / 2) * sin(CGFloat.pi - restAngle))
        }
        _ = anchorPoint
        // Pin joint は GameScene で追加する
    }

    // MARK: - Activation

    func activate() {
        let rotate = SKAction.rotate(toAngle: activeAngle, duration: 0.06, shortestUnitArc: true)
        run(rotate, withKey: "flipperActivate")
    }

    func deactivate() {
        let rotate = SKAction.rotate(toAngle: restAngle, duration: 0.1, shortestUnitArc: true)
        run(rotate, withKey: "flipperDeactivate")
    }
}

// MARK: - CGPath helper

private extension CGPath {
    static func polygon(from points: inout [CGPoint]) -> CGPath {
        let path = CGMutablePath()
        guard points.count >= 3 else { return path }
        path.move(to: points[0])
        for i in 1..<points.count { path.addLine(to: points[i]) }
        path.closeSubpath()
        return path
    }
}
