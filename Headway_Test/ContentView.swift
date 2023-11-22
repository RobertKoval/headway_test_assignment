//
//  ContentView.swift
//  Headway_Test
//
//  Created by Robert Koval on 20.11.2023.
//

import SwiftUI
import AVKit
import ComposableArchitecture

struct BookPlayerFeature: Reducer {
    enum Action: Equatable {
        case onAppear
        case playbackSpeedButtonTapped
        case playPauseButtonTapped
        case goBackwardButtonTapped
        case goForwardButtonTapped
        case rewindButtonTapped
        case fastForwardButtonTapped
        case selectChapterButtonTapped(Int)
        case chapterListSwitchToggled


        // Side effects
        case playbackFinished
        // (Id, Duration)
        case trackLoaded
        case metadataExtracted([Metadata])
        case error(String)
    }

    enum PlaybackSpeed: Double {
        case slow = 0.5
        case noraml = 1.0
        case fast = 1.5
        case superFast = 2.0
    }

    struct PlayerState: Equatable {
        var isPlaying: Bool = false
        var currentChapter: Int = 1
    }

    struct State: Equatable {
        var book: Book = mockBook
        var isChapterListOpen: Bool = false
        var playerState: PlayerState = .init()
        var playbackProgress: Double = 0
        var playbackSpeed: PlaybackSpeed = .noraml
        var chapterDescription: String = ""
        var chapterNumber: Int = 1
        var numberOfChapters: Int = 10
        var currentTime: TimeInterval = 0
        var totalPlaybackTime: TimeInterval = 360
    }

    @Dependency(\.audioPlayer) var audioPlayer
    @Dependency(\.feedbackGenerator) var feedbackGenerator

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let audioTracks = state.book.chapters.compactMap { chapter -> AudioTrack? in
                    guard let url = Bundle.main.url(forResource: chapter.audioFileName, withExtension: nil) else { return nil }
                    return AudioTrack(id: chapter.id, url: url)
                }

                return .run { send in
                    do {
                       try await audioPlayer.loadPlaylist(audioTracks)
                        await send(.trackLoaded)
                    } catch {
                        await send(.error(error.localizedDescription))
                    }
                }
            case .playbackSpeedButtonTapped:
                print("Tapped")
                return .none
            case .playPauseButtonTapped:
                print("Tapped")
                return .none
            case .goBackwardButtonTapped:
                print("Tapped")
                return .none
            case .goForwardButtonTapped:
                print("Tapped")
                return .none
            case .rewindButtonTapped:
                print("Tapped")
                return .none
            case .fastForwardButtonTapped:
                print("Tapped")
                return .none
            case .selectChapterButtonTapped(_):
                print("Tapped")
                return .none
            case .chapterListSwitchToggled:
                state.isChapterListOpen.toggle()
                return .run { send in
                    await feedbackGenerator.selectionOccured()
                }
            case .playbackFinished:
                print("Tapped")
                return .none
            case .trackLoaded:
                return .run { [state = state] send in
                    let audioTracks = state.book.chapters.compactMap { chapter -> AudioTrack? in
                        guard let url = Bundle.main.url(forResource: chapter.audioFileName, withExtension: nil) else { return nil }
                        return AudioTrack(id: chapter.id, url: url)
                    }
                    let metadata = try await audioPlayer.getDuration(audioTracks)
                    await send(.metadataExtracted(metadata))
                }
            case let .metadataExtracted(metadata):
                for data in metadata {
                    state.book.chapters[data.id - 1].duration = data.duration
                }
                return .none
            case .error(_):
                print("Tapped")
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
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { screen in
                VStack {
                    ZStack {
                        bookImage
                            .opacity(viewStore.isChapterListOpen ? 0 : 1)
                            .offset(x: viewStore.isChapterListOpen ? -screen.size.width : 0)

                        bookScrollView
                            .opacity(viewStore.isChapterListOpen ? 1 : 0)
                            .offset(x: viewStore.isChapterListOpen ? 0 : screen.size.width)
                    }
                    .frame(maxHeight: screen.size.height * 0.5)
                    .animation(.easeInOut, value: viewStore.isChapterListOpen)
                    .background(Color.red)

                    bookDescription

                    HStack {
                        timeTitle(formatTime(viewStore.currentTime)).foregroundStyle(Color.hwGraySecondary)
                        PlayerProgressView(value: $player)
                        timeTitle(formatTime(viewStore.totalPlaybackTime)).foregroundStyle(Color.hwGraySecondary)
                    }
                    .padding(.vertical)

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

                    PageSwitch(isToggled: viewStore.binding(get: \.isChapterListOpen, send: .chapterListSwitchToggled),
                               leftIcon: Image(systemName: "headphones"),
                               rightIcon: Image(systemName: "text.alignright"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background(Color.hwBackground)
            }
            .onAppear {
                viewStore.send(.onAppear)
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
        WithViewStore(store, observe: \.book) { state in
            List {
                ForEach(state.chapters, id: \.id) { chapter in
                    HStack {
                        Text(chapter.title)
                        Spacer()
                        if let duration = chapter.duration {
                            timeTitle(formatTime(duration))
                        } else {
                            Text("--:--")
                        }
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
            VStack {
                Text("KEY POINT \(state.playerState.currentChapter) OF \(state.book.chapters.count)")
                    .fontWeight(.medium)
                    .foregroundStyle(Color.hwGraySecondary)
                    .padding(4)

                Text("\(state.book.chapters[state.playerState.currentChapter - 1].title)")
                    .fontWeight(.light)
                    .multilineTextAlignment(.center)

            }
        }
    }

    func timeTitle(_ time: String) -> some View {
        Text(time).font(.custom("Spot Mono Regular", size: 17, relativeTo: .body))
    }

    var playerButtons: some View {
        WithViewStore(store, observe: \.playerState) { state in
            HStack(spacing: 16) {
                playerButton(with: "backward.end.fill", imageSize: .init(width: 32, height: 32)) {

                }

                playerButton(with: "gobackward.5", imageSize: .init(width: 40, height: 40)) {

                }

                playerButton(with: state.isPlaying ? "pause.fill" : "play.fill", imageSize: .init(width: 44, height: 44)) {

                }


                playerButton(with: "goforward.10", imageSize: .init(width: 40, height: 40)) {

                }

                playerButton(with: "forward.end.fill", imageSize: .init(width: 32, height: 32)) {

                }
            }
            .foregroundColor(.black)
        }
    }

    func playerButton(with imageName: String, imageSize: CGSize, action: @escaping () -> Void) -> some View {
        Button {
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
