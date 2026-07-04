import Foundation

/// Maps a country name to its flag emoji — a lightweight, image-free way to add
/// visual identity to cards and widgets. Falls back to a globe for unknowns.
enum CountryFlag {
    static func emoji(for country: String) -> String {
        let key = country.lowercased()
        if let iso = isoCode[key] { return flag(from: iso) }
        return "🌍"
    }

    private static func flag(from iso: String) -> String {
        iso.uppercased().unicodeScalars.compactMap {
            Unicode.Scalar(127397 + $0.value).map(String.init)
        }.joined()
    }

    private static let isoCode: [String: String] = [
        "jordan": "JO", "peru": "PE", "japan": "JP", "italy": "IT", "iceland": "IS",
        "indonesia": "ID", "united states": "US", "usa": "US", "south africa": "ZA",
        "canada": "CA", "greece": "GR", "portugal": "PT", "thailand": "TH", "chile": "CL",
        "france": "FR", "spain": "ES", "germany": "DE", "netherlands": "NL", "belgium": "BE",
        "united kingdom": "GB", "uk": "GB", "ireland": "IE", "norway": "NO", "sweden": "SE",
        "denmark": "DK", "finland": "FI", "switzerland": "CH", "austria": "AT", "poland": "PL",
        "mexico": "MX", "brazil": "BR", "argentina": "AR", "colombia": "CO", "australia": "AU",
        "new zealand": "NZ", "china": "CN", "india": "IN", "vietnam": "VN", "south korea": "KR",
        "turkey": "TR", "egypt": "EG", "morocco": "MA", "kenya": "KE", "tanzania": "TZ",
        "croatia": "HR", "czech republic": "CZ", "hungary": "HU", "united arab emirates": "AE",
        "faroe islands": "FO", "philippines": "PH", "malaysia": "MY", "singapore": "SG"
    ]
}
