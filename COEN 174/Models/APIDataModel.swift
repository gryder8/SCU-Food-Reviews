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
    @Published var userReviews: [Review] = []

    
    func updateFood(foodId: String, completion: @escaping (Result<Food, Error>) -> ()) async {
        let urlEndpointString = baseURLString+"getFood"
        let url: URL = URL(string: urlEndpointString)!
        
        print("Using URL: \(url) with foodID: \(foodId)")
        var request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData)
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
                //let result: Result<[Review], Error>
                
                if let error = error {
                    print("Error with POST request: \(error)")
                    completion(.failure(error))
                    return
                }
                
                if let responseCode = (response as? HTTPURLResponse)?.statusCode {
                    guard responseCode == 200 else {
                        print("Invalid response code for updating food: \(responseCode) with id: \(foodId)")
                        print("Using url: \(url)")
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
                    print("Response JSON data for updating food = \n\(responseJSONData)")
                }
                
                ///Try decoding data
                do {
                    let updateFoodResponse: GetFoodResponse = try JSONDecoder().decode(GetFoodResponse.self, from: responseData)
                    let updatedFood = updateFoodResponse.food
                    print("Got updated food: \(updatedFood)")
                    DispatchQueue.main.async { [weak self] in
                        //remove and replace
                        self?.foods.removeAll(where: { food in
                            food.foodId == updatedFood.foodId
                        })

                        self?.foods.append(updatedFood)
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
    
    func getAllFoods(completion: @escaping (Result<[Food], Error>) -> ()) async {
        let urlEndpointString = baseURLString+"getAllFood"
        let url: URL = URL(string: urlEndpointString)!
        
        do {
            isFetchingAllFoods = true
            let (resultData, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 else {
                    print("***Error: Status \(httpResponse.statusCode) from \(url)")
                    
                    isFetchingAllFoods = false
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }
            }
            
            let allFood: AllFoodResult = try JSONDecoder().decode(AllFoodResult.self, from: resultData)
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
                
                if let error = error {
                    print("Error with POST request: \(error)")
                    completion(.failure(error))
                    return
                }
                
                if let responseCode = (response as? HTTPURLResponse)?.statusCode {
                    guard responseCode == 200 else {
                        print("Invalid response code for get reviews for user: \(responseCode) with id: \(userId)")
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
                    let allReviewsForUser: ReviewsResponse = try JSONDecoder().decode(ReviewsResponse.self, from: responseData)
                    print("All Reviews:\n\(allReviewsForUser)")
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
                
                if let error = error {
                    print("Error with POST request: \(error)")
                    completion(.failure(error))
                    return
                }
                
                if let responseCode = (response as? HTTPURLResponse)?.statusCode {
                    guard responseCode == 200 else {
                        print("Invalid response code to remove review with id: \(reviewId): Code \(responseCode)")
                        if responseCode >= 500 {
                            completion(.failure(URLError(.badServerResponse)))
                        } else {
                            completion(.failure(URLError(.badURL)))
                        }
                        return
                    }
                    
                    completion(.success(responseCode))
                }
            }.resume()
            
        } catch {
            print(error)
            completion(.failure(error))
        }
    }
}
