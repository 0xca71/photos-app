import CloudCore
import SwiftUI

struct RandomExploreScreen: View {
    let session: LibrarySession
    let collections: CollectionsModel
    @State var round: RandomExploreRound
    @State private var filter = RandomExploreFilter()
    @State private var editing = false
    @AppStorage("collection.columns") private var columns = 3

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { editing = true } label: {
                    Label("Filter", systemImage: filter == RandomExploreFilter() ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                }
                Spacer()
                Button { round.restart(query: filter.query()) } label: { Label("Shuffle", systemImage: "shuffle") }
            }
            .buttonStyle(.bordered)
            .padding(.horizontal)
            .padding(.vertical, 8)

            if !round.items.isEmpty {
                PhotoGridView(snapshot: TimelineSnapshot(items: round.items, version: round.version, isLoaded: true),
                              session: session, columns: $columns, isPrimary: false, exploration: round)
                    .id(round.roundID)
                if round.isLoading { ProgressView().padding(8) }
            } else if round.isLoading {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if round.errorMessage == nil {
                ContentUnavailableView("No Matching Photos or Videos", systemImage: "photo.on.rectangle",
                                       description: Text("Try a different album, date range, or media type."))
            }
            if let error = round.errorMessage {
                VStack(spacing: 8) {
                    Text(error).font(.callout).multilineTextAlignment(.center)
                    Button("Try Again") { round.retry() }
                }
                .padding()
                .frame(maxHeight: round.items.isEmpty ? .infinity : nil)
            }
        }
        .navigationTitle("Random Explore")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { if round.version == 0 { round.restart(query: filter.query()) } }
        .sheet(isPresented: $editing) {
            RandomExploreFilters(draft: filter, collections: collections, session: session) { selected in
                guard filter != selected else { return }
                filter = selected
                round.restart(query: selected.query())
            }
        }
    }
}

private struct RandomExploreFilters: View {
    @State var draft: RandomExploreFilter
    let collections: CollectionsModel
    let session: LibrarySession
    let apply: (RandomExploreFilter) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Gallery Album") {
                    Picker("Gallery Album", selection: $draft.albumID) {
                        Text("All Albums").tag(nil as String?)
                        ForEach(collections.albums ?? []) { album in Text(album.name).tag(Optional(album.id)) }
                        ForEach(collections.sharedAlbums ?? []) { album in Text(album.name).tag(Optional(album.id)) }
                    }
                    if collections.albums == nil {
                        if let error = collections.loadError {
                            Text(error).foregroundStyle(.secondary)
                            Button("Try Again") { Task { await collections.load(from: session, force: true) } }
                        } else if session.connection == nil {
                            Text(CloudError.notConnected.message).foregroundStyle(.secondary)
                        } else {
                            ProgressView("Loading Albums…")
                        }
                    }
                }
                Section("Media Type") {
                    Picker("Media Type", selection: $draft.media) {
                        Text("All").tag(RandomExploreFilter.Media.all)
                        Text("Photos").tag(RandomExploreFilter.Media.photos)
                        Text("Videos").tag(RandomExploreFilter.Media.videos)
                    }
                    .pickerStyle(.segmented)
                }
                Section("Capture Date") {
                    Picker("Date Range", selection: $draft.range) {
                        ForEach(RandomExploreFilter.Range.allCases, id: \.self) { Text($0.label).tag($0) }
                    }
                    if draft.range == .custom {
                        dayPicker("Start Date", selection: $draft.start)
                        dayPicker("End Date", selection: $draft.end)
                    }
                }
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Apply Filters") { apply(draft); dismiss() } }
            }
        }
    }

    @ViewBuilder
    private func dayPicker(_ label: LocalizedStringKey, selection: Binding<Date?>) -> some View {
        Toggle(label, isOn: Binding(get: { selection.wrappedValue != nil }, set: { selection.wrappedValue = $0 ? Date.now : nil }))
        if let day = selection.wrappedValue {
            DatePicker(label, selection: Binding(get: { selection.wrappedValue ?? day }, set: { selection.wrappedValue = $0 }), displayedComponents: .date)
        }
    }
}

private extension RandomExploreFilter.Range {
    var label: LocalizedStringKey {
        switch self {
        case .all: "All Dates"
        case .pastYear: "Past Year"
        case .oneToThree: "1–3 Years Ago"
        case .threeToFive: "3–5 Years Ago"
        case .fiveToTen: "5–10 Years Ago"
        case .overTen: "More Than 10 Years Ago"
        case .custom: "Custom Range"
        }
    }
}
