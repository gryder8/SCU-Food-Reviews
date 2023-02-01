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
    
    func submitReview(rating: Int, text: String, title: String, reviewId: String, foodId: String, success: @escaping () -> ()) {
        print("Submitting Review!")
        let apiEndpoint = baseURLString+"putReview"
        let url: URL = URL(string: apiEndpoint)!
        
        
        //on API call success
        success()
    }
}
