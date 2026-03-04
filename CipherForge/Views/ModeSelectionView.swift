import SwiftUI

struct ModeSelectionView: View {
    @ObservedObject var viewModel: CipherViewModel
    @Binding var isPresented: Bool
    @State private var editingMode: CipherMode?
    @State private var showingEditSheet = false
    @State private var showingCustomMode = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("CHOOSE CIPHER")
                            .font(.system(size: 24, weight: .black, design: .serif))
                            .kerning(1.5)
                            .foregroundColor(.orange)

                        Text("SELECT A PRESET MODE")
                            .font(.system(size: 11, weight: .semibold, design: .serif))
                            .kerning(1)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 60)

                    // Preset Modes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PRESET MODES")
                            .font(.system(size: 14, weight: .bold, design: .serif))
                            .kerning(1)
                            .foregroundColor(.orange)
                            .padding(.horizontal)

                            ForEach(viewModel.availableModes) { mode in
                                ModeCard(
                                    mode: mode,
                                    isSelected: mode.id == viewModel.selectedMode.id
                                ) {
                                    viewModel.selectedMode = mode
                                    isPresented = false
                                }
                            }
                        }

                    // Custom Modes
                    if !viewModel.customModes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("CUSTOM MODES")
                                    .font(.system(size: 14, weight: .bold, design: .serif))
                                    .kerning(1)
                                    .foregroundColor(.orange)

                                Spacer()

                                Text("LONG PRESS TO EDIT/DELETE")
                                    .font(.system(size: 9, weight: .semibold, design: .serif))
                                    .kerning(0.5)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)

                            ForEach(Array(viewModel.customModes.enumerated()), id: \.element.id) { index, mode in
                                ModeCard(
                                    mode: mode,
                                    isSelected: mode.id == viewModel.selectedMode.id,
        
                                    action: {
                                        viewModel.selectedMode = mode
                                        isPresented = false
                                    },
                                    onEdit: {
                                        editingMode = mode
                                        showingEditSheet = true
                                    },
                                    onDelete: {
                                        viewModel.deleteCustomMode(at: IndexSet(integer: index))
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.bottom, 100)
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
        .overlay(alignment: .bottom) {
            Button(action: { showingCustomMode = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("CREATE CUSTOM")
                        .font(.system(size: 16, weight: .black, design: .serif))
                        .kerning(1)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "CD7F32"),
                            Color.orange,
                            Color(hex: "ff8800")
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: .orange.opacity(0.5), radius: 8, x: 0, y: 4)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            if let mode = editingMode {
                EditCustomModeView(viewModel: viewModel, mode: mode, isPresented: $showingEditSheet)
            }
        }
        .sheet(isPresented: $showingCustomMode) {
            CustomModeView(viewModel: viewModel, isPresented: $showingCustomMode)
        }
    }
}

struct ModeCard: View {
    let mode: CipherMode
    let isSelected: Bool
    let action: () -> Void
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(mode.emoji)
                    .font(.system(size: 32))

                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.name.uppercased())
                        .font(.system(size: 14, weight: .bold, design: .serif))
                        .kerning(0.5)
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(mode.description)
                        .font(.system(size: 11, design: .serif))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.orange)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: isSelected ? "2a2a2a" : "1a1a1a"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.orange : Color.orange.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
            )
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
        .if(onEdit != nil || onDelete != nil) { view in
            view.contextMenu {
                if let onEdit = onEdit {
                    Button(action: onEdit) {
                        Label("Edit", systemImage: "pencil")
                    }
                }
                if let onDelete = onDelete {
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
}

// Helper extension for conditional view modifiers
extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct EditCustomModeView: View {
    @ObservedObject var viewModel: CipherViewModel
    let mode: CipherMode
    @Binding var isPresented: Bool

    @State private var modeName: String
    @State private var modeEmoji: String
    @State private var modeDescription: String
    @State private var selectedCiphers: [CipherConfig]
    @State private var showingCipherPicker = false
    @State private var editingSettingsIndex: Int?

    init(viewModel: CipherViewModel, mode: CipherMode, isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        self.mode = mode
        self._isPresented = isPresented
        self._modeName = State(initialValue: mode.name)
        self._modeEmoji = State(initialValue: mode.emoji)
        self._modeDescription = State(initialValue: mode.description)
        self._selectedCiphers = State(initialValue: mode.cipherChain)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    VStack(spacing: 8) {
                        Text("✏️ Edit Custom Mode")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                        Text("Modify your cipher combination")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    .padding(.top)

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

                    Button(action: saveChanges) {
                        Text("Save Changes")
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

    private func saveChanges() {
        if let index = viewModel.customModes.firstIndex(where: { $0.id == mode.id }) {
            var updatedMode = mode
            updatedMode.name = modeName
            updatedMode.emoji = modeEmoji
            updatedMode.description = modeDescription.isEmpty ? "Custom cipher mode" : modeDescription
            updatedMode.cipherChain = selectedCiphers
            viewModel.customModes[index] = updatedMode
            viewModel.saveCustomModes()
            isPresented = false
        }
    }
}

#Preview {
    ModeSelectionView(
        viewModel: CipherViewModel(),
        isPresented: .constant(true)
    )
}
