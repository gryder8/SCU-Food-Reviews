//
//  APIDataModel.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/24/23.
//

import Foundation
import SwiftUI

class APIDataModel: ObservableObject {
    
    //MARK: - Singleton Config
    private init() {}
    static let shared = APIDataModel()
    
    //MARK: - Loading States
    var isFetchingAllFoods = false
    var isFetchingReview = false
    
    //MARK: - Published Fields
    @Published private(set) var foods: [Food] = [Food]()
    //@Published private(set) var trendingFoods: [Food] = [Food]()
    
    ///foodId: [Review]
    @Published private(set) var foodReviews: [String : [Review]] = [:]
    @Published private(set) var userReviews: [Review]? = nil
    @Published private(set) var foodRec: FoodRec? = nil
    
    var trendingFoods: [Food] {
        return self.foods.filter { food in
            food.isTrendingFood
        }
    }
    
    private func handleResponse<ResultType>(_ error: Error?, _ response: URLResponse?, _ completion: (Result<ResultType, Error>) -> (), logAction: @autoclosure () -> (), finalActions: (() -> Void)? = nil) {
        if let error {
            print("Error with POST request: \(error)")
            completion(.failure(error))
            return
        }
        
        if let responseCode = (response as? HTTPURLResponse)?.statusCode {
            guard responseCode == 200 else {
                logAction()
                print("***Error Code: \(responseCode)")
                if responseCode >= 500 {
                    completion(.failure(URLError(.badServerResponse)))
                } else {
                    completion(.failure(URLError(.badURL)))
                }
                return
            }
        }
        
        if let finalActions {
            finalActions()
        }
    }
    
    //MARK: - API Call Functions
    func updateFood(foodId: String, completion: @escaping (Result<Food, Error>) -> ()) async {
        let urlEndpointString = baseURLString+"getFood"
        let url: URL = URL(string: urlEndpointString)!
        
        print("Using URL: \(url) with foodID: \(foodId)")
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData) //ignore the caches, force us to get the most recent data from the server
        request.httpMethod = "POST"
        
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let jsonDict:[String:Any] = [
            "foodId": foodId
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonDict)
                        
            URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
                
                self.handleResponse(error, response, completion, logAction: print("Invalid response code for updating food with id: \(foodId) using URL: \(url)"))
                
                guard let responseData else { return }
                
                if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                    print("Response JSON data for updating food = \n\(responseJSONData)")
                }
                
                ///Try decoding data
                do {
                    let updateFoodResponse: GetFoodResponse = try JSONDecoder().decode(GetFoodResponse.self, from: responseData)
                    let updatedFood = updateFoodResponse.food
                    print("Got updated food: \(updatedFood)")
                    DispatchQueue.main.async { [weak self] in
                        //remove and replace
                        withAnimation {
                            self?.foods.removeAll(where: { food in
                                food.foodId == updatedFood.foodId
                            })
                            
                            self?.foods.append(updatedFood)
                        }
                        self?.objectWillChange.send()
                        completion(.success(updatedFood))
                        print("Newest food info: \(updatedFood)")
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
    

    
    func getAllFoods(forceRefresh: Bool = false, completion: @escaping (Result<[Food], Error>) -> ()) async {
        let urlEndpointString = baseURLString+"getAllFood"
        let url: URL = URL(string: urlEndpointString)!
        
        do {
            isFetchingAllFoods = true
            let (resultData, response) = try await URLSession.shared.data(from: url)
            self.handleResponse(nil, response, completion, logAction: print("***Error: Bad status code from \(url)"))
            
            let allFood: FoodsResult = try JSONDecoder().decode(FoodsResult.self, from: resultData)
            print(allFood)
            DispatchQueue.main.async {
                self.foods = allFood.foods //UPDATE FOODS!

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
    
    func getFoodRec(completion: @escaping (Result<FoodRec, Error>) -> ()) async {
        let urlEndpointString = baseURLString+"getFoodRec"
        let url: URL = URL(string: urlEndpointString)!
        
        do {
            isFetchingAllFoods = true
            let (resultData, response) = try await URLSession.shared.data(from: url)
            
            self.handleResponse(nil, response, completion, logAction: print("***Error: Bad status code from \(url)"))
            
            let foodRec: FoodRecResponse = try JSONDecoder().decode(FoodRecResponse.self, from: resultData)
            print(foodRec)
            DispatchQueue.main.async {
                self.foodRec = foodRec.food //UPDATE FOOD!
                completion(.success(foodRec.food))
                print("Foods rec is now: \(foodRec.food)")
            }
        } catch {
            if let err = error as? URLError {
                print("API call failed!\n\(error)")
                completion(.failure(err))
            } else {
                print("Decoding failed!\n\(error)")
                completion(.failure(error))
            }
                
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
                self.handleResponse(error, response, completion, logAction: print("Invalid response code for get reviews for food with id: \(foodID)"))
                
                guard let responseData = responseData else { return }
                
//                if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
//                    print("Response JSON data = \n\(responseJSONData)")
//                }
                
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
    
    func getUserReviews(for userId: String, completion: @escaping (Result<[Review], Error>) -> ()) async {
        let urlEndpointString = baseURLString+"getReviewsByUser"
        let endpointURL: URL = URL(string: urlEndpointString)!
        print("Using URL: \(endpointURL) with userId: \(userId) to get reviews for current user")
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let jsonDict:[String:Any] = [
            "userId": userId
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonDict)
                        
            URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
                
                self.handleResponse(error, response, completion, logAction: print("Invalid response code for get reviews for user with id: \(userId)"))
                
                guard let responseData = responseData else { return }
                
//                if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
//                    print("Response JSON data = \n\(responseJSONData)")
//                }
                
                ///Try decoding data
                do {
                    let allReviewsForUser: ReviewsResponse = try JSONDecoder().decode(ReviewsResponse.self, from: responseData)
                    //print("All Reviews:\n\(allReviewsForUser)")
                    DispatchQueue.main.async { [weak self] in
                        self?.userReviews = allReviewsForUser.reviews
                    }
                    completion(.success(allReviewsForUser.reviews))
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
    
    /*
     Endpoint: removeReview
     Type: POST
     Request: { ‘reviewId’: String }
     */
    func removeReview(reviewId: String, completion: @escaping (Result<Int, Error>) -> ()) async {
        let urlEndpointString = baseURLString+"removeReview"
        let endpointURL: URL = URL(string: urlEndpointString)!
        print("Using URL: \(endpointURL) to remove review with id: \(reviewId)")
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let jsonDict:[String:Any] = [
            "reviewId": reviewId
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonDict)
                        
            URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
                
                self.handleResponse(error, response, completion, logAction: print("Invalid response code to remove review with id: \(reviewId)")) {
                    completion(.success(200))
                }
            }.resume()
            
        } catch {
            print(error)
            completion(.failure(error))
        }
    }
    
    /*
     Endpoint: removeFood
     Type: POST
     Request: { ‘foodId’: String }
     Response: {}
     */
    func removeFood(foodId: String, completion: @escaping (Result<Int, Error>) -> ()) async {
        let urlEndpointString = baseURLString+"removeFood"
        let endpointURL: URL = URL(string: urlEndpointString)!
        print("Using URL: \(endpointURL) to remove food with id: \(foodId)")
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let jsonDict:[String:Any] = [
            "foodId": foodId
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonDict)
                        
            URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
                
                self.handleResponse(error, response, completion, logAction: print("Invalid response code to remove food with id: \(foodId)")) {
                    completion(.success(200))
                    DispatchQueue.main.async {
                        withAnimation {
                            self.foods.removeAll(where: {food in
                                food.foodId == foodId
                            })
                        }
                    }
                }
            }.resume()
            
        } catch {
            print(error)
            completion(.failure(error))
        }
    }
}
