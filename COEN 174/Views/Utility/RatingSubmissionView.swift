//
//  RatingSubmissionView.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/31/23.
//

import SwiftUI


struct RatingSubmissionView: View {
    @Binding var currentRating: Int?
    var max: Int = 5
    var starSize: CGFloat = 24
    
    private func starType(index: Int) -> String {
        
        if let rating = self.currentRating {
            return index <= rating ? "star.fill" : "star"
        } else {
            return "star"
        }
        
    }
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(1..<(max + 1), id: \.self) { index in
                Image(systemName: self.starType(index: index))
                    .font(.system(size: starSize))
                    .foregroundColor(index <= currentRating ?? 0 ? .yellow : .gray)
                    .onTapGesture {
                        self.currentRating = index
                    }
            }
        }
    }
    
}

struct RatingSubmissionView_Previews: PreviewProvider {
    @State static var curr: Int? = 3
    static var previews: some View {
        RatingSubmissionView(currentRating: $curr)
    }
}
