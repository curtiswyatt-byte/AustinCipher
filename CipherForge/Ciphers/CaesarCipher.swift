import Foundation

class CaesarCipher: CipherEngine {
    var name: String = "Caesar Cipher"
    var description: String = "Classic Roman cipher - shifts letters by a fixed amount"
    var settings: [String: Any] = ["shift": 3]

    func encrypt(_ text: String) -> String {
        let shift = settings["shift"] as? Int ?? 3
        return text.map { char in
            guard char.isEnglishLetter else { return char }
            return char.shifted(by: shift)
        }.map(String.init).joined()
    }

    func decrypt(_ text: String) -> String {
        let shift = settings["shift"] as? Int ?? 3
        return text.map { char in
            guard char.isEnglishLetter else { return char }
            return char.shifted(by: -shift)
        }.map(String.init).joined()
    }
}
