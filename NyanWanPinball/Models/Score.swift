import Foundation

struct ScoreEntry: Codable, Comparable {
    let value: Int
    let date: Date
    let playerName: String

    static func < (lhs: ScoreEntry, rhs: ScoreEntry) -> Bool {
        lhs.value < rhs.value
    }
}

class ScoreRepository {

    private let key = "scoreHistory"
    private let maxEntries = 10

    func save(_ entry: ScoreEntry) {
        var entries = load()
        entries.append(entry)
        entries.sort(by: >)
        let trimmed = Array(entries.prefix(maxEntries))
        if let data = try? JSONEncoder().encode(trimmed) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func load() -> [ScoreEntry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let entries = try? JSONDecoder().decode([ScoreEntry].self, from: data)
        else { return [] }
        return entries
    }

    func topScore() -> Int {
        load().first?.value ?? 0
    }
}
