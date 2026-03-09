import Foundation

/// NULL cipher: interleaves every real character with a "null" filler character.
/// Encrypt: "HELLO" → "HXEXLXLXOX"
/// Decrypt: take every other character (indices 0, 2, 4…) → "HELLO"
class NullCipher: CipherEngine {
    var name: String = "Null"
    var description: String = "Hides the real message by inserting decoy letters between every character"
    var settings: [String: Any] = ["nullChar": "X"]

    func encrypt(_ text: String) -> String {
        let nullChar: Character = (settings["nullChar"] as? String)?.first ?? "X"
        var result = ""
        result.reserveCapacity(text.count * 2)
        for char in text {
            result.append(char)
            result.append(nullChar)
        }
        return result
    }

    func decrypt(_ text: String) -> String {
        let chars = Array(text)
        var result = ""
        result.reserveCapacity(chars.count / 2 + 1)
        var i = 0
        while i < chars.count {
            result.append(chars[i])
            i += 2
        }
        return result
    }
}
