//
//  MathHelper.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 27.03.25.
//

import SwiftUI

struct GeometryHelper {
    static func calculateDistance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        return hypot(point2.x - point1.x, point2.y - point1.y)
    }
    
    static func calculateDotProduct(vector1: CGPoint, vector2: CGPoint) -> CGFloat {
        return vector1.x * vector2.x + vector1.y * vector2.y
    }
    
    static func calculateMagnitude(of vector: CGPoint) -> CGFloat {
        return hypot(vector.x, vector.y)
    }
    
    static func normalizeVector(vector: CGPoint) -> CGPoint {
        let mag = calculateMagnitude(of: vector)
        return CGPoint(x: vector.x / mag, y: vector.y / mag)
    }
    
    static func calculateAngleBetween(vector1: CGPoint, vector2: CGPoint) -> CGFloat {
        let dot = calculateDotProduct(vector1: vector1, vector2: vector2)
        let mag = calculateMagnitude(of: vector1) * calculateMagnitude(of: vector2)
        return acos(min(max(dot / mag, -1), 1)) * 180 / .pi
    }
    
    static func calculatePerpendicularVector(to vector: CGPoint) -> CGPoint {
        return CGPoint(x: -vector.y, y: vector.x)
    }
    
    static func checkPointProximity(_ point1: CGPoint, to point2: CGPoint, threshold: CGFloat) -> Bool {
        return calculateDistance(from: point1, to: point2) < threshold
    }
}


