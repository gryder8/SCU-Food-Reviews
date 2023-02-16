//
//  ProfileView.swift
//  COEN 174
//
//  Created by Gavin Ryder on 2/8/23.
//

import SwiftUI

private struct ShowReviewEditor: Hashable, Equatable {}

struct ProfileView: View {
    
    @EnvironmentObject private var authModel: UserAuthModel
    @EnvironmentObject private var navModel: NavigationModel
    @EnvironmentObject private var vm: ViewModel
    
    @State private var confirmSignOut: Bool = false
    @State private var showingEditCover: Bool = false
    @State private var reviewForEdit: Review? = nil
    
    @State private var searchQuery: String = ""
    
    private var reviewsForDisplay: [Review] {
        if (searchQuery.isEmpty) {
            return vm.userReviewsSortedByMostRecent
        } else {
            return vm.userReviewsSortedByMostRecent.filter({review in
                review.title?.localizedCaseInsensitiveContains(searchQuery) ?? false || review.body?.localizedCaseInsensitiveContains(searchQuery) ?? false
            })
        }
    }
    
    var body: some View {
        ZStack {
            AppBackground()
            VStack {
                if authModel.isAdmin {
                    Toggle("Admin Mode: \(vm.adminModeEnabled ? "On" : "Off")",isOn: $vm.adminModeEnabled)
                        .buttonStyle(.borderedProminent)
                        .toggleStyle(.button)
                        .foregroundColor(.black)
                        .tint(.blue)
                }
                
                if let errorMsg = vm.errorMessage, !errorMsg.isEmpty {
                    Text(errorMsg)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                } else if (vm.fetchingUserReviews || vm.removingReview) {
                    LoadingView(text: vm.removingReview ? "Updating" : "Loading\nReviews")
                        .padding()
                } else if (!vm.userReviews.isEmpty) {
                    Text("Your Reviews")
                        .font(.title.bold())
                        .padding(.bottom, -5)
                    if (reviewsForDisplay.isEmpty) {
                        Text("No reviews found, try a different search.")
                            .multilineTextAlignment(.center)
                            .font(.headline.bold())
                    }
                    List {
                        ForEach(reviewsForDisplay) { review in
                            ReviewView(review: review, showsFoodInfo: true)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(allowsFullSwipe: false) {
                                    Button {
                                        //print("Edit selected on review: \(review)")
                                        reviewForEdit = review
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                    
                                    Button(role: .destructive) {
                                        print("Delete review selected")
                                        Task {
                                            //NOTE: Upon success of this, the review is removed locally to eliminate the need for another API call
                                            await vm.removeUserReview(reviewId: review.reviewId)
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { //give the server some time to update
                                            Task {
                                                await vm.updateInfoForFood(foodId: review.foodId)
                                            }
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                }
                            
                        }
                        if (reviewsForDisplay.isEmpty) {
                            Spacer()
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.material, lineWidth: 3)
                    )
                    .searchable(text: $searchQuery, placement: .automatic, prompt: Text("Search Your Reviews"))
                    .onChange(of: reviewForEdit) { val in //needed to make sure the non-nil review is passed in, for some reason it is nil when we attach directly
                        guard val != nil else { return }
                        showingEditCover = true
                        //print("Review to edit: \(val)")
                    }
                    .fullScreenCover(isPresented: $showingEditCover) {
                        if reviewForEdit != nil {
                            ReviewEditor(showingEditor: self.$showingEditCover, review: $reviewForEdit)
                                .environmentObject(authModel)
                                .environmentObject(vm)
                        } else {
                            Text("Error Editing Review! No valid review in memory.")
                                .foregroundColor(.red)
                        }
                    }
                    .listStyle(.inset)
                    //.padding(.leading, -20)
                    .scrollContentBackground(.hidden)
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
                        withAnimation(.linear) {
                            navModel.popToRoot()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .padding()
        }
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
