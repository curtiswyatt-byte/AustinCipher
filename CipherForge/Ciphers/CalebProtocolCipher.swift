/// The Caleb Protocol: swaps every adjacent pair of characters.
/// "austin" → "uatsni"  (a↔u, s↔t, i↔n)
/// Odd-length strings leave the final character in place.
/// Encrypt and decrypt are identical operations.
class CalebProtocolCipher: CipherEngine {
    var name: String = "The Caleb Protocol"
    var description: String = "Swaps every pair of letters"
    var settings: [String: Any] = [:]

    func encrypt(_ text: String) -> String { swap(text) }
    func decrypt(_ text: String) -> String { swap(text) }

    private func swap(_ text: String) -> String {
        var chars = Array(text)
        var i = 0
        while i + 1 < chars.count {
            chars.swapAt(i, i + 1)
            i += 2
        }
        return String(chars)
    }
}
