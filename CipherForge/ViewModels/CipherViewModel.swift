import Foundation
import SwiftUI

class CipherViewModel: ObservableObject {
    @Published var outputText: String = ""
    @Published var selectedMode: CipherMode
    @Published var availableModes: [CipherMode]
    @Published var customModes: [CipherMode] = []
    @Published var isEncrypting: Bool = true

    let history = MessageHistory()

    /// Tracks the current cipher task so rapid taps cancel the previous one.
    private var processingTask: Task<Void, Never>?

    init() {
        let presets = CipherMode.presets
        self.availableModes = presets
        self.selectedMode = presets[0]
        loadCustomModes()
    }

    func processText(input: String) {
        guard !input.isEmpty else {
            outputText = ""
            return
        }

        // Security: Limit input length to prevent memory exhaustion (500KB limit)
        let maxInputBytes = 500_000
        guard input.utf8.count <= maxInputBytes else {
            outputText = "Error: Input text exceeds maximum size of 500KB"
            return
        }

        // Snapshot values so background work doesn't touch @Published state
        let mode = selectedMode
        let encrypting = isEncrypting

        // Cancel any in-flight task before starting a new one
        processingTask?.cancel()
        processingTask = Task.detached(priority: .userInitiated) { [weak self] in
            var result = input

            if encrypting {
                for config in mode.cipherChain {
                    guard !Task.isCancelled else { return }
                    var engine = config.cipherType.createEngine()
                    for (key, value) in config.settings { engine.settings[key] = value.anyValue }
                    result = engine.encrypt(result)
                }
            } else {
                for config in mode.cipherChain.reversed() {
                    guard !Task.isCancelled else { return }
                    var engine = config.cipherType.createEngine()
                    for (key, value) in config.settings { engine.settings[key] = value.anyValue }
                    result = engine.decrypt(result)
                }
            }

            guard !Task.isCancelled else { return }
            let finalResult = result
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.outputText = finalResult
                self.history.addRecord(
                    original: input,
                    encrypted: finalResult,
                    mode: mode.name,
                    isEncryption: encrypting
                )
            }
        }
    }

    /// Swaps input and output. Returns the new input text (old output).
    func swapInputOutput(currentInput: String) -> String {
        let newInput = outputText
        outputText = currentInput
        isEncrypting.toggle()
        return newInput
    }

    func clearAll() {
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
        var code = "CF:"
        for (index, config) in selectedMode.cipherChain.enumerated() {
            if index > 0 { code.append(">") }
            code.append(contentsOf: config.cipherType.rawValue.prefix(3).uppercased())
            if !config.settings.isEmpty {
                code.append("(")
                var first = true
                for (key, value) in config.settings {
                    if !first { code.append(",") }
                    code.append(contentsOf: key)
                    code.append(":")
                    switch value {
                    case .int(let v):    code.append(contentsOf: String(v))
                    case .string(let v): code.append(contentsOf: v)
                    case .bool(let v):   code.append(contentsOf: String(v))
                    }
                    first = false
                }
                code.append(")")
            }
        }
        return code
    }

    func importFromShareCode(_ code: String, name: String = "Imported Mode") -> Bool {
        // Parse share code format: CF:CAE(shift:7)>RAI(rails:4)>VIG(keyword:FORTRESS)
        guard code.count <= 500, code.hasPrefix("CF:") else { return false }

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
            name: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Imported Mode" : name.trimmingCharacters(in: .whitespacesAndNewlines),
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
        case "NUL": return .null
        case "LEV": return .levi
        case "COD": return .codebook
        case "CAL": return .calebProtocol
        default: return nil
        }
    }

    func saveCustomModes() {
        let snapshot = customModes
        DispatchQueue.global(qos: .background).async {
            if let encoded = try? JSONEncoder().encode(snapshot) {
                UserDefaults.standard.set(encoded, forKey: "CustomModes")
            }
        }
    }

    private func loadCustomModes() {
        if let data = UserDefaults.standard.data(forKey: "CustomModes"),
           let decoded = try? JSONDecoder().decode([CipherMode].self, from: data) {
            customModes = decoded
        }
    }
}
