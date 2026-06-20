import UIKit
import SpriteKit

class GameScene: SKScene {

    // MARK: - Nodes

    private var ball: Ball?
    private var leftFlipper: Flipper!
    private var rightFlipper: Flipper!
    private var bumpers: [Bumper] = []

    // MARK: - UI

    private var scoreLabel: SKLabelNode!
    private var ballsLabel: SKLabelNode!
    private var comboLabel: SKLabelNode!

    // MARK: - State

    private var gameManager: GameManager!
    private var isBallInPlay = false

    // MARK: - Layout constants

    private var fieldWidth:  CGFloat { size.width }
    private var fieldHeight: CGFloat { size.height }

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        gameManager = GameManager()
        physicsWorld.gravity     = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self

        setupBackground()
        setupWalls()
        setupGutter()
        setupFlippers()
        setupBumpers()
        setupHUD()
        launchBall()
    }

    // MARK: - Scene Setup

    private func setupBackground() {
        backgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0)

        // タイトルロゴ（ベータ用）
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "🐱 Nyan & Wan Pinball 🐶"
        title.fontSize = 16
        title.fontColor = .white
        title.position = CGPoint(x: fieldWidth / 2, y: fieldHeight - 30)
        addChild(title)
    }

    private func setupWalls() {
        let wallThickness: CGFloat = 8
        let wallColor = SKColor(red: 0.3, green: 0.3, blue: 0.5, alpha: 1.0)

        // 左壁
        addWall(rect: CGRect(x: 0, y: 0,
                             width: wallThickness, height: fieldHeight),
                color: wallColor, name: "wallLeft")
        // 右壁
        addWall(rect: CGRect(x: fieldWidth - wallThickness, y: 0,
                             width: wallThickness, height: fieldHeight),
                color: wallColor, name: "wallRight")
        // 天井
        addWall(rect: CGRect(x: 0, y: fieldHeight - wallThickness,
                             width: fieldWidth, height: wallThickness),
                color: wallColor, name: "wallTop")
    }

    private func addWall(rect: CGRect, color: SKColor, name: String) {
        let node = SKShapeNode(rect: rect)
        node.fillColor   = color
        node.strokeColor = .clear
        node.name        = name
        node.physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
        node.physicsBody?.categoryBitMask  = PhysicsCategory.wall
        node.physicsBody?.isDynamic        = false
        node.physicsBody?.restitution      = 0.3
        node.physicsBody?.friction         = 0.1
        addChild(node)
    }

    private func setupGutter() {
        // ドレイン（ボールロスト領域）
        let drainY: CGFloat = 40
        let drain = SKNode()
        drain.name = "drain"
        drain.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: drainY),
                                          to: CGPoint(x: fieldWidth, y: drainY))
        drain.physicsBody?.categoryBitMask  = PhysicsCategory.drain
        drain.physicsBody?.contactTestBitMask = Ball.physicsCategory
        drain.physicsBody?.isDynamic        = false
        addChild(drain)

        // 視覚的なドレインライン
        let drainLine = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 20, y: drainY))
        path.addLine(to: CGPoint(x: fieldWidth - 20, y: drainY))
        drainLine.path        = path
        drainLine.strokeColor = .red
        drainLine.lineWidth   = 2
        drainLine.alpha       = 0.5
        addChild(drainLine)

        // 左右のスリングショット（ガター壁）
        addSlingshot(isLeft: true,  drainY: drainY)
        addSlingshot(isLeft: false, drainY: drainY)
    }

    private func addSlingshot(isLeft: Bool, drainY: CGFloat) {
        let flipperY = drainY + 80
        let x: CGFloat = isLeft ? 40 : fieldWidth - 40
        let topX: CGFloat = isLeft ? 20 : fieldWidth - 20

        let node = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: topX, y: flipperY + 50))
        path.addLine(to: CGPoint(x: x, y: flipperY))
        node.path        = path
        node.strokeColor = SKColor(red: 0.8, green: 0.4, blue: 0.0, alpha: 1.0)
        node.lineWidth   = 6
        node.name        = "slingshot"
        node.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: topX, y: flipperY + 50),
                                         to: CGPoint(x: x, y: flipperY))
        node.physicsBody?.categoryBitMask    = PhysicsCategory.slingshot
        node.physicsBody?.contactTestBitMask = Ball.physicsCategory
        node.physicsBody?.isDynamic          = false
        node.physicsBody?.restitution        = 0.8
        addChild(node)
    }

    private func setupFlippers() {
        let drainY: CGFloat = 40
        let flipperY = drainY + 60
        let margin: CGFloat = 70

        leftFlipper          = Flipper(side: .left)
        leftFlipper.position = CGPoint(x: margin, y: flipperY)
        addChild(leftFlipper)

        rightFlipper          = Flipper(side: .right)
        rightFlipper.position = CGPoint(x: fieldWidth - margin, y: flipperY)
        addChild(rightFlipper)
    }

    private func setupBumpers() {
        let cx = fieldWidth / 2
        let cy = fieldHeight * 0.65

        // バンパー配置（三角形パターン）
        let positions: [(CGFloat, CGFloat)] = [
            (cx,          cy + 60),
            (cx - 70,     cy),
            (cx + 70,     cy),
            (cx - 35,     cy - 60),
            (cx + 35,     cy - 60)
        ]

        for (x, y) in positions {
            let bumper = Bumper(radius: 22, score: 100)
            bumper.position = CGPoint(x: x, y: y)
            addChild(bumper)
            bumpers.append(bumper)
        }
    }

    private func setupHUD() {
        // スコアラベル
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text             = "SCORE: 0"
        scoreLabel.fontSize         = 18
        scoreLabel.fontColor        = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position         = CGPoint(x: 16, y: fieldHeight - 55)
        addChild(scoreLabel)

        // ボール残数
        ballsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        ballsLabel.text             = "BALLS: 3"
        ballsLabel.fontSize         = 16
        ballsLabel.fontColor        = SKColor(red: 0.8, green: 0.8, blue: 0.3, alpha: 1.0)
        ballsLabel.horizontalAlignmentMode = .right
        ballsLabel.position         = CGPoint(x: fieldWidth - 16, y: fieldHeight - 55)
        addChild(ballsLabel)

        // コンボラベル
        comboLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        comboLabel.text    = ""
        comboLabel.fontSize = 22
        comboLabel.fontColor = .yellow
        comboLabel.position  = CGPoint(x: fieldWidth / 2, y: fieldHeight * 0.45)
        comboLabel.alpha     = 0
        addChild(comboLabel)
    }

    // MARK: - Ball Management

    private func launchBall() {
        guard !isBallInPlay else { return }

        let newBall = Ball()
        let launchX = fieldWidth - 30
        let launchY: CGFloat = 120
        newBall.position = CGPoint(x: launchX, y: launchY)
        addChild(newBall)
        ball = newBall
        isBallInPlay = true

        newBall.physicsBody?.applyImpulse(CGVector(dx: -2, dy: 500))
    }

    private func ballLost() {
        isBallInPlay = false
        ball?.removeFromParent()
        ball = nil

        let remaining = gameManager.ballLost()
        ballsLabel.text = "BALLS: \(remaining)"

        if remaining > 0 {
            let wait = SKAction.wait(forDuration: 1.5)
            let relaunch = SKAction.run { [weak self] in self?.launchBall() }
            run(SKAction.sequence([wait, relaunch]))
        } else {
            gameOver()
        }
    }

    private func gameOver() {
        let overlay = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        overlay.fillColor = .black
        overlay.alpha     = 0
        addChild(overlay)
        overlay.run(SKAction.fadeAlpha(to: 0.65, duration: 0.5))

        let msg = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        msg.text     = "GAME OVER"
        msg.fontSize = 36
        msg.fontColor = .red
        msg.position  = CGPoint(x: fieldWidth / 2, y: fieldHeight / 2 + 30)
        msg.alpha     = 0
        addChild(msg)
        msg.run(SKAction.fadeIn(withDuration: 0.5))

        let finalScore = SKLabelNode(fontNamed: "AvenirNext-Bold")
        finalScore.text      = "SCORE: \(gameManager.score)"
        finalScore.fontSize  = 24
        finalScore.fontColor = .white
        finalScore.position  = CGPoint(x: fieldWidth / 2, y: fieldHeight / 2 - 10)
        finalScore.alpha     = 0
        addChild(finalScore)
        finalScore.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.fadeIn(withDuration: 0.5)
        ]))
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let x = touch.location(in: self).x

        if x < fieldWidth / 2 {
            leftFlipper.activate()
        } else {
            rightFlipper.activate()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let x = touch.location(in: self).x

        if x < fieldWidth / 2 {
            leftFlipper.deactivate()
        } else {
            rightFlipper.deactivate()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        leftFlipper.deactivate()
        rightFlipper.deactivate()
    }

    // MARK: - HUD Update

    private func updateHUD() {
        scoreLabel.text = "SCORE: \(gameManager.score)"
    }

    private func showCombo(text: String) {
        comboLabel.text  = text
        comboLabel.alpha = 1.0
        comboLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.8),
            SKAction.fadeOut(withDuration: 0.4)
        ]))
    }
}

// MARK: - SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {

    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        // ボールがドレインに触れた
        if bodyA.categoryBitMask == PhysicsCategory.drain ||
           bodyB.categoryBitMask == PhysicsCategory.drain {
            ballLost()
            return
        }

        // ボールがバンパーに当たった
        let bumperBody = bodyA.categoryBitMask == Bumper.physicsCategory ? bodyA : bodyB
        if bumperBody.categoryBitMask == Bumper.physicsCategory,
           let bumperNode = bumperBody.node as? Bumper {

            let gained = bumperNode.onHit()
            gameManager.addScore(gained)
            updateHUD()

            // バンパーを一定数叩くとイベント発火
            if bumperNode.reachedEventThreshold {
                bumperNode.resetHitCount()
                triggerCharacterEvent()
            }
        }

        // スリングショット
        if bodyA.categoryBitMask == PhysicsCategory.slingshot ||
           bodyB.categoryBitMask == PhysicsCategory.slingshot {
            gameManager.addScore(50)
            updateHUD()
        }
    }

    private func triggerCharacterEvent() {
        showCombo(text: "✨ キャラクター出現！ ✨")
        gameManager.addScore(10_000)
        updateHUD()
        // TODO: CharacterManager と連携してキャラクターを表示する
    }
}

// MARK: - Physics Categories

enum PhysicsCategory {
    static let wall:       UInt32 = 0x1 << 3
    static let drain:      UInt32 = 0x1 << 4
    static let slingshot:  UInt32 = 0x1 << 5
}
