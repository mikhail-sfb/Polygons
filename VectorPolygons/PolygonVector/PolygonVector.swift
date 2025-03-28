//
//  2DPolygonModel.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 18.03.25.
//

import Foundation
import SwiftUI

struct PolygonVector: Identifiable, Equatable, Hashable {
    let id = UUID()
    let color: Color
    var startPoint: CGPoint
    var endPoint: CGPoint

    var angle: CGFloat {
        let radians = atan2(
            endPoint.y - startPoint.y, endPoint.x - startPoint.x)
        return abs(radians * 180 / .pi)
    }

    var length: CGFloat {
        sqrt(
            pow(endPoint.x - startPoint.x, 2)
                + pow(endPoint.y - startPoint.y, 2))
    }
}
