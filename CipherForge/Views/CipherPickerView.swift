import SwiftUI

struct CipherPickerView: View {
    @Binding var selectedCiphers: [CipherConfig]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    Text("Select Cipher")
                        .font(.headline)
                        .foregroundColor(.white)
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
                    VStack(spacing: 12) {
                        ForEach(CipherType.allCases, id: \.self) { type in
                            Button(action: {
                                selectedCiphers.append(CipherConfig(cipherType: type, settings: type.defaultSettings()))
                                dismiss()
                            }) {
                                HStack {
                                    Text(type.rawValue)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)

                                    Spacer()

                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.orange)
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
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
    }
}
