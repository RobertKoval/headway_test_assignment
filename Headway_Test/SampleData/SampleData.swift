//
//  SampleData.swift
//  Headway_Test
//
//  Created by Robert Koval on 21.11.2023.
//

import Foundation

let mockBook = Book(
    id: UUID(),
    title: "Why Robert Koval is the best candidate for this position",
    author: "Paul C. Green",
    coverImageName: "book_1",
    chapters: [
        Chapter(id: 1, title: "Avanti - Me Time", audioFileName: "audio_1.mp3"),
        Chapter(id: 2, title: "Aylex - Heaven", audioFileName: "audio_2.mp3"),
        Chapter(id: 3, title: "Burgundy - Tell Me", audioFileName: "audio_3.mp3"),
        Chapter(id: 4, title: "Piki - A New Day", audioFileName: "audio_4.mp3"),
        Chapter(id: 5, title: "walen - In Your Eyes", audioFileName: "audio_5.mp3")
    ]
)
