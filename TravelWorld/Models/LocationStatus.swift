import SwiftUI

enum LocationStatus: String, Codable, CaseIterable, Identifiable {
    case wantToVisit
    case visited

    var id: String { rawValue }

    var title: String {
        switch self {
        case .wantToVisit: return "Want to Visit"
        case .visited: return "Visited"
        }
    }

    var shortTitle: String {
        switch self {
        case .wantToVisit: return "Dream"
        case .visited: return "Visited"
        }
    }

    var symbol: String {
        switch self {
        case .wantToVisit: return "sparkles"
        case .visited: return "checkmark.seal.fill"
        }
    }

    var tint: Color {
        switch self {
        case .wantToVisit: return AppTheme.Colors.wantToVisit
        case .visited: return AppTheme.Colors.visited
        }
    }
}

/// Where a saved place originally came from. Drives small provenance UI and future imports.
enum LocationSource: String, Codable, CaseIterable {
    case manual
    case tiktok
    case instagram
    case youtube
    case polarsteps
    case applePhotos
    case imported

    var label: String {
        switch self {
        case .manual: return "Added manually"
        case .tiktok: return "From TikTok"
        case .instagram: return "From Instagram"
        case .youtube: return "From YouTube"
        case .polarsteps: return "From Polarsteps"
        case .applePhotos: return "From Photos"
        case .imported: return "Imported"
        }
    }

    var symbol: String {
        switch self {
        case .manual: return "hand.point.up.left"
        case .tiktok, .youtube: return "play.rectangle"
        case .instagram: return "camera"
        case .polarsteps: return "figure.walk"
        case .applePhotos: return "photo.on.rectangle"
        case .imported: return "square.and.arrow.down"
        }
    }
}

/// Lightweight, curated tag vocabulary. Kept small on purpose — no free-for-all clutter.
enum LocationTag: String, Codable, CaseIterable, Identifiable {
    case nature, city, food, culture, beach, adventure, wonder, romantic

    var id: String { rawValue }

    var label: String { rawValue.capitalized }

    var symbol: String {
        switch self {
        case .nature: return "leaf"
        case .city: return "building.2"
        case .food: return "fork.knife"
        case .culture: return "theatermasks"
        case .beach: return "beach.umbrella"
        case .adventure: return "figure.hiking"
        case .wonder: return "sparkle"
        case .romantic: return "heart"
        }
    }
}
