import SwiftUI

/// Paste a TikTok / Instagram / YouTube link; we detect the place (mocked) and let
/// the user confirm before anything is saved.
struct SocialLinkImportView: View {
    @Environment(AppState.self) private var appState
    @State private var urlString = ""
    @State private var detected: DetectedPlace?
    @State private var isDetecting = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section {
                TextField("Paste a link", text: $urlString, axis: .vertical)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                Button {
                    Task { await detect() }
                } label: {
                    HStack {
                        if isDetecting { ProgressView().padding(.trailing, 4) }
                        Text(isDetecting ? "Detecting…" : "Detect place")
                    }
                }
                .disabled(urlString.isEmpty || isDetecting)
            } footer: {
                Text("We read the link's location. Nothing is saved until you confirm.")
            }

            if let errorMessage {
                Section { Label(errorMessage, systemImage: "exclamationmark.triangle").foregroundStyle(.orange) }
            }

            if let detected {
                Section("Detected place") {
                    HStack(spacing: AppTheme.Spacing.md) {
                        PlaceImage(reference: detected.imageURL, seed: detected.name)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm, style: .continuous))
                        VStack(alignment: .leading) {
                            Text(detected.name).font(.headline)
                            Text(detected.country).font(.subheadline).foregroundStyle(.secondary)
                            Label(detected.source.label, systemImage: detected.source.symbol)
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    NavigationLink {
                        AddLocationConfirmView(draft: LocationDraft(from: detected))
                    } label: {
                        Label("Confirm and continue", systemImage: "checkmark.circle")
                    }
                }
            }
        }
        .navigationTitle("From a Link")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detect() async {
        isDetecting = true
        errorMessage = nil
        detected = nil
        defer { isDetecting = false }
        do {
            detected = try await appState.socialImport.detectPlace(from: urlString)
            Haptics.light()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack { SocialLinkImportView() }
        .environment(AppState())
        .modelContainer(PreviewData.container)
}
