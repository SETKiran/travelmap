import SwiftUI
import Observation

@Observable
final class RecapViewModel {
    var recap: Recap?
    var isPlaying = false
    var index = 0

    func build(from locations: [Location], generator: RecapGeneratorService, year: Int) {
        recap = generator.generate(from: locations, year: year)
        index = 0
    }

    var currentCard: RecapCard? {
        guard let recap, recap.cards.indices.contains(index) else { return nil }
        return recap.cards[index]
    }

    var cardCount: Int { recap?.cards.count ?? 0 }

    /// One step past the generated cards is the shareable finale.
    var isFinale: Bool { index >= cardCount }

    /// Total steps including the finale, for the progress bar.
    var stepCount: Int { cardCount + 1 }

    func advance() {
        guard recap != nil else { return }
        if index < cardCount {
            withAnimation(.easeInOut) { index += 1 }
            Haptics.soft()
        } else {
            isPlaying = false
        }
    }

    func back() {
        if index > 0 { withAnimation(.easeInOut) { index -= 1 } }
    }

    func start() {
        index = 0
        isPlaying = true
        Haptics.light()
    }
}
