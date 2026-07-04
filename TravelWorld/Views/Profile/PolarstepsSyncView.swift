import SwiftUI
import SwiftData

/// Placeholder Polarsteps integration. Loads mocked trips and imports their places as
/// visited — but only when the user explicitly taps Import (privacy-first).
struct PolarstepsSyncView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var context
    @State private var trips: [ImportableTrip] = []
    @State private var isLoading = false
    @State private var connected = false
    @State private var importedTripIDs: Set<UUID> = []

    var body: some View {
        Form {
            Section {
                Label {
                    Text("Connect Polarsteps to automatically mark places as visited from your trips.")
                } icon: {
                    Image(systemName: "figure.walk.motion").foregroundStyle(AppTheme.Colors.accent)
                }
            }

            if !connected {
                Section {
                    Button {
                        Task { await connect() }
                    } label: {
                        HStack {
                            if isLoading { ProgressView().padding(.trailing, 4) }
                            Text(isLoading ? "Connecting…" : "Connect Polarsteps")
                        }
                    }
                    .disabled(isLoading)
                }
            } else {
                ForEach(trips) { trip in
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: AppTheme.Spacing.md) {
                                PlaceImage(reference: trip.coverImageURL, seed: trip.name)
                                    .frame(width: 56, height: 56)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm, style: .continuous))
                                VStack(alignment: .leading) {
                                    Text(trip.name).font(.headline)
                                    Text(trip.startDate, format: .dateTime.month().year())
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            ForEach(trip.places, id: \.name) { place in
                                Text("• \(place.name), \(place.country)")
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                            Button {
                                importTrip(trip)
                            } label: {
                                Label(importedTripIDs.contains(trip.id) ? "Imported" : "Import as visited",
                                      systemImage: importedTripIDs.contains(trip.id) ? "checkmark.circle.fill" : "square.and.arrow.down")
                            }
                            .disabled(importedTripIDs.contains(trip.id))
                            .padding(.top, 4)
                        }
                    }
                }
            }
        }
        .navigationTitle("Polarsteps")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func connect() async {
        isLoading = true
        defer { isLoading = false }
        trips = (try? await appState.polarsteps.availableTrips()) ?? []
        connected = true
        Haptics.light()
    }

    private func importTrip(_ trip: ImportableTrip) {
        let storedTrip = Trip(name: trip.name, startDate: trip.startDate, endDate: trip.endDate,
                              coverImageURL: trip.coverImageURL, source: .polarsteps)
        context.insert(storedTrip)
        for place in trip.places {
            let location = Location(
                name: place.name, country: place.country, region: place.region,
                latitude: place.latitude, longitude: place.longitude, imageURL: place.imageURL,
                status: .visited, source: .polarsteps, tags: place.suggestedTags,
                visitedDate: trip.endDate ?? trip.startDate, tripID: storedTrip.uuid
            )
            context.insert(location)
        }
        try? context.save()
        importedTripIDs.insert(trip.id)
        Haptics.success()
    }
}

#Preview {
    NavigationStack { PolarstepsSyncView() }
        .environment(AppState())
        .modelContainer(PreviewData.container)
}
