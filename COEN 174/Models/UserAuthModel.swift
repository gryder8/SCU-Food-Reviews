import SwiftUI
import GoogleSignIn

class UserAuthModel: ObservableObject {
    
    @Published var userName: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String = ""
    @Published var userId: String = ""
    
    init(){
        check()
    }
    
    func checkStatus(){
        if (GIDSignIn.sharedInstance.currentUser != nil) {
            let user = GIDSignIn.sharedInstance.currentUser
            guard let user = user else { return }
            guard let id = user.userID ?? user.profile?.email else {
                self.errorMessage = "No valid ID found for user"
                return
            }
            self.userId = id
            let givenName = user.profile?.givenName
            self.userName = givenName ?? ""
            self.isLoggedIn = true
            print("Signed in user with id: \(userId)")
        }else{
            self.isLoggedIn = false
            self.userName = "Not Logged In"
            self.errorMessage = ""
        }
    }
    
    func check(){
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                self.errorMessage = "error: \(error.localizedDescription)"
            }
            
            self.checkStatus()
        }
    }
    
    func signIn(){
        
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {return}
        
        let signInConfig = GIDConfiguration.init(clientID: googleClientID)
        
        GIDSignIn.sharedInstance.configuration = signInConfig
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController, hint: "Sign in with your SCU email to continue.", completion: { result, error in
            guard error == nil else {
                print("Error signing in! \(error!)")
                DispatchQueue.main.async {
                    self.errorMessage = "An error occured, please try again later"
                }
                return
            }
            
            guard let email = result?.user.profile?.email else {
                DispatchQueue.main.async {
                    self.errorMessage = "No email found! You must have an SCU email to use this application."
                }
                return
            }
            
            if !email.contains("@scu.edu") {
                DispatchQueue.main.async {
                    self.errorMessage = "You must have an SCU email to use this application."
                    self.isLoggedIn = false
                }
                return
            } else { //valid email
                print("Signed in with email: \(email)")
                self.checkStatus()
            }
        })
    }
    
    func signOut(){
        GIDSignIn.sharedInstance.signOut()
        self.checkStatus()
    }
}
