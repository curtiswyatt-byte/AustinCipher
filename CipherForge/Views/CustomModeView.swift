import SwiftUI

let modeEmojis = ["🔒", "⚡", "🌟", "🎯", "🚀", "💎", "🔮", "⚔️", "🛡️", "👑",
                          "🏴‍☠️", "🧙‍♂️", "🕵️", "🎮", "📡", "📜", "🔢", "🪞", "🚂", "🔐", "🗝️", "🧩"]

struct CustomModeView: View {
    @ObservedObject var viewModel: CipherViewModel
    @Binding var isPresented: Bool

    @State private var modeName = ""
    @State private var modeEmoji = "🔒"
    @State private var modeDescription = ""
    @State private var selectedCiphers: [CipherConfig] = []
    @State private var showingCipherPicker = false
    @State private var editingSettingsIndex: Int?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 8) {
                        Text("🛠️ Create Custom Mode")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)

                        Text("Build your own unique cipher combination")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    .padding(.top)

                    // Name and Emoji
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Mode Details")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)

                        HStack {
                            Text(modeEmoji)
                                .font(.system(size: 40))
                                .onTapGesture { cycleEmoji() }

                            VStack(spacing: 8) {
                                TextField("Mode Name", text: $modeName)
                                    .textFieldStyle(CustomTextFieldStyle())

                                TextField("Description", text: $modeDescription)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Cipher Chain
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Cipher Chain")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)

                            Spacer()

                            Button(action: { showingCipherPicker = true }) {
                                Label("Add Cipher", systemImage: "plus.circle.fill")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.orange)
                            }
                        }

                        if selectedCiphers.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "link.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundColor(.orange.opacity(0.5))

                                Text("No ciphers added yet")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(.gray)

                                Text("Tap 'Add Cipher' to build your chain")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(.gray.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            CipherChainListView(
                                selectedCiphers: $selectedCiphers,
                                editingSettingsIndex: $editingSettingsIndex
                            )
                        }
                    }
                    .padding(.horizontal)

                    // Create Button
                    Button(action: createMode) {
                        Text("Create Mode")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.orange, Color(hex: "ff8800")]),
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                    .disabled(modeName.isEmpty || selectedCiphers.isEmpty)
                    .opacity(modeName.isEmpty || selectedCiphers.isEmpty ? 0.5 : 1)
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
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
        .sheet(isPresented: $showingCipherPicker) {
            CipherPickerView(selectedCiphers: $selectedCiphers)
        }
        .sheet(item: $editingSettingsIndex) { index in
            CipherSettingsView(
                cipherType: selectedCiphers[index].cipherType,
                initialSettings: selectedCiphers[index].settings,
                isEditing: true
            ) { newSettings in
                selectedCiphers[index] = CipherConfig(
                    id: selectedCiphers[index].id,
                    cipherType: selectedCiphers[index].cipherType,
                    settings: newSettings
                )
            }
        }
    }

    private func cycleEmoji() {
        let current = modeEmojis.firstIndex(of: modeEmoji) ?? -1
        modeEmoji = modeEmojis[(current + 1) % modeEmojis.count]
    }

    private func createMode() {
        let mode = CipherMode(
            name: modeName,
            emoji: modeEmoji,
            description: modeDescription.isEmpty ? "Custom cipher mode" : modeDescription,
            cipherChain: selectedCiphers,
            isCustom: true
        )
        viewModel.addCustomMode(mode)
        isPresented = false
    }
}

/// Isolated subview so the List is NOT re-rendered on every text field keystroke.
struct CipherChainListView: View {
    @Binding var selectedCiphers: [CipherConfig]
    @Binding var editingSettingsIndex: Int?

    var body: some View {
        List {
            ForEach(Array(selectedCiphers.enumerated()), id: \.element.id) { index, config in
                CipherRowView(config: config, index: index, editingSettingsIndex: $editingSettingsIndex)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            }
            .onMove { from, to in selectedCiphers.move(fromOffsets: from, toOffset: to) }
            .onDelete { offsets in selectedCiphers.remove(atOffsets: offsets) }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .frame(height: CGFloat(selectedCiphers.count) * 76)
        .environment(\.editMode, .constant(.active))
    }
}

struct CipherRowView: View {
    let config: CipherConfig
    let index: Int
    @Binding var editingSettingsIndex: Int?

    var body: some View {
        HStack {
            Text("\(index + 1)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.orange)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color.orange.opacity(0.2)))

            VStack(alignment: .leading, spacing: 2) {
                Text(config.cipherType.rawValue)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                if !config.settingsSummary.isEmpty {
                    Text(config.settingsSummary)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            if config.cipherType.hasConfigurableSettings {
                Button(action: { editingSettingsIndex = index }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.orange.opacity(0.8))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "1a1a1a"))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange.opacity(0.3), lineWidth: 1))
        )
    }
}

// Make Int identifiable so sheet(item: $editingSettingsIndex) works
extension Int: @retroactive Identifiable {
    public var id: Int { self }
}

#Preview {
    CustomModeView(
        viewModel: CipherViewModel(),
        isPresented: .constant(true)
    )
}
