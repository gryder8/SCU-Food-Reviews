//
//  APIDataTypes.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/24/23.
//

import Foundation

struct FoodsResult: Codable {
    let foods: [Food]
}

struct Food: Codable, Identifiable, Hashable, CustomStringConvertible {
    
    ///For gettign a more readable desc for debugging in console
    var description: String {
        var desc = "\n🍔 \(name): \(rating)/5; \(totalReviews) reviews"
        if let tags {
            desc.append("\ntags: \(tags)")
        }
        if let restaurants {
            desc.append("\nrestaurants: \(restaurants)")
        }
        return desc
    }
    
    
    var foodId: String
    var id: String {
        return foodId
    }
    let name: String
    var rating: Double
    var totalReviews: Int
    private let current: String
    private let trending: String
    private let featured: String
    let tags: [String]?
    let restaurants: [String]?
    
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
        case tags, restaurants
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
    let dateUpdated: String?
    
    
    var date: Date? {
        return dateFromAPIDateString(dateCreated)
    }
    
    var updatedDate: Date? {
        guard let dateUpdated else { return nil }
        return dateFromAPIDateString(dateUpdated)
    }
    
    var relativeDescription: String? {
        return date?.formattedForUIDisplay()
    }
    
    var relativeUpdatedDescription: String? {
        return updatedDate?.formattedForUIDisplay()
    }
}

struct ReviewsResponse: Codable {
    let reviews: [Review]
}

struct GetFoodResponse: Codable {
    let food: Food
}
