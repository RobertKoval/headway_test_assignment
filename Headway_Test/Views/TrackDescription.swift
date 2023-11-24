//
//  TrackDescription.swift
//  Headway_Test
//
//  Created by Robert Koval on 24.11.2023.
//

import SwiftUI

struct TrackDescription: View {
    let chapter: LoadedChapter?
    let numberOfChapters: Int

    var body: some View {
        if let chapter {
            VStack {
                Text("KEY POINT \(chapter.id) OF \(numberOfChapters)")
                    .fontWeight(.medium)
                    .foregroundStyle(Color.hwGraySecondary)
                    .padding(4)

                Text(chapter.title)
                    .fontWeight(.light)
                    .multilineTextAlignment(.center)
            }
        } else {
            placeholderView
        }
    }

    private var placeholderView: some View {
        VStack {
            Text("KEY POINT 5 OF 25").foregroundStyle(Color.hwGraySecondary).padding(4)
            Text("Why Robert Koval is the best candidate")
        }
        .redacted(reason: .placeholder)
    }
}
