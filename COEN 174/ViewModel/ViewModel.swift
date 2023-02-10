//
//  ViewModel.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/31/23.
//

import Foundation
import SwiftUI

class ViewModel: ObservableObject {
    private let apiModel = APIDataModel.shared
    
    private var initiallyFetched = false
    
    private let INIT_ANIM_DURATION = 0.5
    
    @Published var displayData: [Food] = []
    @Published var fetchingData: Bool = false
    @Published var fetchingReviews: Bool = false
    @Published var fetchingUserReviews: Bool = false
    @Published var userReviews: [Review] = []
    @Published var reviewsForCurrentFood: [Review] = []
    @Published var removingReview: Bool = false
    
    @Published var errorMessage: String? = nil
    
    static private let errorMessagePersistanceDuration = 3.0
    
    func foodFromID(foodId: String) -> Food? {
        return apiModel.foods.first(where: { food in
            food.foodId == foodId
        })
    }
    
    var userReviewsSortedByMostRecent: [Review] {
        return userReviews.sorted(by: {r1, r2 in
            r1.updatedDate ?? r1.date ?? Date() > r2.updatedDate ?? r2.date ?? Date()
        })
    }
    
    var currentFoodReviewsSortedByMostRecent: [Review] {
        return reviewsForCurrentFood.sorted(by: {r1, r2 in
            r1.updatedDate ?? r1.date ?? Date() > r2.updatedDate ?? r2.date ?? Date()
        })
    }
    
    func queryReviewsForFoodFromServer(with foodId: String, refreshing: Bool = false) async {
        DispatchQueue.main.async { [weak self] in
            self?.fetchingReviews = true
        }
        if let reviews = apiModel.foodReviews[foodId], !refreshing { //utilize run-time cache held by APIModel
            DispatchQueue.main.async {
                self.reviewsForCurrentFood = reviews
            }
            print("Using existing data!")
            return
        }
        
        await apiModel.getReviewsForFood(with: foodId, completion: { [weak self] result in
            switch result {
            case .success(let reviews):
                DispatchQueue.main.async { [weak self] in
                    self?.reviewsForCurrentFood = reviews
                    print("Assigned \(reviews.count) reviews for current food!")
                    self?.errorMessage = nil
                    withAnimation(.easeIn) {
                        self?.fetchingReviews = false
                    }
                }
            case .failure(let error):
                print("Failed with error: \(error)")
                DispatchQueue.main.async { [weak self] in
                    self?.errorMessage = "An error occurred, please try again later and check your connection."
                }
                
            }
        })
    }
    
    func loadUserReviewsFromServer(userId: String) async {
        DispatchQueue.main.async {
            self.fetchingUserReviews = true
        }
        await apiModel.getUserReviews(for: userId, completion: { result in
            switch (result) {
                case .success(let reviews):
                print("Found \(reviews.count) reviews for the current user")
                DispatchQueue.main.async { [weak self] in
                    self?.userReviews = reviews
                    self?.fetchingUserReviews = false
                }
            case .failure(let error):
                print("Getting user reviews failed with error: \(error)")
                DispatchQueue.main.async { [weak self] in
                    self?.errorMessage = "An error occurred getting your reviews. Try again later."
                    self?.fetchingUserReviews = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + ViewModel.errorMessagePersistanceDuration) { [weak self] in
                    self?.errorMessage = nil
                }

            }
            
        })
    }
        
    func updateInfoForFood(foodId: String) async {
        await apiModel.updateFood(foodId: foodId) { [weak self] result in
            switch (result) {
            case .success(let food):
                print("Succesfully updated food: \(food)")
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.errorMessage = "An error occurred updating food info."
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + ViewModel.errorMessagePersistanceDuration) { [weak self] in
                    self?.errorMessage = nil
                }
                print("Error updating food: \(error)")
            }
        }
    }
    
    //TODO: Call
    func removeUserReview(reviewId: String) async {
        DispatchQueue.main.async {
            self.removingReview = true
        }
        await apiModel.removeReview(reviewId: reviewId) { [weak self] result in
            switch (result) {
            case .success(let code):
                print("Success with code: \(code)")
                DispatchQueue.main.async { [weak self] in
                    self?.userReviews.removeAll(where: { review in //remove from local storage
                        review.reviewId == reviewId
                    })
                    self?.removingReview = false
                }
            case .failure(let error):
                print("Error removing review: \(error)")
                DispatchQueue.main.async { [weak self] in
                    self?.errorMessage = "Failed to remove review, try again later."
                    self?.removingReview = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + ViewModel.errorMessagePersistanceDuration) { [weak self] in
                    self?.errorMessage = nil
                }
            }
        }
    }
    
    func loadReviewsForFood(with foodId: String) {
        DispatchQueue.main.async { [weak self] in
            self?.reviewsForCurrentFood = self?.apiModel.foodReviews[foodId] ?? []
        }
    }
    
    func fetchAllFoods() async {
        await apiModel.getAllFoods(completion: {[weak self] result in
            
            switch result {
            case .success(let food):
                print("Successful API call! Found \(food.count) foods.")
                DispatchQueue.main.async { [weak self] in
                    self?.errorMessage = nil
                }
                self?.configDisplayData()
            case .failure(let error):
                print("Failed with error: \(error)")
                DispatchQueue.main.async { [weak self] in
                    self?.errorMessage = "An error occurred, please try again later and check your connection."
                }
            }
        })
    }
    
    
    public init(){}
    
    public func refresh() {
        configDisplayData()
    }
    
    func initialize(_ forceRefresh: Bool = false) {
        guard !apiModel.isFetchingAllFoods, !initiallyFetched else { return }
        if (forceRefresh) {
            DispatchQueue.main.async { [self] in
                withAnimation(.easeInOut) {
                    fetchingData = true
                }
            }
            Task {
                await fetchAllFoods()
                DispatchQueue.main.async { [self] in
                    withAnimation(.linear(duration: INIT_ANIM_DURATION)) {
                        fetchingData = false
                    }
                }
            }
            
        } else if (apiModel.foods.isEmpty && !initiallyFetched) {
            DispatchQueue.main.async { [self] in
                withAnimation(.easeInOut) {
                    fetchingData = true
                }
            }
            Task {
                await fetchAllFoods()
                DispatchQueue.main.async { [self] in
                    withAnimation(.linear(duration: INIT_ANIM_DURATION)) {
                        fetchingData = false
                    }
                }
            }
            initiallyFetched = true
        } else {
            configDisplayData()
        }
        
    }
    
    var mealsSortedByRating: [Food] {
        return apiModel.foods.sorted(by: {f1, f2 in
            f1.rating > f2.rating
        })
    }
    
    var mealsSortedByName: [Food] {
        return apiModel.foods.sorted(by: {f1, f2 in
            return f1.name < f2.name
        })
    }
    
    var removingNonRatedMeals: [Food] {
        return apiModel.foods.filter({food in
            food.totalReviews > 0
        })
    }
    
    func filteredResults(_ filter: FoodFilter) -> [Food] {
        if (filter == FoodFilter()) { //default filter
            return dataForDisplay
        }
        
        var result = apiModel.foods
        
        if filter.glutenFree { result.removeAll(where: { food in
            !(food.tags?.contains("Gluten Free") ?? false)
            })
        }
        
        if filter.vegan { result.removeAll(where: { food in
            !(food.tags?.contains("Vegan") ?? false)
            })
        }
        
        if let threshold = filter.minRating {
            result.removeAll(where: { food in
                food.rating < threshold
            })
        }
        
        if let threshold = filter.minNumReviews {
            result.removeAll(where: { food in
                food.totalReviews < threshold
            })
        }
        
        if let search = filter.searchQuery {
            result.removeAll(where: { food in
                !food.name.localizedCaseInsensitiveContains(search) && !(food.restaurants?.containsSubstring(search) ?? false)
            })
        }
        
        return result
    }
    
    private var dataForDisplay: [Food] {
        return apiModel.foods.sorted(by: {f1, f2 in
            f1.rating > f2.rating
        })
    }
    
    private func configDisplayData() {
        DispatchQueue.main.async {
            
            withAnimation(.easeIn(duration: 1)) {
                self.displayData = self.dataForDisplay//self.dataForDisplay
            }
            print("Found \(self.displayData.count) entries suitable for display")
        }
    }
}
