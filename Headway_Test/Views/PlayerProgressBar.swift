//
//  PlayerProgressView.swift
//  Headway_Test
//
//  Created by Robert Koval on 20.11.2023.
//

import SwiftUI

struct PlayerProgressBar: View {
    @Binding var value: Double
    @State private var isDragging: Bool = false
    
    
    let bounds: ClosedRange<Double>
    let trackHeight: CGFloat = 4
    let thumbSize: CGFloat = 20
    var thumbCenter: CGFloat { thumbSize / 2 }
    let thumbScaleRatio: CGFloat = 1.2
    
    init(value: Binding<Double>, in bounds: ClosedRange<Double> = 0...1) {
        self._value = value
        self.bounds = bounds
    }
    
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack(alignment: .leading, content:  {
                Capsule()
                    .fill(Color.hwGray)
                    .frame(height: trackHeight)
                    .padding([.leading, .trailing], thumbCenter)

                
                Capsule()
                    .fill(Color.hwSlider)
                    .frame(width: CGFloat(value / bounds.upperBound) * (geometry.size.width - thumbSize), height: trackHeight)
                    .padding([.leading, .trailing], thumbCenter)

                
                Circle().fill(Color.hwSlider)
                    .frame(width: thumbSize, height: thumbSize)
                    .scaleEffect(isDragging ? thumbScaleRatio : 1)
                    .offset(x: CGFloat(value / bounds.upperBound) * (geometry.size.width - thumbSize))
                    .gesture(DragGesture()
                        .onChanged({ value in
                            isDragging = true
                            withAnimation(.linear) {
                                self.value = min(bounds.upperBound, max(0, value.location.x / geometry.size.width * bounds.upperBound))
                            }
                        })
                            .onEnded({ _ in
                                isDragging = false
                            })
                    )

                    .animation(.easeInOut, value: isDragging)
            })
            .frame(width: geometry.size.width)
        })
        .frame(height: thumbSize)
    }
}


#Preview {
    PlayerProgressBar(value: .constant(5), in: 0...10)
        .padding()
}
