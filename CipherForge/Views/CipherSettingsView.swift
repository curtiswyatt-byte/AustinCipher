import SwiftUI

// Which ciphers have user-configurable settings
extension CipherType {
    var hasConfigurableSettings: Bool {
        switch self {
        case .caesar, .vigenere, .railFence, .substitution, .null: return true
        default: return false
        }
    }
}

// Human-readable summary of a config's current settings
extension CipherConfig {
    var settingsSummary: String {
        let parts: [String] = settings.compactMap { key, value in
            switch value {
            case .int(let v): return "\(key): \(v)"
            case .string(let v):
                let display = v.count > 12 ? "\(v.prefix(12))…" : v
                return "\(key): \(display)"
            case .bool(let v): return "\(key): \(v)"
            }
        }
        return parts.joined(separator: ", ")
    }
}

/// Configure settings for a single cipher before adding it to (or updating it in) a chain.
struct CipherSettingsView: View {
    let cipherType: CipherType
    let isEditing: Bool
    let onConfirm: ([String: CodableValue]) -> Void

    @Environment(\.dismiss) var dismiss

    @State private var shift: Int
    @State private var keyword: String
    @State private var rails: Int
    @State private var substitutionKey: String
    @State private var nullChar: String

    init(cipherType: CipherType,
         initialSettings: [String: CodableValue],
         isEditing: Bool = false,
         onConfirm: @escaping ([String: CodableValue]) -> Void) {
        self.cipherType = cipherType
        self.isEditing = isEditing
        self.onConfirm = onConfirm

        var s = 3, r = 3
        var kw = "SECRET", sk = "QWERTYUIOPASDFGHJKLZXCVBNM", nc = "X"
        if case .int(let v) = initialSettings["shift"] { s = v }
        if case .int(let v) = initialSettings["rails"] { r = v }
        if case .string(let v) = initialSettings["keyword"] { kw = v }
        if case .string(let v) = initialSettings["key"] { sk = v }
        if case .string(let v) = initialSettings["nullChar"] { nc = v }
        _shift = State(initialValue: s)
        _rails = State(initialValue: r)
        _keyword = State(initialValue: kw)
        _substitutionKey = State(initialValue: sk)
        _nullChar = State(initialValue: nc)
    }

    var isValid: Bool {
        switch cipherType {
        case .vigenere: return !keyword.isEmpty
        case .substitution: return substitutionKey.count == 26
        default: return true
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Text(isEditing ? "Edit Settings" : "Configure Cipher")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(cipherType.rawValue)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.orange)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.black.opacity(0.9))
                .overlay(alignment: .trailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.orange)
                            .padding()
                    }
                }

                ScrollView {
                    VStack(spacing: 20) {
                        settingsContent
                            .padding(.horizontal)
                            .padding(.top, 24)

                        Button(action: confirm) {
                            Text(isEditing ? "SAVE CHANGES" : "ADD TO CHAIN")
                                .font(.system(size: 17, weight: .black, design: .serif))
                                .kerning(1)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "CD7F32"), .orange, Color(hex: "ff8800")]),
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                        .disabled(!isValid)
                        .opacity(isValid ? 1 : 0.5)
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var settingsContent: some View {
        switch cipherType {

        case .caesar:
            settingsCard {
                Text("SHIFT AMOUNT")
                    .sectionLabel()
                HStack {
                    Text("\(shift)")
                        .font(.system(size: 52, weight: .black, design: .monospaced))
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                    Stepper("", value: $shift, in: 1...25)
                        .labelsHidden()
                }
                Text("Shifts each letter \(shift) position\(shift == 1 ? "" : "s") in the alphabet. A shift of 13 is ROT13.")
                    .hint()
            }

        case .vigenere:
            settingsCard {
                Text("KEYWORD")
                    .sectionLabel()
                TextField("e.g. FORTRESS", text: $keyword)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
                    .onChange(of: keyword) { val in
                        keyword = String(val.uppercased().filter { $0.isLetter }.prefix(20))
                    }
                Text("The keyword repeats across your message. Each letter sets a Caesar shift. Longer keywords = stronger cipher.")
                    .hint()
            }

        case .railFence:
            settingsCard {
                Text("NUMBER OF RAILS")
                    .sectionLabel()
                HStack {
                    Text("\(rails)")
                        .font(.system(size: 52, weight: .black, design: .monospaced))
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                    Stepper("", value: $rails, in: 2...10)
                        .labelsHidden()
                }
                Text("Text is written in a zigzag across \(rails) rails then read row by row. More rails = more scrambling.")
                    .hint()
            }

        case .substitution:
            settingsCard {
                Text("SUBSTITUTION KEY")
                    .sectionLabel()
                TextField("26 unique letters", text: $substitutionKey)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
                    .font(.system(size: 13, design: .monospaced))
                    .onChange(of: substitutionKey) { val in
                        var seen = Set<Character>()
                        substitutionKey = String(val.uppercased().filter { c in
                            c.isLetter && seen.insert(c).inserted
                        }.prefix(26))
                    }
                HStack {
                    Text("\(substitutionKey.count)/26 letters")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(substitutionKey.count == 26 ? .green : .orange)
                    Spacer()
                    if substitutionKey.count != 26 {
                        Text("Needs exactly 26 unique letters")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.red)
                    }
                }
                Text("Each letter A–Z maps to the corresponding letter in your key. All 26 must be unique.")
                    .hint()
            }

        case .null:
            settingsCard {
                Text("NULL CHARACTER")
                    .sectionLabel()
                TextField("Single letter, e.g. X", text: $nullChar)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
                    .onChange(of: nullChar) { val in
                        nullChar = String((val.uppercased().filter { $0.isLetter }.first).map(String.init) ?? "X")
                    }
                Text("The decoy letter inserted between every real character. Decrypt extracts every other character.")
                    .hint()
            }

        default:
            EmptyView()
        }
    }

    private func confirm() {
        var settings: [String: CodableValue] = [:]
        switch cipherType {
        case .caesar:      settings["shift"] = .int(shift)
        case .vigenere:    settings["keyword"] = .string(keyword)
        case .railFence:   settings["rails"] = .int(rails)
        case .substitution: settings["key"] = .string(substitutionKey)
        case .null:        settings["nullChar"] = .string(nullChar.isEmpty ? "X" : nullChar)
        default: break
        }
        onConfirm(settings)
        dismiss()
    }
}

// MARK: - Helpers

private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 12) {
        content()
    }
    .padding()
    .background(
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(hex: "1a1a1a"))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange.opacity(0.3), lineWidth: 1))
    )
}

private extension Text {
    func sectionLabel() -> some View {
        self
            .font(.system(size: 13, weight: .bold, design: .serif))
            .kerning(1)
            .foregroundColor(.orange)
    }

    func hint() -> some View {
        self
            .font(.system(size: 12, design: .rounded))
            .foregroundColor(.gray)
    }
}
