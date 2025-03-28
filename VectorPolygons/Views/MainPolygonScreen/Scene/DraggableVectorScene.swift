//
//  DraggablePolygon.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 23.03.25.
//

import SpriteKit
import SwiftUI

class DraggableVectorScene: SKScene {
    private var storedVectors: [PolygonVector] = []
    private var currentHighlightId: UUID?

    func redrawVectors(_ newVectors: [PolygonVector]) {
        removeAllChildren()
        storedVectors = newVectors
        drawAllVectors()
    }

    func highlightVector(id: UUID) {
        removeHighlight()

        guard let vector = storedVectors.first(where: { $0.id == id }) else {
            return
        }

        let highlightLine = createHighlightLine(vector: vector)
        let highlightArrow = createHighlightArrow(vector: vector)

        addChild(highlightLine)
        addChild(highlightArrow)

        let blink = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: 0.3),
                SKAction.fadeAlpha(to: 1.0, duration: 0.3),
            ])
        )

        highlightLine.run(blink)
        highlightArrow.run(blink)
        currentHighlightId = id
    }

    func removeHighlight() {
        children.filter { $0.name == "HIGHLIGHT" }.forEach { node in
            node.removeAllActions()
            node.removeFromParent()
        }
        currentHighlightId = nil
    }

    private func createHighlightLine(vector: PolygonVector) -> SKShapeNode {
        let path = UIBezierPath()
        path.move(to: vector.startPoint)
        path.addLine(to: vector.endPoint)

        let node = SKShapeNode(path: path.cgPath)
        node.name = "HIGHLIGHT"
        node.strokeColor = .yellow
        node.lineWidth = DrawingConstants.vectorLineWidth + 2
        node.glowWidth = 5
        return node
    }

    private func createHighlightArrow(vector: PolygonVector) -> SKShapeNode {
        let angle = atan2(
            vector.endPoint.y - vector.startPoint.y,
            vector.endPoint.x - vector.startPoint.x
        )

        let arrowPath = UIBezierPath()
        let arrowLength: CGFloat = DrawingConstants.arrowLength + 2

        arrowPath.move(to: vector.endPoint)
        arrowPath.addLine(
            to: CGPoint(
                x: vector.endPoint.x - arrowLength * cos(angle + .pi / 6),
                y: vector.endPoint.y - arrowLength * sin(angle + .pi / 6)
            ))
        arrowPath.addLine(
            to: CGPoint(
                x: vector.endPoint.x - arrowLength * cos(angle - .pi / 6),
                y: vector.endPoint.y - arrowLength * sin(angle - .pi / 6)
            ))
        arrowPath.close()

        let node = SKShapeNode(path: arrowPath.cgPath)
        node.name = "HIGHLIGHT"
        node.fillColor = .yellow.withAlphaComponent(0.7)
        node.strokeColor = .yellow
        return node
    }

    private func drawAllVectors() {
        storedVectors.forEach(drawVector)
    }

    private func drawVector(_ vector: PolygonVector) {
        let path = UIBezierPath()
        path.move(to: vector.startPoint)
        path.addLine(to: vector.endPoint)

        let lineNode = SKShapeNode(path: path.cgPath)
        lineNode.strokeColor = UIColor(vector.color)
        lineNode.lineWidth = DrawingConstants.vectorLineWidth
        addChild(lineNode)

        let arrowNode = createArrowNode(vector: vector)
        addChild(arrowNode)
    }

    private func createArrowNode(vector: PolygonVector) -> SKShapeNode {
        let angle = atan2(
            vector.endPoint.y - vector.startPoint.y,
            vector.endPoint.x - vector.startPoint.x
        )

        let arrowPath = UIBezierPath()
        let arrowLength = DrawingConstants.arrowLength

        arrowPath.move(to: vector.endPoint)
        arrowPath.addLine(
            to: CGPoint(
                x: vector.endPoint.x - arrowLength * cos(angle + .pi / 6),
                y: vector.endPoint.y - arrowLength * sin(angle + .pi / 6)
            ))
        arrowPath.addLine(
            to: CGPoint(
                x: vector.endPoint.x - arrowLength * cos(angle - .pi / 6),
                y: vector.endPoint.y - arrowLength * sin(angle - .pi / 6)
            ))
        arrowPath.close()

        let node = SKShapeNode(path: arrowPath.cgPath)
        node.fillColor = UIColor(vector.color)
        return node
    }
}
