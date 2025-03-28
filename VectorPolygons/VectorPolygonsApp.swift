//
//  VectorPolygonsApp.swift
//  VectorPolygons
//
//  Created by Michail Malashkevich on 28.03.25.
//

import SwiftUI
import SwiftData

@main
struct VectorPolygonsApp: App {
    private let container: ModelContainer
    private let repository: VectorRepositoryProtocol
    
    init() {
        do {
            container = try ModelContainer(for: PolygonVectorModel.self)
            repository = VectorRepository(container: container)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            PolygonScreen(polygonViewModel: MainPolygonViewModel(polygonSize: .zero, repository: repository))
        }
    }
}
