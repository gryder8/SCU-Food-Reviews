//
//  ViewModel.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/31/23.
//

import Foundation
import SwiftUI

class ViewModel: ObservableObject {
    private let model = APIDataModel.shared
    
    private var initiallyFetched = false
    
    private let INIT_ANIM_DURATION = 0.5
    
    @Published var displayData: [Food] = []
    @Published var fetchingData: Bool = false
    @Published var fetchingReviews: Bool = false
    @Published var fetchingUserReviews: Bool = false
    @Published var userReviews: [Review] = []
    @Published var reviewsForCurrentFood: [Review] = []
    
    @Published var errorMessage: String? = nil
    
    static private let errorMessagePersistanceDuration = 3.0
    
    func foodFromID(foodId: String) -> Food? {
        return model.foods.first(where: { food in
            food.foodId == foodId
        })
    }
    
    func queryReviewsForFoodFromServer(with foodId: String, refreshing: Bool = false) async {
        DispatchQueue.main.async { [weak self] in
            self?.fetchingReviews = true
        }
        if let reviews = model.foodReviews[foodId], !refreshing { //utilize run-time cache held by APIModel
            DispatchQueue.main.async {
                self.reviewsForCurrentFood = reviews
            }
            print("Using existing data!")
            return
        }
        
        await model.getReviewsForFood(with: foodId, completion: { [weak self] result in
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
        await model.getUserReviews(for: userId, completion: { result in
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
        await model.updateFood(foodId: foodId, completion: { [weak self] result in
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
        })
    }
    
    func loadReviewsForFood(with foodId: String) {
        DispatchQueue.main.async { [weak self] in
            self?.reviewsForCurrentFood = self?.model.foodReviews[foodId] ?? []
        }
    }
    
    func fetchAllFoods() async {
        await model.getAllFoods(completion: {[weak self] result in
            
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
        guard !model.isFetchingAllFoods, !initiallyFetched else { return }
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
            
        } else if (model.foods.isEmpty && !initiallyFetched) {
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
        return model.foods.sorted(by: {f1, f2 in
            f1.rating > f2.rating
        })
    }
    
    var mealsSortedByName: [Food] {
        return model.foods.sorted(by: {f1, f2 in
            return f1.name < f2.name
        })
    }
    
    var removingNonRatedMeals: [Food] {
        return model.foods.filter({food in
            food.totalReviews > 0
        })
    }
    
    func filteredResults(_ filter: FoodFilter) -> [Food] {
        if (filter == FoodFilter()) { //default filter
            return dataForDisplay
        }
        
        var result = model.foods
        
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
        return model.foods.sorted(by: {f1, f2 in
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
