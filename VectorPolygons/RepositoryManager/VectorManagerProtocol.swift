//
//  VectorManagerProtocol.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 27.03.25.
//

import Foundation

protocol VectorManagerProtocol {
    func fetchAllVectors() async -> [PolygonVector]
    func saveVector(_ vector: PolygonVector) async -> Bool
    func deleteVector(id: PolygonVector) async -> Bool
    func updateVector(_ vector: PolygonVector) async -> Bool
    func addVectors(_ vectors: [PolygonVector]) async -> Bool
}
