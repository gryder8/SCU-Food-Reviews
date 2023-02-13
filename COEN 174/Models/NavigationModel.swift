//
//  NavigationModel.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/24/23.
//

import Foundation
import SwiftUI

class NavigationModel: ObservableObject {
    
    @Published var navPath = NavigationPath()
    
    func popToRoot() {
        DispatchQueue.main.async {
            self.navPath = NavigationPath()
        }
    }
}
