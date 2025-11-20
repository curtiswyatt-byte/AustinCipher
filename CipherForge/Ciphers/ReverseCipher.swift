import Foundation

class ReverseCipher: CipherEngine {
    var name: String = "Reverse Text"
    var description: String = "Simply reverses the entire message backwards"
    var settings: [String: Any] = [:]

    func encrypt(_ text: String) -> String {
        return String(text.reversed())
    }

    func decrypt(_ text: String) -> String {
        return String(text.reversed())
    }
}
