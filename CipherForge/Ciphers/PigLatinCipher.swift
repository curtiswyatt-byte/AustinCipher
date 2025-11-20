import Foundation

class PigLatinCipher: CipherEngine {
    var name: String = "Pig Latin"
    var description: String = "Playful language game - moves consonants to end and adds 'ay'"
    var settings: [String: Any] = [:]

    func encrypt(_ text: String) -> String {
        let words = text.components(separatedBy: .whitespaces)
        return words.map { word in
            guard !word.isEmpty else { return word }

            let lower = word.lowercased()
            guard lower.first?.isLetter == true else { return word }

            let vowels = "aeiou"
            let firstChar = lower.first!

            if vowels.contains(firstChar) {
                // Started with vowel - add "way"
                return lower + "way"
            } else {
                // Find first vowel
                if let vowelIndex = lower.firstIndex(where: { vowels.contains($0) }) {
                    let consonantCluster = String(lower[..<vowelIndex])
                    let rest = String(lower[vowelIndex...])
                    // Add marker § to show where split happened
                    return rest + "§" + consonantCluster + "ay"
                } else {
                    // No vowels - all consonants
                    return lower + "ay"
                }
            }
        }.joined(separator: " ")
    }

    func decrypt(_ text: String) -> String {
        let words = text.components(separatedBy: .whitespaces)
        return words.map { word in
            guard !word.isEmpty else { return word }

            let lower = word.lowercased()

            // If ends with "way", it originally started with a vowel
            if lower.hasSuffix("way") {
                let original = String(lower.dropLast(3))
                return original
            }
            // If ends with "ay", it originally started with consonant(s)
            else if lower.hasSuffix("ay") {
                let withoutAy = String(lower.dropLast(2))

                // Look for the § marker that shows where we split
                if let markerIndex = withoutAy.firstIndex(of: "§") {
                    let vowelPart = String(withoutAy[..<markerIndex])
                    let consonantPart = String(withoutAy[withoutAy.index(after: markerIndex)...])
                    return consonantPart + vowelPart
                }

                // No marker - this shouldn't happen with our encryption, but handle gracefully
                // Assume entire thing was consonants (no vowels in original word)
                return withoutAy
            }

            return word
        }.joined(separator: " ")
    }
}
