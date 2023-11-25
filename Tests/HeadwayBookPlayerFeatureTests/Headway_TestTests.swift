//
//  Headway_TestTests.swift
//  Headway_TestTests
//
//  Created by Robert Koval on 22.11.2023.
//

import XCTest
@testable import HeadwayBookPlayerFeature
import ComposableArchitecture
import SharedModels
import PlayerClient

@MainActor
final class Headway_TestTests: XCTestCase {
    let url = URL(string: "/audio/file.mp3")!
    let book = Book(id: UUID(1), title: "Server-side Swift", author: "Paul Hudson", coverImageName: "")

    func testLoading() async throws {
        let chapters =  [
            Chapter(id: 1, title: "Introduction: Swift for Complete Beginners", audioFile: url),
            Chapter(id: 2, title: "CouchDB Poll", audioFile: url),
        ]

        let loadedChaptes = [
            LoadedChapter(id: 1, title: "Introduction: Swift for Complete Beginners", duration: "02:45"),
            LoadedChapter(id: 2, title: "CouchDB Poll", duration: "01:00"),
        ]

        let metadata = [
            Metadata(trackId: 1, duration: 165),
            Metadata(trackId: 2, duration: 60),
        ]

        let currentIdStream = AsyncStream<Int>.makeStream()
        let playbackProgress = AsyncStream<Double>.makeStream()
        let playbackTime = AsyncStream<Double>.makeStream()

        let store = TestStore(initialState: BookPlayerFeature.State(book: book)) {
            BookPlayerFeature()
        } withDependencies: {
            $0.chapterRepository.getChaptersFor = { _ in chapters }
            $0.audioPlayer.loadPlaylist = { _ in metadata }
            $0.audioPlayer.playbackProgress = { playbackProgress.stream }
            $0.audioPlayer.playbackTime = { playbackTime.stream }
            $0.audioPlayer.currentAudioId = { currentIdStream.stream }
            $0.audioPlayer.playNext = { currentIdStream.continuation.yield(2) }
            $0.dateFormatter.formatTrackTime = {
                if $0 == 0 {
                    "00:00"
                } else if $0 == 60 {
                    "01:00"
                } else {
                    "02:45"
                }
            }
            $0.feedbackGenerator.impactOccurred = {}
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }

        await store.receive(.tracksLoaded(loadedChaptes)) {
            $0.isLoading = false
            $0.loadedChapters = loadedChaptes
            $0.currentChapter = loadedChaptes.first
        }

        playbackTime.continuation.yield(0)

        await store.receive(.playbackTime(0))
        await store.receive(.formattedPlaybackTime("00:00")) {
            $0.currentTime = "00:00"
        }

        await store.send(.playNextButtonTapped)

        await store.receive(.trackDidChange(2)) {
            $0.currentChapter = loadedChaptes.last
        }

        await store.send(.onDisappear)
    }
}
