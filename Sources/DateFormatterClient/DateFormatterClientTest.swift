//
//  DateFormatterClientTest.swift
//  Headway_Test
//
//  Created by Robert Koval on 24.11.2023.
//

import Dependencies

extension DateFormatterClient: TestDependencyKey {
    public static var testValue: DateFormatterClient = Self(formatTrackTime: unimplemented("\(Self.self).formatTrackTime"))
}
