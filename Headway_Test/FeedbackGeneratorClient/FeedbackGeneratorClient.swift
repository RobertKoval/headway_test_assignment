//
//  FeedbackGeneratorClient.swift
//  Headway_Test
//
//  Created by Robert Koval on 22.11.2023.
//

import Foundation

struct FeedbackGeneratorClient {
    var impactOccurred: @Sendable () async -> Void
    var selectionOccured: @Sendable () async -> Void
}
