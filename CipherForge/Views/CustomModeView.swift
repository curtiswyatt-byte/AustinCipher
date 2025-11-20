import SwiftUI

struct CustomModeView: View {
    @ObservedObject var viewModel: CipherViewModel
    @Binding var isPresented: Bool

    @State private var modeName = ""
    @State private var modeEmoji = "🔒"
    @State private var modeDescription = ""
    @State private var selectedCiphers: [CipherConfig] = []
    @State private var showingCipherPicker = false

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
                                    .onTapGesture {
                                        // Cycle through emoji
                                        let emojis = ["🔒", "⚡", "🌟", "🎯", "🚀", "💎", "🔮", "⚔️", "🛡️", "👑"]
                                        if let index = emojis.firstIndex(of: modeEmoji) {
                                            modeEmoji = emojis[(index + 1) % emojis.count]
                                        }
                                    }

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
                                VStack(spacing: 10) {
                                    ForEach(Array(selectedCiphers.enumerated()), id: \.element.id) { index, config in
                                        HStack {
                                            Text("\(index + 1)")
                                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                                .foregroundColor(.orange)
                                                .frame(width: 30, height: 30)
                                                .background(Circle().fill(Color.orange.opacity(0.2)))

                                            Text(config.cipherType.rawValue)
                                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                                .foregroundColor(.white)

                                            Spacer()

                                            Button(action: {
                                                selectedCiphers.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(hex: "1a1a1a"))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                    }
                                }
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
                                        startPoint: .leading,
                                        endPoint: .trailing
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


#Preview {
    CustomModeView(
        viewModel: CipherViewModel(),
        isPresented: .constant(true)
    )
}
