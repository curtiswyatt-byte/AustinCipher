import SwiftUI

struct NamedSubstitutionView: View {
    @ObservedObject var viewModel: CipherViewModel
    @Binding var isPresented: Bool

    @State private var codeName = ""
    @State private var codeEmoji = "🗝️"
    @State private var key = ""

    private let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

    var isValid: Bool { codeName.count > 0 && key.count == 26 }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 6) {
                        Text("🗝️ Create Named Cipher")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                        Text("Build your own A→B code with a custom name")
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

                    // Key builder
                    VStack(alignment: .leading, spacing: 14) {
                        Text("YOUR CODE KEY")
                            .font(.system(size: 12, weight: .bold, design: .serif))
                            .kerning(1)
                            .foregroundColor(.orange)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Type 26 unique letters — each replaces A, B, C… in order.")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.gray)

                            // Alphabet reference row
                            alphabetReferenceRow

                            // Key text field
                            TextField("e.g. QWERTYUIOPASDFGHJKLZXCVBNM", text: $key)
                                .textFieldStyle(CustomTextFieldStyle())
                                .font(.system(size: 15, design: .monospaced))
                                .autocapitalization(.allCharacters)
                                .disableAutocorrection(true)
                                .onChange(of: key) { val in
                                    var seen = Set<Character>()
                                    key = String(val.uppercased().filter { c in
                                        c.isLetter && seen.insert(c).inserted
                                    }.prefix(26))
                                }

                            // Progress
                            HStack {
                                Text("\(key.count)/26 letters")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(key.count == 26 ? .green : .orange)
                                Spacer()
                                if key.count < 26 {
                                    Text("\(26 - key.count) more needed")
                                        .font(.system(size: 11, design: .rounded))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "1a1a1a"))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange.opacity(0.3), lineWidth: 1))
                        )

                        // Live mapping grid
                        if key.count > 0 {
                            MappingGridView(alphabet: alphabet, key: Array(key))
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

    private var alphabetReferenceRow: some View {
        VStack(spacing: 2) {
            // Split into two rows so it fits on screen
            ForEach([0..<13, 13..<26], id: \.lowerBound) { range in
                HStack(spacing: 0) {
                    ForEach(Array(alphabet[range]).indices, id: \.self) { i in
                        Text(String(alphabet[range][i]))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.orange.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange.opacity(0.2), lineWidth: 1))
        )
    }

    private func cycleEmoji() {
        let current = modeEmojis.firstIndex(of: codeEmoji) ?? -1
        codeEmoji = modeEmojis[(current + 1) % modeEmojis.count]
    }

    private func save() {
        let mode = CipherMode(
            name: codeName,
            emoji: codeEmoji,
            description: "Custom A→B substitution cipher",
            cipherChain: [CipherConfig(cipherType: .substitution, settings: ["key": .string(key)])],
            isCustom: true
        )
        viewModel.addCustomMode(mode)
        isPresented = false
    }
}

/// Isolated grid view so the key TextField doesn't cause it to re-render slowly.
private struct MappingGridView: View {
    let alphabet: [Character]
    let key: [Character]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("PREVIEW")
                .font(.system(size: 11, weight: .bold, design: .serif))
                .kerning(1)
                .foregroundColor(.orange)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 6), spacing: 6) {
                ForEach(0..<key.count, id: \.self) { i in
                    HStack(spacing: 2) {
                        Text(String(alphabet[i]))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                        Text("→")
                            .font(.system(size: 9))
                            .foregroundColor(.orange.opacity(0.6))
                        Text(String(key[i]))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.orange)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.orange.opacity(0.1))
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "1a1a1a"))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange.opacity(0.3), lineWidth: 1))
        )
    }
}

#Preview {
    NamedSubstitutionView(
        viewModel: CipherViewModel(),
        isPresented: .constant(true)
    )
}
