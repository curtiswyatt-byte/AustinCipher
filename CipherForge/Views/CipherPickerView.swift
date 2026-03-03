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
                    VStack(spacing: 2) {
                        Text("Add Ciphers")
                            .font(.headline)
                            .foregroundColor(.white)
                        if !selectedCiphers.isEmpty {
                            Text("\(selectedCiphers.count) in chain")
                                .font(.system(size: 11, design: .rounded))
                                .foregroundColor(.orange)
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color.black.opacity(0.9))
                .overlay(alignment: .trailing) {
                    Button(action: { dismiss() }) {
                        Text("Done")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.orange)
                            .padding()
                    }
                }

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(CipherType.allCases, id: \.self) { type in
                            Button(action: {
                                selectedCiphers.append(CipherConfig(cipherType: type, settings: type.defaultSettings()))
                            }) {
                                HStack {
                                    Text(type.rawValue)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)

                                    Spacer()

                                    let count = selectedCiphers.filter { $0.cipherType == type }.count
                                    if count > 0 {
                                        Text("×\(count)")
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                            .foregroundColor(.orange)
                                    }

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
