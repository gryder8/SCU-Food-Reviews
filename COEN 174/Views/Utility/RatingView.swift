//
//  RatingView.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/31/23.
//

import SwiftUI

struct RatingView: View {
    
    let rating: Double
    var showRatingNum: Bool = true
    
    var body: some View {
        HStack (spacing: 0){
            if (showRatingNum) {
                Text(String(format: "(%.2f)", rating))
                    .font(.system(size: 18).italic())
                    .foregroundColor(Color.lightGray)
            }
            FiveStarView(rating: rating)
                .frame(minWidth: 100, idealWidth: 150, maxWidth: 150, minHeight: 30, idealHeight: 40, maxHeight: 40, alignment: .leading)
                .padding(.bottom, -15)
        }
    }
}

struct RatingView_Previews: PreviewProvider {
    static var previews: some View {
        
        ZStack {
            AppBackground()
            RatingView(rating: 3.25)
        }
    }
}
