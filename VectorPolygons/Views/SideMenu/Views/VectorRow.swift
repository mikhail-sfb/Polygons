//
//  VectorRow.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 23.03.25.
//

import SwiftUI


struct VectorRow: View {
    let vector: PolygonVector
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Length: \(vector.length, format: .number.precision(.fractionLength(2)))")
                .font(.subheadline)
            
            HStack(spacing: 2) {
                Text("(\(vector.startPoint.x, format: .number.precision(.fractionLength(1))),")
                
                Text("\(vector.startPoint.y, format: .number.precision(.fractionLength(1)))) →")
                
                Text("(\(vector.endPoint.x, format: .number.precision(.fractionLength(1))),")
                
                Text("\(vector.endPoint.y, format: .number.precision(.fractionLength(1))))")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .contentShape(Rectangle())
    }
}
