//
//  ChapterRepositoryClient.swift
//  Headway_Test
//
//  Created by Robert Koval on 23.11.2023.
//

import SharedModels

public struct ChapterRepositoryClient {
    public var getChaptersFor: @Sendable (Book) async throws -> [Chapter]
}
