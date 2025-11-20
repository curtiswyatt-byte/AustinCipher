import Foundation

class NumberCipher: CipherEngine {
    var name: String = "Number Substitution"
    var description: String = "Replaces letters with numbers (A=1, B=2, etc.)"
    var settings: [String: Any] = [:]

    func encrypt(_ text: String) -> String {
        return text.uppercased().map { char in
            if char.isEnglishLetter {
                let value = Int(char.asciiValue!) - Int(Character("A").asciiValue!) + 1
                // Wrap number in markers so other ciphers skip it
                return "⬡\(value)⬡"
            } else {
                return String(char)
            }
        }.joined()
    }

    func decrypt(_ text: String) -> String {
        var result = ""
        var i = text.startIndex

        while i < text.endIndex {
            // Check for Number marker
            if text[i] == "⬡" {
                let nextIdx = text.index(after: i)
                if nextIdx < text.endIndex {
                    // Find the closing marker
                    var numStr = ""
                    var j = nextIdx

                    while j < text.endIndex && text[j] != "⬡" {
                        numStr.append(text[j])
                        j = text.index(after: j)
                    }

                    // Check if we found closing marker and have a valid number
                    if j < text.endIndex && text[j] == "⬡" {
                        if let num = Int(numStr), num >= 1, num <= 26 {
                            let charValue = Int(Character("A").asciiValue!) + num - 1
                            result.append(Character(UnicodeScalar(charValue)!))
                            i = text.index(after: j)
                            continue
                        }
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
