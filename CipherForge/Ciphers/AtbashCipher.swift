import Foundation

class AtbashCipher: CipherEngine {
    var name: String = "Atbash Cipher"
    var description: String = "Ancient Hebrew cipher - reverses the alphabet (A↔Z, B↔Y)"
    var settings: [String: Any] = [:]

    private static let upperA = Int(Character("A").asciiValue!)
    private static let lowerA = Int(Character("a").asciiValue!)

    func encrypt(_ text: String) -> String {
        var result = ""
        result.reserveCapacity(text.count)
        for char in text {
            guard char.isEnglishLetter else { result.append(char); continue }
            let base = char.isUppercase ? Self.upperA : Self.lowerA
            let charValue = Int(char.asciiValue!)
            let reversed = base + (25 - (charValue - base))
            result.append(Character(UnicodeScalar(reversed)!))
        }
        return result
    }

    func decrypt(_ text: String) -> String {
        // Atbash is its own inverse
        return encrypt(text)
    }
}
