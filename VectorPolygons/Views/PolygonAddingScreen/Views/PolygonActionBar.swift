//
//  PolygonActionBar.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 23.03.25.
//

import SwiftUI

struct PolygonActionBar: View {
    @ObservedObject var drawablePolygonViewModel: DrawablePolygonViewModel
    @ObservedObject var draggblePolygonViewModel: MainPolygonViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        UnevenRoundedRectangle(topLeadingRadius: 15, topTrailingRadius: 15)
            .frame(height: 60)
            .foregroundStyle(.polygonBackground.opacity(0.9))
            .overlay {
                HStack {
                    Button(action: drawablePolygonViewModel.removeLastVector) {
                        Image(systemName: "arrow.backward")
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(.blue, in: Circle())
                    }
                    
                    Spacer()
                    
                    SnapModeBar(drawablePolygonViewModel: drawablePolygonViewModel)
                    
                    Spacer()
                    
                    Button("Save") {
                        let newVectors = draggblePolygonViewModel.normaliseVectors(
                            otherPolygonSize: drawablePolygonViewModel.polygonSize,
                            vectors: drawablePolygonViewModel.vectors)

                        draggblePolygonViewModel.addVectors(newVectors)
                        dismiss()
                    }
                    .padding(7)
                    .foregroundStyle(.white)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal)
            }
    }
}
