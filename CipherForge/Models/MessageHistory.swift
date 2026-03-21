import Foundation

struct MessageRecord: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let originalText: String
    let encryptedText: String
    let modeName: String
    let isEncryption: Bool

    init(id: UUID = UUID(), timestamp: Date = Date(), originalText: String, encryptedText: String, modeName: String, isEncryption: Bool) {
        self.id = id
        self.timestamp = timestamp
        self.originalText = originalText
        self.encryptedText = encryptedText
        self.modeName = modeName
        self.isEncryption = isEncryption
    }
}

class MessageHistory: ObservableObject {
    @Published var records: [MessageRecord] = []

    private let saveKey = "CipherForgeHistory"
    private let maxHistorySize = 500  // Prevent unbounded growth
    private var pendingSave: DispatchWorkItem?

    init() {
        loadHistory()
    }

    func addRecord(original: String, encrypted: String, mode: String, isEncryption: Bool) {
        let record = MessageRecord(
            originalText: original,
            encryptedText: encrypted,
            modeName: mode,
            isEncryption: isEncryption
        )
        records.append(record)

        // Security: Limit history size to prevent unbounded growth
        if records.count > maxHistorySize {
            records.removeFirst()
        }

        saveHistoryDebounced()
    }

    func deleteRecord(at offsets: IndexSet) {
        records.remove(atOffsets: offsets)
        saveHistory()
    }

    func clearHistory() {
        records.removeAll()
        saveHistory()
    }

    /// Coalesces rapid saves — only writes to disk 2 seconds after the last addRecord call.
    private func saveHistoryDebounced() {
        pendingSave?.cancel()
        let snapshot = records
        let key = saveKey
        let work = DispatchWorkItem {
            if let encoded = try? JSONEncoder().encode(snapshot) {
                UserDefaults.standard.set(encoded, forKey: key)
            }
        }
        pendingSave = work
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2, execute: work)
    }

    private func saveHistory() {
        pendingSave?.cancel()
        let snapshot = records
        let key = saveKey
        DispatchQueue.global(qos: .background).async {
            if let encoded = try? JSONEncoder().encode(snapshot) {
                UserDefaults.standard.set(encoded, forKey: key)
            }
        }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([MessageRecord].self, from: data) {
            records = decoded
        }
    }
}
