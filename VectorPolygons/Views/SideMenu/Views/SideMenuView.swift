//
//  VectorRow.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 23.03.25.
//

import SwiftUI

struct SideMenuContent: View {
    @ObservedObject var viewModel: MainPolygonViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Vectors")
                .font(.title.bold())
                .padding()

            if viewModel.vectors.isEmpty {
                Text("No vectors has been created")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List {
                    ForEach(viewModel.vectors) { vector in
                        VectorRow(vector: vector)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.highlightVector(id: vector.id)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.removeVector(id: vector.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SideMenu: View {
    let width: CGFloat
    let isOpen: Bool
    let viewModel: MainPolygonViewModel
    let menuClose: () -> Void

    var body: some View {
        ZStack {
            if isOpen {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        menuClose()
                    }
            }

            HStack {
                SideMenuContent(viewModel: viewModel)
                    .frame(width: width)
                    .background(Color.white)
                    .offset(x: isOpen ? 0 : -width)

                Spacer()
            }
        }
    }
}
