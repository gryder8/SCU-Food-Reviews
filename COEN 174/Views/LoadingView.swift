//
//  LoadingView.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/31/23.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.gray.opacity(0.4))
            ProgressView {
                Text("Loading...")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 12, design: .rounded))
                
            }
            .scaleEffect(1.5)
        }
        .frame(width: 120, height: 120)
        .fixedSize()
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
