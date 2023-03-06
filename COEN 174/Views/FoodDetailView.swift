//
//  FoodDetailView.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/31/23.
//

import SwiftUI


struct NewReview: Equatable, Hashable {}

struct FoodDetailView: View {
    
    @State var food: Food
    @State private var showsErrorAlert: Bool = false
    @State private var capturedErrorMsg: String = ""
    @EnvironmentObject private var navModel: NavigationModel
    @EnvironmentObject private var viewModel: ViewModel
    @EnvironmentObject private var authModel: UserAuthModel
    
    init(food: Food) {
        self.food = food
    }
    
    var body: some View {
        ZStack {
            AppBackground()
                .edgesIgnoringSafeArea(.all)
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
                    
                    
                    Text(food.totalReviews != 1 ? "\(food.totalReviews) Reviews" : "\(food.totalReviews) Review")
//                    if let msg = viewModel.errorMessage {
//                        Text(msg)
//                            .foregroundColor(.red)
//                            .multilineTextAlignment(.leading)
//                            .font(.caption.italic())
//                    }
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
                        List(viewModel.currentFoodReviewsSortedByMostRecent) { review in
                            ReviewView(review: review)
                                .environmentObject(viewModel)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions {
                                    if (viewModel.adminModeEnabled) {
                                        Button(role: .destructive) {
                                            print("Delete review selected!")
                                            Task {
                                                await viewModel.removeUserReview(reviewId: review.reviewId)
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash.fill")
                                        }
                                    }
                                }
                        }
                        .refreshable {
                            await viewModel.queryReviewsForFoodFromServer(with: food.foodId, refreshing: true)
                        }
                        .listStyle(.inset)
                        .padding(.leading, -20)
                        .scrollContentBackground(.hidden)
                    } else if let _ = viewModel.errorMessage {
                        List {
                            HStack {
                                Spacer()
                                Text("An error occurred, pull down to refresh and try again")
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .font(.headline)
                                    .padding(.top, 5)
                                    
                                Spacer()
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            
                        }
                        .refreshable {
                            await viewModel.queryReviewsForFoodFromServer(with: food.foodId, refreshing: true)
                        }
                        .listStyle(.inset)
                        .padding(.leading, -20)
                        .scrollContentBackground(.hidden)
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
        .navigationDestination(for: NewReview.self) { _ in
            NewReviewView(food: self.food)
                .environmentObject(navModel)
                .environmentObject(viewModel)
                .environmentObject(authModel)
        }
        .onChange(of: viewModel.errorMessage) { val in
            guard let msg = val else { return }
            showsErrorAlert = true
            capturedErrorMsg = msg
        }
        .alert(isPresented: $showsErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(capturedErrorMsg)
            )
        }
        .onAppear {
            if let upToDateFood = viewModel.foodFromID(foodId: food.foodId) {
                self.food = upToDateFood
            }
            if let msg = viewModel.errorMessage {
                showsErrorAlert = true
                capturedErrorMsg = msg
            }
        }
    }
    
}

//struct FoodDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        FoodDetailView(food: Food(name: "Test", rating: 4.0, totalReviews: 8))
//    }
//}
