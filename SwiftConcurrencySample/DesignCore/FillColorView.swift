//
//  FillColorView.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/10.
//

import SwiftUI

struct FillColorView: View {
    let size: CGFloat
    let color: Color
    let type: viewType
    
    init(
        size: CGFloat,
        color: Color,
        type: viewType
    ) {
        self.size = size
        self.color = color
        self.type = type
    }
    
    var body: some View {
        switch type {
        case .circle:
            Rectangle()
                .frame(width: size, height: size, alignment: .center)
                .cornerRadius(size/2)
                .foregroundColor(color)
        case .square:
            Rectangle()
                .frame(width: size, height: size, alignment: .center)
                .cornerRadius(size/5)
                .foregroundColor(color)
        }
    }
             
     enum viewType {
         case circle
         case square
     }
}
