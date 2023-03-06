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
    
    @Published private(set) var displayData: [Food] = []
    @Published private(set) var foodRec: Food? = nil
    @Published private(set) var fetchingData: Bool = false
    @Published private(set) var fetchingReviews: Bool = false
    @Published private(set) var fetchingFoodRec: Bool = false
    @Published private(set) var fetchingUserReviews: Bool = false
    @Published private(set) var userReviews: [Review] = []
    @Published private(set) var reviewsForCurrentFood: [Review] = []
    @Published private(set) var removingReview: Bool = false
    @Published private(set) var removingFood: Bool = false
    @Published private(set) var errorMessage: String? = nil
    @Published var adminModeEnabled: Bool = false
    
    
    static private let errorMessagePersistanceDuration = 3.0
    private var persistingErrorMessage = false
    
    func testErrorMessage() {
        presentTempErrorMsg("Testing", duration: 10.0)
    }
    
    private func presentPersistentErrorMessage(_ msg: String) {
        DispatchQueue.main.async { [weak self] in
            withAnimation(.easeIn) {
                self?.errorMessage = msg
                self?.persistingErrorMessage = true
            }
        }
    }
    
    private func presentTempErrorMsg(_ msg: String, duration: Double = errorMessagePersistanceDuration) {
        guard self.persistingErrorMessage == false else {
            print("Error message is being persisted, will not be changed.")
            return
        }
        DispatchQueue.main.async { [weak self] in
            withAnimation(.easeIn) {
                self?.errorMessage = msg
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            guard self?.persistingErrorMessage == false else {
                print("Error message is being persisted, will not reset.")
                return
            }
            withAnimation(.easeOut) {
                self?.errorMessage = nil
            }
        }
    }
    
    func foodFromID(foodId: String) -> Food? {
        return apiModel.foods.first(where: { food in
            food.foodId == foodId
        })
    }
    
    var trendingFoods: [Food] {
        print("\(apiModel.trendingFoods.count) foods are trending")
        return apiModel.trendingFoods
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
                self.fetchingReviews = false
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
                self?.presentPersistentErrorMessage("An error occurred, please try again later and check your connection.")
                DispatchQueue.main.async { [weak self] in
                    withAnimation(.easeIn) {
                        self?.fetchingReviews = false
                    }
                }
            }
        })
    }
    
    func loadUserReviewsFromServer(userId: String) async {
        DispatchQueue.main.async {
            withAnimation {
                self.fetchingUserReviews = true
            }
        }
        await apiModel.getUserReviews(for: userId, completion: { result in
            switch (result) {
            case .success(let reviews):
                print("Found \(reviews.count) reviews for the current user")
                DispatchQueue.main.async { [weak self] in
                    withAnimation(.easeIn) {
                        self?.userReviews = reviews
                        self?.fetchingUserReviews = false
                    }
                }
            case .failure(let error):
                print("Getting user reviews failed with error: \(error)")
                self.presentTempErrorMsg("An error occurred getting your reviews. Try again later.")
                DispatchQueue.main.async { [weak self] in
                    withAnimation(.easeIn) {
                        self?.fetchingUserReviews = false
                    }
                }
            }
            
        })
    }
    
    func updateInfoForFood(foodId: String) async {
        await apiModel.updateFood(foodId: foodId) { [weak self] result in
            switch (result) {
            case .success(let food):
                print("Succesfully updated food: \(food)")
                self?.objectWillChange.send()
            case .failure(let error):
                if self?.errorMessage == nil {
                    self?.presentTempErrorMsg("An error occurred updating food info.")
                }
                print("Error updating food: \(error)")
            }
        }
    }
    
    func removeFood(food: Food) async {
        DispatchQueue.main.async {
            self.removingFood = true
        }
        await apiModel.removeFood(foodId: food.foodId) { [weak self] result in
            switch (result) {
            case .success(let code):
                print("Success with code: \(code)")
                DispatchQueue.main.async { [weak self] in
                    withAnimation {
                        self?.displayData.removeAll(where: { foodItem in //remove from local storage
                            food.foodId == foodItem.foodId
                        })
                        self?.removingFood = false
                    }
                }
            case .failure(let error):
                print("Error removing food: \(error)")
                self?.presentTempErrorMsg("Failed to remove food, try again later.")
                DispatchQueue.main.async { [weak self] in
                    self?.removingFood = false
                }
            }
        }
    }
    
    func removeUserReview(reviewId: String) async {
        DispatchQueue.main.async { [weak self] in
            self?.removingReview = true
            self?.userReviews.removeAll(where: { review in //remove from local storage
                review.reviewId == reviewId
            })
            
            
            self?.reviewsForCurrentFood.removeAll { review in
                review.reviewId == reviewId
            }
        }
        await apiModel.removeReview(reviewId: reviewId) { [weak self] result in
            switch (result) {
            case .success(let code):
                print("Success with code: \(code)")
                DispatchQueue.main.async { [weak self] in
                    self?.removingReview = false
                }
            case .failure(let error):
                print("Error removing review: \(error)")
                self?.presentTempErrorMsg("Failed to remove review, try again later.")
                DispatchQueue.main.async { [weak self] in
                    self?.removingReview = false
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
                print("Failed to get foods with error: \(error)")
                self?.presentPersistentErrorMessage("An error occurred, please try again later and check your connection.")
            }
        })
    }
    
    func getFoodRec() async {
        DispatchQueue.main.async { [weak self] in
            self?.fetchingFoodRec = true
        }
        await apiModel.getFoodRec { [weak self] result in
            switch result {
            case .success(let foodRec):
                print("Got food rec of: \(foodRec)")
                DispatchQueue.main.async { [weak self] in
                    guard let foodFromRec = self?.foodFromID(foodId: foodRec.foodId) else {
                        print("***Could not find corresponding food for reccomendation!")
                        return
                    }
                    withAnimation(.easeIn) {
                        self?.foodRec = foodFromRec
                        self?.fetchingFoodRec = false
                    }
                }
            case .failure(let err):
                print("Failed with error: \(err)")
                //self?.presentTempErrorMsg("Error fetching food rec!", duration: 1.0)
                DispatchQueue.main.async { [weak self] in
                    withAnimation(.easeIn) {
                        self?.fetchingFoodRec = false
                    }
                }
            }
        }
    }
    
    
    public init(){}
    
    public func refresh() {
        configDisplayData()
    }
    
    func initialize(_ forceRefresh: Bool = false) {
        guard !apiModel.isFetchingAllFoods, !initiallyFetched else { return }
        if (forceRefresh) { //force refresh
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
    
    func filteredResults(_ filter: FoodFilter, foods: [Food]? = nil) -> [Food] {
        if (filter == FoodFilter()) { //default filter
            return dataForDisplay
        }
        
        var result = [Food]()
        if let foods  {
            result = foods
        } else {
            result = apiModel.foods //all foods
        }
        
        if filter.glutenFree { result.removeAll(where: { food in
            !(food.tags?.contains("Gluten Free") ?? false)
        })
        }
        
        if filter.vegan {
            result.removeAll { food in
                !(food.tags?.contains("Vegan") ?? false)
            }
        }
        
        if filter.trending {
            result.removeAll { food in
                food.isTrendingFood == false
            }
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
        
        if let threshold = filter.maxNumReviews {
            result.removeAll { food in
                food.totalReviews > threshold
            }
        }
        
        if let threshold = filter.maxRating {
            result.removeAll { food in
                food.rating > threshold
            }
        }
        
        if let search = filter.searchQuery {
            result.removeAll(where: { food in
                !food.name.localizedCaseInsensitiveContains(search) && !(food.restaurants?.containsSubstring(search) ?? false)
            })
        }
        
        print("Displaying \(result.count) items")
        
        return result.sorted(by: {f1, f2 in
            f1.rating > f2.rating
        })
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
            print("Found \(self.displayData.count) total food entries")
        }
    }
}
