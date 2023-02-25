//
//  MealHomeViewCell.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/24/23.
//

import Foundation
import SwiftUI

struct MealHomeViewCell: View {
    
    let food: Food
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    var body: some View {
        VStack (alignment: .center, spacing: 5){
            Text(food.name)
                .font(.title)
                .multilineTextAlignment(.leading)
                .padding(.leading, 0)
                .foregroundColor(.whiteBlack)
            HStack (spacing: 0){
                Text(String(format: "(%.1f)", food.rating))
                    .font(.system(size: 18).italic())
                    .foregroundColor(.gray)
                FiveStarView(rating: food.rating)
                    .frame(minWidth: 100, idealWidth: 150, maxWidth: 150, minHeight: 30, idealHeight: 40, maxHeight: 40, alignment: .leading)
                    .padding(.bottom, -15)
            }
            .padding(.horizontal, 30)
            if let restaurants = food.restaurants {
                Text(commaSeparatedListFromStringArray(restaurants))
                    .font(.body)
            }
            if let tags = food.tags {
                HStack(alignment: .center, spacing: 0) {
                    if tags.contains("Vegan") {
                        VeganSymbolView(size: 20)
                    }
                    
                    if tags.contains("Gluten Free") {
                        GFSymbolView(size: 20)
                    }
                    
                }
            }
            
        }
        .frame(minWidth: 250, idealWidth: 300, maxWidth: 350)
        .padding(EdgeInsets(top: 15, leading: -10, bottom: 15, trailing: -10))
        .background(Color.white.opacity(0.45))
        .cornerRadius(20)
        
    }
}

//struct MealHomeViewCell_Previews: PreviewProvider {
//    static var previews: some View {
//        MealHomeViewCell(food: Food(name: "Test", rating: 4.25, totalReviews: 5))
//    }
//}
