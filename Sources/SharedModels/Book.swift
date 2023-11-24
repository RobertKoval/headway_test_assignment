//
//  Book.swift
//  Headway_Test
//
//  Created by Robert Koval on 20.11.2023.
//

import Foundation

public struct Book: Identifiable, Equatable {
    public let id: UUID
    public let title: String
    public let author: String
    public let coverImageName: String

    public init(id: UUID, title: String, author: String, coverImageName: String) {
        self.id = id
        self.title = title
        self.author = author
        self.coverImageName = coverImageName
    }
}
