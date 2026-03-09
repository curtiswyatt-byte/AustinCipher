import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CipherViewModel()
    @State private var inputText = ""
    @State private var showingModeSelection = false
    @State private var showingHistory = false
    @State private var showingShare = false
    @State private var showingCustomMode = false
    @State private var showingImport = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(hex: "1a1a1a")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                // Header
                VStack(spacing: 4) {
                    Text("⚒️ CIPHER FORGE")
                        .font(.system(size: 32, weight: .black, design: .serif))
                        .kerning(2)
                        .foregroundColor(.orange)
                        .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 0)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)

                    Text("FORGE SECRET CODES")
                        .font(.system(size: 10, weight: .semibold, design: .serif))
                        .kerning(1)
                        .foregroundColor(.orange.opacity(0.7))
                }
                .padding(.top, 8)

                // Mode Selection
                Button(action: { showingModeSelection = true }) {
                    HStack(spacing: 10) {
                        Text(viewModel.selectedMode.emoji)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(viewModel.selectedMode.name.uppercased())
                                .font(.system(size: 13, weight: .bold, design: .serif))
                                .kerning(0.5)
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Text(viewModel.selectedMode.description)
                                .font(.system(size: 9, design: .serif))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                        Spacer(minLength: 4)
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "2a2a2a"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal)

                // Input/Output Section
                VStack(spacing: 10) {
                    // Input
                    VStack(alignment: .leading, spacing: 6) {
                        Text(viewModel.isEncrypting ? "PLAIN TEXT" : "ENCRYPTED MESSAGE")
                            .font(.system(size: 12, weight: .bold, design: .serif))
                            .kerning(0.5)
                            .foregroundColor(.orange)

                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "1a1a1a"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                                .frame(height: 90)

                            TextEditor(text: $inputText)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .foregroundColor(.white)
                                .font(.system(size: 14, design: .monospaced))
                                .padding(6)
                                .frame(height: 90)
                                .focused($isInputFocused)
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button("Done") { isInputFocused = false }
                                            .foregroundColor(.orange)
                                    }
                                }
                        }
                    }

                    // Action Buttons
                    HStack(spacing: 15) {
                        Button(action: { inputText = viewModel.swapInputOutput(currentInput: inputText) }) {
                            Image(systemName: "arrow.up.arrow.down.circle.fill")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }

                        Button(action: {
                            isInputFocused = false
                            viewModel.processText(input: inputText)
                        }) {
                            HStack {
                                Image(systemName: viewModel.isEncrypting ? "lock.fill" : "lock.open.fill")
                                Text(viewModel.isEncrypting ? "ENCRYPT" : "DECRYPT")
                                    .font(.system(size: 18, weight: .black, design: .serif))
                                    .kerning(1.5)
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "CD7F32"), // Copper/Bronze
                                        Color.orange,
                                        Color(hex: "ff8800")
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .orange.opacity(0.5), radius: 8, x: 0, y: 4)
                            .cornerRadius(12)
                        }

                        Button(action: { inputText = ""; viewModel.clearAll() }) {
                            Image(systemName: "eraser.fill")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                    }

                    // Output
                    VStack(alignment: .leading, spacing: 6) {
                        Text(viewModel.isEncrypting ? "ENCRYPTED MESSAGE" : "PLAIN TEXT")
                            .font(.system(size: 12, weight: .bold, design: .serif))
                            .kerning(0.5)
                            .foregroundColor(.orange)

                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "1a1a1a"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                                .frame(height: 90)

                            ScrollView {
                                Text(viewModel.outputText.isEmpty ? "Output appears here..." : viewModel.outputText)
                                    .font(.system(size: 14, design: .monospaced))
                                    .foregroundColor(viewModel.outputText.isEmpty ? .gray : .white)
                                    .padding(6)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                            }
                            .frame(height: 90)
                        }

                        if !viewModel.outputText.isEmpty {
                            Button(action: {
                                #if os(macOS)
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(viewModel.outputText, forType: .string)
                                #else
                                UIPasteboard.general.string = viewModel.outputText
                                #endif
                            }) {
                                Label("Copy to Clipboard", systemImage: "doc.on.doc")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Bottom Actions
                HStack(spacing: 12) {
                    Button(action: { showingHistory = true }) {
                        VStack(spacing: 4) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 18))
                            Text("HISTORY")
                                .font(.system(size: 9, weight: .bold, design: .serif))
                                .kerning(0.3)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "2a2a2a"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }

                    Button(action: { showingShare = true }) {
                        VStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18))
                            Text("SHARE")
                                .font(.system(size: 9, weight: .bold, design: .serif))
                                .kerning(0.3)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "2a2a2a"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }

                    Button(action: { showingImport = true }) {
                        VStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 18))
                            Text("IMPORT")
                                .font(.system(size: 9, weight: .bold, design: .serif))
                                .kerning(0.3)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "2a2a2a"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .padding(.top)
        }
        // Tap anywhere outside a text field to dismiss the keyboard
        .simultaneousGesture(TapGesture().onEnded { _ in isInputFocused = false })
        .sheet(isPresented: $showingModeSelection) {
            ModeSelectionView(viewModel: viewModel, isPresented: $showingModeSelection)
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView(history: viewModel.history) { text in
                inputText = text
                showingHistory = false
            }
        }
        .sheet(isPresented: $showingShare) {
            ShareView(viewModel: viewModel, isPresented: $showingShare)
        }
        .sheet(isPresented: $showingCustomMode) {
            CustomModeView(viewModel: viewModel, isPresented: $showingCustomMode)
        }
        .sheet(isPresented: $showingImport) {
            ImportModeView(viewModel: viewModel, isPresented: $showingImport)
        }
    }
}

#Preview {
    ContentView()
}
