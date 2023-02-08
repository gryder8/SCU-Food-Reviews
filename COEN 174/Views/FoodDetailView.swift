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
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            }
        }
    }
}

struct NewReview: Equatable, Hashable {
    
}

struct FoodDetailView: View {
    
    var food: Food
    @EnvironmentObject private var navModel: NavigationModel
    @EnvironmentObject private var viewModel: ViewModel
    
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
                        .environmentObject(viewModel)
                }
                
                Text(food.totalReviews != 1 ? "\(food.totalReviews) Reviews" : "\(food.totalReviews) Review")
                Text("Reviews")
                    .font(.title)
                    .padding(.top)
                if viewModel.fetchingReviews {
                    HStack {
                        Spacer()
                        LoadingView()
                            .transition(.opacity)
                        Spacer()
                    }
                    .padding(.top)
                } else if (!viewModel.reviewsForCurrentFood.isEmpty) {
                    
                    
                    List(viewModel.reviewsForCurrentFood.sortedByDate()) { review in
                        ReviewView(review: review)
                    }
                    .refreshable {
                        await viewModel.queryReviewsForFoodFromServer(with: food.foodId, refreshing: true)
                    }
                    .listStyle(.inset)
                    .padding(.leading, -20)
                } else {
                    List {
                        Text("Be the first to write a review!")
                            .multilineTextAlignment(.center)
                            .font(.headline)
                            .padding(.top)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    .refreshable {
                        await viewModel.queryReviewsForFoodFromServer(with: food.foodId, refreshing: true)
                    }
                    .listStyle(.inset)
                    .padding(.leading, -20)
                    .scrollContentBackground(.hidden)
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
