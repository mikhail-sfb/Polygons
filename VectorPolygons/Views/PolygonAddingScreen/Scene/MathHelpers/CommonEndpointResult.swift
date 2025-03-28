//
//  CommonEndpointResult.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 27.03.25.
//

import SwiftUI

struct CommonEndpointResult {
    let found: Bool
    let commonPoint: CGPoint
    let otherPoint: CGPoint
    
    static func createNotFound() -> CommonEndpointResult {
        return CommonEndpointResult(found: false, commonPoint: .zero, otherPoint: .zero)
    }
    
    static func createFound(common: CGPoint, other: CGPoint) -> CommonEndpointResult {
        return CommonEndpointResult(found: true, commonPoint: common, otherPoint: other)
    }
}
