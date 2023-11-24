//
//  AudioPlayerClient.swift
//  Headway_Test
//
//  Created by Robert Koval on 21.11.2023.
//

import Foundation

public struct AudioTrack: Equatable {
    public let id: Int
    public let url: URL

    public init(id: Int, url: URL) {
        self.id = id
        self.url = url
    }
}

public struct Metadata: Equatable {
    public let trackId: Int
    public let duration: TimeInterval

    public init(trackId: Int, duration: TimeInterval) {
        self.trackId = trackId
        self.duration = duration
    }
}

public struct AudioPlayerClient {
    public var loadPlaylist: @Sendable ([AudioTrack]) async throws -> [Metadata]
    public var play: @Sendable () async -> Void
    public var pause: @Sendable () async -> Void
    public var playNext: @Sendable () async -> Void
    public var playPrevious: @Sendable () async -> Void
    public var playbackProgress: @Sendable () async throws -> AsyncStream<Double>
    public var playbackTime: @Sendable () async throws -> AsyncStream<Double>
    public var setPlaybackRate: @Sendable (Float) async -> Void
    public var rewind: @Sendable (Double) async throws -> Void
    public var rewindSeconds: @Sendable (Double) async throws -> Void
    public var currentAudioId: @Sendable () async -> AsyncStream<Int>
    public var playWithId: @Sendable (Int) async -> Void
}
