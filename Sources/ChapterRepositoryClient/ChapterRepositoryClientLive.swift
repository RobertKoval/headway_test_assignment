//
//  ChapterRepositoryClientLive.swift
//  Headway_Test
//
//  Created by Robert Koval on 23.11.2023.
//

import Foundation
import Dependencies
import SharedModels

extension DependencyValues {
    public var chapterRepository: ChapterRepositoryClient {
        get { self[ChapterRepositoryClient.self] }
        set { self[ChapterRepositoryClient.self] = newValue }
    }
}

extension ChapterRepositoryClient: DependencyKey {
    // Actually MOCK
    public static let liveValue = Self { book in
        let chaptersData = [
            (1, "Avanti - Me Time", "audio_1.mp3"),
            (2, "Aylex - Heaven", "audio_2.mp3"),
            (3, "Burgundy - Tell Me", "audio_3.mp3"),
            (4, "Piki - A New Day", "audio_4.mp3"),
            (5, "walen - In Your Eyes", "audio_5.mp3")
        ]

        return chaptersData.compactMap { id, title, audioFileName in
            guard let url = Bundle.main.url(forResource: audioFileName, withExtension: nil) else {
               return nil
            }

            return Chapter(id: id, title: title, audioFile: url)
        }
    }
}
