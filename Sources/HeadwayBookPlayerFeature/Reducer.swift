//
//  File.swift
//
//
//  Created by Robert Koval on 24.11.2023.
//

import ComposableArchitecture
import SharedModels
import PlayerClient
import DateFormatterClient
import ChapterRepositoryClient
import FeedbackGeneratorClient


public struct BookPlayerFeature: Reducer {
    public enum Action: Equatable {
        case onAppear
        case onDisappear
        case playButtonTapped
        case pauseButtonTapped
        case goBackward5ButtonTapped
        case goForward10ButtonTapped
        case playPreviousButtonTapped
        case playNextButtonTapped
        case selectChapterButtonTapped(Int)
        case chapterListSwitchToggled
        case rewind(Double)
        case playbackRateButtonTapped
        case alertConfirmButtonTapped


        // Side effects
        case playerIsPlaying
        case playerIsPaused
        case trackDidChange(Int)
        case playbackProgress(Double)
        case playbackTime(Double)
        case formattedPlaybackTime(String)
        case tracksLoaded([LoadedChapter])
        case error(String)
    }

    public enum PlaybackSpeed: Float {
        case slow = 0.5
        case normal = 1.0
        case fast = 1.5
        case superFast = 2.0

        var next: PlaybackSpeed {
            switch self {
            case .slow:
                return .normal
            case .normal:
                return .fast
            case .fast:
                return .superFast
            case .superFast:
                return .slow
            }
        }

        var description: String {
            switch self {
            case .slow:
                return "x0.5"
            case .normal:
                return "x1.0"
            case .fast:
                return "x1.5"
            case .superFast:
                return "x2.0"
            }
        }
    }

    public struct State: Equatable {
        public var book: Book
        public var isLoading = false
        public var loadedChapters: [LoadedChapter] = []
        public var currentChapter: LoadedChapter?
        public var isPlaying = false
        public var playbackProgress: Double = 0
        public var isChapterListOpen: Bool = false
        public var playbackSpeed: PlaybackSpeed = .normal
        public var currentTime: String = "--:--"
        public var numberOfChapters: Int {
            loadedChapters.count
        }
         @PresentationState public var alert: AlertState<Action>?

        public init(book: Book) {
            self.book = book
        }
    }

    @Dependency(\.audioPlayer) var audioPlayer
    @Dependency(\.feedbackGenerator) var feedbackGenerator
    @Dependency(\.chapterRepository) var chapterRepository
    @Dependency(\.dateFormatter) var dateFormatter

    private enum CancelID {
        case playbackProgress
        case trackID
        case playbackTime
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        // TODO: Split reducer
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true

                return .run { [book = state.book] send in
                    do {
                        let chapters = try await chapterRepository.getChaptersFor(book)
                        let tracks = chapters.map({ AudioTrack(id: $0.id, url: $0.audioFile) })
                        let metadata = try await audioPlayer.loadPlaylist(tracks)

                        let loadedChapters = chapters.filter({ chapter in metadata.contains(where: { $0.trackId == chapter.id }) })

                        let loadedTracks = zip(loadedChapters, metadata).map { chapter, metadata in
                            LoadedChapter(id: chapter.id, title: chapter.title, duration: dateFormatter.formatTrackTime(metadata.duration))
                        }

                        await send(.tracksLoaded(loadedTracks))
                    } catch {
                        await send(.error(error.localizedDescription))
                    }
                }

            case .onDisappear:
                return .merge(.cancel(id: CancelID.trackID), .cancel(id: CancelID.playbackTime), .cancel(id: CancelID.playbackProgress))

            case .playButtonTapped:
                return .run { send in
                    await audioPlayer.play()
                    await feedbackGenerator.impactOccurred()
                    await send(.playerIsPlaying)
                }

            case .pauseButtonTapped:
                return .run { send in
                    await audioPlayer.pause()
                    await feedbackGenerator.impactOccurred()
                    await send(.playerIsPaused)
                }

            case .goBackward5ButtonTapped:
                return .run { send in
                    try await audioPlayer.rewindSeconds(-5)
                    await feedbackGenerator.impactOccurred()
                }

            case .goForward10ButtonTapped:
                return .run { send in
                    try await audioPlayer.rewindSeconds(10)
                    await feedbackGenerator.impactOccurred()
                }

            case .playPreviousButtonTapped:
                return .run { send in
                    await audioPlayer.playPrevious()
                    await feedbackGenerator.impactOccurred()
                }

            case .playNextButtonTapped:
                return .run { send in
                    await audioPlayer.playNext()
                    await feedbackGenerator.impactOccurred()
                }

            case let .selectChapterButtonTapped(id):
                return .run { _ in
                    await audioPlayer.playWithId(id)
                    await feedbackGenerator.impactOccurred()
                }

            case .playbackRateButtonTapped:
                let newSpeed = state.playbackSpeed.next
                state.playbackSpeed = newSpeed
                return .run { send in
                    await audioPlayer.setPlaybackRate(newSpeed.rawValue)
                }

            case let .rewind(value):
                return .run { send in
                    do {
                        try await audioPlayer.rewind(value)
                    } catch {
                        await send(.error(error.localizedDescription))
                    }
                }

            case .chapterListSwitchToggled:
                state.isChapterListOpen.toggle()
                return .run { send in
                    await feedbackGenerator.selectionOccured()
                }
            case let .trackDidChange(id):
                state.currentChapter = state.loadedChapters.first(where: { $0.id == id })
                return .none

            case .playerIsPlaying:
                state.isPlaying = true
                return .none

            case .playerIsPaused:
                state.isPlaying = false
                return .none

            case let.tracksLoaded(loadedTracks):
                state.isLoading = false
                state.loadedChapters = loadedTracks
                state.currentChapter = loadedTracks.first
                return .merge(
                    .run { send in
                        do {
                            for await progress in try await audioPlayer.playbackProgress() {
                                await send(.playbackProgress(progress))
                            }
                        } catch {
                            await send(.error(error.localizedDescription))
                        }
                    }
                        .cancellable(id: CancelID.playbackProgress),

                        .run(operation: { send in
                            for await currentId in await audioPlayer.currentAudioId() {
                                await send(.trackDidChange(currentId))
                            }
                        })
                        .cancellable(id: CancelID.trackID),
                    .run(operation: { send in
                        do {
                            for await time in try await audioPlayer.playbackTime() {
                                await send(.playbackTime(time))
                            }
                        } catch {
                            await send(.error(error.localizedDescription))
                        }
                    })
                    .cancellable(id: CancelID.playbackTime)

                )

            case let .error(error):
                state.alert = AlertState(title: TextState("Error!"), message: TextState(error), buttons: [
                    .default(TextState("Ok"), action: .send(Action.alertConfirmButtonTapped))
                ])
                return .none

            case .alertConfirmButtonTapped:
                state.alert = nil
                return .none

            case let .playbackProgress(progress):
                state.playbackProgress = progress
                return .none

            case let .formattedPlaybackTime(time):
                state.currentTime = time
                return .none

            case let .playbackTime(time):
                return .run { send in
                    await send(.formattedPlaybackTime(dateFormatter.formatTrackTime(time)))
                }
            }
        }
    }
}
