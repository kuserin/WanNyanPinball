import Foundation

enum CharacterType: String, CaseIterable, Codable {
    // 猫キャラクター
    case tabby       = "たびー猫"
    case tuxedo      = "タキシード猫"
    case calico      = "三毛猫"
    case siamese     = "シャム猫"
    case mainecoon   = "メインクーン"

    // 犬キャラクター
    case shiba       = "柴犬"
    case poodle      = "プードル"
    case goldenRetriever = "ゴールデンレトリバー"
    case chihuahua   = "チワワ"
    case husky       = "ハスキー"

    var emoji: String {
        switch self {
        case .tabby:            return "🐱"
        case .tuxedo:           return "🐈"
        case .calico:           return "🐈‍⬛"
        case .siamese:          return "😺"
        case .mainecoon:        return "🦁"
        case .shiba:            return "🐕"
        case .poodle:           return "🐩"
        case .goldenRetriever:  return "🦮"
        case .chihuahua:        return "🐶"
        case .husky:            return "🐺"
        }
    }

    var catchScore: Int { 50_000 }
    var appearScore: Int { 10_000 }

    var isCat: Bool {
        switch self {
        case .tabby, .tuxedo, .calico, .siamese, .mainecoon: return true
        default: return false
        }
    }
}

struct Character: Codable {
    let type: CharacterType
    var isCaught: Bool = false
    var caughtAt: Date?

    mutating func catch_() {
        isCaught = true
        caughtAt = Date()
    }
}
