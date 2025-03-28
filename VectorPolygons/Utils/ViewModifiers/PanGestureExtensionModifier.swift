//
//  Untitled.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 14.03.25.
//

import SwiftUI

private struct DraggableView: ViewModifier {
    @Binding var endOffset: CGSize
    @Binding var borderOpacity: Double
    @GestureState private var gestureOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var isAnimating = false

    private let childGeometry: CGRect?
    private let parentGeometry: CGRect?

    init(
        endOffset: Binding<CGSize>, borderOpacity: Binding<Double>,
        childGeometry: CGRect?, parentGeometry: CGRect?
    ) {
        self._endOffset = endOffset
        self._borderOpacity = borderOpacity
        self.childGeometry = childGeometry
        self.parentGeometry = parentGeometry
    }

    func body(content: Content) -> some View {
        content
            .offset(
                x: calculateConstrainedOffset().width,
                y: calculateConstrainedOffset().height
            )
            .overlay(
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(coordinateSpace: .global)
                            .updating($gestureOffset) { value, state, _ in
                                state = value.translation
                                isDragging = true
                            }
                            .onChanged { value in
                                updateBorderOpacity(
                                    with: calculatePositionWithTranslation(
                                        value.translation))
                            }
                            .onEnded { gesture in
                                let newEndOffset = CGSize(
                                    width: endOffset.width
                                        + gesture.translation.width,
                                    height: endOffset.height
                                        + gesture.translation.height
                                )

                                endOffset = constrainOffset(
                                    offset: newEndOffset)
                                isDragging = false
                            }
                    )
         
            )
    }

    private func calculateConstrainedOffset() -> CGSize {
        let totalOffset = CGSize(
            width: endOffset.width + gestureOffset.width,
            height: endOffset.height + gestureOffset.height
        )
        return constrainOffset(offset: totalOffset)
    }

    private func calculatePositionWithTranslation(_ translation: CGSize)
        -> CGSize
    {
        let position = CGSize(
            width: endOffset.width + translation.width,
            height: endOffset.height + translation.height
        )
        return position
    }

    private func updateBorderOpacity(with position: CGSize) {
        guard let childGeometry = childGeometry,
            let parentGeometry = parentGeometry,
            isDragging
        else {
            return
        }

        let maxX = (parentGeometry.width - childGeometry.width) / 2
        let maxY = (parentGeometry.height - childGeometry.height) / 2

        let normalizedDistanceX = 1 - min(abs(position.width) / maxX, 1)
        let normalizedDistanceY = 1 - min(abs(position.height) / maxY, 1)

        let minNormalizedDistance =
            min(normalizedDistanceX, normalizedDistanceY) * 3
        let calculatedOpacity = max(0, 1 - minNormalizedDistance)

        DispatchQueue.main.async {
            var transaction = Transaction()
            transaction.disablesAnimations = true

            withTransaction(transaction) {
                borderOpacity = calculatedOpacity
            }
        }
    }

    private func constrainOffset(offset: CGSize) -> CGSize {
        guard let childGeometry = childGeometry,
            let parentGeometry = parentGeometry
        else {
            return offset
        }

        let maxX = (parentGeometry.width - childGeometry.width) / 2
        let maxY = (parentGeometry.height - childGeometry.height) / 2

        let constrainedX = max(-maxX, min(maxX, offset.width))
        let constrainedY = max(-maxY, min(maxY, offset.height))

        return CGSize(width: constrainedX, height: constrainedY)
    }
}

extension View {
    func panGesture(
        endOffset: Binding<CGSize>, borderOpacity: Binding<Double>,
        childGeometry: CGRect?, parentGeometry: CGRect?
    ) -> some View {
        return modifier(
            DraggableView(
                endOffset: endOffset, borderOpacity: borderOpacity,
                childGeometry: childGeometry, parentGeometry: parentGeometry))
    }
}
