//
//  Book.swift
//  Headway_Test
//
//  Created by Robert Koval on 20.11.2023.
//

import Foundation

struct Book: Identifiable, Equatable {
    let id: UUID
    let title: String
    let author: String
    let coverImageName: String
    var chapters: [Chapter]
}

struct Chapter: Identifiable, Equatable {
    let id: Int
    let title: String
    let audioFileName: String
    var duration: TimeInterval? = nil
}
