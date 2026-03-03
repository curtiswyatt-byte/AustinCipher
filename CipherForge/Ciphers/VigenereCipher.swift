import Foundation

class VigenereCipher: CipherEngine {
    var name: String = "Vigenère Cipher"
    var description: String = "Uses a keyword to create a complex polyalphabetic substitution"
    var settings: [String: Any] = ["keyword": "SECRET"]

    private static let aAscii = Int(Character("A").asciiValue!)

    func encrypt(_ text: String) -> String {
        let keyword = (settings["keyword"] as? String ?? "SECRET").uppercased()
        guard !keyword.isEmpty else { return text }
        let keyChars = Array(keyword)   // O(1) index access
        var result = ""
        result.reserveCapacity(text.count)
        var keyIndex = 0

        for char in text {
            guard char.isEnglishLetter else { result.append(char); continue }
            let shift = Int(keyChars[keyIndex % keyChars.count].asciiValue!) - Self.aAscii
            result.append(char.shifted(by: shift))
            keyIndex += 1
        }
        return result
    }

    func decrypt(_ text: String) -> String {
        let keyword = (settings["keyword"] as? String ?? "SECRET").uppercased()
        guard !keyword.isEmpty else { return text }
        let keyChars = Array(keyword)   // O(1) index access
        var result = ""
        result.reserveCapacity(text.count)
        var keyIndex = 0

        for char in text {
            guard char.isEnglishLetter else { result.append(char); continue }
            let shift = Int(keyChars[keyIndex % keyChars.count].asciiValue!) - Self.aAscii
            result.append(char.shifted(by: -shift))
            keyIndex += 1
        }
        return result
    }
}
