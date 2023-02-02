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
