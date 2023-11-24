//
//  ChapterRepositoryClientTest.swift
//  Headway_Test
//
//  Created by Robert Koval on 24.11.2023.
//

import Dependencies

extension ChapterRepositoryClient: TestDependencyKey {
    public static var testValue: ChapterRepositoryClient = Self(getChaptersFor: unimplemented("\(Self.self).getChaptersFor"))
}
