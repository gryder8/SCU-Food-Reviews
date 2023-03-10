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
    @State private var showsErrorAlert: Bool = false
    @State var capturedErrorMsg: String = ""
    
    private var reviewsForDisplay: [Review] {
        if (searchQuery.isEmpty) {
            return vm.userReviewsSortedByMostRecent
        } else {
            return vm.userReviewsSortedByMostRecent.filter({review in
                review.title?.localizedCaseInsensitiveContains(searchQuery) ?? false || review.body?.localizedCaseInsensitiveContains(searchQuery) ?? false
            })
        }
    }
    
    @ViewBuilder
    private func reviewList() -> some View {
        List {
            ForEach(reviewsForDisplay) { review in
                ReviewView(review: review, showsFoodInfo: true)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .swipeActions(allowsFullSwipe: false) {
                        swipeActionsForReview(review)
                    }
                
            }
            if (reviewsForDisplay.isEmpty) {
                Spacer()
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
        .refreshable {
            await vm.loadUserReviewsFromServer(userId: authModel.userId, refreshing: true)
        }
    }
    
    @ViewBuilder
    private func swipeActionsForReview(_ review: Review) -> some View {
        Button {
            //print("Edit selected on review: \(review)")
            self.reviewForEdit = review
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        .tint(.blue)
        
        Button(role: .destructive) {
            print("Delete review selected")
            
            Task {
                //NOTE: Upon success of this, the review is removed locally to eliminate the need for another API call
                await vm.removeUserReview(reviewId: review.reviewId)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { //give the server some time to update
                    Task {
                        await vm.updateInfoForFood(foodId: review.foodId)
                    }
                }
            }
            
            
        } label: {
            Label("Delete", systemImage: "trash.fill")
        }
    }
    
    var body: some View {
        ZStack {
            AppBackground()
            VStack {
                
                
                if (vm.fetchingUserReviews) {
                    LoadingView(text: "Loading\nReviews")
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
                    reviewList()
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
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 5)
                    
                    
                    
                    
                    if (vm.userReviews.isEmpty && !vm.fetchingUserReviews) {
                        Text("You haven't made any reviews yet!")
                            .font(.subheadline.bold())
                    }
                    Spacer()
                    if authModel.userIsAdmin {
                        Toggle("Admin Mode: \(vm.adminModeEnabled ? "On" : "Off")",isOn: $vm.adminModeEnabled)
                            .buttonStyle(.borderedProminent)
                            .toggleStyle(.button)
                            .foregroundColor(.black)
                            .tint(.blue)
                    }
                    Button("Sign Out") {
                        print("User tapped sign out.")
                        confirmSignOut = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .padding()

                }
            }
            .navigationTitle("Profile")
            .onChange(of: vm.errorMessage, perform: {val in
                guard let msg = val else { return }
                showsErrorAlert = true
                capturedErrorMsg = msg
            })
            .alert(isPresented: $showsErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(capturedErrorMsg)
                )
            }
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
