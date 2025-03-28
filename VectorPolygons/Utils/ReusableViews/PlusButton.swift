//
//  PlusButton.swift
//  GRYMALATestTask
//
//  Created by Michail Malashkevich on 15.03.25.
//

import SwiftUI

struct PlusButton: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var action: () -> Void
    
    private var fontSize: CGFloat {
        horizontalSizeClass == .regular ? 40 : 32
    }
    
    private var padding: CGFloat {
        horizontalSizeClass == .regular ? 15 : 10
    }
    
    private var shadowRadius: CGFloat {
        horizontalSizeClass == .regular ? 15 : 10
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: fontSize))
                .foregroundColor(.white)
                .padding(padding)
                .background(
                    Circle()
                        .fill(Color.orange)
                        .shadow(color: .yellow, radius: shadowRadius)
                )
        }
    }
}

#Preview {
    PlusButton(action: {
        print("hello")
    } )
}

