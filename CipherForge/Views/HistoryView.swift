import SwiftUI

struct HistoryView: View {
    @ObservedObject var history: MessageHistory
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
                Color.black.ignoresSafeArea()

                if history.records.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.orange.opacity(0.5))

                        Text("No History Yet")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Your encrypted and decrypted messages will appear here")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(history.records) { record in
                                HistoryCard(record: record)
                            }
                        }
                        .padding()
                    }
                }
        }
        .overlay(alignment: .top) {
            HStack {
                Button(action: { dismiss() }) {
                    Text("Done")
                        .foregroundColor(.orange)
                        .padding()
                }

                Spacer()

                Text("History")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                if !history.records.isEmpty {
                    Button(role: .destructive, action: { history.clearHistory() }) {
                        Text("Clear All")
                            .foregroundColor(.red)
                            .padding()
                    }
                } else {
                    Text("")
                        .padding()
                }
            }
            .background(Color.black.opacity(0.9))
        }
    }
}

struct HistoryCard: View {
    let record: MessageRecord
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: record.isEncryption ? "lock.fill" : "lock.open.fill")
                    .foregroundColor(.orange)

                Text(record.isEncryption ? "Encrypted" : "Decrypted")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Spacer()

                Text(record.timestamp, style: .relative)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.gray)
            }

            // Mode
            Text(record.modeName)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.2))
                .foregroundColor(.orange)
                .cornerRadius(6)

            // Preview
            VStack(alignment: .leading, spacing: 8) {
                Text("Original:")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray)

                Text(record.originalText)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(isExpanded ? nil : 2)

                Divider().background(Color.orange.opacity(0.3))

                Text("Result:")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray)

                Text(record.encryptedText)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(isExpanded ? nil : 2)
            }

            // Expand button
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Spacer()
                    Text(isExpanded ? "Show Less" : "Show More")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.orange)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(hex: "1a1a1a"))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    HistoryView(history: MessageHistory())
}
