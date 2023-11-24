//
//  Headway_TestApp.swift
//  Headway_Test
//
//  Created by Robert Koval on 20.11.2023.
//

import SwiftUI
import HeadwayBookPlayerFeature
import SharedModels

public let mockBook = Book(
    id: UUID(),
    title: "Why Robert Koval is the best candidate for this position",
    author: "Paul C. Green",
    coverImageName: "book_1"
)


@main
struct Headway_TestApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(store: .init(initialState: BookPlayerFeature.State(book: mockBook), reducer: { BookPlayerFeature() }))
        }
    }
}


