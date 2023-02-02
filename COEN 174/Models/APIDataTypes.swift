//
//  APIDataTypes.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/24/23.
//

import Foundation

struct AllFoodResult: Codable {
    let foods: [Food]
}

struct Food: Codable, Identifiable, Hashable {
    
    var foodId: String
    var id: String {
        return foodId
    }
    let name: String
    let rating: Double
    let totalReviews: Int
    private let current: String
    private let trending: String
    private let featured: String
    
    var isCurrentFood: Bool {
        return current != "F"
    }
    
    var isTrendingFood: Bool {
        return trending != "F"
    }
    
    var isFeaturedFood: Bool {
        return featured != "F"
    }
    
    
    var reviews: [Review] = []
    
    enum CodingKeys: String, CodingKey {
            case totalReviews, current, rating, name, featured
            case foodId
            case trending
    }
}

struct Review: Identifiable, Hashable, Codable {
    let reviewId: String
    var id: String {
        return reviewId
    }
    let foodId: String
    let rating: Int
    let body: String?
    let title: String?
    let dateCreated: String
}

struct ReviewsResponse: Codable {
    let reviews: [Review]
}
