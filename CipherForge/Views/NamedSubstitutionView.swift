import SwiftUI

struct NamedSubstitutionView: View {
    @ObservedObject var viewModel: CipherViewModel
    @Binding var isPresented: Bool

    @State private var codeName = ""
    @State private var codeEmoji = "🗝️"
    /// One entry per letter A–Z (indices 0–25)
    @State private var mappings: [String] = Array(repeating: "", count: 26)

    private let alphabet: [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

    // MARK: - Validation

    var filledCount: Int { mappings.filter { !$0.isEmpty }.count }

    /// Returns the set of mapping strings that appear more than once.
    var duplicates: Set<String> {
        var seen = Set<String>()
        var dups = Set<String>()
        for m in mappings where !m.isEmpty {
            if !seen.insert(m).inserted { dups.insert(m) }
        }
        return dups
    }

    var hasSpaceInMapping: Bool { mappings.contains { $0.contains(" ") } }
    var usesReservedUnderscore: Bool { mappings.contains("_") }

    var isValid: Bool {
        !codeName.isEmpty
            && filledCount == 26
            && duplicates.isEmpty
            && !hasSpaceInMapping
            && !usesReservedUnderscore
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 6) {
                        Text("⚒️ The Forge")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                        Text("Give each letter its own secret code")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    .padding(.top)

                    // Name + Emoji
                    VStack(alignment: .leading, spacing: 10) {
                        Text("CIPHER NAME")
                            .font(.system(size: 12, weight: .bold, design: .serif))
                            .kerning(1)
                            .foregroundColor(.orange)

                        HStack(spacing: 12) {
                            Text(codeEmoji)
                                .font(.system(size: 36))
                                .onTapGesture { cycleEmoji() }
                                .padding(8)
                                .background(Circle().fill(Color.orange.opacity(0.15)))

                            TextField("e.g. Bobby's Secret", text: $codeName)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                    }
                    .padding(.horizontal)

                    // Letter mapping grid
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("YOUR CODE KEY")
                                .font(.system(size: 12, weight: .bold, design: .serif))
                                .kerning(1)
                                .foregroundColor(.orange)
                            Spacer()
                            Text("\(filledCount)/26")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(filledCount == 26 ? .green : .orange)
                        }

                        Text("Type what each letter becomes. Any text works — letters, numbers, symbols — as long as each is unique and has no spaces. (\"_\" is reserved.)")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.gray)

                        // Two columns: A–M on left, N–Z on right
                        HStack(alignment: .top, spacing: 10) {
                            letterColumn(from: 0, to: 13)
                            letterColumn(from: 13, to: 26)
                        }

                        // Validation feedback
                        if !duplicates.isEmpty {
                            Label("Duplicate codes: \(duplicates.sorted().joined(separator: ", "))", systemImage: "exclamationmark.triangle.fill")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.red)
                        }
                        if hasSpaceInMapping {
                            Label("Codes cannot contain spaces", systemImage: "exclamationmark.triangle.fill")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.red)
                        }
                        if usesReservedUnderscore {
                            Label("\"_\" is reserved for spaces — choose a different code", systemImage: "exclamationmark.triangle.fill")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)

                    // Save
                    Button(action: save) {
                        Text("SAVE CIPHER")
                            .font(.system(size: 18, weight: .black, design: .serif))
                            .kerning(1.5)
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
        .overlay(alignment: .topTrailing) {
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                    .padding()
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func letterColumn(from start: Int, to end: Int) -> some View {
        VStack(spacing: 5) {
            ForEach(start..<end, id: \.self) { i in
                LetterBoxView(
                    letter: alphabet[i],
                    mapping: $mappings[i],
                    isDuplicate: !mappings[i].isEmpty && duplicates.contains(mappings[i])
                )
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func cycleEmoji() {
        let current = modeEmojis.firstIndex(of: codeEmoji) ?? -1
        codeEmoji = modeEmojis[(current + 1) % modeEmojis.count]
    }

    private func save() {
        var settings: [String: CodableValue] = [:]
        for (i, letter) in alphabet.enumerated() {
            settings[String(letter)] = .string(mappings[i])
        }
        let mode = CipherMode(
            name: codeName,
            emoji: codeEmoji,
            description: "Custom codebook cipher",
            cipherChain: [CipherConfig(cipherType: .codebook, settings: settings)],
            isCustom: true
        )
        viewModel.addCustomMode(mode)
        isPresented = false
    }
}

// MARK: - Isolated letter box

/// One box per letter — isolated struct so only the changed box re-renders on typing.
private struct LetterBoxView: View {
    let letter: Character
    @Binding var mapping: String
    let isDuplicate: Bool

    var body: some View {
        HStack(spacing: 5) {
            Text(String(letter))
                .font(.system(size: 13, weight: .black, design: .monospaced))
                .foregroundColor(.orange)
                .frame(width: 18)

            TextField("…", text: $mapping)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(isDuplicate ? .red : .white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
                .padding(.horizontal, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isDuplicate ? Color(hex: "2a0000") : Color(hex: "1a1a1a"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(isDuplicate ? Color.red : Color.orange.opacity(0.35), lineWidth: 1)
                        )
                )
                .onChange(of: mapping) {
                    // Strip spaces immediately as user types
                    if mapping.contains(" ") {
                        mapping = mapping.replacingOccurrences(of: " ", with: "")
                    }
                }
        }
    }
}

#Preview {
    NamedSubstitutionView(
        viewModel: CipherViewModel(),
        isPresented: .constant(true)
    )
}
