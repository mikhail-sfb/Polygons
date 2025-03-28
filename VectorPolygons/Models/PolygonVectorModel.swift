//
//  P.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 25.03.25.
//

import SwiftData
import SwiftUI

@Model
final class PolygonVectorModel {
    @Attribute(.unique) var id: UUID
    var colorHex: String
    var startX: Double
    var startY: Double
    var endX: Double
    var endY: Double
    
    init(id: UUID, colorHex: String, startX: Double, startY: Double, endX: Double, endY: Double) {
        self.id = id
        self.colorHex = colorHex
        self.startX = startX
        self.startY = startY
        self.endX = endX
        self.endY = endY
    }
    
    func toDomain() -> PolygonVector {
        PolygonVector(
            color: Color(hex: colorHex),
            startPoint: CGPoint(x: startX, y: startY),
            endPoint: CGPoint(x: endX, y: endY)
        )
    }
}
