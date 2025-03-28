//
//  AddingVectorSceen.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 15.03.25.
//

import SpriteKit
import SwiftUI

struct AddingVectorScreen: View {
    @ObservedObject var draggblePolygonViewModel: MainPolygonViewModel
    @StateObject private var drawablePolygonViewModel =
        DrawablePolygonViewModel(
            polygonSize: .zero)
    @State var pickedColor: Color = .blue
    @State var randomColorOption: Bool = true
    @State private var scene: DrawablePolygon?

    private let heightScale = 0.6
    private let roundedRadius: CGFloat = 15

    var body: some View {

        GeometryReader { geometry in
            VStack(spacing: 15) {
                VStack(spacing: 0) {
                    if let scene = scene {
                        Text("Hold the buttons to understand the context")
                            .opacity(0.5)
                            .padding(.bottom)

                        PolygonActionBar(
                            drawablePolygonViewModel: drawablePolygonViewModel,
                            draggblePolygonViewModel: draggblePolygonViewModel)

                        AddingPolygonView(
                            heightScale: heightScale,
                            roundedRadius: roundedRadius, geometry: geometry,
                            scene: scene)
                    }
                }
                .onAppear {
                    sceneInitialisation(geometry: geometry)
                }

                ToggleView(
                    condition: $randomColorOption,
                    title: "Randomise vector colors"
                )

                ColorPickerView(
                    pickedColor: randomColorOption
                        ? .constant(Color.gray) : $pickedColor,
                    isRandomColorOn: randomColorOption
                )
                .disabled(randomColorOption)
            }
            .padding()
            .onChange(of: randomColorOption) {
                scene?.setRandomColorOption(randomColorOption)
            }
            .onChange(of: pickedColor) {
                setSelectedColor()
            }

        }

    }

    private func setSelectedColor() {
        if randomColorOption == false {
            scene?.setSelectedColor(pickedColor)
        }
    }

    private func sceneInitialisation(geometry: GeometryProxy) {
        if scene == nil {
            let size = CGSize(
                width: geometry.size.width,
                height: geometry.size.height * heightScale)
            scene = createScene(
                size: size)

            drawablePolygonViewModel.updatePolygonSize(size)
        }
    }

    private func createScene(size: CGSize) -> DrawablePolygon {
        let newScene = DrawablePolygon(
            drawablePolygonViewModel: drawablePolygonViewModel, size: size)

        newScene.setRandomColorOption(randomColorOption)
        newScene.setSelectedColor(pickedColor)

        return newScene
    }
}
