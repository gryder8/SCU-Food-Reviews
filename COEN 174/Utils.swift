//
//  Utils.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/24/23.
//

import Foundation
import SwiftUI

extension Date {
    var descriptionString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: self)
    }
}

struct AppBackground: View {
    var body: some View {
        LinearGradient(colors: [.accentColor.opacity(0.8), .accentColor.opacity(0.25)], startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
    }
}

public func dateFromAPIDateString(_ dateString: String) -> Date? {
    let dateFormatter = DateFormatter()
    
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone.autoupdatingCurrent
    dateFormatter.dateFormat = "MM/dd/yyyy, HH:mm:ss"
    
    
    guard let parsedDate = dateFormatter.date(from: dateString) else {
        print("Error occured parsing date from string: \(dateString)")
        return nil
    }
    
    return parsedDate
}

extension Date {
    //self represents the date the review was made
    public func formattedForUIDisplay() -> String {
        
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        
        //let currDate = Date()
        
        //let dateDiff:TimeInterval = currDate.timeIntervalSince(self)
        
        let currDateInGMT = Date().addingTimeInterval(-1.0 * Double(TimeZone.current.secondsFromGMT()))
        return formatter.localizedString(for: self, relativeTo: currDateInGMT)
    }
}

extension Array where Element == Review {
    func sortedByDate() -> [Review] {
        var copy = self
        copy.sort(by: {r1, r2 in
            guard let d1 = r1.date, let d2 = r2.date else { return false }
            return d1 > d2
        })
        return copy
    }
    
    mutating func sortedByRating() -> [Review] {
        var copy = self
         copy.sort(by: {r1, r2 in
            return r1.rating > r2.rating
        })
        return copy
    }
}
