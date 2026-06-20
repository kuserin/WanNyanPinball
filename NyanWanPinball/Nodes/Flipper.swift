import SpriteKit

enum FlipperSide {
    case left, right
}

class Flipper: SKNode {

    static let physicsCategory: UInt32 = 0x1 << 1

    let side: FlipperSide

    // isDynamic = false にして zRotation で制御する（物理干渉を避けるため）
    private let restAngle:   CGFloat
    private let activeAngle: CGFloat

    static let width:  CGFloat = 88
    static let height: CGFloat = 18

    init(side: FlipperSide) {
        self.side = side
        switch side {
        case .left:
            restAngle   = -CGFloat.pi / 5   // -36°
            activeAngle =  CGFloat.pi / 5   //  36°
        case .right:
            restAngle   =  CGFloat.pi + CGFloat.pi / 5   // 216°
            activeAngle =  CGFloat.pi - CGFloat.pi / 5   // 144°
        }
        super.init()
        name = (side == .left) ? "flipperLeft" : "flipperRight"
        setupVisual()
        setupPhysics()
        zRotation = restAngle
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Visual

    private func setupVisual() {
        let w = Flipper.width
        let h = Flipper.height

        // 台形パス（片端が太く、軸側が細い）
        let path = CGMutablePath()
        if side == .left {
            // 左フリッパー：左端（x = -w/2）が軸（細）、右端が太
            path.move(to:    CGPoint(x: -w/2,  y:  h * 0.22))
            path.addLine(to: CGPoint(x:  w/2,  y:  h * 0.44))
            path.addLine(to: CGPoint(x:  w/2,  y: -h * 0.44))
            path.addLine(to: CGPoint(x: -w/2,  y: -h * 0.22))
        } else {
            // 右フリッパー：右端（x = +w/2）が軸（細）、左端が太
            path.move(to:    CGPoint(x:  w/2,  y:  h * 0.22))
            path.addLine(to: CGPoint(x: -w/2,  y:  h * 0.44))
            path.addLine(to: CGPoint(x: -w/2,  y: -h * 0.44))
            path.addLine(to: CGPoint(x:  w/2,  y: -h * 0.22))
        }
        path.closeSubpath()

        let shape = SKShapeNode(path: path)
        shape.fillColor   = SKColor(red: 0.95, green: 0.55, blue: 0.1, alpha: 1.0)
        shape.strokeColor = SKColor(red: 1.0,  green: 0.75, blue: 0.3, alpha: 1.0)
        shape.lineWidth   = 1.5
        shape.zPosition   = 5
        addChild(shape)

        // 軸側の丸みピン
        let pivotRadius: CGFloat = 5
        let pinX: CGFloat = (side == .left) ? -w/2 : w/2
        let pin = SKShapeNode(circleOfRadius: pivotRadius)
        pin.fillColor   = SKColor(white: 0.9, alpha: 1)
        pin.strokeColor = .clear
        pin.position    = CGPoint(x: pinX, y: 0)
        pin.zPosition   = 6
        addChild(pin)
    }

    // MARK: - Physics

    private func setupPhysics() {
        let w = Flipper.width
        let h = Flipper.height
        var points: [CGPoint]
        if side == .left {
            points = [
                CGPoint(x: -w/2,  y:  h * 0.22),
                CGPoint(x:  w/2,  y:  h * 0.44),
                CGPoint(x:  w/2,  y: -h * 0.44),
                CGPoint(x: -w/2,  y: -h * 0.22)
            ]
        } else {
            points = [
                CGPoint(x:  w/2,  y:  h * 0.22),
                CGPoint(x: -w/2,  y:  h * 0.44),
                CGPoint(x: -w/2,  y: -h * 0.44),
                CGPoint(x:  w/2,  y: -h * 0.22)
            ]
        }
        let path = CGMutablePath()
        path.addLines(between: points)
        path.closeSubpath()

        physicsBody = SKPhysicsBody(polygonFrom: path)
        physicsBody?.categoryBitMask    = Flipper.physicsCategory
        physicsBody?.contactTestBitMask = Ball.physicsCategory
        physicsBody?.collisionBitMask   = Ball.physicsCategory
        physicsBody?.isDynamic          = false   // kinematic: zRotation で動かす
        physicsBody?.restitution        = 0.2
        physicsBody?.friction           = 0.1
    }

    // MARK: - Activation

    func activate() {
        removeAction(forKey: "flip")
        let action = SKAction.rotate(toAngle: activeAngle, duration: 0.07, shortestUnitArc: true)
        run(action, withKey: "flip")
    }

    func deactivate() {
        removeAction(forKey: "flip")
        let action = SKAction.rotate(toAngle: restAngle, duration: 0.12, shortestUnitArc: true)
        run(action, withKey: "flip")
    }
}
