import SwiftUI

/// Persists user-added memory photos as JPEGs in the app's documents directory.
/// The `Location` model stores only the file names.
enum MemoryImageStore {
    private static var directory: URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("Memories", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static func save(_ data: Data) -> String? {
        let name = "\(UUID().uuidString).jpg"
        let url = directory.appendingPathComponent(name)
        do {
            try data.write(to: url, options: .atomic)
            return name
        } catch {
            return nil
        }
    }

    static func url(for name: String) -> URL {
        directory.appendingPathComponent(name)
    }

    static func delete(_ name: String) {
        try? FileManager.default.removeItem(at: url(for: name))
    }
}

/// Loads a locally-stored memory image by file name.
struct MemoryImage: View {
    let name: String

    var body: some View {
        if let data = try? Data(contentsOf: MemoryImageStore.url(for: name)),
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage).resizable().scaledToFill()
        } else {
            GradientPlaceholder(seed: name)
        }
    }
}
