//
//  AudioPlayerClientLive.swift
//  Headway_Test
//
//  Created by Robert Koval on 21.11.2023.
//

import Dependencies
import AVFoundation

extension DependencyValues {
    var audioPlayer: AudioPlayerClient {
        get { self[AudioPlayerClient.self] }
        set { self[AudioPlayerClient.self] = newValue }
    }
}

enum AudioMetadataClientError: Error {
    case fileNotFound(String)
}

extension AudioPlayerClient: DependencyKey {
    static let liveValue: AudioPlayerClient = {
        let player = AudioPlayer()

        return AudioPlayerClient(
            loadPlaylist: { try await player.load(tracks: $0) },
            getDuration: { await player.extractMetadata(from: $0) },
            play: {},
            pause: {},
            playNext: {},
            playPrevious: {}, 
            setPlaybackSpeed: { _ in },
            rewind: { _ in  },
            fastForward: { _ in })
    }()
}

fileprivate actor AudioPlayer {
    let player = AVQueuePlayer()

    func load(tracks: [AudioTrack]) async throws {
        let items = tracks.map { AVPlayerItem(url: $0.url) }
        // TODO: Handle not playable items

        items.forEach { player.insert($0, after: nil) }
    }

    func extractMetadata(from tracks: [AudioTrack]) -> [Metadata] {
        return tracks.map { track in
            let asset = AVAsset(url: track.url)
            let duration = CMTimeGetSeconds(asset.duration)
            return Metadata(id: track.id, duration: duration)
        }
    }
}


