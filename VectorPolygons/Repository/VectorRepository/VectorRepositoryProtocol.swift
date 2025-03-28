//
//  VectorRepositoryProtocol.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 25.03.25.
//

import Foundation

protocol VectorRepositoryProtocol {
    func fetchAll() async throws -> [PolygonVector]
    func save(vector: PolygonVector) async throws
    func delete(id: PolygonVector) async throws
    func update(vector: PolygonVector) async throws
    func addVectors(_ vectors: [PolygonVector]) async throws
}
