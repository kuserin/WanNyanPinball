import SpriteKit

// MARK: - Physics Categories

enum PhysicsCategory {
    static let wall:      UInt32 = 0x1 << 3
    static let drain:     UInt32 = 0x1 << 4
    static let slingshot: UInt32 = 0x1 << 5
}

// MARK: - GameScene

class GameScene: SKScene {

    // MARK: Nodes
    private var leftFlipper:  Flipper!
    private var rightFlipper: Flipper!
    private var bumpers:      [Bumper] = []
    private var ball:         Ball?

    // MARK: HUD
    private var scoreLabel: SKLabelNode!
    private var ballsLabel: SKLabelNode!
    private var comboLabel: SKLabelNode!

    // MARK: State
    private var gameManager  = GameManager()
    private var isBallInPlay = false

    // MARK: Layout — anchorPoint=(0,0) 前提（左下原点）
    private let wallThick: CGFloat = 10
    private let drainY:    CGFloat = 60

    private var flipperY:    CGFloat { drainY + 65 }
    private var launchLaneX: CGFloat { size.width - 24 }
    private var fieldRight:  CGFloat { size.width - wallThick - 32 }   // 発射レーン左壁

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        // ★ 必須: 左下を原点にする（全座標計算の前提）
        anchorPoint = CGPoint(x: 0, y: 0)

        print("[GameScene] didMove  size=\(size)  anchorPoint=\(anchorPoint)")

        physicsWorld.gravity         = CGVector(dx: 0, dy: -15)
        physicsWorld.contactDelegate = self

        buildBackground()
        buildWalls()
        buildDrain()
        buildSlingshots()
        buildFlippers()
        buildBumpers()
        buildHUD()
        launchBall()
    }

    // MARK: - Background

    private func buildBackground() {
        // ★ 明確な青にしてデバッグしやすくする
        backgroundColor = SKColor(red: 0.05, green: 0.10, blue: 0.60, alpha: 1.0)

        // フィールド内側（少し明るい青）
        let field = SKShapeNode(rect: CGRect(x: wallThick,
                                             y: 0,
                                             width: fieldRight - wallThick,
                                             height: size.height))
        field.fillColor   = SKColor(red: 0.08, green: 0.15, blue: 0.70, alpha: 1.0)
        field.strokeColor = .clear
        field.zPosition   = 0
        addChild(field)

        // ★ デバッグ用マーカー: 画面中央に黄色い円と文字を表示
        // anchorPoint=(0,0) なら (size.width/2, size.height/2) が画面中央になる
        let cx = size.width / 2
        let cy = size.height / 2

        let marker = SKShapeNode(circleOfRadius: 30)
        marker.fillColor   = SKColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 0.9)
        marker.strokeColor = .white
        marker.lineWidth   = 3
        marker.position    = CGPoint(x: cx, y: cy)
        marker.zPosition   = 100
        addChild(marker)

        let debugLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        debugLabel.text      = "CENTER"
        debugLabel.fontSize  = 10
        debugLabel.fontColor = .black
        debugLabel.verticalAlignmentMode   = .center
        debugLabel.horizontalAlignmentMode = .center
        debugLabel.position  = CGPoint(x: cx, y: cy)
        debugLabel.zPosition = 101
        addChild(debugLabel)

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text      = "🐱 NYAN & WAN PINBALL 🐶"
        title.fontSize  = 14
        title.fontColor = SKColor(white: 1.0, alpha: 0.35)
        title.horizontalAlignmentMode = .center
        title.position  = CGPoint(x: cx, y: size.height - 70)
        title.zPosition = 1
        addChild(title)
    }

    // MARK: - Walls

    private func buildWalls() {
        let h = size.height
        let w = size.width
        let t = wallThick

        // 左壁
        addWallEdge(from: CGPoint(x: t, y: 0),       to: CGPoint(x: t, y: h))
        // 天井
        addWallEdge(from: CGPoint(x: t, y: h - t),   to: CGPoint(x: w - t, y: h - t))
        // 発射レーン左仕切り
        addWallEdge(from: CGPoint(x: fieldRight, y: drainY + 60), to: CGPoint(x: fieldRight, y: h - t))
        // 発射レーン右壁
        addWallEdge(from: CGPoint(x: w - t, y: 0),   to: CGPoint(x: w - t, y: h))
        // 天井（発射レーン上蓋）
        addWallEdge(from: CGPoint(x: fieldRight, y: h - t), to: CGPoint(x: w - t, y: h - t))
    }

    private func addWallEdge(from a: CGPoint, to b: CGPoint) {
        let node = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: a)
        path.addLine(to: b)
        node.path        = path
        node.strokeColor = SKColor(red: 0.55, green: 0.55, blue: 1.0, alpha: 1.0)
        node.lineWidth   = wallThick
        node.lineCap     = .round
        node.zPosition   = 5

        node.physicsBody = SKPhysicsBody(edgeFrom: a, to: b)
        node.physicsBody?.categoryBitMask = PhysicsCategory.wall
        node.physicsBody?.isDynamic       = false
        node.physicsBody?.restitution     = 0.35
        node.physicsBody?.friction        = 0.05
        addChild(node)
    }

    // MARK: - Drain

    private func buildDrain() {
        // 赤いドレインライン（左壁〜発射レーン仕切りまで）
        let drainLine = SKShapeNode()
        let path      = CGMutablePath()
        path.move(to:    CGPoint(x: wallThick + 2, y: drainY))
        path.addLine(to: CGPoint(x: fieldRight - 2, y: drainY))
        drainLine.path        = path
        drainLine.strokeColor = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.9)
        drainLine.lineWidth   = 3
        drainLine.zPosition   = 6
        addChild(drainLine)

        // 物理センサー（不可視）
        let sensor = SKNode()
        sensor.name = "drain"
        sensor.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: wallThick, y: drainY),
                                           to:       CGPoint(x: fieldRight, y: drainY))
        sensor.physicsBody?.categoryBitMask    = PhysicsCategory.drain
        sensor.physicsBody?.contactTestBitMask = Ball.physicsCategory
        sensor.physicsBody?.isDynamic          = false
        addChild(sensor)
    }

    // MARK: - Slingshots

    private func buildSlingshots() {
        let baseY = flipperY + 10
        let topY  = flipperY + 90

        // 左スリングショット
        addSlingshot(from: CGPoint(x: wallThick + 6, y: topY),
                     to:   CGPoint(x: wallThick + 28, y: baseY))
        // 右スリングショット
        addSlingshot(from: CGPoint(x: fieldRight - 6, y: topY),
                     to:   CGPoint(x: fieldRight - 28, y: baseY))
    }

    private func addSlingshot(from a: CGPoint, to b: CGPoint) {
        let node = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: a)
        path.addLine(to: b)
        node.path        = path
        node.strokeColor = SKColor(red: 1.0, green: 0.75, blue: 0.0, alpha: 1.0)
        node.lineWidth   = 7
        node.lineCap     = .round
        node.zPosition   = 6
        node.name        = "slingshot"

        node.physicsBody = SKPhysicsBody(edgeFrom: a, to: b)
        node.physicsBody?.categoryBitMask    = PhysicsCategory.slingshot
        node.physicsBody?.contactTestBitMask = Ball.physicsCategory
        node.physicsBody?.isDynamic          = false
        node.physicsBody?.restitution        = 0.9
        node.physicsBody?.friction           = 0.0
        addChild(node)
    }

    // MARK: - Flippers

    private func buildFlippers() {
        let halfW = Flipper.width / 2
        let lx    = wallThick + halfW + 18
        let rx    = fieldRight - halfW - 18

        leftFlipper          = Flipper(side: .left)
        leftFlipper.position = CGPoint(x: lx, y: flipperY)
        addChild(leftFlipper)

        rightFlipper          = Flipper(side: .right)
        rightFlipper.position = CGPoint(x: rx, y: flipperY)
        addChild(rightFlipper)

        print("[Flipper] left=\(leftFlipper.position)  right=\(rightFlipper.position)  flipperY=\(flipperY)")
    }

    // MARK: - Bumpers

    private func buildBumpers() {
        let cx = (fieldRight + wallThick) / 2
        let cy = size.height * 0.60

        let positions: [CGPoint] = [
            CGPoint(x: cx,        y: cy + 80),
            CGPoint(x: cx - 75,   y: cy + 15),
            CGPoint(x: cx + 75,   y: cy + 15),
            CGPoint(x: cx - 40,   y: cy - 60),
            CGPoint(x: cx + 40,   y: cy - 60),
        ]

        for pos in positions {
            let b = Bumper(radius: 22, score: 100)
            b.position  = pos
            b.zPosition = 8
            addChild(b)
            bumpers.append(b)
        }
    }

    // MARK: - HUD

    private func buildHUD() {
        // 上部バー背景
        let barH: CGFloat = 40
        let bar = SKShapeNode(rect: CGRect(x: 0,
                                           y: size.height - barH,
                                           width: size.width,
                                           height: barH))
        bar.fillColor   = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.60)
        bar.strokeColor = .clear
        bar.zPosition   = 50
        addChild(bar)

        scoreLabel = makeLabelNode(text: "SCORE  0", size: 16, color: .white)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: wallThick + 6, y: size.height - barH + 11)
        scoreLabel.zPosition = 51
        addChild(scoreLabel)

        ballsLabel = makeLabelNode(text: "●●●", size: 16,
                                   color: SKColor(red: 0.4, green: 0.9, blue: 1.0, alpha: 1.0))
        ballsLabel.horizontalAlignmentMode = .right
        ballsLabel.position = CGPoint(x: size.width - 36, y: size.height - barH + 11)
        ballsLabel.zPosition = 51
        addChild(ballsLabel)

        comboLabel = makeLabelNode(text: "", size: 22, color: .yellow)
        comboLabel.position  = CGPoint(x: (fieldRight + wallThick) / 2, y: size.height * 0.42)
        comboLabel.alpha     = 0
        comboLabel.zPosition = 40
        addChild(comboLabel)
    }

    private func makeLabelNode(text: String, size: CGFloat, color: SKColor) -> SKLabelNode {
        let l = SKLabelNode(fontNamed: "AvenirNext-Bold")
        l.text     = text
        l.fontSize = size
        l.fontColor = color
        l.verticalAlignmentMode = .center
        return l
    }

    // MARK: - Ball

    private func launchBall() {
        guard !isBallInPlay else { return }

        let newBall      = Ball()
        let spawnX       = launchLaneX - 4
        let spawnY       = flipperY + 60
        newBall.position = CGPoint(x: spawnX, y: spawnY)
        newBall.zPosition = 10
        addChild(newBall)
        ball         = newBall
        isBallInPlay = true

        print("[Ball] spawned at (\(spawnX), \(spawnY))  sceneSize=\(self.size)")

        let wait    = SKAction.wait(forDuration: 0.12)
        let impulse = SKAction.run { [weak newBall] in
            newBall?.physicsBody?.applyImpulse(CGVector(dx: -4, dy: 450))
        }
        run(SKAction.sequence([wait, impulse]))
    }

    private func ballLost() {
        guard isBallInPlay else { return }
        isBallInPlay = false

        ball?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.12),
            SKAction.removeFromParent()
        ]))
        ball = nil

        let remaining = gameManager.ballLost()
        ballsLabel.text = String(repeating: "●", count: remaining)

        if remaining > 0 {
            showBanner("BALL LOST!", color: .red)
            run(SKAction.sequence([
                SKAction.wait(forDuration: 1.6),
                SKAction.run { [weak self] in self?.launchBall() }
            ]))
        } else {
            showGameOver()
        }
    }

    // MARK: - HUD Helpers

    private func updateHUD() {
        scoreLabel.text = "SCORE  \(gameManager.score)"
    }

    private func showBanner(_ text: String, color: SKColor) {
        comboLabel.text      = text
        comboLabel.fontColor = color
        comboLabel.alpha     = 1.0
        comboLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.9),
            SKAction.fadeOut(withDuration: 0.4)
        ]))
    }

    // MARK: - Game Over

    private func showGameOver() {
        physicsWorld.speed = 0

        let overlay = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        overlay.fillColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        overlay.strokeColor = .clear
        overlay.alpha     = 0
        overlay.zPosition = 80
        addChild(overlay)
        overlay.run(SKAction.fadeIn(withDuration: 0.4))

        let overLabel = makeLabelNode(text: "GAME OVER", size: 36,
                                      color: SKColor(red: 1, green: 0.25, blue: 0.25, alpha: 1))
        overLabel.position  = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        overLabel.zPosition = 81
        overLabel.alpha     = 0
        addChild(overLabel)

        let scoreVal = makeLabelNode(text: "SCORE  \(gameManager.score)", size: 24, color: .white)
        scoreVal.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        scoreVal.zPosition = 81
        scoreVal.alpha     = 0
        addChild(scoreVal)

        let tapLabel = makeLabelNode(text: "TAP TO RESTART", size: 15,
                                     color: SKColor(white: 0.8, alpha: 1))
        tapLabel.position  = CGPoint(x: size.width / 2, y: size.height / 2 - 60)
        tapLabel.zPosition = 81
        tapLabel.name      = "restart"
        tapLabel.alpha     = 0
        addChild(tapLabel)

        for (i, node) in [overLabel, scoreVal, tapLabel].enumerated() {
            node.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.3 + Double(i) * 0.2),
                SKAction.fadeIn(withDuration: 0.35)
            ]))
        }
    }

    private func restartGame() {
        removeAllChildren()
        removeAllActions()
        bumpers.removeAll()
        gameManager.reset()
        physicsWorld.speed = 1.0
        isBallInPlay = false
        ball = nil

        buildBackground()
        buildWalls()
        buildDrain()
        buildSlingshots()
        buildFlippers()
        buildBumpers()
        buildHUD()
        launchBall()
    }

    // MARK: - Character Event

    private func triggerCharacterEvent() {
        gameManager.addScore(10_000)
        updateHUD()
        showBanner("✨ キャラクター出現！", color: .yellow)
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)

        if physicsWorld.speed == 0 {
            restartGame()
            return
        }

        if loc.x < (fieldRight + wallThick) / 2 {
            leftFlipper.activate()
        } else {
            rightFlipper.activate()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if touch.location(in: self).x < (fieldRight + wallThick) / 2 {
            leftFlipper.deactivate()
        } else {
            rightFlipper.deactivate()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        leftFlipper?.deactivate()
        rightFlipper?.deactivate()
    }
}

// MARK: - SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {

    func didBegin(_ contact: SKPhysicsContact) {
        let masks = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if masks & PhysicsCategory.drain != 0 {
            DispatchQueue.main.async { [weak self] in self?.ballLost() }
            return
        }

        if masks & Bumper.physicsCategory != 0 {
            let bBody = (contact.bodyA.categoryBitMask == Bumper.physicsCategory)
                ? contact.bodyA : contact.bodyB
            if let bumper = bBody.node as? Bumper {
                gameManager.addScore(bumper.onHit())
                updateHUD()
                if bumper.reachedEventThreshold {
                    bumper.resetHitCount()
                    triggerCharacterEvent()
                }
            }
        }

        if masks & PhysicsCategory.slingshot != 0 {
            gameManager.addScore(50)
            updateHUD()
            let sBody = (contact.bodyA.categoryBitMask == PhysicsCategory.slingshot)
                ? contact.bodyA : contact.bodyB
            if let node = sBody.node as? SKShapeNode {
                let orig = node.strokeColor
                node.strokeColor = .white
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.1),
                    SKAction.run { node.strokeColor = orig }
                ]))
            }
        }
    }
}
