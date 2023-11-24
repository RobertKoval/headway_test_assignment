//
//  BookCover.swift
//  Headway_Test
//
//  Created by Robert Koval on 24.11.2023.
//

import SwiftUI

struct BookCover: View {
    let imageName: String

    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
    }
}
