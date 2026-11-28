import CloudCore
import SwiftUI

/// A server-backed exploration page. It never reads PhotoKit or the synced timeline.
struct RandomExploreScreen: View {
    let session: LibrarySession
    @State private var model: RandomExploreModel
    @State private var albums: [CloudAlbum]
    @State private var showsFilters = false
    @State private var columns = 3
    @State private var headerBottom: CGFloat = 116
    @State private var safeBottom: CGFloat = 0

    init(session: LibrarySession, albums: [CloudAlbum] = []) {
        self.session = session
        _model = State(initialValue: RandomExploreModel(session: session))
        _albums = State(initialValue: albums)
    }

    var body: some View {
        @Bindable var model = model
        ZStack(alignment: .top) {
            if model.items.isEmpty {
                Color(.systemBackground).ignoresSafeArea()
                VStack(spacing: 14) {
                    Spacer()
                    if model.isLoading {
                        ProgressView()
                    } else if let error = model.errorMessage {
                        ContentUnavailableView(String(localized: "Couldn't Load Random Explore"), systemImage: "wifi.exclamationmark", description: Text(error))
                        Button("Try Again") { Task { await model.resetAndLoad() } }
                            .buttonStyle(.borderedProminent)
                    } else if model.hasLoaded {
                        ContentUnavailableView(String(localized: "No Matching Photos or Videos"), systemImage: "sparkles.rectangle.stack", description: Text(String(localized: "Try a different album, date range, or media type.")))
                    } else {
                        ProgressView()
                    }
                    Spacer()
                }
            } else {
                PhotoGridView(
                    snapshot: TimelineSnapshot(items: model.items, version: model.revision, isLoaded: true),
                    session: session,
                    columns: $columns,
                    insets: UIEdgeInsets(top: headerBottom + 8, left: 0, bottom: safeBottom + 12, right: 0),
                    isPrimary: false,
                    onNearBottom: { Task { await model.loadNextBatch() } },
                    preservesPositionWhenAppending: true,
                    viewerNearEnd: { viewer in
                        Task { @MainActor in
                            let added = await model.loadNextBatch()
                            viewer.appendItems(added)
                        }
                    }
                )
                .ignoresSafeArea()
                TopScrim(height: headerBottom + 44)
                    .ignoresSafeArea(edges: .top)
                    .allowsHitTesting(false)
                if let error = model.errorMessage, !model.isLoading {
                    VStack(spacing: 8) {
                        Text(error)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                        Button("Try Again") { Task { await model.loadNextBatch() } }
                            .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .frame(maxWidth: 340)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 16)
                    .padding(.bottom, safeBottom + 16)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text("Random Explore")
                        .font(.system(size: 34, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                    Spacer(minLength: 8)
                    Button { showsFilters = true } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 20, weight: .semibold))
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Filters")
                    .glassSurface(Circle())
                    Button { Task { await model.shuffle() } } label: {
                        Image(systemName: "shuffle")
                            .font(.system(size: 19, weight: .semibold))
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(.plain)
                    .disabled(model.isLoading)
                    .accessibilityLabel("Shuffle")
                    .glassSurface(Circle())
                }
                Text(summary)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.88))
                    .lineLimit(1)
            }
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.25), radius: 6, y: 1)
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            .onGeometryChange(for: CGFloat.self) { $0.frame(in: .global).maxY } action: { headerBottom = $0 }
        }
        .onGeometryChange(for: CGFloat.self) { $0.safeAreaInsets.bottom } action: { safeBottom = $0 }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showsFilters) {
            RandomExploreFiltersView(model: model, albums: albums)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .task {
            if albums.isEmpty {
                let owned = (try? await session.albums(shared: false)) ?? []
                let shared = (try? await session.albums(shared: true)) ?? []
                albums = (owned + shared).reduce(into: [CloudAlbum]()) { result, album in
                    if !result.contains(where: { $0.id == album.id }) { result.append(album) }
                }.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            }
            await model.start()
        }
        .onChange(of: model.filters) { _, _ in
            Task { await model.resetAndLoad() }
        }
    }

    private var summary: String {
        var parts: [String] = []
        if !model.filters.albumID.isEmpty, let album = albums.first(where: { $0.id == model.filters.albumID }) {
            parts.append(album.name)
        } else {
            parts.append(String(localized: "All Albums"))
        }
        parts.append(model.filters.media.title)
        if model.filters.dateRange != .all { parts.append(model.filters.dateRange.title) }
        return parts.joined(separator: " · ")
    }
}

private struct RandomExploreFiltersView: View {
    @Bindable var model: RandomExploreModel
    let albums: [CloudAlbum]

    private var startDate: Binding<Date> {
        Binding(
            get: { model.filters.startDate ?? Date.now },
            set: { model.filters.startDate = $0 }
        )
    }

    private var endDate: Binding<Date> {
        Binding(
            get: { model.filters.endDate ?? Date.now },
            set: { model.filters.endDate = $0 }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Album") {
                    Picker("Gallery Album", selection: $model.filters.albumID) {
                        Text("All Albums").tag("")
                        ForEach(albums) { album in
                            Text(album.name).tag(album.id)
                        }
                    }
                }
                Section("Media Type") {
                    Picker("Media Type", selection: $model.filters.media) {
                        ForEach(RandomExploreMediaFilter.allCases, id: \.self) { media in
                            Text(media.title).tag(media)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Date") {
                    Picker("Date Range", selection: $model.filters.dateRange) {
                        ForEach(RandomExploreDateRange.allCases, id: \.self) { range in
                            Text(range.title).tag(range)
                        }
                    }
                    if model.filters.dateRange == .custom {
                        DatePicker("Start Date", selection: startDate, displayedComponents: .date)
                        DatePicker("End Date", selection: endDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Random Explore Filters")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
