//
//  ContentView.swift
//  Headway_Test
//
//  Created by Robert Koval on 20.11.2023.
//

import SwiftUI
import AVKit
import ComposableArchitecture

struct LoadedTrack: Equatable {
    let id: Int
    let title: String
    let duration: TimeInterval
}

struct BookPlayerFeature: Reducer {
    enum Action: Equatable {
        case onAppear
        case playbackSpeedButtonTapped
        case playPauseButtonTapped
        case goBackward5ButtonTapped
        case goForward10ButtonTapped
        case playPreviousButtonTapped
        case playNextButtonTapped
        case rewindButtonTapped
        case selectChapterButtonTapped(Int)
        case chapterListSwitchToggled
        case trackPlaybackProgress
        case rewind(Double)


        // Side effects
        case playbackFinished
        case playerIsPlaying
        case playerIsPaused
        case trackDidChange(Int)
        case playbackProgress(Double)
        case playbackTime(Double)
        case tracksLoaded([LoadedTrack])
        case error(String)
    }

    enum PlaybackSpeed: Double {
        case slow = 0.5
        case normal = 1.0
        case fast = 1.5
        case superFast = 2.0
    }

    struct State: Equatable {
        var book: Book = mockBook
        var isLoading = false
        var loadedTracks: [LoadedTrack] = []
        var currentTrack: LoadedTrack?
        var isPlaying = false
        var playbackProgress: Double = 0

        var isChapterListOpen: Bool = false

        var playbackSpeed: PlaybackSpeed = .normal
        var chapterDescription: String = ""
        var chapterNumber: Int = 1
        var numberOfChapters: Int = 10
        var currentTime: TimeInterval = 0
        var totalPlaybackTime: TimeInterval = 360
    }

    @Dependency(\.audioPlayer) var audioPlayer
    @Dependency(\.feedbackGenerator) var feedbackGenerator
    @Dependency(\.chapterRepository) var chapterRepository

    private enum CancelID {
        case playbackProgress
        case trackID
        case playbackTime
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true

                return .merge(
                    .run { [book = state.book] send in
                        do {
                            let chapters = try await chapterRepository.getChaptersFor(book)
                            let tracks = chapters.map({ AudioTrack(id: $0.id, url: $0.audioFile) })
                            let metadata = try await audioPlayer.loadPlaylist(tracks)

                            let loadedChapters = chapters.filter({ chapter in metadata.contains(where: { $0.trackId == chapter.id }) })

                            let loadedTracks = zip(loadedChapters, metadata).map { chapter, metadata in
                                LoadedTrack(id: chapter.id, title: chapter.title, duration: metadata.duration)
                            }

                            await send(.tracksLoaded(loadedTracks))
                        } catch {
                            await send(.error(error.localizedDescription))
                        }
                    },
                    .run(operation: { send in
                        for await currentId in await audioPlayer.currentAudioId() {
                            await send(.trackDidChange(currentId))
                        }
                    })
                    .cancellable(id: CancelID.trackID),
                    .run(operation: { send in
                        for await time in try await audioPlayer.playbackTime() {
                            await send(.playbackTime(time))
                        }
                    })
                    .cancellable(id: CancelID.playbackTime)
                )
            case .playbackSpeedButtonTapped:
                print("Tapped")
                return .none
            case .playPauseButtonTapped:
                return .run { [state = state] send in
                    if state.isPlaying {
                        await audioPlayer.pause()
                        await send(.playerIsPaused)
                    } else {
                        await audioPlayer.play()
                        await send(.playerIsPlaying)
                    }
                }
            case .goBackward5ButtonTapped:
                return .run { send in
                    try await audioPlayer.rewindSeconds(-5)
                }
            case .goForward10ButtonTapped:
                return .run { send in
                    try await audioPlayer.rewindSeconds(10)
                }
            case .playPreviousButtonTapped:
                return .run { send in
                    await audioPlayer.playPrevious()
                }
            case .playNextButtonTapped:
                return .run { send in
                    await audioPlayer.playNext()
                }
            case .rewindButtonTapped:
                print("Tapped")
                return .none
            case .selectChapterButtonTapped(_):
                print("Tapped")
                return .none
            case let .rewind(value):
                return .run { send in
                    try await audioPlayer.rewind(value)
                }
            case .chapterListSwitchToggled:
                state.isChapterListOpen.toggle()
                return .run { send in
                    await feedbackGenerator.selectionOccured()
                }
            case let .trackDidChange(id):
                state.currentTrack = state.loadedTracks.first(where: { $0.id == id })
                return .none
            case .trackPlaybackProgress:
                return .run { send in
                    for await progress in try await audioPlayer.playbackProgress() {
                        await send(.playbackProgress(progress))
                    }
                }.cancellable(id: CancelID.playbackProgress)

            case .playbackFinished:
                print("Tapped")
                return .none
            case .playerIsPlaying:
                state.isPlaying = true
                return .none
            case .playerIsPaused:
                state.isPlaying = false
                return .none
            case let.tracksLoaded(loadedTracks):
                state.isLoading = false
                state.loadedTracks = loadedTracks
                state.currentTrack = loadedTracks.first
                return .send(.trackPlaybackProgress)

            case .error(_):
                print("Tapped")
                return .none
            case let .playbackProgress(progress):
                state.playbackProgress = progress
                return .none
            case let .playbackTime(time):
                state.currentTime = time
                return .none
            }
        }
    }
}

@MainActor
struct ContentView: View {
    let store: StoreOf<BookPlayerFeature>
    @State var player: Double = 0


    var body: some View {
        WithViewStore(store, observe: { $0 }) { store in
            GeometryReader { screen in
                VStack {
                    ZStack {
                        bookImage
                            .opacity(store.isChapterListOpen ? 0 : 1)
                            .offset(x: store.isChapterListOpen ? -screen.size.width : 0)

                        bookScrollView
                            .opacity(store.isChapterListOpen ? 1 : 0)
                            .offset(x: store.isChapterListOpen ? 0 : screen.size.width)
                    }
                    .frame(maxHeight: screen.size.height * 0.5)
                    .animation(.easeInOut, value: store.isChapterListOpen)

                    bookDescription


                    if let track = store.currentTrack  {
                        HStack {
                            timeTitle(formatTime(store.currentTime)).foregroundStyle(Color.hwGraySecondary)
                            PlayerProgressView(value: store.binding(get: \.playbackProgress, send: { .rewind($0) }))
                            timeTitle(formatTime(track.duration)).foregroundStyle(Color.hwGraySecondary)
                        }
                        .padding(.vertical)
                    } else {
                        HStack {
                            Text("--:--")
                            PlayerProgressView(value: .constant(0))
                            Text("--:--")
                        }
                        .padding(.vertical)
                        .redacted(reason: .placeholder)
                    }

                    Button {
                        print("Button tapped!")
                    } label: {
                        Text("Speed x1").fontWeight(.semibold)
                    }
                    .buttonStyle(.bordered)
                    .foregroundStyle(Color.black)

                    Spacer()
                    playerButtons

                    Spacer()

                    PageSwitch(isToggled: store.binding(get: \.isChapterListOpen, send: .chapterListSwitchToggled),
                               leftIcon: Image(systemName: "headphones"),
                               rightIcon: Image(systemName: "text.alignright"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background(Color.hwBackground)
            }
            .onAppear {
                store.send(.onAppear)
            }
        }


    }

    var bookImage: some View  {
        Image("book_1")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))

    }

    var bookScrollView: some View {
        WithViewStore(store, observe: { $0 }) { state in
            List {
                ForEach(state.loadedTracks, id: \.id) { track in
                    HStack {
                        Text(track.title)
                        Spacer()
                        timeTitle(formatTime(track.duration))

                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.hwBackground)
                .listRowSeparatorTint(Color.hwGray)
            }
            .listStyle(.plain)
            .background(Color.green)
        }
    }

    var bookDescription: some View {
        WithViewStore(store, observe: { $0 }) { state in
            if let currentTrack = state.currentTrack {
                VStack {
                    Text("KEY POINT \(currentTrack.id) OF \(state.loadedTracks.count)")
                        .fontWeight(.medium)
                        .foregroundStyle(Color.hwGraySecondary)
                        .padding(4)

                    Text(currentTrack.title)
                        .fontWeight(.light)
                        .multilineTextAlignment(.center)
                }
            } else {
                VStack {
                    Text("KEY POINT 5 OF 25").foregroundStyle(Color.hwGraySecondary).padding(4)
                    Text("Why Robert Koval is the best candidate")
                }
                .redacted(reason: .placeholder)
            }
        }
    }

    func timeTitle(_ time: String) -> some View {
        Text(time).font(.custom("Spot Mono Regular", size: 17, relativeTo: .body))
    }

    var playerButtons: some View {
        WithViewStore(store, observe: { $0 }) { state in
            HStack(spacing: 16) {
                playerButton(with: "backward.end.fill", imageSize: .init(width: 32, height: 32)) {
                    store.send(.playPreviousButtonTapped)
                }

                playerButton(with: "gobackward.5", imageSize: .init(width: 40, height: 40)) {
                    store.send(.goBackward5ButtonTapped)
                }

                playerButton(with: state.isPlaying ? "pause.fill" : "play.fill", imageSize: .init(width: 44, height: 44)) {
                    store.send(.playPauseButtonTapped)
                }


                playerButton(with: "goforward.10", imageSize: .init(width: 40, height: 40)) {
                    store.send(.goForward10ButtonTapped)
                }

                playerButton(with: "forward.end.fill", imageSize: .init(width: 32, height: 32)) {
                    store.send(.playNextButtonTapped)
                }
            }
            .foregroundColor(.black)
        }
    }

    func playerButton(with imageName: String, imageSize: CGSize, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: imageSize.width, height: imageSize.height)
        }
        .frame(width: 44, height: 44)
    }

    func formatTime(_ time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad

        if let formattedString = formatter.string(from: time) {
            return formattedString
        } else {
            return "00:00"
        }
    }
}

#Preview {
    ContentView(store: .init(initialState: BookPlayerFeature.State(), reducer: {
        BookPlayerFeature()
            ._printChanges()
    }))
}
