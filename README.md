# Wander — your beautiful personal map of places

A minimalist, premium iOS travel bucket-list & memory app built with SwiftUI, MapKit, SwiftData and WidgetKit.

> Your beautiful personal map of places you dream of visiting and memories you have made.

## Requirements

- macOS with **Xcode 15+** (iOS 17 SDK)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate the Xcode project from `project.yml`

```bash
brew install xcodegen
```

## Getting started

```bash
cd TravelWorld
xcodegen generate      # creates TravelWorld.xcodeproj from project.yml
open TravelWorld.xcodeproj
```

Then in Xcode:

1. Select the **TravelWorld** scheme and an iOS 17 simulator (e.g. iPhone 15 Pro).
2. Set your **Development Team** on both the `TravelWorld` and `TravelWorldWidgets` targets (Signing & Capabilities) if you run on device.
3. Run. The app launches pre-seeded with 10 sample places so the map feels alive immediately.

### Widgets

The widget extension shares data with the app through the App Group
`group.com.wander.travelworld`. The app writes a small JSON snapshot on every change;
widgets read it — no shared SwiftData store required. Add a Wander widget from the
Home Screen gallery to see the **Your World** globe widget (an orthographic globe
rendered from your coordinates, auto-centered on where you've been), plus **Dream
Place** and **Memory** widgets. All widgets render offline via a shared `Canvas`
globe (`Shared/WorldGlobeView.swift`) — no map tiles or network images.

## Architecture

Simple, scalable MVVM. Views are dumb; view models own presentation logic; services
are protocol-first so the mock importers can be swapped for real ones later.

```
TravelWorld/
  App/            app entry, global state, root tab shell
  Models/         SwiftData models + sample seed data
  Services/       protocol-first services (search, images, imports, recap)
  ViewModels/     one per screen
  Views/          Globe · Places · AddLocation · LocationDetail · Recap · Profile
  DesignSystem/   theme, reusable cards, markers, badges, haptics
TravelWorldWidgets/
                  WidgetKit widgets + shared snapshot reader
```

### Swapping mocks for real integrations

Every integration is behind a protocol with a `Mock…` implementation:

| Protocol | Mock | Future real source |
| --- | --- | --- |
| `SocialLinkImportService` | `MockSocialLinkImportService` | URL metadata / caption parsing / OCR / LLM extraction |
| `PolarstepsSyncService` | `MockPolarstepsSyncService` | Polarsteps export / API |
| `PhotoLocationImportService` | `MockPhotoLocationImportService` | Photos framework + CLLocation reverse-geocode |
| `ImageService` | `RemoteImageService` | Unsplash / Pexels / user uploads |

Inject a real implementation in `AppState` and nothing else needs to change.

## Privacy

- No background location tracking.
- Nothing is ever silently marked as visited — imports always require explicit confirmation.
- Data is local-first (SwiftData). iCloud sync is a prepared toggle, not yet wired.
