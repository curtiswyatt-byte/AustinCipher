import Foundation

class SubstitutionCipher: CipherEngine {
    var name: String = "Substitution Cipher"
    var description: String = "Replaces each letter with another letter"
    var settings: [String: Any] = ["key": "QWERTYUIOPASDFGHJKLZXCVBNM"]

    private static let alphabet: [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

    func encrypt(_ text: String) -> String {
        let key = (settings["key"] as? String ?? "QWERTYUIOPASDFGHJKLZXCVBNM").uppercased()
        guard key.count == 26 else { return text }
        let keyChars = Array(key)

        var mapping: [Character: Character] = [:]
        mapping.reserveCapacity(26)
        for (index, char) in Self.alphabet.enumerated() {
            mapping[char] = keyChars[index]
        }

        var result = ""
        result.reserveCapacity(text.count)
        for char in text {
            if let ascii = char.asciiValue {
                let upperChar: Character = ascii >= 97 && ascii <= 122
                    ? Character(UnicodeScalar(ascii - 32))
                    : Character(UnicodeScalar(ascii))
                if let replacement = mapping[upperChar] {
                    result.append(char.isUppercase ? replacement : Character(replacement.lowercased()))
                    continue
                }
            }
            result.append(char)
        }
        return result
    }

    func decrypt(_ text: String) -> String {
        let key = (settings["key"] as? String ?? "QWERTYUIOPASDFGHJKLZXCVBNM").uppercased()
        guard key.count == 26 else { return text }
        let keyChars = Array(key)

        var reverseMapping: [Character: Character] = [:]
        reverseMapping.reserveCapacity(26)
        for (index, char) in Self.alphabet.enumerated() {
            reverseMapping[keyChars[index]] = char
        }

        var result = ""
        result.reserveCapacity(text.count)
        for char in text {
            if let ascii = char.asciiValue {
                let upperChar: Character = ascii >= 97 && ascii <= 122
                    ? Character(UnicodeScalar(ascii - 32))
                    : Character(UnicodeScalar(ascii))
                if let replacement = reverseMapping[upperChar] {
                    result.append(char.isUppercase ? replacement : Character(replacement.lowercased()))
                    continue
                }
            }
            result.append(char)
        }
        return result
    }
}
