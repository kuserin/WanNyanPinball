import Foundation

class CharacterManager {

    private let saveKey = "caughtCharacters"
    private(set) var collection: [CharacterType: Character] = [:]

    init() {
        loadCollection()
        // 未収録キャラクターの初期化
        for type in CharacterType.allCases where collection[type] == nil {
            collection[type] = Character(type: type)
        }
    }

    // MARK: - Appearance

    /// 現在のフィールドに応じてランダムなキャラクターを選出
    func pickRandomCharacter(forCatField: Bool) -> CharacterType {
        let pool = CharacterType.allCases.filter { $0.isCat == forCatField }
        return pool.randomElement() ?? (forCatField ? .tabby : .shiba)
    }

    // MARK: - Catch

    func catchCharacter(_ type: CharacterType) {
        collection[type]?.catch_()
        saveCollection()
    }

    var caughtCount: Int { collection.values.filter(\.isCaught).count }
    var totalCount: Int  { CharacterType.allCases.count }

    var isComplete: Bool { caughtCount == totalCount }

    // MARK: - Persistence

    private func saveCollection() {
        let values = Array(collection.values)
        if let data = try? JSONEncoder().encode(values) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func loadCollection() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let entries = try? JSONDecoder().decode([Character].self, from: data)
        else { return }
        for entry in entries {
            collection[entry.type] = entry
        }
    }
}
