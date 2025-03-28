//
//  ContentView.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 14.03.25.
//

import SpriteKit
import SwiftData
import SwiftUI

struct PolygonScreen: View {
    @StateObject var polygonViewModel: MainPolygonViewModel
    @State private var borderOpacity: Double = 0.0
    @State private var navigateToAdd = false
    @State private var isMenuOpen = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    RestrictionAreaView(
                        borderOpacity: $borderOpacity,
                        polygonViewModel: polygonViewModel
                    )

                    Spacer()

                    PlusButton(action: {
                        navigateToAdd.toggle()
                    })
                }
                .padding()
                .navigationDestination(isPresented: $navigateToAdd) {
                    AddingVectorScreen(
                        draggblePolygonViewModel: polygonViewModel)
                }

                SideMenu(
                    width: UIScreen.main.bounds.width / 3,
                    isOpen: isMenuOpen,
                    viewModel: polygonViewModel
                ) {
                    withAnimation {
                        isMenuOpen.toggle()
                    }
                }
            }
            .navigationBarItems(
                leading: SideMenuCallButton(isMenuOpen: $isMenuOpen))
        }
        .onChange(of: isMenuOpen) {
            if !isMenuOpen {
                polygonViewModel.unhighlightVector()
            }
        }
    }
}

private struct SideMenuCallButton: View {
    @Binding var isMenuOpen: Bool

    var body: some View {
        Button(action: {
            withAnimation {
                isMenuOpen.toggle()
            }
        }) {
            Image(systemName: "line.horizontal.3")
                .imageScale(.large)
        }
        .opacity(isMenuOpen ? 0 : 1)
    }
}
