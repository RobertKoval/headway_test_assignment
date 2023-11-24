//
//  FeedbackGeneratorClient.swift
//  Headway_Test
//
//  Created by Robert Koval on 22.11.2023.
//

import Foundation

public struct FeedbackGeneratorClient {
    public var impactOccurred: @Sendable () async -> Void
    public var selectionOccured: @Sendable () async -> Void
}
