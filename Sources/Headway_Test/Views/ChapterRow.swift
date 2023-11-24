//
//  TrackRowView.swift
//  Headway_Test
//
//  Created by Robert Koval on 24.11.2023.
//

import SwiftUI

struct ChapterRow: View {
    let track: LoadedChapter
    let isSelected: Bool
    let selectTrack: (Int) -> Void

    var body: some View {
        HStack {
            Text(track.title)
            Spacer()
            Text(track.duration)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .listRowBackground(isSelected ? Color(.systemFill) : Color.hwBackground)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowSeparatorTint(Color.hwGray)
        .onTapGesture {
            selectTrack(track.id)
        }
    }
}
