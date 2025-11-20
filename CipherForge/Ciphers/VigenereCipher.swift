import Foundation

class VigenereCipher: CipherEngine {
    var name: String = "Vigenère Cipher"
    var description: String = "Uses a keyword to create a complex polyalphabetic substitution"
    var settings: [String: Any] = ["keyword": "SECRET"]

    func encrypt(_ text: String) -> String {
        let keyword = (settings["keyword"] as? String ?? "SECRET").uppercased()
        guard !keyword.isEmpty else { return text }

        // Optimization: Pre-allocate result string capacity
        var result = ""
        result.reserveCapacity(text.count)
        var keyIndex = 0

        for char in text {
            guard char.isEnglishLetter else {
                result.append(char)
                continue
            }

            let keyChar = keyword[keyword.index(keyword.startIndex, offsetBy: keyIndex % keyword.count)]
            let shift = Int(keyChar.asciiValue!) - Int(Character("A").asciiValue!)
            result.append(char.shifted(by: shift))
            keyIndex += 1
        }

        return result
    }

    func decrypt(_ text: String) -> String {
        let keyword = (settings["keyword"] as? String ?? "SECRET").uppercased()
        guard !keyword.isEmpty else { return text }

        // Optimization: Pre-allocate result string capacity
        var result = ""
        result.reserveCapacity(text.count)
        var keyIndex = 0

        for char in text {
            guard char.isEnglishLetter else {
                result.append(char)
                continue
            }

            let keyChar = keyword[keyword.index(keyword.startIndex, offsetBy: keyIndex % keyword.count)]
            let shift = Int(keyChar.asciiValue!) - Int(Character("A").asciiValue!)
            result.append(char.shifted(by: -shift))
            keyIndex += 1
        }

        return result
    }
}
