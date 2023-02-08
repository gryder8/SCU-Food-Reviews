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
    
    var isFetchingAllFoods = false
    var isFetchingReview = false
    
    //MARK: - Published Fields
    @Published var foods: [Food] = [Food]()
    
    ///foodId: [Review]
    @Published var foodReviews: [String : [Review]] = [:]
    
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
    
    func getAllFoods(completion: @escaping (Result<[Food], Error>) -> ()) async {
        let urlEndpointString = baseURLString+"getAllFood"
        let url: URL = URL(string: urlEndpointString)!
        
        do {
            isFetchingAllFoods = true
            let (resultData, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 else {
                    print("***Error: Status \(httpResponse.statusCode)")
                    isFetchingAllFoods = false
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }
            }
            
            let allFood: AllFoodResult = try JSONDecoder().decode(AllFoodResult.self, from: resultData)
            print(allFood)
            DispatchQueue.main.async {
                self.foods = allFood.foods
                completion(.success(allFood.foods))
                print("Foods now has \(self.foods.count) entries")
            }
            isFetchingAllFoods = false
            
        } catch {
            if let err = error as? URLError {
                print("API call failed!\n\(error)")
                completion(.failure(err))
            } else {
                print("Decoding failed!\n\(error)")
                completion(.failure(error))
            }
            isFetchingAllFoods = false
                
        }
    }
    
    
    func getReviewsForFood(with foodID: String, completion: @escaping (Result<[Review], Error>) -> ()) async {
        let urlEndpointString = baseURLString+"getReviewsByFood"
        let endpointURL: URL = URL(string: urlEndpointString)!
        print("Using URL: \(endpointURL) with foodID: \(foodID)")
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let jsonDict:[String:Any] = [
            "foodId": foodID
        ]
        
        ///Try requesting data from the server
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonDict)
                        
            URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
                //let result: Result<[Review], Error>
                
                if let error = error {
                    print("Error with POST request: \(error)")
                    completion(.failure(error))
                    return
                }
                
                if let responseCode = (response as? HTTPURLResponse)?.statusCode {
                    guard responseCode == 200 else {
                        print("Invalid response code for get reviews for food: \(responseCode) with id: \(foodID)")
                        if responseCode >= 500 {
                            completion(.failure(URLError(.badServerResponse)))
                        } else {
                            completion(.failure(URLError(.badURL)))
                        }
                        return
                    }
                }
                
                guard let responseData = responseData else { return }
                
                if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                    print("Response JSON data = \n\(responseJSONData)")
                }
                
                ///Try decoding data
                do {
                    let allReviewsForFood: ReviewsResponse = try JSONDecoder().decode(ReviewsResponse.self, from: responseData)
                    print(allReviewsForFood)
                    DispatchQueue.main.async { [weak self] in
                        self?.foodReviews[foodID] = allReviewsForFood.reviews
                        completion(.success(allReviewsForFood.reviews))
                        print("Found \(allReviewsForFood.reviews.count) reviews for foodId: \(foodID)")
                    }
                } catch {
                    print(error)
                    completion(.failure(error))
                }
            }.resume()
            
        } catch {
            print(error)
            completion(.failure(error))
        }
    }
}
