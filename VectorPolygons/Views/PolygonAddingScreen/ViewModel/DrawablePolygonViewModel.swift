//
//  DrawablePolygonViewModel.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 27.03.25.
//

import SwiftUI

enum VectorDragType {
    case startPoint
    case endPoint
    case move
}

class DrawablePolygonViewModel: ObservableObject {
    @Published var vectors: [PolygonVector] = []
    @Published var activeSnapModes: Set<SnapMode> = []
    @Published var isEditMode: Bool = false
    @Published var selectedVectorId: UUID?
    @Published var dragType: VectorDragType?
    @Published var polygonSize: CGSize = .zero
    @Published var freeMovementMode: Bool = false
    
    private var dragStartLocation: CGPoint = .zero
    private var originalVectorPositions: (start: CGPoint, end: CGPoint)?

    init(polygonSize: CGSize) {
        self.polygonSize = polygonSize
    }

    func appendVector(_ vector: PolygonVector) {
        vectors.append(vector)
    }

    func removeVector(id: UUID) {
        vectors.removeAll { $0.id == id }
    }

    func removeLastVector() {
        guard !vectors.isEmpty else { return }
        vectors.removeLast()
    }

    func updatePolygonSize(_ size: CGSize) {
        polygonSize = size
    }

    func handleLongPress(at location: CGPoint, in size: CGSize) {
        guard isEditMode else { return }

        if freeMovementMode {
            guard let vector = findClosestVector(to: location) else { return }
            selectedVectorId = vector.id
            dragType = .move
            dragStartLocation = location
            originalVectorPositions = (vector.startPoint, vector.endPoint)
        } else {
            let handleRadius: CGFloat = 20
            guard let vector = findClosestVector(to: location) else { return }
            
            let startDistance = distance(vector.startPoint, location)
            let endDistance = distance(vector.endPoint, location)
            
            if vector.contains(point: location, threshold: 20) {
                setSelectedVector(id: vector.id, dragType: .move)
            } else if startDistance < handleRadius {
                setSelectedVector(id: vector.id, dragType: .startPoint)
            } else if endDistance < handleRadius {
                setSelectedVector(id: vector.id, dragType: .endPoint)
            }
        }
    }

    func handleDrag(at location: CGPoint, in size: CGSize) {
        guard isEditMode,
              let vectorId = selectedVectorId,
              let index = vectors.firstIndex(where: { $0.id == vectorId }),
              let dragType = dragType
        else { return }

        var vector = vectors[index]
        let clampedLocation = clampLocation(location, to: size)

        switch dragType {
        case .startPoint:
            vector.startPoint = applySnaps(
                point: clampedLocation,
                anchor: vector.endPoint,
                otherVectors: vectors.filter { $0.id != vectorId }
            )
            
        case .endPoint:
            vector.endPoint = applySnaps(
                point: clampedLocation,
                anchor: vector.startPoint,
                otherVectors: vectors.filter { $0.id != vectorId }
            )
            
        case .move:
            guard let originalPositions = originalVectorPositions else { return }
            let deltaX = clampedLocation.x - dragStartLocation.x
            let deltaY = clampedLocation.y - dragStartLocation.y
            
            vector.startPoint = CGPoint(
                x: originalPositions.start.x + deltaX,
                y: originalPositions.start.y + deltaY
            )
            vector.endPoint = CGPoint(
                x: originalPositions.end.x + deltaX,
                y: originalPositions.end.y + deltaY
            )
        }
        
        vectors[index] = vector
    }

    func endDrag() {
        selectedVectorId = nil
        dragType = nil
        dragStartLocation = .zero
        originalVectorPositions = nil
    }
}
