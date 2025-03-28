//
//  CGPointExtension.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 25.03.25.
//

import SwiftUI

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
    
    func applying(_ delta: CGPoint) -> CGPoint {
        CGPoint(x: x + delta.x, y: y + delta.y)
    }
}

