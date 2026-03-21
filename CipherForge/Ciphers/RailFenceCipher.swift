import Foundation

class RailFenceCipher: CipherEngine {
    var name: String = "Rail Fence Cipher"
    var description: String = "Writes message in a zigzag pattern across multiple rails"
    var settings: [String: Any] = ["rails": 3]

    func encrypt(_ text: String) -> String {
        let rails = min(50, max(2, settings["rails"] as? Int ?? 3))

        // Replace spaces with a special marker that Rail Fence can process
        // Use ¶ (pilcrow) for Rail Fence space markers (different from § used by Pig Latin)
        let markedText = text.replacingOccurrences(of: " ", with: "¶")

        guard markedText.count > rails else { return markedText }

        // Optimization: Pre-allocate array capacity
        var fence: [[Character]] = []
        fence.reserveCapacity(rails)
        for _ in 0..<rails {
            var row: [Character] = []
            row.reserveCapacity(markedText.count / rails + 1)
            fence.append(row)
        }

        var rail = 0
        var direction = 1

        for char in markedText {
            fence[rail].append(char)
            rail += direction

            if rail == 0 || rail == rails - 1 {
                direction *= -1
            }
        }

        // Optimization: Use single-pass string building
        var result = ""
        result.reserveCapacity(markedText.count)
        for row in fence {
            for char in row {
                result.append(char)
            }
        }
        return result
    }

    func decrypt(_ text: String) -> String {
        let rails = min(50, max(2, settings["rails"] as? Int ?? 3))

        guard text.count > rails else {
            // Restore spaces from markers
            return text.replacingOccurrences(of: "¶", with: " ")
        }

        // Calculate positions
        var fence = Array(repeating: Array(repeating: Character("\0"), count: text.count), count: rails)
        var rail = 0
        var direction = 1

        // Mark positions
        for i in 0..<text.count {
            fence[rail][i] = Character("*")
            rail += direction

            if rail == 0 || rail == rails - 1 {
                direction *= -1
            }
        }

        // Fill with characters — pre-convert to array for O(1) index access
        let chars = Array(text)
        var index = 0
        for r in 0..<rails {
            for c in 0..<text.count {
                if fence[r][c] == "*" {
                    fence[r][c] = chars[index]
                    index += 1
                }
            }
        }

        // Read in zigzag
        // Optimization: Pre-allocate result string capacity
        var result = ""
        result.reserveCapacity(text.count)
        rail = 0
        direction = 1

        for i in 0..<text.count {
            result.append(fence[rail][i])
            rail += direction

            if rail == 0 || rail == rails - 1 {
                direction *= -1
            }
        }

        // Restore spaces from markers
        return result.replacingOccurrences(of: "¶", with: " ")
    }
}
