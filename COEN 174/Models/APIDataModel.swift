//
//  APIDataModel.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/24/23.
//

import Foundation

class APIDataModel: ObservableObject {
    
    //MARK: - Singleton Config
    private init() {
//        Task.init {
//            print("Fetching all foods from API...")
//            await self.getAllFoods()
//            print("All foods fetched!")
//        }
    }
    static let shared = APIDataModel()
    
    public var isFetchingAllFoods = false
    
    //MARK: - Published Fields
    @Published var foods: [Food] = [Food]()
    
    //TODO: This belongs in ViewModel

    
    //MARK: - API Base URL
    private let baseURLString = "https://e4d4rr5w80.execute-api.us-west-2.amazonaws.com/Stage/" //append endpoints onto this as needed
    
//    public func useTestData() {
//        let food1 = Food(name: "Breakfast Burrito", rating: 4.5, totalReviews: 5)
//        let food2 = Food(name: "Ramen", rating: 1, totalReviews: 8)
//        let food3 = Food(name: "Acai Bowl", rating: 5, totalReviews: 3)
//        let food4 = Food(name: "DNS", rating: 0.0, totalReviews: 0)
//        DispatchQueue.main.async {
//            self.meals = [food1, food2, food3, food4]
//        }
//    }
    
    func getAllFoods(success: @escaping (_ result: [Food]) -> ()) async {
        let urlEndpointString = baseURLString+"getAllFood"
        let url: URL = URL(string: urlEndpointString)!
        
        do {
            isFetchingAllFoods = true
            let (resultData, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 else {
                    print("***Error: Status \(httpResponse.statusCode)")
                    isFetchingAllFoods = false
                    return
                }
            }
            
            let allFood: AllFoodResult = try JSONDecoder().decode(AllFoodResult.self, from: resultData)
            print(allFood)
            DispatchQueue.main.async {
                self.foods = allFood.foods
                success(allFood.foods)
                print("Foods now has \(self.foods.count) entries")
            }
            isFetchingAllFoods = false
            
        } catch {
            print("API call or decoding failed!\n\(error)")
            isFetchingAllFoods = false
        }
        
    }
    

    
    
}
