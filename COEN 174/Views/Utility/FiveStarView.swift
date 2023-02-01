//
//  StarsView.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/24/23.
//

import SwiftUI
import StarRating


public struct FiveStarView: View {
    var rating: Double
    var color: Color = .yellow
    
    @State private var config: StarRatingConfiguration = StarRatingConfiguration(spacing: 5, numberOfStars: 5, borderWidth: 0, emptyColor: .gray, shadowColor: .clear, fillColors: [.yellow])
    
    
    public var body: some View {
        StarRating(initialRating: rating, configuration: $config)
    }
}


struct FiveStarView_Previews: PreviewProvider {


    static var previews: some View {
        FiveStarView(rating: 3.8)
            .frame(width: 300, height: 50)
    }
}

