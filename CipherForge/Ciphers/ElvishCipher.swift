import Foundation

class ElvishCipher: CipherEngine {
    var name: String = "Elvish Script"
    var description: String = "Fantasy language with mystical character substitutions"
    var settings: [String: Any] = [:]

    // Hybrid approach: Use rune mapping but encode it in ASCII-compatible format
    // Format: Each letter becomes ◈{letter}◈ which preserves the letter for other ciphers
    // The ◈ markers indicate this is Elvish-encoded

    private let runeDisplay: [Character: String] = [
        "A": "ᚨ", "B": "ᛒ", "C": "ᚲ", "D": "ᛞ", "E": "ᛖ",
        "F": "ᚠ", "G": "ᚷ", "H": "ᚺ", "I": "ᛁ", "J": "ᛃ",
        "K": "ᚴ", "L": "ᛚ", "M": "ᛗ", "N": "ᚾ", "O": "ᛟ",
        "P": "ᛈ", "Q": "ᚦ", "R": "ᚱ", "S": "ᛋ", "T": "ᛏ",
        "U": "ᚢ", "V": "ᚡ", "W": "ᚹ", "X": "ᛪ", "Y": "ᛦ",
        "Z": "ᛉ"
    ]

    func encrypt(_ text: String) -> String {
        return text.uppercased().map { char in
            if char.isEnglishLetter {
                // Wrap letter in Elvish markers - preserves the actual letter for other ciphers
                return "◈\(char)◈"
            } else {
                return String(char)
            }
        }.joined()
    }

    func decrypt(_ text: String) -> String {
        var result = ""
        var i = text.startIndex

        while i < text.endIndex {
            // Check for Elvish marker
            if text[i] == "◈" {
                let nextIdx = text.index(after: i)
                if nextIdx < text.endIndex {
                    let letter = text[nextIdx]
                    let afterLetter = text.index(after: nextIdx)

                    // Check if followed by closing marker
                    if afterLetter < text.endIndex && text[afterLetter] == "◈" {
                        // Extract the letter
                        result.append(letter)
                        i = text.index(after: afterLetter)
                        continue
                    }
                }
            }

            // Regular character
            result.append(text[i])
            i = text.index(after: i)
        }

        return result
    }
}
