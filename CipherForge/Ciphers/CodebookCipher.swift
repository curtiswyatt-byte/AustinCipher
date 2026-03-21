import Foundation

/// Codebook cipher: each letter A–Z maps to a custom code (any characters, no spaces).
/// Encrypt: tokens separated by spaces; original spaces become "_".
/// Decrypt: split by space, reverse-lookup each token.
class CodebookCipher: CipherEngine {
    var name: String = "Codebook"
    var description: String = "Custom letter-to-code substitution"
    var settings: [String: Any] = {
        var s: [String: Any] = [:]
        for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" { s[String(char)] = "" }
        return s
    }()

    func encrypt(_ text: String) -> String {
        let map = buildMap()
        var result = ""
        result.reserveCapacity(text.count * 3)
        var first = true
        for char in text.uppercased() {
            if !first { result.append(" ") }
            if char == " " {
                result.append("_")
            } else if let replacement = map[char] {
                result.append(contentsOf: replacement)
            } else {
                result.append(char)
            }
            first = false
        }
        return result
    }

    func decrypt(_ text: String) -> String {
        let reverseMap = buildReverseMap()
        let tokens = text.components(separatedBy: " ")
        var result = ""
        result.reserveCapacity(tokens.count)
        for token in tokens {
            if token == "_" {
                result.append(" ")
            } else if let letter = reverseMap[token] {
                result.append(letter)
            } else {
                result.append(contentsOf: token)
            }
        }
        return result
    }

    private func buildMap() -> [Character: String] {
        var map: [Character: String] = [:]
        for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {
            if let val = settings[String(char)] as? String, !val.isEmpty {
                map[char] = val
            }
        }
        return map
    }

    private func buildReverseMap() -> [String: Character] {
        var map: [String: Character] = [:]
        for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {
            if let val = settings[String(char)] as? String, !val.isEmpty {
                map[val] = char
            }
        }
        return map
    }
}
