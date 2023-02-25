//
//  FoodFilter.swift
//  COEN 174
//
//  Created by Gavin Ryder on 2/7/23.
//

import Foundation
import SwiftUI

struct FoodFilter: Equatable {
    var vegan: Bool = false
    var glutenFree: Bool = false
    var trending: Bool = false
    var minRating: Double?
    var minNumReviews: Int?
    var maxNumReviews: Int?
    var maxRating: Double?
    var searchQuery: String?
}
