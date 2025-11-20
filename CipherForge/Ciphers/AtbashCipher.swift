import Foundation

class AtbashCipher: CipherEngine {
    var name: String = "Atbash Cipher"
    var description: String = "Ancient Hebrew cipher - reverses the alphabet (A↔Z, B↔Y)"
    var settings: [String: Any] = [:]

    func encrypt(_ text: String) -> String {
        return text.map { char in
            guard char.isEnglishLetter else { return char }
            let isUpper = char.isUppercase
            let base = isUpper ? Character("A") : Character("a")
            let baseValue = Int(base.asciiValue!)
            let charValue = Int(char.asciiValue!)
            let reversed = baseValue + (25 - (charValue - baseValue))
            return Character(UnicodeScalar(reversed)!)
        }.map(String.init).joined()
    }

    func decrypt(_ text: String) -> String {
        // Atbash is its own inverse
        return encrypt(text)
    }
}
