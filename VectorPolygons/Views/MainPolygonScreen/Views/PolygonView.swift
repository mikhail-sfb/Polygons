//
//  PolygonView.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 15.03.25.
//

import SpriteKit
import SwiftUI

struct PolygonView: View {
    @Binding var borderOpacity: Double
    @State var endOffset: CGSize = .zero
    @State private var scene: DraggableVectorScene?
    @ObservedObject var polygonViewModel: MainPolygonViewModel

    var parentGeometry: CGRect

    init(
        borderOpacity: Binding<Double>, polygonViewModel: MainPolygonViewModel,
        parentGeometry: CGRect
    ) {
        self._borderOpacity = borderOpacity
        self.polygonViewModel = polygonViewModel
        self.parentGeometry = parentGeometry
    }

    var body: some View {
        ZStack {
            if let scene = scene {
                SpriteView(scene: scene)
                    .frame(
                        width: polygonViewModel.polygonSize.width,
                        height: polygonViewModel.polygonSize.height
                    )
                    .cornerRadius(12)
                    .onAppear {
                        print(polygonViewModel.vectors.count)
                    }
            }

            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        if scene != nil {
                        } else {
                            scene = makeScene(
                                size: polygonViewModel.polygonSize)
                        }
                    }
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .panGesture(
            endOffset: $endOffset,
            borderOpacity: $borderOpacity,
            childGeometry: CGRect(
                origin: .zero, size: polygonViewModel.polygonSize),
            parentGeometry: parentGeometry
        )
        .onChange(of: polygonViewModel.vectors) {
            scene?.redrawVectors(polygonViewModel.vectors)
        }
        .onChange(of: polygonViewModel.highlightedVectorId) {
            if let id = polygonViewModel.highlightedVectorId {
                scene?.highlightVector(id: id)
            } else {
                scene?.removeHighlight()
            }
        }
    }

    private func makeScene(size: CGSize) -> DraggableVectorScene {
        let scene = DraggableVectorScene(size: size)
        scene.scaleMode = .resizeFill
        scene.redrawVectors(polygonViewModel.vectors)
        return scene
    }
}
