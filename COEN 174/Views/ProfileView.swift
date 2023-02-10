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
    
    var body: some View {
        ZStack {
            AppBackground()
            VStack {
                if let errorMsg = vm.errorMessage, !errorMsg.isEmpty {
                    Text(errorMsg)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                } else if (vm.fetchingUserReviews) {
                    LoadingView(text: "Loading\nReviews")
                        .padding()
                } else if (!vm.userReviews.isEmpty) {
                    Text("Your Reviews")
                        .font(.title.bold())
                        .padding(.bottom, -5)
                    List(vm.userReviewsSortedByMostRecent) { review in
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
                                    
                                    Task.init(priority: .background) {
                                        await vm.updateInfoForFood(foodId: review.foodId)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                            
                    }
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
                    .padding(.leading, -20)
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
