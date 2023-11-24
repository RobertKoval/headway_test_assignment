//
//  AudioPlayerClientLive.swift
//  Headway_Test
//
//  Created by Robert Koval on 21.11.2023.
//

import Dependencies
import AVFoundation
import OrderedCollections

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
            play: { await player.play() },
            pause: { await player.pause() },
            playNext: { await player.playNextTrack() },
            playPrevious: { await player.playPreviousTrack() },
            playbackProgress: { try await player.normalizedPlaybackTime() },
            playbackTime: { try await player.playbackTime() },
            setPlaybackRate: { await player.setRate($0) },
            rewind: {  try await player.rewind($0) },
            rewindSeconds: { try await player.rewind(seconds: $0) },
            currentAudioId: { await player.currentAudioIdStream },
            playWithId: { await player.playWithId($0) }
        )
    }()
}
struct PlaylistItem: Equatable {
    let id: Int
    let item: AVPlayerItem
    let duration: Double
}

fileprivate actor AudioPlayer: Sendable {
    private let player = AVQueuePlayer()
    private let (stream, continuateion) = AsyncStream<Int>.makeStream()
    private var playlist: [PlaylistItem] = []
    private var itemDidFinishObserver: Any?
    private var currentItem: PlaylistItem? = nil {
        didSet {
            if let currentItem {
                continuateion.yield(currentItem.id)

            }
        }
    }

    var currentAudioIdStream: AsyncStream<Int> {
        stream
    }


    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category. Error: \(error)")
        }


        Task {
            await createObserver()
        }
    }

    deinit {
        Task {
           await removeObserver()
        }
    }

    func createObserver() {
        itemDidFinishObserver = NotificationCenter.default.addObserver(
            forName: AVPlayerItem.didPlayToEndTimeNotification,
            object: nil,
            queue: .main
        ) { [weak self] object in
            guard let item = object.object as? AVPlayerItem else { return }
            self?.setNextCurrentItem(currentItem: item)
        }
    }

    func removeObserver() {
        if let itemDidFinishObserver {
            NotificationCenter.default.removeObserver(itemDidFinishObserver)
        }
    }

    private func setNextCurrentItem(currentItem: AVPlayerItem) {
        if let currentIndex = playlist.firstIndex(where: { $0.item == currentItem }) {
            let nextIndex = currentIndex + 1
            if nextIndex < playlist.count {
                self.currentItem = playlist[nextIndex]
            } else {
                // End of playlist
            }
        }
    }

    func resetPlaylist() {
        player.removeAllItems()
        playlist.forEach { item in
            item.item.seek(to: .zero, completionHandler: nil)
        }
        playlist.forEach { item in
            player.insert(item.item, after: nil)
        }
        self.currentItem = playlist.first
    }

    func load(tracks: [AudioTrack]) async throws -> [Metadata] {
        var metadata: [Metadata] = []
        var playlist: [PlaylistItem] = []

        for track in tracks {
            let item = AVPlayerItem(url: track.url)
            let isPlayable = try await item.asset.load(.isPlayable)
            if isPlayable {
                let duration = try await item.asset.load(.duration)
                metadata.append(Metadata(trackId: track.id, duration: CMTimeGetSeconds(duration)))
                playlist.append(PlaylistItem(id: track.id, item: item, duration: duration.seconds))
                player.insert(item, after: nil)
            }
        }

        self.playlist = playlist
        self.currentItem = playlist.first

        return metadata
    }

    func play() async {
        await player.play()
    }

    func playWithId(_ id: Int) {
        if let index = playlist.firstIndex(where: { $0.id == id }) {
            player.removeAllItems()
            playlist.forEach { item in
                item.item.seek(to: .zero, completionHandler: nil)
            }
            let newlist = playlist.suffix(from: index)

            newlist.forEach { item in
                player.insert(item.item, after: nil)
            }
            self.currentItem = newlist.first
        }
    }

    func pause() async {
        await player.pause()
    }

    func playNextTrack() {
        if let currentItem {
            if playlist.isLastElement(currentItem) { resetPlaylist(); return }
            setNextCurrentItem(currentItem: currentItem.item)
            player.advanceToNextItem()
        }
    }

    func playPreviousTrack() {
        if let currentItem, let currentIndex = playlist.firstIndex(where: { $0.item == currentItem.item }) {
            player.removeAllItems()
            playlist.forEach { item in
                item.item.seek(to: .zero, completionHandler: nil)
            }
            let newlist = playlist.suffix(from: currentIndex == 0 ? 0 : currentIndex - 1)

            newlist.forEach { item in
                player.insert(item.item, after: nil)
            }
            self.currentItem = newlist.first
        }
    }

    func setRate(_ rate: Float) async {
        await MainActor.run {
            player.rate = rate
        }
    }

    func rewind(_ value: Double) async throws {
        guard let item = player.currentItem else {
            throw AudioMetadataClientError.fileNotFound("Current item is not available.")
        }
        let duration = try await item.asset.load(.duration)
        let seconds = duration.seconds * value
        let time = CMTime(seconds: seconds)

        await item.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func rewind(seconds: Double) async throws {
        guard let item = player.currentItem else {
            throw AudioMetadataClientError.fileNotFound("Current item is not available.")
        }

        let newTime = item.currentTime() + CMTime(seconds: seconds)


        await item.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }


    struct ObserverContainer: @unchecked Sendable {
        let observer: Any
    }

    func getCurrentDuration() async throws -> CMTime {
        guard let duration = try await player.currentItem?.asset.load(.duration) else {
            throw AudioMetadataClientError.fileNotFound("Current item is not available.")
        }
        return duration
    }

    func normalizedPlaybackTime() async throws -> AsyncStream<Double> {
        let (stream, continuation) = AsyncStream.makeStream(of: Double.self)


        let observer = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { time in
            Task { @Sendable [weak self] in
                guard let duration = try await self?.getCurrentDuration() else { return }
                continuation.yield(CMTimeGetSeconds(time) / CMTimeGetSeconds(duration))
            }
        }

        let container = ObserverContainer(observer: observer)

        continuation.onTermination = { @Sendable _ in
            Task {
                await self.removeObserver(container)
            }
        }
        return stream
    }

    func playbackTime() async throws -> AsyncStream<Double> {
        let (stream, continuation) = AsyncStream.makeStream(of: TimeInterval.self)

        let observer = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { time in
            continuation.yield(time.seconds)
        }

        let container = ObserverContainer(observer: observer)

        continuation.onTermination = { @Sendable _ in
            Task {
                await self.removeObserver(container)
            }
        }
        return stream
    }

    func removeObserver(_ container: ObserverContainer) {
        self.player.removeTimeObserver(container.observer)
    }
}

extension CMTime {
    init(seconds: Double) {
        self = CMTime(value: CMTimeValue(seconds), timescale: 1)
    }

    var seconds: Double {
        CMTimeGetSeconds(self)
    }
}
