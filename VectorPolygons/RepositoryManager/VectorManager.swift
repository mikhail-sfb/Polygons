//
//  VectorManager.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 27.03.25.
//

import Foundation

struct VectorManager: VectorManagerProtocol {
    private let repository: VectorRepositoryProtocol
    
    init(repository: VectorRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchAllVectors() async -> [PolygonVector] {
        do {
            return try await repository.fetchAll()
        } catch {
            print("Error fetching vectors: \(error)")
            return []
        }
    }
    
    func saveVector(_ vector: PolygonVector) async -> Bool {
        do {
            try await repository.save(vector: vector)
            return true
        } catch {
            print("Error saving vector: \(error)")
            return false
        }
    }
    
    func deleteVector(id: PolygonVector) async -> Bool {
        do {
            try await repository.delete(id: id)
            return true
        } catch {
            print("Error deleting vector: \(error)")
            return false
        }
    }
    
    func updateVector(_ vector: PolygonVector) async -> Bool {
        do {
            try await repository.update(vector: vector)
            return true
        } catch {
            print("Error updating vector: \(error)")
            return false
        }
    }
    
    func addVectors(_ vectors: [PolygonVector]) async -> Bool {
        do {
            try await repository.addVectors(vectors)
            return true
        } catch {
            print("Error adding vectors: \(error)")
            return false
        }
    }
}
