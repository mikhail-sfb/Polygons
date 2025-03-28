//
//  RightAngleMarkerResult.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 27.03.25.
//

import SwiftUI
import SpriteKit

struct RightAngleMarkerResult {
    let marker: SKShapeNode?
    let exists: Bool
    
    static func createNotFound() -> RightAngleMarkerResult {
        return RightAngleMarkerResult(marker: nil, exists: false)
    }
    
    static func createFound(marker: SKShapeNode) -> RightAngleMarkerResult {
        return RightAngleMarkerResult(marker: marker, exists: true)
    }
}
