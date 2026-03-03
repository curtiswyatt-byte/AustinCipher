import Foundation
import SwiftUI

class CipherViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var outputText: String = ""
    @Published var selectedMode: CipherMode
    @Published var availableModes: [CipherMode]
    @Published var customModes: [CipherMode] = []
    @Published var isEncrypting: Bool = true

    let history = MessageHistory()

    init() {
        let presets = CipherMode.presets
        self.availableModes = presets
        self.selectedMode = presets[0]
        loadCustomModes()
    }

    func processText() {
        guard !inputText.isEmpty else {
            outputText = ""
            return
        }

        // Security: Limit input length to prevent memory exhaustion (500KB limit)
        let maxInputBytes = 500_000
        guard inputText.utf8.count <= maxInputBytes else {
            outputText = "Error: Input text exceeds maximum size of 500KB"
            return
        }

        // Snapshot values so background thread doesn't touch @Published state
        let text = inputText
        let mode = selectedMode
        let encrypting = isEncrypting

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var result = text

            if encrypting {
                for config in mode.cipherChain {
                    var engine = config.cipherType.createEngine()
                    for (key, value) in config.settings {
                        engine.settings[key] = value.anyValue
                    }
                    result = engine.encrypt(result)
                }
            } else {
                for config in mode.cipherChain.reversed() {
                    var engine = config.cipherType.createEngine()
                    for (key, value) in config.settings {
                        engine.settings[key] = value.anyValue
                    }
                    result = engine.decrypt(result)
                }
            }

            DispatchQueue.main.async {
                guard let self = self else { return }
                self.outputText = result
                self.history.addRecord(
                    original: text,
                    encrypted: result,
                    mode: mode.name,
                    isEncryption: encrypting
                )
            }
        }
    }

    func swapInputOutput() {
        let temp = inputText
        inputText = outputText
        outputText = temp
        isEncrypting.toggle()
    }

    func clearAll() {
        inputText = ""
        outputText = ""
    }

    func addCustomMode(_ mode: CipherMode) {
        var customMode = mode
        customMode.isCustom = true
        customModes.append(customMode)
        saveCustomModes()
    }

    func deleteCustomMode(at offsets: IndexSet) {
        customModes.remove(atOffsets: offsets)
        saveCustomModes()
    }

    func generateShareCode() -> String {
        // Generate a shareable code for the current mode
        var code = "CF:"  // CipherForge prefix

        for (index, config) in selectedMode.cipherChain.enumerated() {
            if index > 0 { code += ">" }

            code += config.cipherType.rawValue.prefix(3).uppercased()

            // Add settings
            if !config.settings.isEmpty {
                code += "("
                let settingsStr = config.settings.map { key, value in
                    switch value {
                    case .int(let val): return "\(key):\(val)"
                    case .string(let val): return "\(key):\(val)"
                    case .bool(let val): return "\(key):\(val)"
                    }
                }.joined(separator: ",")
                code += settingsStr + ")"
            }
        }

        return code
    }

    func generatePIN() -> String {
        // Generate a simple 6-digit PIN based on the mode
        let hash = selectedMode.name.hashValue
        let pin = abs(hash) % 1000000
        return String(format: "%06d", pin)
    }

    func importFromShareCode(_ code: String) -> Bool {
        // Parse share code format: CF:CAE(shift:7)>RAI(rails:4)>VIG(keyword:FORTRESS)
        guard code.hasPrefix("CF:") else { return false }

        let ciphersPart = String(code.dropFirst(3))
        let cipherBlocks = ciphersPart.components(separatedBy: ">")

        var cipherChain: [CipherConfig] = []

        for block in cipherBlocks {
            // Parse cipher type and settings
            let parts = block.components(separatedBy: "(")
            guard let cipherPrefix = parts.first else { continue }

            // Map cipher prefix to type
            guard let cipherType = mapPrefixToCipherType(cipherPrefix) else { continue }

            var settings: [String: CodableValue] = cipherType.defaultSettings()

            // Parse settings if present
            if parts.count > 1 {
                let settingsPart = parts[1].replacingOccurrences(of: ")", with: "")
                let settingPairs = settingsPart.components(separatedBy: ",")

                for pair in settingPairs {
                    let keyValue = pair.components(separatedBy: ":")
                    guard keyValue.count == 2 else { continue }

                    let key = keyValue[0]
                    let value = keyValue[1]

                    // Try to parse as int, then bool, then string
                    if let intVal = Int(value) {
                        settings[key] = .int(intVal)
                    } else if let boolVal = Bool(value) {
                        settings[key] = .bool(boolVal)
                    } else {
                        settings[key] = .string(value)
                    }
                }
            }

            cipherChain.append(CipherConfig(cipherType: cipherType, settings: settings))
        }

        guard !cipherChain.isEmpty else { return false }

        // Create new custom mode
        let newMode = CipherMode(
            name: "Imported Mode",
            emoji: "📥",
            description: "Imported cipher configuration",
            cipherChain: cipherChain,
            isCustom: true
        )

        addCustomMode(newMode)
        selectedMode = newMode
        return true
    }

    private func mapPrefixToCipherType(_ prefix: String) -> CipherType? {
        let prefixUpper = prefix.uppercased()
        switch prefixUpper {
        case "CAE": return .caesar
        case "VIG": return .vigenere
        case "ATB": return .atbash
        case "RAI": return .railFence
        case "PIG": return .pigLatin
        case "MOR": return .morse
        case "SUB": return .substitution
        case "REV": return .reverse
        case "NUM": return .number
        case "ELV": return .elvish
        default: return nil
        }
    }

    func saveCustomModes() {
        if let encoded = try? JSONEncoder().encode(customModes) {
            UserDefaults.standard.set(encoded, forKey: "CustomModes")
        }
    }

    private func loadCustomModes() {
        if let data = UserDefaults.standard.data(forKey: "CustomModes"),
           let decoded = try? JSONDecoder().decode([CipherMode].self, from: data) {
            customModes = decoded
        }
    }
}
