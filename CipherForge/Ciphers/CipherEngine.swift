import Foundation

protocol CipherEngine {
    var name: String { get }
    var description: String { get }
    var settings: [String: Any] { get set }

    func encrypt(_ text: String) -> String
    func decrypt(_ text: String) -> String
}

// Helper extension for character manipulation
extension Character {
    var isEnglishLetter: Bool {
        return ("a"..."z").contains(self.lowercased().first ?? Character(""))
    }

    func shifted(by amount: Int) -> Character {
        let isUpperCase = self.isUppercase
        let base = isUpperCase ? Character("A") : Character("a")
        let baseValue = Int(base.asciiValue!)
        let charValue = Int(self.asciiValue!)
        let shifted = ((charValue - baseValue + amount) % 26 + 26) % 26
        return Character(UnicodeScalar(baseValue + shifted)!)
    }
}
