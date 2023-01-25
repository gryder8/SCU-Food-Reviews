//
//  APIDataTypes.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/24/23.
//

import Foundation


struct Food: Codable, Identifiable, Hashable {
    var id: UUID {
        return UUID()
    }
    let name: String
    let rating: Double
}
