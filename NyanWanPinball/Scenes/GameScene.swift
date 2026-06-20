import SpriteKit

// MARK: - Physics Categories (全ファイルから参照)

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
    private var scoreLabel:  SKLabelNode!
    private var ballsLabel:  SKLabelNode!
    private var comboLabel:  SKLabelNode!

    // MARK: State
    private var gameManager   = GameManager()
    private var isBallInPlay  = false

    // MARK: Layout
    private let wallThick:   CGFloat = 10
    private let drainY:      CGFloat = 55
    private var flipperY:    CGFloat { drainY + 62 }
    private var launchLaneX: CGFloat { size.width - 22 }

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        print("[GameScene] didMove — scene size: \(size)")

        physicsWorld.gravity          = CGVector(dx: 0, dy: -18)
        physicsWorld.contactDelegate  = self
        physicsWorld.speed            = 1.0

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
        // はっきりした紫（デバッグ用）
        backgroundColor = .purple

        // 中央レーン（見やすい明るめの紫）
        let lane = SKShapeNode(rectOf: CGSize(width: size.width - wallThick * 2,
                                              height: size.height))
        lane.fillColor   = SKColor(red: 0.45, green: 0.15, blue: 0.65, alpha: 1.0)
        lane.strokeColor = .clear
        lane.position    = CGPoint(x: size.width / 2, y: size.height / 2)
        lane.zPosition   = -10
        addChild(lane)

        // 発射レーン（右端の細い縦帯）
        let launchLane = SKShapeNode(rectOf: CGSize(width: 30, height: size.height))
        launchLane.fillColor   = SKColor(red: 0.35, green: 0.10, blue: 0.50, alpha: 1.0)
        launchLane.strokeColor = SKColor(white: 1.0, alpha: 0.4)
        launchLane.lineWidth   = 1
        launchLane.position    = CGPoint(x: launchLaneX, y: size.height / 2)
        launchLane.zPosition   = -9
        addChild(launchLane)

        // フィールドタイトル（薄く）
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text      = "🐱 NYAN & WAN 🐶"
        title.fontSize  = 13
        title.fontColor = SKColor(white: 1.0, alpha: 0.25)
        title.position  = CGPoint(x: size.width / 2 - 12, y: size.height - 28)
        title.zPosition = -5
        addChild(title)

        // ガイドライン（装飾）
        addGuideLine(y: size.height * 0.50)
        addGuideLine(y: size.height * 0.35)
    }

    private func addGuideLine(y: CGFloat) {
        let line = SKShapeNode()
        let path = CGMutablePath()
        path.move(to:    CGPoint(x: wallThick + 2, y: y))
        path.addLine(to: CGPoint(x: size.width - wallThick - 30, y: y))
        let shape       = SKShapeNode(path: path)
        shape.strokeColor = SKColor(white: 1.0, alpha: 0.06)
        shape.lineWidth   = 1
        shape.zPosition   = -5
        _ = line
        addChild(shape)
    }

    // MARK: - Walls

    private func buildWalls() {
        // 左壁
        addStaticEdge(
            from: CGPoint(x: wallThick, y: 0),
            to:   CGPoint(x: wallThick, y: size.height),
            color: SKColor(red: 0.3, green: 0.2, blue: 0.6, alpha: 1.0),
            thickness: wallThick,
            category: PhysicsCategory.wall
        )
        // 右壁（発射レーンの左側まで）
        addStaticEdge(
            from: CGPoint(x: size.width - wallThick - 28, y: drainY + 80),
            to:   CGPoint(x: size.width - wallThick - 28, y: size.height),
            color: SKColor(red: 0.3, green: 0.2, blue: 0.6, alpha: 1.0),
            thickness: wallThick,
            category: PhysicsCategory.wall
        )
        // 天井
        addStaticEdge(
            from: CGPoint(x: wallThick, y: size.height - wallThick),
            to:   CGPoint(x: size.width - wallThick, y: size.height - wallThick),
            color: SKColor(red: 0.3, green: 0.2, blue: 0.6, alpha: 1.0),
            thickness: wallThick,
            category: PhysicsCategory.wall
        )
        // 発射レーン右壁
        addStaticEdge(
            from: CGPoint(x: size.width - wallThick, y: 0),
            to:   CGPoint(x: size.width - wallThick, y: size.height),
            color: SKColor(red: 0.2, green: 0.15, blue: 0.4, alpha: 1.0),
            thickness: wallThick,
            category: PhysicsCategory.wall
        )
        // 発射レーン仕切り壁の上端を丸く閉じる
        addStaticEdge(
            from: CGPoint(x: size.width - wallThick - 28, y: size.height - wallThick),
            to:   CGPoint(x: size.width - wallThick,     y: size.height - wallThick),
            color: SKColor(red: 0.3, green: 0.2, blue: 0.6, alpha: 1.0),
            thickness: wallThick,
            category: PhysicsCategory.wall
        )
    }

    private func addStaticEdge(from a: CGPoint, to b: CGPoint,
                                color: SKColor, thickness: CGFloat,
                                category: UInt32) {
        let shape       = SKShapeNode()
        let path        = CGMutablePath()
        path.move(to: a)
        path.addLine(to: b)
        shape.path        = path
        shape.strokeColor = color
        shape.lineWidth   = thickness
        shape.lineCap     = .round
        shape.zPosition   = 1

        shape.physicsBody = SKPhysicsBody(edgeFrom: a, to: b)
        shape.physicsBody?.categoryBitMask  = category
        shape.physicsBody?.isDynamic        = false
        shape.physicsBody?.restitution      = 0.4
        shape.physicsBody?.friction         = 0.1
        addChild(shape)
    }

    // MARK: - Drain

    private func buildDrain() {
        // ドレインセンサー（不可視）
        let drainNode       = SKNode()
        drainNode.name      = "drain"
        drainNode.physicsBody = SKPhysicsBody(
            edgeFrom: CGPoint(x: wallThick, y: drainY),
            to:       CGPoint(x: size.width - wallThick, y: drainY)
        )
        drainNode.physicsBody?.categoryBitMask    = PhysicsCategory.drain
        drainNode.physicsBody?.contactTestBitMask = Ball.physicsCategory
        drainNode.physicsBody?.isDynamic          = false
        addChild(drainNode)

        // 視覚ライン
        let drainLine   = SKShapeNode()
        let path        = CGMutablePath()
        path.move(to:    CGPoint(x: wallThick + 5, y: drainY))
        path.addLine(to: CGPoint(x: size.width - wallThick - 30, y: drainY))
        drainLine.path        = path
        drainLine.strokeColor = SKColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 0.7)
        drainLine.lineWidth   = 2
        drainLine.zPosition   = 2
        addChild(drainLine)
    }

    // MARK: - Slingshots

    private func buildSlingshots() {
        let topY  = flipperY + 80
        let botY  = flipperY + 8
        let leftX = wallThick + 8

        // 左スリングショット
        addSlingshot(
            from: CGPoint(x: leftX,       y: topY),
            to:   CGPoint(x: leftX + 20,  y: botY)
        )
        // 右スリングショット
        let rightX = size.width - wallThick - 36
        addSlingshot(
            from: CGPoint(x: rightX,      y: topY),
            to:   CGPoint(x: rightX - 20, y: botY)
        )
    }

    private func addSlingshot(from a: CGPoint, to b: CGPoint) {
        let node    = SKShapeNode()
        let path    = CGMutablePath()
        path.move(to: a)
        path.addLine(to: b)
        node.path        = path
        node.strokeColor = SKColor(red: 1.0, green: 0.6, blue: 0.1, alpha: 1.0)
        node.lineWidth   = 6
        node.lineCap     = .round
        node.zPosition   = 2
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

        leftFlipper          = Flipper(side: .left)
        leftFlipper.position = CGPoint(x: wallThick + halfW + 14, y: flipperY)
        addChild(leftFlipper)

        rightFlipper          = Flipper(side: .right)
        rightFlipper.position = CGPoint(x: size.width - wallThick - halfW - 36, y: flipperY)
        addChild(rightFlipper)

        print("[Flipper] left  pos=\(leftFlipper.position)  flipperY=\(flipperY)")
        print("[Flipper] right pos=\(rightFlipper.position)  sceneW=\(size.width)")
    }

    // MARK: - Bumpers

    private func buildBumpers() {
        let cx = (size.width - wallThick - 30) / 2 + wallThick
        let cy = size.height * 0.62

        let positions: [(CGFloat, CGFloat)] = [
            (cx,       cy + 70),
            (cx - 72,  cy + 10),
            (cx + 72,  cy + 10),
            (cx - 36,  cy - 55),
            (cx + 36,  cy - 55)
        ]

        for (x, y) in positions {
            let bumper = Bumper(radius: 22, score: 100)
            bumper.position = CGPoint(x: x, y: y)
            addChild(bumper)
            bumpers.append(bumper)
        }
    }

    // MARK: - HUD

    private func buildHUD() {
        let hudBg = SKShapeNode(rectOf: CGSize(width: size.width, height: 44))
        hudBg.fillColor   = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.55)
        hudBg.strokeColor = .clear
        hudBg.position    = CGPoint(x: size.width / 2, y: size.height - 36)
        hudBg.zPosition   = 50
        addChild(hudBg)

        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text               = "SCORE  0"
        scoreLabel.fontSize           = 17
        scoreLabel.fontColor          = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode   = .center
        scoreLabel.position           = CGPoint(x: wallThick + 8, y: size.height - 36)
        scoreLabel.zPosition          = 51
        addChild(scoreLabel)

        ballsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        ballsLabel.text               = "●●●"
        ballsLabel.fontSize           = 16
        ballsLabel.fontColor          = SKColor(red: 0.4, green: 0.85, blue: 1.0, alpha: 1.0)
        ballsLabel.horizontalAlignmentMode = .right
        ballsLabel.verticalAlignmentMode   = .center
        ballsLabel.position           = CGPoint(x: size.width - 38, y: size.height - 36)
        ballsLabel.zPosition          = 51
        addChild(ballsLabel)

        comboLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        comboLabel.text      = ""
        comboLabel.fontSize  = 22
        comboLabel.fontColor = .yellow
        comboLabel.position  = CGPoint(x: size.width / 2 - 14, y: size.height * 0.44)
        comboLabel.alpha     = 0
        comboLabel.zPosition = 30
        addChild(comboLabel)
    }

    // MARK: - Ball

    private func launchBall() {
        guard !isBallInPlay else { return }

        let newBall       = Ball()
        newBall.position  = CGPoint(x: launchLaneX - 4, y: flipperY + 50)
        newBall.zPosition = 10
        addChild(newBall)
        ball         = newBall
        isBallInPlay = true

        print("[Ball] spawned at \(newBall.position)  radius=\(Ball.radius)  sceneSize=\(size)")

        // 少し待ってから発射（物理安定後）
        let wait    = SKAction.wait(forDuration: 0.15)
        let impulse = SKAction.run { [weak newBall] in
            newBall?.physicsBody?.applyImpulse(CGVector(dx: -3, dy: 480))
        }
        run(SKAction.sequence([wait, impulse]))
    }

    private func ballLost() {
        guard isBallInPlay else { return }
        isBallInPlay = false
        ball?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.15),
            SKAction.removeFromParent()
        ]))
        ball = nil

        let remaining = gameManager.ballLost()
        updateBallsDisplay(remaining: remaining)

        if remaining > 0 {
            showBanner(text: "BALL LOST!", color: .red)
            run(SKAction.sequence([
                SKAction.wait(forDuration: 1.8),
                SKAction.run { [weak self] in self?.launchBall() }
            ]))
        } else {
            showGameOver()
        }
    }

    // MARK: - HUD Update

    private func updateHUD() {
        scoreLabel.text = "SCORE  \(gameManager.score)"
    }

    private func updateBallsDisplay(remaining: Int) {
        ballsLabel.text = String(repeating: "●", count: remaining)
    }

    private func showBanner(text: String, color: SKColor) {
        comboLabel.text      = text
        comboLabel.fontColor = color
        comboLabel.alpha     = 1.0
        comboLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeOut(withDuration: 0.4)
        ]))
    }

    // MARK: - Game Over

    private func showGameOver() {
        physicsWorld.speed = 0

        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = .black
        overlay.alpha     = 0
        overlay.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 90
        addChild(overlay)

        overlay.run(SKAction.fadeAlpha(to: 0.72, duration: 0.45))

        let over = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        over.text      = "GAME OVER"
        over.fontSize  = 38
        over.fontColor = SKColor(red: 1.0, green: 0.25, blue: 0.25, alpha: 1.0)
        over.position  = CGPoint(x: size.width / 2, y: size.height / 2 + 45)
        over.zPosition = 91
        over.alpha     = 0
        addChild(over)

        let finalLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        finalLabel.text      = "SCORE  \(gameManager.score)"
        finalLabel.fontSize  = 26
        finalLabel.fontColor = .white
        finalLabel.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        finalLabel.zPosition = 91
        finalLabel.alpha     = 0
        addChild(finalLabel)

        let restartLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        restartLabel.text      = "TAP TO RESTART"
        restartLabel.fontSize  = 16
        restartLabel.fontColor = SKColor(white: 0.8, alpha: 1.0)
        restartLabel.position  = CGPoint(x: size.width / 2, y: size.height / 2 - 55)
        restartLabel.zPosition = 91
        restartLabel.name      = "restartLabel"
        restartLabel.alpha     = 0
        addChild(restartLabel)

        let appear = SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.fadeIn(withDuration: 0.4)
        ])
        over.run(appear)
        finalLabel.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.fadeIn(withDuration: 0.4)]))
        restartLabel.run(SKAction.sequence([SKAction.wait(forDuration: 0.9), SKAction.fadeIn(withDuration: 0.4)]))
    }

    private func restartGame() {
        removeAllChildren()
        removeAllActions()
        gameManager.reset()
        physicsWorld.speed = 1.0

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
        showBanner(text: "✨ キャラクター出現！ ✨", color: .yellow)
        // TODO: CharacterManager と連携してキャラクターノードを表示する
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)

        // ゲームオーバー後のリスタート
        if nodes(at: loc).contains(where: { $0.name == "restartLabel" }) ||
           physicsWorld.speed == 0 {
            restartGame()
            return
        }

        if loc.x < size.width / 2 {
            leftFlipper.activate()
        } else {
            rightFlipper.activate()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)

        if loc.x < size.width / 2 {
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

        // ドレイン接触
        if masks & PhysicsCategory.drain != 0 {
            DispatchQueue.main.async { [weak self] in self?.ballLost() }
            return
        }

        // バンパー接触
        if masks & Bumper.physicsCategory != 0 {
            let bumperBody = contact.bodyA.categoryBitMask == Bumper.physicsCategory
                ? contact.bodyA : contact.bodyB
            if let bumper = bumperBody.node as? Bumper {
                let gained = bumper.onHit()
                gameManager.addScore(gained)
                updateHUD()

                if bumper.reachedEventThreshold {
                    bumper.resetHitCount()
                    triggerCharacterEvent()
                }
            }
        }

        // スリングショット接触
        if masks & PhysicsCategory.slingshot != 0 {
            gameManager.addScore(50)
            updateHUD()
            // スリングショット光らせる
            let slingshotBody = contact.bodyA.categoryBitMask == PhysicsCategory.slingshot
                ? contact.bodyA : contact.bodyB
            if let node = slingshotBody.node as? SKShapeNode {
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
