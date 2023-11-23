//
//  AudioPlayerClient.swift
//  Headway_Test
//
//  Created by Robert Koval on 21.11.2023.
//

import Foundation

struct AudioTrack: Equatable {
    let id: Int
    let url: URL
}

struct Metadata: Equatable {
    let trackId: Int
    let duration: TimeInterval
}

struct AudioPlayerClient {
    var loadPlaylist: @Sendable ([AudioTrack]) async throws -> [Metadata]
    var play: @Sendable () async -> Void
    var pause: @Sendable () async -> Void
    var playNext: @Sendable () async -> Void
    var playPrevious: @Sendable () async -> Void
    var playbackProgress: @Sendable () async throws -> AsyncStream<Double>
    var playbackTime: @Sendable () async throws -> AsyncStream<Double>
    var setPlaybackSpeed: @Sendable (Float) async -> Void
    var rewind: @Sendable (Double) async throws -> Void
    var rewindSeconds: @Sendable (Double) async throws -> Void
    var currentAudioId: @Sendable () async -> AsyncStream<Int>
}
