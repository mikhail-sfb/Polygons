//
//  DrawablePolygon.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 14.03.25.
//

import Combine
import SpriteKit
import SwiftUI

class DrawablePolygon: SKScene {
    @ObservedObject var drawablePolygonViewModel: DrawablePolygonViewModel

    private var startPoint: CGPoint?
    private var useRandomColor = false
    private var selectedColor: Color = .blue
    private var cancellables = Set<AnyCancellable>()
    private var vectorNodes: [UUID: (SKShapeNode, SKShapeNode, SKShapeNode)] =
        [:]
    private var activeSnapModes: Set<SnapMode> = []
    private let snapDistance: CGFloat = DrawingConstants.snapDistance
    private var previewLine: SKShapeNode?
    private let rightAngleSquareSize: CGFloat = DrawingConstants
        .rightAngleSquareSize
    private var rightAngleIndicators: [UUID: SKShapeNode] = [:]
    private var longPressTimer: Timer?

    init(drawablePolygonViewModel: DrawablePolygonViewModel, size: CGSize) {
        self.drawablePolygonViewModel = drawablePolygonViewModel
        super.init(size: size)

        backgroundColor = .polygonBackground
        isUserInteractionEnabled = true

        initializeVectorSubscription()
        initializeSnapModeSubscription()
        initializeVectors()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureRandomColorOption(_ value: Bool) {
        useRandomColor = value
    }

    func configureSelectedColor(_ color: Color) {
        selectedColor = color
    }

    private func initializeVectorSubscription() {
        drawablePolygonViewModel.$vectors
            .sink { [weak self] vectors in
                self?.refreshVectorNodes(vectors)
            }
            .store(in: &cancellables)

        drawablePolygonViewModel.$selectedVectorId
            .sink { [weak self] selectedId in
                self?.highlightSelectedVector(selectedId)
            }
            .store(in: &cancellables)
    }

    private func initializeSnapModeSubscription() {
        drawablePolygonViewModel.$activeSnapModes
            .sink { [weak self] modes in
                self?.activeSnapModes = modes
            }
            .store(in: &cancellables)
    }

    private func initializeVectors() {
        refreshVectorNodes(drawablePolygonViewModel.vectors)
    }

    private func refreshVectorNodes(_ vectors: [PolygonVector]) {
        let currentIds = Set(vectors.map { $0.id })
        let nodesToRemove = Set(vectorNodes.keys).subtracting(currentIds)

        for id in nodesToRemove {
            if let (line, handle, arrow) = vectorNodes[id] {
                line.removeFromParent()
                handle.removeFromParent()
                arrow.removeFromParent()
                vectorNodes.removeValue(forKey: id)
            }
        }

        for vector in vectors {
            let path = UIBezierPath()
            path.move(to: vector.startPoint)
            path.addLine(to: vector.endPoint)

            let line: SKShapeNode
            let startHandle: SKShapeNode
            let arrow: SKShapeNode

            if let existingNodes = vectorNodes[vector.id] {
                line = existingNodes.0
                startHandle = existingNodes.1
                arrow = existingNodes.2
                line.path = path.cgPath
            } else {
                line = SKShapeNode(path: path.cgPath)
                startHandle = SKShapeNode(
                    circleOfRadius: DrawingConstants.vectorHandleRadius)
                arrow = createArrowNode(vector: vector)

                line.strokeColor = UIColor(vector.color)
                line.lineWidth = 2
                startHandle.fillColor = UIColor(vector.color)
                startHandle.alpha = 0.7
                arrow.fillColor = UIColor(vector.color)

                addChild(line)
                addChild(startHandle)
                addChild(arrow)
                vectorNodes[vector.id] = (line, startHandle, arrow)
            }

            startHandle.position = vector.startPoint
            updateArrowNode(arrow, vector: vector)
            let isSelected =
                vector.id == drawablePolygonViewModel.selectedVectorId
            line.lineWidth = isSelected ? 4 : 2
            startHandle.isHidden = !drawablePolygonViewModel.isEditMode
        }
        refreshRightAngleIndicators()
    }

    private func highlightSelectedVector(_ selectedId: UUID?) {
        for (id, (line, handle, arrow)) in vectorNodes {
            let isSelected = id == selectedId
            line.lineWidth = isSelected ? 4 : 2
            handle.setScale(isSelected ? 1.2 : 1.0)
            arrow.fillColor =
                isSelected
                ? .white
                : UIColor(
                    drawablePolygonViewModel.vectors.first(where: {
                        $0.id == id
                    })?.color ?? .blue)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if drawablePolygonViewModel.freeMovementMode {
            drawablePolygonViewModel.handleLongPress(
                at: location, in: self.size)
        } else if drawablePolygonViewModel.isEditMode {
            longPressTimer = Timer.scheduledTimer(
                withTimeInterval: 0.5, repeats: false
            ) { [weak self] _ in
                self?.drawablePolygonViewModel.handleLongPress(
                    at: location, in: self?.size ?? .zero)
            }
        } else {
            startPoint = location
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        longPressTimer?.invalidate()
        if (drawablePolygonViewModel.freeMovementMode
            || drawablePolygonViewModel.isEditMode)
            && drawablePolygonViewModel.selectedVectorId != nil
        {
            drawablePolygonViewModel.endDrag()
        } else if let touch = touches.first, let start = startPoint {
            previewLine?.removeFromParent()
            var end = touch.location(in: self)
            let result = detectNearestEndpoint(to: end)
            if result.found { end = result.point }
            let color = useRandomColor ? .randomColor() : selectedColor
            drawablePolygonViewModel.appendVector(
                PolygonVector(color: color, startPoint: start, endPoint: end))
            startPoint = nil
            refreshRightAngleIndicators()
        }
    }

    private func refreshVectorVisuals(
        _ nodes: (SKShapeNode, SKShapeNode, SKShapeNode),
        _ vector: PolygonVector
    ) {
        let (line, startHandle, arrow) = nodes
        let isSelected = vector.id == drawablePolygonViewModel.selectedVectorId

        line.strokeColor = isSelected ? .white : UIColor(vector.color)
        line.lineWidth = isSelected ? 4 : 2
        arrow.fillColor = isSelected ? .white : UIColor(vector.color)

        let showHandles =
            drawablePolygonViewModel.freeMovementMode
            || drawablePolygonViewModel.isEditMode
        [startHandle].forEach {
            $0.alpha = showHandles ? 0.9 : 0
            $0.fillColor = UIColor(vector.color)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        if drawablePolygonViewModel.freeMovementMode
            || drawablePolygonViewModel.isEditMode
        {
            let location = touch.location(in: self)
            drawablePolygonViewModel.handleDrag(at: location, in: size)
        } else if let start = startPoint {
            var location = touch.location(in: self)

            if activeSnapModes.contains(.endpoints) {
                let result = detectNearestEndpoint(to: location)
                if result.found { location = result.point }
            }

            if activeSnapModes.contains(.verticalHorizontal) {
                let dx = abs(location.x - start.x)
                let dy = abs(location.y - start.y)
                if dx < snapDistance && dx < dy {
                    location.x = start.x
                } else if dy < snapDistance && dy < dx {
                    location.y = start.y
                }
            }

            if activeSnapModes.contains(.rightAngle) {
                for vector in drawablePolygonViewModel.vectors {
                    location = calculateRightAnglePosition(
                        for: location, fixedPoint: start, otherVector: vector)
                }
            }

            renderPreviewLine(from: start, to: location)
        }
    }

    override func touchesCancelled(
        _ touches: Set<UITouch>, with event: UIEvent?
    ) {
        longPressTimer?.invalidate()
        previewLine?.removeFromParent()
        startPoint = nil

        if (drawablePolygonViewModel.freeMovementMode
            || drawablePolygonViewModel.isEditMode)
            && drawablePolygonViewModel.selectedVectorId != nil
        {
            drawablePolygonViewModel.endDrag()
        }
    }

    private func renderPreviewLine(from start: CGPoint, to end: CGPoint) {
        previewLine?.removeFromParent()

        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)

        let line = SKShapeNode(path: path.cgPath)
        line.strokeColor = UIColor(Color.gray)
        line.lineWidth = DrawingConstants.previewLineWidth
        addChild(line)

        previewLine = line
    }

    private func detectNearestEndpoint(to point: CGPoint)
        -> EndpointDetectionResult
    {
        let allEndpoints = drawablePolygonViewModel.vectors.flatMap {
            [$0.startPoint, $0.endPoint]
        }
        var closestPoint: CGPoint? = nil
        var minDistance = CGFloat.greatestFiniteMagnitude

        for endpoint in allEndpoints {
            let distance = GeometryHelper.calculateDistance(
                from: point, to: endpoint)
            if distance < snapDistance && distance < minDistance {
                minDistance = distance
                closestPoint = endpoint
            }
        }
        return closestPoint != nil
            ? EndpointDetectionResult(found: true, point: closestPoint!)
            : EndpointDetectionResult(found: false, point: .zero)
    }

    private func calculateRightAnglePosition(
        for point: CGPoint, fixedPoint: CGPoint, otherVector: PolygonVector
    ) -> CGPoint {
        let result = detectCommonEndpoint(fixedPoint, otherVector)
        guard result.found else { return point }

        let common = result.commonPoint
        let other = result.otherPoint
        let v1 = CGPoint(x: point.x - common.x, y: point.y - common.y)
        let v2 = CGPoint(x: other.x - common.x, y: other.y - common.y)
        let angle = GeometryHelper.calculateAngleBetween(
            vector1: v1, vector2: v2)

        guard abs(angle - 90) < DrawingConstants.rightAngleTolerance else {
            return point
        }

        let perp = GeometryHelper.calculatePerpendicularVector(to: v2)
        let perpNormalized = GeometryHelper.normalizeVector(vector: perp)
        let v1Mag = GeometryHelper.calculateMagnitude(of: v1)

        return CGPoint(
            x: common.x + perpNormalized.x * v1Mag,
            y: common.y + perpNormalized.y * v1Mag)
    }

    private func detectCommonEndpoint(_ point: CGPoint, _ vector: PolygonVector)
        -> CommonEndpointResult
    {
        if GeometryHelper.checkPointProximity(
            point, to: vector.startPoint,
            threshold: DrawingConstants.endpointSnapThreshold)
        {
            return CommonEndpointResult(
                found: true, commonPoint: vector.startPoint,
                otherPoint: vector.endPoint)
        }

        if GeometryHelper.checkPointProximity(
            point, to: vector.endPoint,
            threshold: DrawingConstants.endpointSnapThreshold)
        {
            return CommonEndpointResult(
                found: true, commonPoint: vector.endPoint,
                otherPoint: vector.startPoint)
        }

        return CommonEndpointResult(
            found: false, commonPoint: .zero, otherPoint: .zero)
    }

    private func refreshRightAngleIndicators() {
        rightAngleIndicators.values.forEach { $0.removeFromParent() }
        rightAngleIndicators.removeAll()

        for i in 0..<drawablePolygonViewModel.vectors.count {
            for j in i + 1..<drawablePolygonViewModel.vectors.count {
                let v1 = drawablePolygonViewModel.vectors[i]
                let v2 = drawablePolygonViewModel.vectors[j]
                let result = generateRightAngleMarker(v1, v2)
                if result.exists, let indicator = result.marker {
                    addChild(indicator)
                    rightAngleIndicators[UUID()] = indicator
                }
            }
        }
    }

    private func generateRightAngleMarker(
        _ v1: PolygonVector, _ v2: PolygonVector
    ) -> RightAngleMarkerResult {
        let potentialCommonPoints = [
            (v1.startPoint, v1.endPoint, v2.startPoint, v2.endPoint),
            (v1.startPoint, v1.endPoint, v2.endPoint, v2.startPoint),
            (v1.endPoint, v1.startPoint, v2.startPoint, v2.endPoint),
            (v1.endPoint, v1.startPoint, v2.endPoint, v2.startPoint),
        ]

        for (p1, p2, p3, p4) in potentialCommonPoints {
            if GeometryHelper.checkPointProximity(
                p1, to: p3, threshold: DrawingConstants.endpointSnapThreshold)
            {
                let common = p1
                let v1Dir = CGPoint(x: p2.x - common.x, y: p2.y - common.y)
                let v2Dir = CGPoint(x: p4.x - common.x, y: p4.y - common.y)
                let angle = GeometryHelper.calculateAngleBetween(
                    vector1: v1Dir, vector2: v2Dir)

                if abs(angle - 90) < DrawingConstants.rightAngleTolerance {
                    let size = rightAngleSquareSize
                    let path = UIBezierPath()
                    let v1Norm = GeometryHelper.normalizeVector(vector: v1Dir)
                    let v2Norm = GeometryHelper.normalizeVector(vector: v2Dir)

                    let p1 = common
                    let p2 = CGPoint(
                        x: common.x + v1Norm.x * size,
                        y: common.y + v1Norm.y * size)
                    let p3 = CGPoint(
                        x: common.x + v1Norm.x * size + v2Norm.x * size,
                        y: common.y + v1Norm.y * size + v2Norm.y * size)
                    let p4 = CGPoint(
                        x: common.x + v2Norm.x * size,
                        y: common.y + v2Norm.y * size)

                    path.move(to: p1)
                    path.addLine(to: p2)
                    path.addLine(to: p3)
                    path.addLine(to: p4)
                    path.close()

                    let indicator = SKShapeNode(path: path.cgPath)
                    indicator.fillColor = .blue
                    indicator.alpha = 0.5
                    return RightAngleMarkerResult(
                        marker: indicator, exists: true)
                }
            }
        }

        return RightAngleMarkerResult(marker: nil, exists: false)
    }

    private func createArrowNode(vector: PolygonVector) -> SKShapeNode {
        let angle = atan2(
            vector.endPoint.y - vector.startPoint.y,
            vector.endPoint.x - vector.startPoint.x)
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

    private func updateArrowNode(_ node: SKShapeNode, vector: PolygonVector) {
        let angle = atan2(
            vector.endPoint.y - vector.startPoint.y,
            vector.endPoint.x - vector.startPoint.x)
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

        node.path = arrowPath.cgPath
    }

    func setRandomColorOption(_ value: Bool) {
        useRandomColor = value
    }

    func setSelectedColor(_ color: Color) {
        selectedColor = color
    }
}
