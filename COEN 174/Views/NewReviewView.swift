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
    
    let creator = ReviewCreator()
    
    @State private var currentRating: Int?
    @State private var title: String = ""
    @State private var bodyText: String = ""
    
    @State private var successText: String = ""
    
    @EnvironmentObject private var navModel: NavigationModel
    
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
                    guard currentRating != nil, !title.isEmpty, !bodyText.isEmpty else {
                        showAlert = true
                        return
                    }
                    
                    creator.submitReview(rating: self.currentRating!, text: self.bodyText, title: self.title, reviewId: UUID().uuidString, foodId: food.foodId, success: {
                        let pathLen = navModel.navPath.count
                        successText = "Review Submitted!"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            guard navModel.navPath.count == pathLen else { return } //avoid popping off the view if the user does it for us
                            navModel.navPath.removeLast()
                        }
                    })
                    
                }
                .buttonStyle(.borderedProminent)
                .font(.system(size: 20, design: .rounded))
                Spacer()
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            if (!successText.isEmpty) {
                HStack {
                    Spacer()
                    Text(successText)
                        .font(.headline)
                        .padding(.top)
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
}

//struct NewReviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewReviewView()
//    }
//}
