//
//  FeedbackGeneratorClientTest.swift
//  Headway_Test
//
//  Created by Robert Koval on 24.11.2023.
//

import Dependencies

extension FeedbackGeneratorClient: TestDependencyKey {
    public static let testValue = Self(
        impactOccurred: unimplemented("\(Self.self).impactOccurred"), 
        selectionOccured: unimplemented("\(Self.self).selectionOccured")
    )
}
