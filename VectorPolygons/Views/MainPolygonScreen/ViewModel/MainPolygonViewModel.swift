//
//  2DPolygonViewModel.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 18.03.25.
//

import SwiftUI

class MainPolygonViewModel: ObservableObject {
    @Published var vectors: [PolygonVector] = []
    @Published var selectedVectorId: UUID?
    @Published var highlightedVectorId: UUID?
    @Published var polygonSize: CGSize = .zero

    private let repository: VectorRepositoryProtocol
    private let manager: VectorManagerProtocol

    init(polygonSize: CGSize, repository: VectorRepositoryProtocol) {
        self.polygonSize = polygonSize
        self.repository = repository
        self.manager = VectorManager(repository: repository)
        loadVectors()
    }

    private func loadVectors() {
        Task {
            let fetchedVectors = await manager.fetchAllVectors()
            await MainActor.run {
                vectors = fetchedVectors
            }
        }
    }

    func appendVector(_ vector: PolygonVector) {
        vectors.append(vector)
        Task {
            let success = await manager.saveVector(vector)
            if !success {
                await MainActor.run {
                    vectors.removeAll { $0.id == vector.id }
                }
            }
        }
    }

    func removeVector(id: UUID) {
        guard let index = vectors.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        let vector = vectors[index]
        vectors.remove(at: index)

        Task {
            let success = await manager.deleteVector(id: vector)
            if !success {
                await MainActor.run {
                    vectors.insert(vector, at: index)
                }
            }
        }
    }

    func removeLastVector() {
        guard !vectors.isEmpty else { return }
        let lastVector = vectors.removeLast()

        Task {
            let success = await manager.deleteVector(id: lastVector)
            if !success {
                await MainActor.run {
                    vectors.append(lastVector)
                }
            }
        }
    }

    func addVectors(_ vectors: [PolygonVector]) {
        self.vectors.append(contentsOf: vectors)
        Task {
            let success = await manager.addVectors(vectors)
            if !success {
                await MainActor.run {
                    self.vectors.removeAll { vector in
                        vectors.contains(where: { $0.id == vector.id })
                    }
                }
            }
        }
    }

    func highlightVector(id: UUID) {
        highlightedVectorId = id

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.highlightedVectorId = nil
        }
    }
    
    func unhighlightVector() {
        highlightedVectorId = nil
    }

    func updatePolygonSize(_ size: CGSize) {
        polygonSize = size
    }

    func normaliseVectors(otherPolygonSize: CGSize, vectors: [PolygonVector])
        -> [PolygonVector]
    {
        guard otherPolygonSize.width > 0, otherPolygonSize.height > 0,
            self.polygonSize.width > 0, self.polygonSize.height > 0
        else {
            return vectors
        }

        let scaleX = self.polygonSize.width / otherPolygonSize.width
        let scaleY = self.polygonSize.height / otherPolygonSize.height

        return vectors.map { vector in
            PolygonVector(
                color: vector.color,
                startPoint: CGPoint(
                    x: vector.startPoint.x * scaleX,
                    y: vector.startPoint.y * scaleY
                ),
                endPoint: CGPoint(
                    x: vector.endPoint.x * scaleX,
                    y: vector.endPoint.y * scaleY
                )
            )
        }
    }
}
