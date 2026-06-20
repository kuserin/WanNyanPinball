import AVFoundation
import SpriteKit

class SoundManager {

    static let shared = SoundManager()

    private var bgmPlayer: AVAudioPlayer?
    private var isMuted = false

    // SpriteKit のサウンドアクション（低レイテンシ）
    private let bumperHitAction = SKAction.playSoundFileNamed("bumper_hit.wav",  waitForCompletion: false)
    private let flipperAction   = SKAction.playSoundFileNamed("flipper.wav",     waitForCompletion: false)
    private let charAppearAction = SKAction.playSoundFileNamed("char_appear.wav", waitForCompletion: false)
    private let drainAction     = SKAction.playSoundFileNamed("drain.wav",       waitForCompletion: false)

    private init() {}

    // MARK: - BGM

    func playBGM(named fileName: String, loop: Bool = true) {
        guard !isMuted,
              let url = Bundle.main.url(forResource: fileName, withExtension: nil)
        else { return }

        bgmPlayer?.stop()
        bgmPlayer = try? AVAudioPlayer(contentsOf: url)
        bgmPlayer?.numberOfLoops = loop ? -1 : 0
        bgmPlayer?.volume = 0.5
        bgmPlayer?.play()
    }

    func stopBGM() {
        bgmPlayer?.stop()
    }

    func fadeBGM(to volume: Float, duration: TimeInterval = 1.0) {
        bgmPlayer?.setVolume(volume, fadeDuration: duration)
    }

    // MARK: - SE (via SKNode)

    func playBumperHit(on node: SKNode) {
        guard !isMuted else { return }
        node.run(bumperHitAction)
    }

    func playFlipper(on node: SKNode) {
        guard !isMuted else { return }
        node.run(flipperAction)
    }

    func playCharacterAppear(on node: SKNode) {
        guard !isMuted else { return }
        node.run(charAppearAction)
    }

    func playDrain(on node: SKNode) {
        guard !isMuted else { return }
        node.run(drainAction)
    }

    // MARK: - Mute Toggle

    func toggleMute() {
        isMuted = !isMuted
        bgmPlayer?.volume = isMuted ? 0 : 0.5
    }
}
