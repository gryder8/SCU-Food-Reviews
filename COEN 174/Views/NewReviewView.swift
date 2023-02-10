//
//  NewReviewView.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/31/23.
//

import SwiftUI

struct NewReviewView: View {
    
    let food: Food
    
    @State private var showAlert = false
    
    @StateObject private var creator = ReviewAndFoodCreator()
    
    @State private var currentRating: Int?
    @State private var title: String = ""
    @State private var bodyText: String = ""
    
    @State private var responseText: String = ""
    
    @EnvironmentObject private var navModel: NavigationModel
    @EnvironmentObject private var viewModel: ViewModel
    @EnvironmentObject private var authModel: UserAuthModel
    
    var body: some View {
        Form {
            Section {
                RatingSubmissionView(currentRating: $currentRating)
            } header: {
                if let rating = currentRating, rating > 0 {
                    Text("Your Rating: \(rating)/5")
                } else {
                    Text("Your Rating:")
                }
            }
            
            
            Section {
                TextField("Title", text: $title)
            } header: {
                Text("Title")
            }
            
            Section {
                TextField("Review", text: $bodyText, axis: .vertical)
                    .lineLimit(3...10)
            } header: {
                Text("Review")
            }
            
            HStack {
                Spacer()
                Button("Submit") {
                    sendReview()
                }
                .buttonStyle(.borderedProminent)
                .font(.system(size: 20, design: .rounded))
                

                
                Spacer()
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            if (creator.submittingReview) {
                HStack {
                    Spacer()
                    LoadingView(text: "Submitting...").padding(.top, 5)
                    Spacer()
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            } else if (!responseText.isEmpty) {
                HStack {
                    Spacer()
                    Text(responseText)
                        .font(.headline)
                        .padding(.top)
                        .foregroundColor(responseText.lowercased().contains("error") ? .red : .gray)
                    Spacer()
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .headerProminence(.increased)
        .navigationTitle("Submit A Review")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text("Make sure all fields are filled out to submit your review!"), dismissButton: .default(Text("OK")))
        }
    }
    
    func sendReview() {
        hideKeyboard()
        guard currentRating != nil, !title.isEmpty, !bodyText.isEmpty else {
            showAlert = true
            return
        }
        
        creator.submitReview(rating: self.currentRating!, text: self.bodyText, title: self.title, foodId: food.foodId, userId: authModel.userId, completion: { result in
            
            switch result {
            case .failure(let error):
                print("Recieved error: \(error)")
                responseText = "An error occured, try again later"
            case .success(let code):
                Task.init(priority: .userInitiated) {
                    await viewModel.queryReviewsForFoodFromServer(with:food.foodId, refreshing: true)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { //give the server some time to update
                    Task.init(priority: .high) {
                        await viewModel.updateInfoForFood(foodId: food.foodId)
                    }
                }
                print("Success! Code: \(code)")
                responseText = "Review Submitted!"
            }
            let desiredPathLen = navModel.navPath.count-2 //back to main view
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                let popLen = navModel.navPath.count - desiredPathLen
                guard popLen != 0 else { return } //avoid popping off the view if the user does it for us
                print("Popping back \(popLen) views")
                navModel.navPath.removeLast(popLen)
            }
            
        })
    }
}

//struct NewReviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewReviewView()
//    }
//}
