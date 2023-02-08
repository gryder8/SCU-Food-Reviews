//
//  ContentView.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/12/23.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel: ViewModel = ViewModel()
    @EnvironmentObject private var navModel: NavigationModel
    
    @State private var showingAddFoodCover = false
    
    var body: some View {
        ZStack {
            AppBackground()
            if (!viewModel.fetchingData) {
                VStack {
                    HStack {
                        Spacer()
                        Button("Add A Food") {
                            showingAddFoodCover.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.trailing, 20)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: -10, trailing: 0))
                    
                    List(viewModel.displayData) { food in
                        HStack {
                            Spacer()
                            Button {
                                Task {
                                    await viewModel.queryReviewsForFoodFromServer(with: food.foodId, refreshing: true)
                                }
                                navModel.navPath.append(food)
                            } label: {
                                MealHomeViewCell(food: food)
                            }
                            .listRowBackground(Color.clear)
                            .buttonStyle(.plain)
                            
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(Visibility.hidden)
                    }
                    .accessibilityIdentifier("foodList")
                    .scrollContentBackground(.hidden)
                    .transition(.opacity)
                    //MARK: - Nav Destination
                    .navigationDestination(for: Food.self) { food in
                        FoodDetailView(food: food)
                            .environmentObject(navModel)
                            .environmentObject(viewModel)
                    }
                    .listStyle(.inset)
                    .padding()
                    .navigationTitle("Today's Food") //not shown in preview
                    .onAppear {
                        viewModel.initialize()
                }
                }
                .fullScreenCover(isPresented: $showingAddFoodCover) {
                    SubmitFoodView()
                        .environmentObject(viewModel)
                }
            } else {
                LoadingView()
                    .navigationTitle("Today's Food")
                    .transition(.opacity)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(APIDataModel.shared)
    }
}
