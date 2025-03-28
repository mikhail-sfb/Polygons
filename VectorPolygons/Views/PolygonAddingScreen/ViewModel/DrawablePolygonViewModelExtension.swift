//
//  DrawablePolygonViewModelExtension.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 27.03.25.
//

import SwiftUI

extension DrawablePolygonViewModel {
    
    func calculateMoveDelta(location: CGPoint, vector: PolygonVector) -> CGPoint {
        let midpoint = CGPoint(
            x: (vector.startPoint.x + vector.endPoint.x) / 2,
            y: (vector.startPoint.y + vector.endPoint.y) / 2
        )
        return CGPoint(x: location.x - midpoint.x, y: location.y - midpoint.y)
    }

    func clampLocation(_ location: CGPoint, to size: CGSize) -> CGPoint {
        CGPoint(
            x: min(max(location.x, 0), size.width),
            y: min(max(location.y, 0), size.height)
        )
    }

    func scalePoint(_ point: CGPoint, from size: CGSize) -> CGPoint {
        CGPoint(
            x: point.x * polygonSize.width / size.width,
            y: point.y * polygonSize.height / size.height
        )
    }

    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        sqrt(pow((a.x - b.x), 2) + pow((a.y - b.y), 2))
    }

    func calculateAngle(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        abs(atan2(point2.y - point1.y, point2.x - point1.x) * 180 / .pi)
    }

    func snapToRightAngle(point: CGPoint, from anchor: CGPoint) -> CGPoint {
        let dx = point.x - anchor.x
        let dy = point.y - anchor.y
        let distanceMagnitude = sqrt(dx * dx + dy * dy)
        
        guard distanceMagnitude > 0 else { return anchor }
        
        let normalizedDirection = CGPoint(x: dx / distanceMagnitude, y: dy / distanceMagnitude)
        
        return CGPoint(
            x: anchor.x + normalizedDirection.y * distanceMagnitude,
            y: anchor.y - normalizedDirection.x * distanceMagnitude
        )
    }

    func setSelectedVector(id: UUID, dragType: VectorDragType) {
        selectedVectorId = id
        self.dragType = dragType
       
    }
    
    
    private func distanceToVector(_ point: CGPoint, _ vector: PolygonVector) -> CGFloat {
           let v1 = vector.endPoint.x - vector.startPoint.x
           let v2 = vector.endPoint.y - vector.startPoint.y
           let w1 = point.x - vector.startPoint.x
           let w2 = point.y - vector.startPoint.y
           let c1 = w1 * v1 + w2 * v2
           let c2 = v1 * v1 + v2 * v2

           if c1 <= 0 {
               return sqrt(w1 * w1 + w2 * w2)
           }
           if c2 <= c1 {
               return sqrt(pow((point.x - vector.endPoint.x), 2) + pow((point.y - vector.endPoint.y), 2))
           }

           let b = c1 / c2
           let pb = CGPoint(
               x: vector.startPoint.x + b * v1,
               y: vector.startPoint.y + b * v2
           )
           return sqrt(pow((point.x - pb.x), 2) + pow((point.y - pb.y), 2))
       }
       
       
    func findClosestVector(to point: CGPoint) -> PolygonVector? {
           vectors.min(by: {
               distanceToVector(point, $0) < distanceToVector(point, $1)
           })
       }

    func applySnaps(
        point: CGPoint, anchor: CGPoint, otherVectors: [PolygonVector]
    ) -> CGPoint {
        var newPoint = point

        if activeSnapModes.contains(.verticalHorizontal) {
            if abs(newPoint.y - anchor.y) < DrawingConstants.snapDistance {
                newPoint.y = anchor.y
            }
            if abs(newPoint.x - anchor.x) < DrawingConstants.snapDistance {
                newPoint.x = anchor.x
            }
        }

        if activeSnapModes.contains(.endpoints) {
            for otherVector in otherVectors {
                if distance(newPoint, otherVector.startPoint)
                    < DrawingConstants.snapDistance
                {
                    return otherVector.startPoint
                }
                if distance(newPoint, otherVector.endPoint)
                    < DrawingConstants.snapDistance
                {
                    return otherVector.endPoint
                }
            }
        }

        if activeSnapModes.contains(.rightAngle) {
            let angle = calculateAngle(from: anchor, to: newPoint)
            if (abs(angle - 90)).isLess(than: 5) {
                return snapToRightAngle(point: newPoint, from: anchor)
            }
        }

        return newPoint
    }
}
