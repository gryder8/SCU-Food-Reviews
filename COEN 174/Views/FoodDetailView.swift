//
//  FoodDetailView.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/31/23.
//

import SwiftUI

private struct ReviewView: View {
    
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading) {
            RatingView(rating: review.rating, showRatingNum: false)
                .padding(.leading, -15)
                .listRowSeparator(.hidden)
            Text(review.text)
                .font(.system(size: 16, design: .rounded))
        }
    }
}

struct NewReview: Equatable, Hashable {
    
}

struct FoodDetailView: View {
    
    var food: Food
    @EnvironmentObject private var navModel: NavigationModel
    
    var body: some View {
        HStack {
            VStack (alignment: .leading, spacing: 5) {
                //Text(food.name)
                //.font(.largeTitle)
                HStack {
                    RatingView(rating: food.rating)
                    Spacer()
                    Button {
                        navModel.navPath.append(NewReview())
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 24))
                    }
                    .padding(.trailing, 10)
                }
                .navigationDestination(for: NewReview.self) { _ in
                    NewReviewView(food: self.food)
                        .environmentObject(navModel)
                }
                
                
                Text(food.totalReviews != 1 ? "\(food.totalReviews) Reviews" : "\(food.totalReviews) Review")
                
                if (food.totalReviews > 0) {
                    Text("Reviews")
                        .font(.title)
                        .padding(.top)
                    
                    List(food.reviews) { review in
                        ReviewView(review: review)
                    }
                    .listStyle(.inset)
                    .padding(.leading, -20)
                } else {
                    Text("Be the first to write a review!")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .padding(.top)
                }
                
                Spacer()
            }
            .padding(.leading, 15)
            .navigationTitle(food.name)
        }
        Spacer()
    }
}

//struct FoodDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        FoodDetailView(food: Food(name: "Test", rating: 4.0, totalReviews: 8))
//    }
//}
