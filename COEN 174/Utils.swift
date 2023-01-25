//
//  Utils.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/24/23.
//

import Foundation

extension Date {
    var descriptionString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: self)
    }
}
