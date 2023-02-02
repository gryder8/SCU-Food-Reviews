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
    
    @Published var displayData: [Food] = []
    @Published var fetchingData: Bool = false
    
    func fetchAllFoods() async {
        await model.getAllFoods(completion: {[weak self] result in
            
            switch result {
            case .success(let food):
                print("Successful API call! Found \(food.count) foods.")
                self?.configDisplayData()
            case .failure(let error):
                print("Failed with error: \(error)")
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
                fetchingData = true
            }
            Task {
                await fetchAllFoods()
                DispatchQueue.main.async { [self] in
                    fetchingData = false
                }
            }
            
        } else if (model.foods.isEmpty && !initiallyFetched) {
            DispatchQueue.main.async { [self] in
                fetchingData = true
            }
            Task {
                await fetchAllFoods()
                DispatchQueue.main.async { [self] in
                    fetchingData = false
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
    
    private var dataForDisplay: [Food] {
        return removingNonRatedMeals.sorted(by: {f1, f2 in
            f1.rating > f2.rating
        })
    }
    
    private func configDisplayData() {
        DispatchQueue.main.async {
            
            withAnimation(.easeIn(duration: 1)) {
                self.displayData = self.model.foods//self.dataForDisplay
            }
            print("Found \(self.displayData.count) entries suitable for display")
        }
    }
}
