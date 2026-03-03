import Foundation

class CaesarCipher: CipherEngine {
    var name: String = "Caesar Cipher"
    var description: String = "Classic Roman cipher - shifts letters by a fixed amount"
    var settings: [String: Any] = ["shift": 3]

    func encrypt(_ text: String) -> String {
        let shift = settings["shift"] as? Int ?? 3
        var result = ""
        result.reserveCapacity(text.count)
        for char in text {
            result.append(char.isEnglishLetter ? char.shifted(by: shift) : char)
        }
        return result
    }

    func decrypt(_ text: String) -> String {
        let shift = settings["shift"] as? Int ?? 3
        var result = ""
        result.reserveCapacity(text.count)
        for char in text {
            result.append(char.isEnglishLetter ? char.shifted(by: -shift) : char)
        }
        return result
    }
}
