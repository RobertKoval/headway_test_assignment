//
//  PageSwitch.swift
//  Headway_Test
//
//  Created by Robert Koval on 21.11.2023.
//

import SwiftUI

struct PageSwitch: View {
    @Binding var isToggled: Bool
    
    let leftIcon: Image
    let rightIcon: Image

    let shadowRadius = 3.0
    let circleRadius = 42.0
    let viewSize = CGSize(width: 88, height: 44)
    let iconSize = CGSize(width: 20, height: 20)

    var paddingSize: Double {
        ((viewSize.width / 2.0) - iconSize.width) / 2.0
    }
    var toggleOffset: Double {
        viewSize.width / 4.0
    }

    var body: some View {
        ZStack {
            Capsule()
                .fill(Color.white)
                .frame(width: viewSize.width, height: viewSize.height)
                .shadow(radius: shadowRadius)

            Circle()
                .fill(Color.blue)
                .frame(width: circleRadius, height: circleRadius)
                .offset(x: isToggled ? toggleOffset : -toggleOffset)

            HStack {
                switchIcon(leftIcon, color: isToggled ? .black : .white)
                Spacer()
                switchIcon(rightIcon, color: isToggled ? .white : .black)
            }
            .padding(.horizontal, paddingSize)
            .frame(width: viewSize.width, height: viewSize.height)
        }
        // TODO: Add swipe gesture
        .onTapGesture {
            toggleSwitch()
        }
    }

    private func switchIcon(_ icon: Image, color: Color) -> some View {
        icon
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: iconSize.width, height: iconSize.height)
            .foregroundColor(color)
    }

    private func toggleSwitch() {
        withAnimation(.easeInOut) {
            isToggled.toggle()
        }
    }

}

#Preview {
    struct Container: View {
        @State var isToggled = false
        var body: some View {
            PageSwitch(isToggled: $isToggled, 
                       leftIcon: Image(systemName: "headphones"),
                       rightIcon: Image(systemName: "text.alignright"))
        }
    }
    return Container()
}
