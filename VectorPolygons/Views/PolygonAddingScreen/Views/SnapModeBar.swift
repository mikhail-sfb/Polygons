//
//  SnapModeBa.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 25.03.25.
//

import SwiftUI

struct SnapModeBar: View {
    @ObservedObject var drawablePolygonViewModel: DrawablePolygonViewModel

    private let editMode = "Edit Mode"

    var body: some View {
        HStack(spacing: 8) {
            SnapModeButton(
                isActive: Binding(
                    get: {
                        drawablePolygonViewModel.activeSnapModes.contains(
                            .verticalHorizontal)
                    },
                    set: { toggle(.verticalHorizontal, $0) }
                ),
                systemImage: "arrow.up.and.down.and.arrow.left.and.right",
                tooltip: "Vertical/Horizontal Snap"
            )

            SnapModeButton(
                isActive: Binding(
                    get: {
                        drawablePolygonViewModel.activeSnapModes.contains(.endpoints)
                    },
                    set: { toggle(.endpoints, $0) }
                ),
                systemImage: "point.topleft.down.curvedto.point.bottomright.up",
                tooltip: "Endpoint Snap"
            )

            SnapModeButton(
                isActive: Binding(
                    get: {
                        drawablePolygonViewModel.activeSnapModes.contains(.rightAngle)
                    },
                    set: { toggle(.rightAngle, $0) }
                ),
                systemImage: "square",
                tooltip: "Right Angle Snap"
            )

            Button {
                drawablePolygonViewModel.isEditMode.toggle()
            } label: {
                Image(systemName: "cursorarrow.and.square.on.square.dashed")
                    .padding(6)
                    .foregroundStyle(
                        drawablePolygonViewModel.isEditMode ? .white : .gray
                    )
                    .background(
                        drawablePolygonViewModel.isEditMode ? .blue : .clear,
                        in: RoundedRectangle(cornerRadius: 8))
            }
            .help(editMode)
            .contextMenu {
                Text(editMode)
            }

            SnapModeButton(
                isActive: Binding(
                    get: {
                        drawablePolygonViewModel.activeSnapModes.contains(.freeMovement)
                    },
                    set: {
                        toggle(.freeMovement, $0)
                    }
                ),
                systemImage:
                    "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left",
                tooltip: "Free Movement"
            )
        }
    }

    private func toggle(_ mode: SnapMode, _ active: Bool) {
        if active {
            drawablePolygonViewModel.activeSnapModes.insert(mode)
        } else {
            drawablePolygonViewModel.activeSnapModes.remove(mode)
        }
    }
}

struct SnapModeButton: View {
    @Binding var isActive: Bool
    
    var systemImage: String
    var tooltip: String

    var body: some View {
        Button {
            isActive.toggle()
        } label: {
            Image(systemName: systemImage)
                .padding(6)
                .foregroundStyle(isActive ? .white : .gray)
                .background(
                    isActive ? .blue : .clear,
                    in: RoundedRectangle(cornerRadius: 8))
        }
        .help(tooltip)
        .contextMenu {
            Text(tooltip)
        }
    }
}
