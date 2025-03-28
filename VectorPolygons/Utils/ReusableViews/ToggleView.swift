//
//  ToggleView.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 23.03.25.
//

import SwiftUI

struct ToggleView: View {
    @Binding var condition: Bool
    
    let title: String

    var body: some View {
        Toggle(isOn: $condition) {
            Text(title)
        }
    }
}
