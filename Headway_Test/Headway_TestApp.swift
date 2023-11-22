//
//  Headway_TestApp.swift
//  Headway_Test
//
//  Created by Robert Koval on 20.11.2023.
//

import SwiftUI
import ComposableArchitecture

@main
struct Headway_TestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: .init(initialState: BookPlayerFeature.State(), reducer: { BookPlayerFeature() }))
        }
    }
}


