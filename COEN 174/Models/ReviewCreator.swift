//
//  ReviewCreator.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/31/23.
//

import Foundation

class ReviewCreator {
    
    private let baseURLString = "https://e4d4rr5w80.execute-api.us-west-2.amazonaws.com/Stage/" //append endpoints onto this as needed
    
    //TODO: Make PUT call to endpoint
    //https://www.simpleswiftguide.com/how-to-make-http-put-request-with-json-as-data-in-swift/
    
    func submitReview(rating: Int, text: String, title: String, reviewId: String, foodId: String, completion: @escaping (Result<Int, Error>) -> ()) {
        print("Submitting Review!")
        let apiEndpoint = baseURLString+"putReview"
        let url: URL = URL(string: apiEndpoint)!
        print("Using url: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let jsonDict = generateJSONDictForTransmission(rating: rating, text: text, title: title, reviewId: reviewId, foodId: foodId)
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonDict)
            
            URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
                let result: Result<Int, Error>

                if let error = error {
                    print("Error with POST request: \(error)")
                    completion(.failure(error))
                    return
                }
                
                if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = responseData {
                    guard responseCode == 200 else {
                        print("Invalid response code: \(responseCode)")
                        if responseCode >= 500 {
                            completion(.failure(URLError(.badServerResponse)))
                        } else {
                            completion(.failure(URLError(.badURL)))
                        }
                        return
                    }
                    result = .success(responseCode)
                    completion(result)
                    
                    if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                        print("Response JSON data = \(responseJSONData)")
                    }
                }
            }.resume()
            
        } catch {
            print(error)
            completion(.failure(error))
        }
        
        
        
        
        //on API call success
        //success()
    }
    
    
    /*
     Request: { ‘reviewId’: <optional>String, ‘userId’: String, ‘foodId’: String, ‘rating’: Num, ‘title’: <optional>String, ‘body’: <optional>String }
     */
    private func generateJSONDictForTransmission(rating: Int, text: String, title: String, reviewId: String, foodId: String) -> [String: Any] {
        let userID = "Gavin"
        let dict: [String: Any] = [
            "reviewId":reviewId,
            "userId":userID,
            "foodId":foodId,
            "rating":rating,
            "title":title,
            "body": text
        ]
        return dict
    }
    
    
}
