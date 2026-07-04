import Foundation
import Observation

@Observable
final class AddLocationViewModel {
    var query = ""
    var results: [PlaceSearchResult] = []
    var isSearching = false
    var errorMessage: String?

    private let search: LocationSearchService
    private var searchTask: Task<Void, Never>?

    init(search: LocationSearchService) {
        self.search = search
    }

    func onQueryChange() {
        searchTask?.cancel()
        let current = query
        guard current.trimmingCharacters(in: .whitespaces).count >= 2 else {
            results = []
            return
        }
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300)) // debounce
            guard !Task.isCancelled else { return }
            await performSearch(current)
        }
    }

    @MainActor
    private func performSearch(_ text: String) async {
        isSearching = true
        defer { isSearching = false }
        do {
            let found = try await search.search(text)
            guard !Task.isCancelled else { return }
            results = found
            errorMessage = nil
        } catch {
            errorMessage = "Couldn't search right now."
        }
    }
}
