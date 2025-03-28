//
//  CGFLoatExtension.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 27.03.25.
//

import SwiftUI

extension CGFloat {
    var isApproximatelyRightAngle: Bool {
        abs(self - 90) < DrawingConstants.rightAngleTolerance
    }
}
