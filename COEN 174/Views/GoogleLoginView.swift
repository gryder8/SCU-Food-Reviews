//
//  GoogleLoginView.swift
//  COEN 174
//
//  Created by Gavin Ryder on 2/8/23.
//

import SwiftUI
import GoogleSignInSwift

struct GoogleLoginView: View {
    
    @EnvironmentObject private var authModel: UserAuthModel
    
    var body: some View {
        ZStack {
            AppBackground()
            VStack {
                Text("Welcome to SCU Food Reviews!")
                    .font(.largeTitle)
                    .padding(.vertical)
                Text("Sign in with your SCU Google Account to get started.")
                GoogleSignInButton {
                    authModel.signIn()
                }
                .cornerRadius(35)
                .font(.system(size: 18, design: .rounded))
                .foregroundColor(.black)
                .frame(width: 120)
                .padding(.vertical, 5)
                
                if (!authModel.errorMessage.isEmpty) {
                    Text(authModel.errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.vertical)
                }
            }
            .multilineTextAlignment(.center)
        }
    }
}

struct GoogleLoginView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleLoginView()
            .environmentObject(UserAuthModel())
    }
}
