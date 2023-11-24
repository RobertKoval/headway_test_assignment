//
//  TrackTimeForamtter.swift
//  Headway_Test
//
//  Created by Robert Koval on 24.11.2023.
//

import Foundation


extension DateComponentsFormatter {
    func formatAudioTime(_ time: TimeInterval) -> String {
        allowedUnits = [.minute, .second]
        unitsStyle = .positional
        zeroFormattingBehavior = .pad

        if let formattedString = string(from: time) {
            return formattedString
        } else {
            return "--:--"
        }
    }
}
