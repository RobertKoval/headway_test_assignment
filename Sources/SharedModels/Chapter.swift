//
//  Chapter.swift
//  Headway_Test
//
//  Created by Robert Koval on 24.11.2023.
//

import Foundation

public struct Chapter: Identifiable, Equatable {
    public let id: Int
    public let title: String
    public let audioFile: URL

    public init(id: Int, title: String, audioFile: URL) {
        self.id = id
        self.title = title
        self.audioFile = audioFile
    }
}
