//
//  COEN_174App.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/12/23.
//

import SwiftUI

@main
struct COEN_174App: App {
    @StateObject private var apiModel = APIDataModel.shared
    @StateObject private var navModel = NavigationModel()
    @StateObject var userAuth: UserAuthModel =  UserAuthModel()
    
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navModel.navPath) {
                if (userAuth.isLoggedIn) {
                    HomeView()
                        .environmentObject(apiModel)
                        .environmentObject(navModel)
                        .environmentObject(userAuth)
                } else {
                    GoogleLoginView()
                        .environmentObject(userAuth)
                }
            }
        }
    }
}
