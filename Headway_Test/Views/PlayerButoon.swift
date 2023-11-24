//
//  PlayerButoon.swift
//  Headway_Test
//
//  Created by Robert Koval on 24.11.2023.
//

import SwiftUI

struct PlayerButton: View {
    let imageName: String
    let imageSize: CGSize
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: imageSize.width, height: imageSize.height)
        }
        .frame(width: 44, height: 44)
    }
}
