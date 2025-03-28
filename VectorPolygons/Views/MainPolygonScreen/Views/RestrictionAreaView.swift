//
//  RestrictionAreaView.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 23.03.25.
//

import SwiftUI

struct RestrictionAreaView: View {
    @Binding var borderOpacity: Double
    @ObservedObject var polygonViewModel: MainPolygonViewModel
    
    private var parentGeometry: CGRect = .zero
    
    init(borderOpacity: Binding<Double>, polygonViewModel: MainPolygonViewModel) {
        self._borderOpacity = borderOpacity
        self.polygonViewModel = polygonViewModel
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(style: .init(lineWidth: 4))
            .foregroundStyle(.orange.opacity(borderOpacity))
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .center
            )
            .aspectRatio(16 / 20, contentMode: .fit)
            .coordinateSpace(name: "restriction")
            .background {
                GeometryReader { parentProxy in
                    let parentGeometry = parentProxy.frame(in: .named("restriction"))
                    
                    PolygonView(
                        borderOpacity: $borderOpacity,
                        polygonViewModel: polygonViewModel,
                        parentGeometry: parentGeometry
                    )
                    .onChange(of: parentGeometry) {
                        polygonViewModel.updatePolygonSize(CGSize(
                            width: parentGeometry.width / 1.1,
                            height: parentGeometry.height / 1.2
                        ))
                    }
                }
            }
    }
}
