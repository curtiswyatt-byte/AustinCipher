import Foundation

struct CipherMode: Identifiable, Codable {
    let id: UUID
    var name: String
    var emoji: String
    var description: String
    var cipherChain: [CipherConfig]
    var isCustom: Bool

    init(id: UUID = UUID(), name: String, emoji: String, description: String, cipherChain: [CipherConfig], isCustom: Bool = false) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.description = description
        self.cipherChain = cipherChain
        self.isCustom = isCustom
    }
}

struct CipherConfig: Identifiable, Codable {
    let id: UUID
    var cipherType: CipherType
    var settings: [String: CodableValue]

    init(id: UUID = UUID(), cipherType: CipherType, settings: [String: CodableValue] = [:]) {
        self.id = id
        self.cipherType = cipherType
        self.settings = settings
    }
}

enum CipherType: String, Codable, CaseIterable {
    case caesar = "Caesar"
    case vigenere = "Vigenère"
    case atbash = "Atbash"
    case railFence = "Rail Fence"
    case pigLatin = "Pig Latin"
    case morse = "Morse Code"
    case substitution = "Substitution"
    case reverse = "Reverse"
    case number = "Number"
    case elvish = "Elvish"

    var displayName: String {
        return self.rawValue
    }

    func createEngine() -> CipherEngine {
        switch self {
        case .caesar: return CaesarCipher()
        case .vigenere: return VigenereCipher()
        case .atbash: return AtbashCipher()
        case .railFence: return RailFenceCipher()
        case .pigLatin: return PigLatinCipher()
        case .morse: return MorseCipher()
        case .substitution: return SubstitutionCipher()
        case .reverse: return ReverseCipher()
        case .number: return NumberCipher()
        case .elvish: return ElvishCipher()
        }
    }

    func defaultSettings() -> [String: CodableValue] {
        let engine = createEngine()
        var codableSettings: [String: CodableValue] = [:]

        for (key, value) in engine.settings {
            if let intVal = value as? Int {
                codableSettings[key] = .int(intVal)
            } else if let stringVal = value as? String {
                codableSettings[key] = .string(stringVal)
            } else if let boolVal = value as? Bool {
                codableSettings[key] = .bool(boolVal)
            }
        }

        return codableSettings
    }
}

// Helper to make settings codable
enum CodableValue: Codable {
    case string(String)
    case int(Int)
    case bool(Bool)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .int(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        }
    }

    var anyValue: Any {
        switch self {
        case .string(let value): return value
        case .int(let value): return value
        case .bool(let value): return value
        }
    }
}

// Preset modes with fun names
extension CipherMode {
    static var presets: [CipherMode] {
        [
            CipherMode(
                name: "Pirate's Code",
                emoji: "🏴‍☠️",
                description: "Arr! Simple Caesar shift for quick secrets",
                cipherChain: [
                    CipherConfig(cipherType: .caesar, settings: ["shift": .int(13)])
                ]
            ),
            CipherMode(
                name: "Wizard's Scroll",
                emoji: "🧙‍♂️",
                description: "Mystical Elvish runes with a twist",
                cipherChain: [
                    CipherConfig(cipherType: .elvish),
                    CipherConfig(cipherType: .reverse)
                ]
            ),
            CipherMode(
                name: "Spy Academy",
                emoji: "🕵️",
                description: "Professional grade Vigenère cipher",
                cipherChain: [
                    CipherConfig(cipherType: .vigenere, settings: ["keyword": .string("CLASSIFIED")])
                ]
            ),
            CipherMode(
                name: "Playground Secret",
                emoji: "🎮",
                description: "Fun Pig Latin for sharing with friends",
                cipherChain: [
                    CipherConfig(cipherType: .pigLatin)
                ]
            ),
            CipherMode(
                name: "Telegraph Station",
                emoji: "📡",
                description: "Classic Morse code transmission",
                cipherChain: [
                    CipherConfig(cipherType: .morse)
                ]
            ),
            CipherMode(
                name: "Ancient Scroll",
                emoji: "📜",
                description: "Biblical Atbash cipher from ancient times",
                cipherChain: [
                    CipherConfig(cipherType: .atbash)
                ]
            ),
            CipherMode(
                name: "Math Class",
                emoji: "🔢",
                description: "Number substitution for numeric minds",
                cipherChain: [
                    CipherConfig(cipherType: .number)
                ]
            ),
            CipherMode(
                name: "Mirror Realm",
                emoji: "🪞",
                description: "Everything backwards in the mirror world",
                cipherChain: [
                    CipherConfig(cipherType: .reverse)
                ]
            ),
            CipherMode(
                name: "Train Tracks",
                emoji: "🚂",
                description: "Rail fence zigzag pattern",
                cipherChain: [
                    CipherConfig(cipherType: .railFence, settings: ["rails": .int(3)])
                ]
            ),
            CipherMode(
                name: "Maximum Security",
                emoji: "🔐",
                description: "Triple-layered encryption for ultimate secrecy",
                cipherChain: [
                    CipherConfig(cipherType: .vigenere, settings: ["keyword": .string("FORTRESS")]),
                    CipherConfig(cipherType: .railFence, settings: ["rails": .int(4)]),
                    CipherConfig(cipherType: .caesar, settings: ["shift": .int(7)])
                ]
            ),
            CipherMode(
                name: "Fantasy Quest",
                emoji: "⚔️",
                description: "Elvish script combined with ancient ciphers",
                cipherChain: [
                    CipherConfig(cipherType: .elvish),
                    CipherConfig(cipherType: .atbash)
                ]
            ),
            CipherMode(
                name: "Secret Agent",
                emoji: "🎯",
                description: "Multi-stage cipher for field operatives",
                cipherChain: [
                    CipherConfig(cipherType: .substitution, settings: ["key": .string("QWERTYUIOPASDFGHJKLZXCVBNM")]),
                    CipherConfig(cipherType: .reverse)
                ]
            )
        ]
    }
}
