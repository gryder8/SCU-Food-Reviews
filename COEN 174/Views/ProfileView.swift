//
//  ProfileView.swift
//  COEN 174
//
//  Created by Gavin Ryder on 2/8/23.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject private var authModel: UserAuthModel
    @EnvironmentObject private var navModel: NavigationModel
    @EnvironmentObject private var vm: ViewModel
    
    @State private var confirmSignOut: Bool = false
    
    var body: some View {
        VStack {
            if (vm.fetchingUserReviews) {
                LoadingView()
                    .padding()
            } else if (!vm.userReviews.isEmpty) {
                Text("Your Reviews")
                    .font(.title.bold())
                    .padding(.bottom, -5)
                List(vm.userReviews) { review in
                    ReviewView(review: review, showsFoodInfo: true)
                }
                .listStyle(.inset)
                .padding(.leading, -20)
            }
            Button("Sign Out") {
                confirmSignOut = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            Spacer()
        }
        .navigationTitle("Profile")
        .alert(isPresented: $confirmSignOut) {
            Alert(
                title: Text("Are you sure you want to sign out?"),
                message: Text("You'll be returned to the login screen."),
                primaryButton: .destructive(Text("Sign Out")) {
                    print("User selected sign out")
                    authModel.signOut()
                    withAnimation {
                        navModel.popToRoot()
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .padding()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(NavigationModel())
            .environmentObject(UserAuthModel())
            .environmentObject(ViewModel())
    }
}
