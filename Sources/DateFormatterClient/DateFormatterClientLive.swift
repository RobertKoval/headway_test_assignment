//
//  DateFormatterClientLive.swift
//  Headway_Test
//
//  Created by Robert Koval on 24.11.2023.
//

import Dependencies
import Foundation

public extension DependencyValues {
    var dateFormatter: DateFormatterClient {
        get { self[DateFormatterClient.self] }
        set { self[DateFormatterClient.self] = newValue }
    }
}

extension DateFormatterClient: DependencyKey {
    public static let liveValue: DateFormatterClient = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        return Self { time in
            if let formattedString = formatter.string(from: time) {
                return formattedString
            } else {
                return "--:--"
            }
        }
    }()
}
