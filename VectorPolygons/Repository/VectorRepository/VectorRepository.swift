//
//  VectorRepository.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 25.03.25.
//

import SwiftData
import SwiftUI

@MainActor
final class VectorRepository: VectorRepositoryProtocol {
    private let container: ModelContainer
    private let context: ModelContext
    
    init(container: ModelContainer) {
        self.container = container
        self.context = ModelContext(container)
    }
    
    func fetchAll() async throws -> [PolygonVector] {
        let descriptor = FetchDescriptor<PolygonVectorModel>()
        
        return try context.fetch(descriptor).map { $0.toDomain() }
    }
    
    func save(vector: PolygonVector) async throws {
        context.insert(vector.toDataModel())
        
        try context.save()
    }
    
    func delete(id: PolygonVector) async throws {
        let descriptor = FetchDescriptor<PolygonVectorModel>()
         
        if let model = try context.fetch(descriptor).first {
            context.delete(model)
            try context.save()
            
            print("Successfully deleted vector with ID: \(id.id)")
        } else {
            print("Object not found for deletion")
        }
    }
    
    func update(vector: PolygonVector) async throws {
        try await delete(id: vector)
        try await save(vector: vector)
    }
    
    func addVectors(_ vectors: [PolygonVector]) async throws {
        vectors.forEach { context.insert($0.toDataModel()) }
        try context.save()
    }
}
