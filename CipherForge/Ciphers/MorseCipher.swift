import Foundation

class MorseCipher: CipherEngine {
    var name: String = "Morse Code"
    var description: String = "Telegraph system using dots and dashes"
    var settings: [String: Any] = [:]

    private let morseCode: [Character: String] = [
        "A": ".-", "B": "-...", "C": "-.-.", "D": "-..", "E": ".",
        "F": "..-.", "G": "--.", "H": "....", "I": "..", "J": ".---",
        "K": "-.-", "L": ".-..", "M": "--", "N": "-.", "O": "---",
        "P": ".--.", "Q": "--.-", "R": ".-.", "S": "...", "T": "-",
        "U": "..-", "V": "...-", "W": ".--", "X": "-..-", "Y": "-.--",
        "Z": "--..", "1": ".----", "2": "..---", "3": "...--",
        "4": "....-", "5": ".....", "6": "-....", "7": "--...",
        "8": "---..", "9": "----.", "0": "-----", " ": "/", "§": "§", "¶": "¶", "◈": "◈", "⬡": "⬡"
    ]

    private lazy var reverseMorse: [String: Character] = {
        Dictionary(uniqueKeysWithValues: morseCode.map { ($1, $0) })
    }()

    func encrypt(_ text: String) -> String {
        var result = ""
        result.reserveCapacity(text.count * 5)
        var first = true
        for char in text.uppercased() {
            if !first { result.append("|") }
            result.append(contentsOf: morseCode[char] ?? String(char))
            first = false
        }
        return result
    }

    func decrypt(_ text: String) -> String {
        return text.components(separatedBy: "|").map { code in
            // Handle word separator
            if code == "/" {
                return " "
            }
            return String(reverseMorse[code] ?? Character(code))
        }.joined()
    }
}
