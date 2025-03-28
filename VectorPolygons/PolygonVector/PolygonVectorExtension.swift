//
//  2DPolygon.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 25.03.25.
//

import SwiftUI

extension PolygonVector {
    func distanceFrom(_ point: CGPoint) -> CGFloat {
        let startDistance = startPoint.distance(to: point)
        let endDistance = endPoint.distance(to: point)
        let midPoint = CGPoint(
            x: (startPoint.x + endPoint.x) / 2,
            y: (startPoint.y + endPoint.y) / 2
        )
        return min(startDistance, endDistance, midPoint.distance(to: point))
    }

    func dragType(for point: CGPoint) -> VectorDragType {
        let startDist = startPoint.distance(to: point)
        let endDist = endPoint.distance(to: point)
        return startDist < endDist ? .startPoint : .endPoint
    }

    func closestPoint(to point: CGPoint) -> CGPoint {
        let vector = CGPoint(
            x: endPoint.x - startPoint.x, y: endPoint.y - startPoint.y)
        let pointVector = CGPoint(
            x: point.x - startPoint.x, y: point.y - startPoint.y)

        let t = max(
            0,
            min(
                1,
                (pointVector.x * vector.x + pointVector.y * vector.y)
                    / (vector.x * vector.x + vector.y * vector.y)))

        return CGPoint(
            x: startPoint.x + vector.x * t,
            y: startPoint.y + vector.y * t)
    }

    func contains(point: CGPoint, threshold: CGFloat = 10) -> Bool {
        let lineVector = CGPoint(
            x: endPoint.x - startPoint.x, y: endPoint.y - startPoint.y)
        let pointVector = CGPoint(
            x: point.x - startPoint.x, y: point.y - startPoint.y)

        let crossProduct =
            pointVector.x * lineVector.y - pointVector.y * lineVector.x
        guard abs(crossProduct) < threshold else { return false }

        let dotProduct =
            pointVector.x * lineVector.x + pointVector.y * lineVector.y
        guard dotProduct >= -threshold else { return false }

        let squaredLength =
            lineVector.x * lineVector.x + lineVector.y * lineVector.y
        guard dotProduct <= squaredLength + threshold else { return false }

        return true
    }

    func toDataModel() -> PolygonVectorModel {
        PolygonVectorModel(
            id: self.id,
            colorHex: self.color.toHex(),
            startX: self.startPoint.x,
            startY: self.startPoint.y,
            endX: self.endPoint.x,
            endY: self.endPoint.y
        )
    }

}
