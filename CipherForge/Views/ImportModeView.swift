import SwiftUI

struct ImportModeView: View {
    @ObservedObject var viewModel: CipherViewModel
    @Binding var isPresented: Bool
    @State private var shareCode = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 8) {
                        Text("📥 IMPORT MODE")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(.orange)
                            .kerning(1.5)

                        Text("Enter a share code to import cipher settings")
                            .font(.system(size: 12, design: .serif))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 40)

                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("HOW TO IMPORT")
                            .font(.system(size: 14, weight: .bold, design: .serif))
                            .kerning(1)
                            .foregroundColor(.orange)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 12) {
                                Text("1.")
                                    .font(.system(size: 14, weight: .bold, design: .serif))
                                    .foregroundColor(.orange)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Get a share code from a friend")
                                        .font(.system(size: 13, design: .serif))
                                        .foregroundColor(.white)
                                    Text("Example: CF:CAE(shift:7)>REV")
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundColor(.gray)
                                }
                            }

                            HStack(alignment: .top, spacing: 12) {
                                Text("2.")
                                    .font(.system(size: 14, weight: .bold, design: .serif))
                                    .foregroundColor(.orange)
                                Text("Paste or type the code below")
                                    .font(.system(size: 13, design: .serif))
                                    .foregroundColor(.white)
                            }

                            HStack(alignment: .top, spacing: 12) {
                                Text("3.")
                                    .font(.system(size: 14, weight: .bold, design: .serif))
                                    .foregroundColor(.orange)
                                Text("Tap Import to add it to your custom modes")
                                    .font(.system(size: 13, design: .serif))
                                    .foregroundColor(.white)
                            }
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
                    .padding(.horizontal)

                    // Share Code Input
                    VStack(alignment: .leading, spacing: 10) {
                        Text("SHARE CODE")
                            .font(.system(size: 14, weight: .bold, design: .serif))
                            .kerning(1)
                            .foregroundColor(.orange)

                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "1a1a1a"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                                .frame(height: 100)

                            TextEditor(text: $shareCode)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .foregroundColor(.white)
                                .font(.system(size: 14, design: .monospaced))
                                .padding(8)
                                .frame(height: 100)
                                .autocapitalization(.allCharacters)
                                .disableAutocorrection(true)
                        }
                    }
                    .padding(.horizontal)

                    // Import Button
                    Button(action: importMode) {
                        Text("IMPORT MODE")
                            .font(.system(size: 18, weight: .black, design: .serif))
                            .kerning(1.5)
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
                    }
                    .disabled(shareCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(shareCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                    .padding(.horizontal)

                    if showSuccess {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Mode imported successfully!")
                                .font(.system(size: 14, weight: .semibold, design: .serif))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.green.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.green.opacity(0.5), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal)
                    }

                    if showError {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .font(.system(size: 14, weight: .semibold, design: .serif))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.red.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.red.opacity(0.5), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding(.bottom, 40)
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

    private func importMode() {
        showError = false
        showSuccess = false

        let trimmedCode = shareCode.trimmingCharacters(in: .whitespacesAndNewlines)

        if viewModel.importFromShareCode(trimmedCode) {
            showSuccess = true
            shareCode = ""

            // Auto-dismiss after 1.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isPresented = false
            }
        } else {
            showError = true
            errorMessage = "Invalid share code format"
        }
    }
}

#Preview {
    ImportModeView(
        viewModel: CipherViewModel(),
        isPresented: .constant(true)
    )
}
