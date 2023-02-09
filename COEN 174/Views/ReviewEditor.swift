//
//  ReviewEditor.swift
//  COEN 174
//
//  Created by Gavin Ryder on 2/9/23.
//

import SwiftUI

struct ReviewEditor: View {
    
    //let review: Review
    
    @Binding var showingEditor: Bool
    @Binding var review: Review?
    
    @State private var showAlert = false
    
    @StateObject private var creator = ReviewAndFoodCreator()
    
    @State private var currentRating: Int?
    @State private var title: String = ""
    @State private var bodyText: String = ""
    
    @State private var responseText: String = ""
    
    //@EnvironmentObject private var navModel: NavigationModel
    @EnvironmentObject private var viewModel: ViewModel
    @EnvironmentObject private var authModel: UserAuthModel
    
    @Environment(\.dismiss) private var dismiss
    
    private func tearDown() {
        showingEditor = false
        review = nil
        dismiss()
    }
    
    var body: some View {
        ZStack {
            AppBackground()
            VStack {
                HStack {
                    Button {
                        tearDown()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.white.opacity(0.3))
                            .font(.system(size: 26))
                    }
                    Spacer()
                }
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 0))
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
                    .listRowBackground(Color.white.opacity(0.45))
                    
                    
                    Section {
                        TextField("Title", text: $title)
                    } header: {
                        Text("Title")
                    }
                    .listRowBackground(Color.white.opacity(0.45))
                    
                    
                    Section {
                        TextField("Review", text: $bodyText, axis: .vertical)
                            .lineLimit(3...10)
                    } header: {
                        Text("Review")
                    }
                    .listRowBackground(Color.white.opacity(0.45))
                    
                    
                    HStack {
                        Spacer()
                        Button("Update") {
                            sendReview()
                        }
                        .buttonStyle(.borderedProminent)
                        .font(.system(size: 20, design: .rounded))
                        
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .padding(.top, -5)
                    
                    if (creator.submittingReview) {
                        HStack {
                            Spacer()
                            LoadingView(text: "Updating...").padding(.top, 5)
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
                .scrollContentBackground(.hidden)
                .headerProminence(.increased)
                .navigationTitle("Update Review")
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text("Make sure all fields are filled out to submit your review!"), dismissButton: .default(Text("OK")))
                }
            }
            .onAppear {
                self.currentRating = self.review?.rating
                self.title = self.review?.title ?? ""
                self.bodyText = self.review?.body ?? ""
            }
        }
    }
    
    func sendReview() {
        hideKeyboard()
        guard currentRating != nil, !title.isEmpty, !bodyText.isEmpty else {
            showAlert = true
            return
        }
        
        guard let review else {
            showAlert = true
            print("***REVIEW WAS NIL!")
            return
        }
        
        creator.submitReview(reviewIdForUpdate: review.reviewId, rating: self.currentRating!, text: self.bodyText, title: self.title, foodId: review.foodId, userId: authModel.userId, completion: { result in
            
            switch result {
            case .failure(let error):
                print("Recieved error: \(error)")
                responseText = "An error occured, try again later"
            case .success(let code):
                Task.init(priority: .userInitiated) {
                    await viewModel.loadUserReviewsFromServer(userId: authModel.userId)
                }
                print("Success! Code: \(code)")
                responseText = "Review Updated!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    tearDown()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                tearDown()
            }
            
        })
    }
}


struct ReviewEditor_Previews: PreviewProvider {
    static var previews: some View {
        ReviewEditor(showingEditor: Binding.constant(true), review: Binding.constant(Review(reviewId: UUID().uuidString, foodId: UUID().uuidString, rating: 4, body: "Lorem ipsum dolor sit amet", title: "Test Review", dateCreated: "02/09/2023, 06:40:10", dateUpdated: nil)))
    }
}
