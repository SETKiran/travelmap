import Foundation

/// Mapbox access configuration.
///
/// 1. Create a free account at https://account.mapbox.com
/// 2. Copy your **public** token (starts with `pk.`) and paste it below.
/// 3. For the SDK download, add a **secret** token (scope `Downloads:Read`) to `~/.netrc`
///    — see the README. Without it, Swift Package Manager can't fetch MapboxMaps.
enum MapboxConfig {
    static let accessToken = "pk.PASTE_YOUR_MAPBOX_PUBLIC_TOKEN_HERE"

    static var isConfigured: Bool { accessToken.hasPrefix("pk.") && !accessToken.contains("PASTE") }
}
