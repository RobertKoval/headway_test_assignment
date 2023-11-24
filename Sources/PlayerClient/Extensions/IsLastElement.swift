//
//  IsLastElement.swift
//  Headway_Test
//
//  Created by Robert Koval on 23.11.2023.
//

import Foundation

extension Array where Element: Equatable {
    func isLastElement(_ element: Element) -> Bool {
        return last == element
    }
}
