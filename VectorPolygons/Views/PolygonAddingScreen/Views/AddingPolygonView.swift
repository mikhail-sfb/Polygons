//
//  PolygonDi.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 23.03.25.
//

import SwiftUI
import SpriteKit

struct AddingPolygonView: View {
    var heightScale: CGFloat
    var roundedRadius: CGFloat
    var geometry: GeometryProxy
    var scene: DrawablePolygon
    
    var body: some View {
        SpriteView(scene: scene)
            .cornerRadius(roundedRadius)
            .frame(height: geometry.size.height * heightScale)
            .background {
                UnevenRoundedRectangle(
                    bottomLeadingRadius: roundedRadius,
                    bottomTrailingRadius: roundedRadius
                )
                .foregroundStyle(.polygonBackground)
            }
    }
}
