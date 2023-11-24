//
//  AudioPlayerClientTest.swift
//  Headway_Test
//
//  Created by Robert Koval on 24.11.2023.
//

import Dependencies

extension AudioPlayerClient: TestDependencyKey {
    public static var testValue: AudioPlayerClient =  Self(
        loadPlaylist: unimplemented("\(Self.self).loadPlaylist"),
        play: unimplemented("\(Self.self).play"),
        pause: unimplemented("\(Self.self).pause"),
        playNext: unimplemented("\(Self.self).playNext"),
        playPrevious: unimplemented("\(Self.self).playPrevious"),
        playbackProgress: unimplemented("\(Self.self).playbackProgress"),
        playbackTime: unimplemented("\(Self.self).playbackTime"),
        setPlaybackRate: unimplemented("\(Self.self).setPlaybackRate"),
        rewind: unimplemented("\(Self.self).rewind"),
        rewindSeconds: unimplemented("\(Self.self).rewindSeconds"),
        currentAudioId: unimplemented("\(Self.self).currentAudioId"),
        playWithId: unimplemented("\(Self.self).playWithId")
    )
}
