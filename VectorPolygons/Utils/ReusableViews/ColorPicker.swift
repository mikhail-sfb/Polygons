//
//  ColorPicker.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 23.03.25.
//

import SwiftUI

struct ColorPickerView: View {
    @Binding var pickedColor: Color
    
    var isRandomColorOn: Bool
    
    init(pickedColor: Binding<Color>, isRandomColorOn: Bool?) {
        self._pickedColor = pickedColor
        self.isRandomColorOn = isRandomColorOn ?? true
    }

    var body: some View {
        ColorPicker(
            "Color picker",
            selection: isRandomColorOn
                ? .constant(Color.gray) : $pickedColor,
            supportsOpacity: true
        )
        .disabled(isRandomColorOn)
    }
}
