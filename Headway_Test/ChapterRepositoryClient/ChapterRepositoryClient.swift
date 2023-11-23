//
//  ChapterRepositoryClient.swift
//  Headway_Test
//
//  Created by Robert Koval on 23.11.2023.
//

import Foundation

struct ChapterRepositoryClient {
    var getChaptersFor: @Sendable (Book) async throws -> [Chapter]
}
