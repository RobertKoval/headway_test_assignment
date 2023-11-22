//
//  FeedbackGeneratorClientLive.swift
//  Headway_Test
//
//  Created by Robert Koval on 22.11.2023.
//

import Foundation
import Dependencies
import UIKit

extension DependencyValues {
    var feedbackGenerator: FeedbackGeneratorClient {
        get { self[FeedbackGeneratorClient.self] }
        set { self[FeedbackGeneratorClient.self] = newValue }
    }
}

extension FeedbackGeneratorClient: DependencyKey {
    static let liveValue = Self {
        await UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    } selectionOccured: {
        await UISelectionFeedbackGenerator().selectionChanged()
    }
}
