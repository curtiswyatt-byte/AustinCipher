import Foundation

class ElvishCipher: CipherEngine {
    var name: String = "Elvish Script"
    var description: String = "Fantasy language with mystical character substitutions"
    var settings: [String: Any] = [:]

    private let runeDisplay: [Character: String] = [
        "A": "ᚨ", "B": "ᛒ", "C": "ᚲ", "D": "ᛞ", "E": "ᛖ",
        "F": "ᚠ", "G": "ᚷ", "H": "ᚺ", "I": "ᛁ", "J": "ᛃ",
        "K": "ᚴ", "L": "ᛚ", "M": "ᛗ", "N": "ᚾ", "O": "ᛟ",
        "P": "ᛈ", "Q": "ᚦ", "R": "ᚱ", "S": "ᛋ", "T": "ᛏ",
        "U": "ᚢ", "V": "ᚡ", "W": "ᚹ", "X": "ᛪ", "Y": "ᛦ",
        "Z": "ᛉ"
    ]

    private lazy var runeToLetter: [String: Character] = {
        Dictionary(uniqueKeysWithValues: runeDisplay.map { ($1, $0) })
    }()

    func encrypt(_ text: String) -> String {
        return text.uppercased().map { char in
            runeDisplay[char] ?? String(char)
        }.joined()
    }

    func decrypt(_ text: String) -> String {
        var result = ""
        result.reserveCapacity(text.unicodeScalars.count)
        for scalar in text.unicodeScalars {
            let runeStr = String(scalar)
            if let letter = runeToLetter[runeStr] {
                result.append(letter)
            } else {
                result.append(Character(scalar))
            }
        }
        return result
    }
}
