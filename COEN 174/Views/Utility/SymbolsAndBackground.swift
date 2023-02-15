//
//  Symbols.swift
//  COEN 174
//
//  Created by Gavin Ryder on 2/14/23.
//

import Foundation
import SwiftUI

struct GFSymbolView: View {
    
    var size:CGFloat = 30
    
    var body: some View {
        HStack(spacing: -5) {
            Image(systemName: "laurel.leading")
            Image(systemName: "laurel.trailing")
        }
        .font(.system(size: size))
        .foregroundColor(Color("Wheat"))
    }
}

struct VeganSymbolView: View {
    
    var size:CGFloat = 30
    
    var body: some View {
        Image(systemName: "leaf")
            .font(.system(size: size))
            .foregroundColor(Color("Fern"))
    }
}

struct AppBackground: View {
    
    var reversed = false
    
    var body: some View {
        LinearGradient(colors: reversed ? [.accentColor.opacity(0.8), .accentColor.opacity(0.65)].reversed() : [.accentColor.opacity(0.8), .accentColor.opacity(0.65)], startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
}


struct CheckboxStyle: ToggleStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        
        return HStack {
            
            configuration.label
            
            Spacer()
            
            Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(configuration.isOn ? .accentColor : .gray)
                .font(.system(size: 20, weight: .bold, design: .default))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        configuration.isOn.toggle()
                    }
                }
        }
        
    }
}
