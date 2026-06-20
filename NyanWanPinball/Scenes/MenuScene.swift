import UIKit
import SpriteKit

class MenuScene: SKScene {

    override func didMove(to view: SKView) {
        setupBackground()
        setupTitle()
        setupButtons()
        setupHighScore()
    }

    private func setupBackground() {
        backgroundColor = SKColor(red: 0.08, green: 0.05, blue: 0.18, alpha: 1.0)

        // パーティクル的な星
        for _ in 0..<20 {
            let star = SKLabelNode(text: Bool.random() ? "🐱" : "🐶")
            star.fontSize = CGFloat.random(in: 10...20)
            star.alpha    = CGFloat.random(in: 0.2...0.5)
            star.position = CGPoint(x: CGFloat.random(in: 0...size.width),
                                    y: CGFloat.random(in: 0...size.height))
            addChild(star)
            let float = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -20...20),
                                y: CGFloat.random(in: -20...20),
                                duration: Double.random(in: 2...5)),
                SKAction.moveBy(x: CGFloat.random(in: -20...20),
                                y: CGFloat.random(in: -20...20),
                                duration: Double.random(in: 2...5))
            ])
            star.run(SKAction.repeatForever(float))
        }
    }

    private func setupTitle() {
        let nyan = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        nyan.text      = "🐱 Nyan & Wan 🐶"
        nyan.fontSize  = 28
        nyan.fontColor = .white
        nyan.position  = CGPoint(x: size.width / 2, y: size.height * 0.75)
        addChild(nyan)

        let pinball = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        pinball.text      = "PINBALL"
        pinball.fontSize  = 40
        pinball.fontColor = SKColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0)
        pinball.position  = CGPoint(x: size.width / 2, y: size.height * 0.67)
        addChild(pinball)

        // タイトルアニメ
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.8),
            SKAction.scale(to: 1.0,  duration: 0.8)
        ])
        pinball.run(SKAction.repeatForever(pulse))

        let beta = SKLabelNode(fontNamed: "AvenirNext-Bold")
        beta.text      = "β BETA"
        beta.fontSize  = 14
        beta.fontColor = .systemYellow
        beta.position  = CGPoint(x: size.width / 2, y: size.height * 0.62)
        addChild(beta)
    }

    private func setupButtons() {
        addButton(text: "▶  PLAY",
                  position: CGPoint(x: size.width / 2, y: size.height * 0.45),
                  name: "btnPlay",
                  color: SKColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 1.0))

        addButton(text: "🐱 CAT STAGE",
                  position: CGPoint(x: size.width / 2, y: size.height * 0.35),
                  name: "btnCat",
                  color: SKColor(red: 0.4, green: 0.2, blue: 0.6, alpha: 1.0))

        addButton(text: "🐶 DOG STAGE",
                  position: CGPoint(x: size.width / 2, y: size.height * 0.27),
                  name: "btnDog",
                  color: SKColor(red: 0.6, green: 0.35, blue: 0.1, alpha: 1.0))
    }

    private func addButton(text: String, position: CGPoint, name: String, color: SKColor) {
        let bg = SKShapeNode(rectOf: CGSize(width: 200, height: 44), cornerRadius: 22)
        bg.fillColor   = color
        bg.strokeColor = .white
        bg.lineWidth   = 1.5
        bg.position    = position
        bg.name        = name
        addChild(bg)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text     = text
        label.fontSize = 18
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name     = name
        bg.addChild(label)
    }

    private func setupHighScore() {
        let repo = ScoreRepository()
        let best = repo.topScore()

        let hs = SKLabelNode(fontNamed: "AvenirNext-Bold")
        hs.text      = best > 0 ? "BEST: \(best)" : "BEST: ---"
        hs.fontSize  = 16
        hs.fontColor = SKColor(red: 0.8, green: 0.8, blue: 0.3, alpha: 1.0)
        hs.position  = CGPoint(x: size.width / 2, y: size.height * 0.15)
        addChild(hs)
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)

        for node in nodes {
            switch node.name {
            case "btnPlay", "btnCat":
                transitionToGame(catField: true)
            case "btnDog":
                transitionToGame(catField: false)
            default:
                break
            }
        }
    }

    private func transitionToGame(catField: Bool) {
        let scene = GameScene(size: size)
        scene.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(scene, transition: transition)
    }
}
