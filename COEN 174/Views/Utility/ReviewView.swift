//
//  ReviewView.swift
//  COEN 174
//
//  Created by Gavin Ryder on 2/8/23.
//

import SwiftUI

struct ReviewView: View {
    
    @EnvironmentObject private var vm: ViewModel
    
    let review: Review
    var showsFoodInfo: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if showsFoodInfo, let food = vm.foodFromID(foodId: review.foodId) {
                Text(food.name)
                    .font(.title2.italic())
            }
            if let title = review.title {
                Text(title)
                    .font(.title3)
                    .padding(.vertical, -5)
            }
            RatingView(rating: Double(review.rating), showRatingNum: false)
                .padding(.leading, -15)
                .listRowSeparator(.hidden)
            if let body = review.body {
                Text(body)
                    .font(.system(size: 16, design: .rounded))
            }
            if let relativeDesc = review.relativeDescription {
                Text(relativeDesc)
                    .font(.caption)
                    .foregroundColor(.lightGray)
                    .padding(.top, 1)
            }
            
            if let updatedDesc = review.relativeUpdatedDescription {
                Text("Edited: \(updatedDesc)")
                    .font(.caption)
                    .foregroundColor(.lightGray)
            }
        }
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppBackground()
            ReviewView(review: Review(reviewId: UUID().uuidString, foodId: UUID().uuidString, rating: 4, body: "Lorem ipsum dolor sit amet", title: "Test Review", dateCreated: "02/09/2023, 06:26:54", dateUpdated: "02/09/2023, 20:40:10"))
        }
    }
}
