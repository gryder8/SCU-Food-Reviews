//
//  MealHomeViewCell.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/24/23.
//

import SwiftUI

struct MealHomeViewCell: View {
    
    let food: Food
    
    var body: some View {
        VStack (alignment: .center){
            Text(food.name)
                .font(.title)
                .multilineTextAlignment(.leading)
                .padding(.leading, 0)
            HStack (spacing: 0){
                Text(String(format: "(%.2f)", food.rating))
                    .font(.system(size: 18).italic())
                    .foregroundColor(.gray)
                    //.padding(.bottom, 18)
                FiveStarView(rating: food.rating)
                    .frame(minWidth: 100, idealWidth: 150, maxWidth: 150, minHeight: 30, idealHeight: 40, maxHeight: 40, alignment: .leading)
                    .padding(.bottom, -15)
            }
            .padding(.horizontal, 30)
            
        }
        .padding(.vertical, 15)
        .background(.ultraThickMaterial)
        .cornerRadius(10)
    }
}

struct MealHomeViewCell_Previews: PreviewProvider {
    static var previews: some View {
        MealHomeViewCell(food: Food(name: "Test", rating: 4.25))
    }
}
