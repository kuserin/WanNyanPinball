import Foundation

class GameManager {

    // MARK: - Score

    private(set) var score: Int = 0
    private(set) var highScore: Int = 0

    private let highScoreKey = "highScore"

    // MARK: - Balls

    private(set) var ballsRemaining: Int = 3
    static let initialBallCount = 3

    // MARK: - Multiplier

    private(set) var multiplier: Int = 1
    private var multiBallActive = false

    // MARK: - Init

    init() {
        highScore = UserDefaults.standard.integer(forKey: highScoreKey)
    }

    // MARK: - Score

    func addScore(_ points: Int) {
        score += points * multiplier
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: highScoreKey)
        }
    }

    // MARK: - Ball Management

    /// ボールロスト処理。残数を返す。
    @discardableResult
    func ballLost() -> Int {
        ballsRemaining = max(0, ballsRemaining - 1)
        multiplier     = 1
        multiBallActive = false
        return ballsRemaining
    }

    var isGameOver: Bool { ballsRemaining <= 0 }

    // MARK: - Multiball

    func activateMultiBall() {
        guard !multiBallActive else { return }
        multiBallActive = true
        multiplier      = 2
    }

    func deactivateMultiBall() {
        multiBallActive = false
        multiplier      = 1
    }

    // MARK: - Reset

    func reset() {
        score           = 0
        ballsRemaining  = GameManager.initialBallCount
        multiplier      = 1
        multiBallActive = false
    }
}
