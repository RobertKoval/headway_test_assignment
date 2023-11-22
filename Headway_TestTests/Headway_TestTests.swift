//
//  Headway_TestTests.swift
//  Headway_TestTests
//
//  Created by Robert Koval on 22.11.2023.
//

import XCTest
@testable import Headway_Test
import ComposableArchitecture

final class Headway_TestTests: XCTestCase {

    func testPlayPauseAction() async {
        let store = TestStore(initialState: BookPlayerFeature.State()) {
            BookPlayerFeature()
        }

        await store.send(.playPauseButtonTapped) {
            $0.playerState.isPlaying = true
        }

//        await store.send(.onAppear)
//        await store.receive(.fetchCounter)
    }

    func testPageSwitchAction() async {
        let store = TestStore(initialState: BookPlayerFeature.State()) {
            BookPlayerFeature()
        }

        await store.send(.chapterListSwitchToggled) {
            $0.isChapterListOpen = true
        }
    }

    func testAudioLoading() async {
        let store = TestStore(initialState: BookPlayerFeature.State()) {
            BookPlayerFeature()
        }

        await store.send(.onAppear)
        await store.receive(.trackLoaded([]))
    }

    func testNextAudio() async {
        let store = TestStore(initialState: BookPlayerFeature.State()) {
            BookPlayerFeature()
        }

        await store.send(.goForwardButtonTapped)
    }

    func testPreviousAudio() async {
        let store = TestStore(initialState: BookPlayerFeature.State()) {
            BookPlayerFeature()
        }

        await store.send(.goBackwardButtonTapped)
    }

}
