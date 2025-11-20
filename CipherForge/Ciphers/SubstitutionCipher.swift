import Foundation

class SubstitutionCipher: CipherEngine {
    var name: String = "Substitution Cipher"
    var description: String = "Replaces each letter with another letter"
    var settings: [String: Any] = ["key": "QWERTYUIOPASDFGHJKLZXCVBNM"]

    func encrypt(_ text: String) -> String {
        let key = (settings["key"] as? String ?? "QWERTYUIOPASDFGHJKLZXCVBNM").uppercased()
        guard key.count == 26 else { return text }

        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var mapping: [Character: Character] = [:]

        for (index, char) in alphabet.enumerated() {
            let keyIndex = key.index(key.startIndex, offsetBy: index)
            mapping[char] = key[keyIndex]
        }

        // Optimization: Use single-pass string building instead of map().map().joined()
        var result = ""
        result.reserveCapacity(text.count)
        for char in text {
            let upperChar = char.uppercased().first!
            if let replacement = mapping[upperChar] {
                result.append(char.isUppercase ? replacement : Character(replacement.lowercased()))
            } else {
                result.append(char)
            }
        }
        return result
    }

    func decrypt(_ text: String) -> String {
        let key = (settings["key"] as? String ?? "QWERTYUIOPASDFGHJKLZXCVBNM").uppercased()
        guard key.count == 26 else { return text }

        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var reverseMapping: [Character: Character] = [:]

        for (index, char) in alphabet.enumerated() {
            let keyIndex = key.index(key.startIndex, offsetBy: index)
            reverseMapping[key[keyIndex]] = char
        }

        // Optimization: Use single-pass string building instead of map().map().joined()
        var result = ""
        result.reserveCapacity(text.count)
        for char in text {
            let upperChar = char.uppercased().first!
            if let replacement = reverseMapping[upperChar] {
                result.append(char.isUppercase ? replacement : Character(replacement.lowercased()))
            } else {
                result.append(char)
            }
        }
        return result
    }
}
