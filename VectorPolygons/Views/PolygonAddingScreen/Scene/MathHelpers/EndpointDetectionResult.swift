//
//  EndpointDetectionResult.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 27.03.25.
//

import SwiftUI

struct EndpointDetectionResult {
    let found: Bool
    let point: CGPoint
    
    static func createNotFound() -> EndpointDetectionResult {
        return EndpointDetectionResult(found: false, point: .zero)
    }
    
    static func createFound(at point: CGPoint) -> EndpointDetectionResult {
        return EndpointDetectionResult(found: true, point: point)
    }
}
