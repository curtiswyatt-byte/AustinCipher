import Foundation

/// Levi's Conundrum: A=26, B=1, C=25, D=2, E=24... alternating descending/ascending.
/// Encrypt: each letter becomes its number, hyphen-separated within letter runs.
/// Decrypt: parse hyphen-separated numbers back to letters.
class LeviCipher: CipherEngine {
    var name: String = "Levi's Conundrum"
    var description: String = "A=26, B=1, C=25, D=2… alternating number substitution"
    var settings: [String: Any] = [:]

    private static let letterToNumber: [Character: Int] = {
        let letters: [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        var map: [Character: Int] = [:]
        for (i, letter) in letters.enumerated() {
            map[letter] = i.isMultiple(of: 2) ? 26 - i / 2 : i / 2 + 1
        }
        return map
    }()

    private static let numberToLetter: [Int: Character] = {
        Dictionary(uniqueKeysWithValues: letterToNumber.map { ($1, $0) })
    }()

    func encrypt(_ text: String) -> String {
        var result = ""
        result.reserveCapacity(text.count * 3)
        var needsSeparator = false
        for char in text.uppercased() {
            if let num = Self.letterToNumber[char] {
                if needsSeparator { result.append("-") }
                result.append(contentsOf: String(num))
                needsSeparator = true
            } else {
                result.append(char)
                needsSeparator = false
            }
        }
        return result
    }

    func decrypt(_ text: String) -> String {
        var result = ""
        var numStr = ""

        func flushNum() {
            guard !numStr.isEmpty else { return }
            if let num = Int(numStr), let letter = Self.numberToLetter[num] {
                result.append(letter)
            } else {
                result += numStr
            }
            numStr = ""
        }

        for char in text {
            if char.isNumber {
                numStr.append(char)
            } else if char == "-" {
                flushNum()
            } else {
                flushNum()
                result.append(char)
            }
        }
        flushNum()
        return result
    }
}
