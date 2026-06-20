import UIKit
import SpriteKit

class ResultScene: SKScene {

    private let finalScore: Int
    private let caughtCharacters: [Character]

    init(size: CGSize, score: Int, caught: [Character]) {
        self.finalScore       = score
        self.caughtCharacters = caught
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        setupBackground()
        setupScore()
        setupCaughtCharacters()
        setupButtons()
        saveScore()
    }

    private func setupBackground() {
        backgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0)
    }

    private func setupScore() {
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text      = "RESULT"
        title.fontSize  = 32
        title.fontColor = .white
        title.position  = CGPoint(x: size.width / 2, y: size.height * 0.82)
        addChild(title)

        let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text      = "SCORE"
        scoreLabel.fontSize  = 18
        scoreLabel.fontColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        scoreLabel.position  = CGPoint(x: size.width / 2, y: size.height * 0.72)
        addChild(scoreLabel)

        let scoreValue = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        scoreValue.text      = "\(finalScore)"
        scoreValue.fontSize  = 48
        scoreValue.fontColor = SKColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0)
        scoreValue.position  = CGPoint(x: size.width / 2, y: size.height * 0.62)
        addChild(scoreValue)

        // ハイスコア判定
        let repo = ScoreRepository()
        let prev = repo.topScore()
        if finalScore >= prev {
            let newRecord = SKLabelNode(fontNamed: "AvenirNext-Heavy")
            newRecord.text      = "★ NEW RECORD! ★"
            newRecord.fontSize  = 20
            newRecord.fontColor = .systemYellow
            newRecord.position  = CGPoint(x: size.width / 2, y: size.height * 0.55)
            addChild(newRecord)
            let flash = SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.4),
                SKAction.fadeIn(withDuration: 0.4)
            ])
            newRecord.run(SKAction.repeatForever(flash))
        }
    }

    private func setupCaughtCharacters() {
        guard !caughtCharacters.isEmpty else { return }

        let header = SKLabelNode(fontNamed: "AvenirNext-Bold")
        header.text      = "ゲットしたキャラクター"
        header.fontSize  = 16
        header.fontColor = .white
        header.position  = CGPoint(x: size.width / 2, y: size.height * 0.48)
        addChild(header)

        let perRow = 5
        for (i, char) in caughtCharacters.enumerated() {
            let col = i % perRow
            let row = i / perRow
            let x = size.width / 2 + CGFloat(col - perRow / 2) * 40
            let y = size.height * 0.42 - CGFloat(row) * 40

            let emoji = SKLabelNode(text: char.type.emoji)
            emoji.fontSize = 24
            emoji.position = CGPoint(x: x, y: y)
            addChild(emoji)
        }
    }

    private func setupButtons() {
        addMenuButton(text: "もう一度プレイ", position: CGPoint(x: size.width / 2, y: size.height * 0.22), name: "btnRetry")
        addMenuButton(text: "タイトルへ戻る", position: CGPoint(x: size.width / 2, y: size.height * 0.13), name: "btnMenu")
    }

    private func addMenuButton(text: String, position: CGPoint, name: String) {
        let bg = SKShapeNode(rectOf: CGSize(width: 220, height: 44), cornerRadius: 22)
        bg.fillColor   = SKColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 1.0)
        bg.strokeColor = .white
        bg.lineWidth   = 1.5
        bg.position    = position
        bg.name        = name
        addChild(bg)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text     = text
        label.fontSize = 17
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name     = name
        bg.addChild(label)
    }

    private func saveScore() {
        let repo  = ScoreRepository()
        let entry = ScoreEntry(value: finalScore, date: Date(), playerName: "Player")
        repo.save(entry)
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        for node in nodes(at: location) {
            switch node.name {
            case "btnRetry":
                let scene = GameScene(size: size)
                scene.scaleMode = .aspectFill
                view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.4))
            case "btnMenu":
                let scene = MenuScene(size: size)
                scene.scaleMode = .aspectFill
                view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.4))
            default:
                break
            }
        }
    }
}
