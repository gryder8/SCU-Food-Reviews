//
//  ReviewCreator.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/31/23.
//

import Foundation

class ReviewAndFoodCreator: ObservableObject {
    
        
    @Published var submittingReview: Bool = false
    @Published var submittingFood: Bool = false
    
    func submitReview(rating: Int, text: String, title: String, reviewId: String, foodId: String, userId: String, completion: @escaping (Result<Int, Error>) -> ()) {
        print("Submitting Review!")
        
        DispatchQueue.main.async {
            self.submittingReview = true
        }
        
        let apiEndpoint = baseURLString+"putReview"
        let url: URL = URL(string: apiEndpoint)!
        print("Using url: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let jsonDict = generateJSONDictForReviewTransmission(rating: rating, text: text, title: title, reviewId: reviewId, foodId: foodId, userId: userId)
        
        
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonDict)
            
            print("Beginning transmission of review by user with id: \(userId)")
            URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
                let result: Result<Int, Error>
                
                if let error = error {
                    print("Error with POST request: \(error)")
                    completion(.failure(error))
                    return
                }
                
                if let responseCode = (response as? HTTPURLResponse)?.statusCode, let _ = responseData {
                    guard responseCode == 200 else {
                        print("Invalid response code: \(responseCode)")
                        if responseCode >= 500 {
                            completion(.failure(URLError(.badServerResponse)))
                        } else {
                            completion(.failure(URLError(.badURL)))
                        }
                        DispatchQueue.main.async {
                            self.submittingReview = false
                        }
                        return
                    }
                    result = .success(responseCode)
                    completion(result)
                    DispatchQueue.main.async {
                        self.submittingReview = false
                    }
                }
            }.resume()
            
        } catch {
            print(error)
            completion(.failure(error))
            DispatchQueue.main.async {
                self.submittingReview = false
            }
        }
    }
    
    
    /*
     Endpoint: putFood
     Type: PUT
     Request: { ‘foodId’: <optional>String, ‘featured’: <optional>String(‘T’,’F’), ‘current’: <optional>String(‘T’,’F’), ‘name’: String, ‘restaurants’: <optional><array>[String], ‘tags’: <optional><array>[String] }
     */
    func submitFood(foodId: String, name: String, restaurants: [String]?, tags: [String]?, completion: @escaping (Result<Int, Error>) -> ()) {
        DispatchQueue.main.async {
            self.submittingFood = true
        }
        
        let apiEndpoint = baseURLString+"putFood"
        let url: URL = URL(string: apiEndpoint)!
        print("Using url: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let jsonDict = generateJSONDictForFoodTransmission(foodId: foodId, name: name, restaurants: restaurants, tags: tags)
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonDict)
            if let payloadJSONData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                print("Payload JSON data = \(payloadJSONData)")
            }
            
            
            URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
                let result: Result<Int, Error>
                
                if let error = error {
                    print("Error with PUT request: \(error)")
                    completion(.failure(error))
                    return
                }
                
                if let responseCode = (response as? HTTPURLResponse)?.statusCode, let _ = responseData {
                    guard responseCode == 200 else {
                        print("Invalid response code: \(responseCode)")
                        if responseCode >= 500 {
                            completion(.failure(URLError(.badServerResponse)))
                        } else {
                            completion(.failure(URLError(.badURL)))
                        }
                        DispatchQueue.main.async {
                            self.submittingFood = false
                        }
                        return
                    }
                    result = .success(responseCode)
                    completion(result)
                    DispatchQueue.main.async {
                        self.submittingFood = false
                    }
                }
            }.resume()
            
        } catch {
            print(error)
            completion(.failure(error))
            DispatchQueue.main.async {
                self.submittingFood = false
            }
        }
        
        
    }
    
    
    /*
     Request: { ‘reviewId’: <optional>String, ‘userId’: String, ‘foodId’: String, ‘rating’: Num, ‘title’: <optional>String, ‘body’: <optional>String }
     */
    private func generateJSONDictForReviewTransmission(rating: Int, text: String, title: String, reviewId: String, foodId: String, userId: String) -> [String: Any] {
        //let userID = "Gavin"
        let dict: [String: Any] = [
            //"reviewId":reviewId,
            "userId":userId,
            "foodId":foodId,
            "rating":rating,
            "title":title,
            "body": text
        ]
        print("Generated dict of \(dict.keys.count) keys for transmission")
        return dict
    }
    
    private func generateJSONDictForFoodTransmission(foodId: String, name: String, restaurants: [String]?, tags: [String]?) -> [String: Any] {
        var dict: [String: Any] = [
            //"foodId": foodId,
            "name": name
        ]
        if let restaurants {
            dict["restaurants"] = restaurants
        }
        if let tags {
            dict["tags"] = tags
        }
        print("Generated dict of \(dict.keys.count) keys for transmission")
        
        return dict
    }
    
    
}
