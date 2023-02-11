//
//  ContentView.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/12/23.
//

import SwiftUI

private struct ShowProfileView: Equatable, Hashable { //for nav
    
}

struct HomeView: View {
    
    private let MENUBAR_BUTTON_SIZE: CGFloat = 30
    
    @StateObject private var viewModel: ViewModel = ViewModel()
    @EnvironmentObject private var navModel: NavigationModel
    @EnvironmentObject private var authModel: UserAuthModel
    
    @State private var showingAddFoodCover = false
    @State private var showingFilterEditor = false
    
    @State private var foodFilter = FoodFilter()
    
    @State private var searchText: String = ""
    
    var body: some View {
        ZStack {
            AppBackground()
            if (!viewModel.fetchingData) {
                VStack {
                    let foods = viewModel.filteredResults(self.foodFilter)
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 18).bold())
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    else if (foods.isEmpty && searchText.isEmpty) {
                        Text("No foods meet your criteria, try changing it.")
                            .multilineTextAlignment(.center)
                            .font(.title3.bold())
                            .onAppear { //for some reason, the onChange() modifier doesn't detect when the field is emptied so we need to check it here
                                //this check if inexpensive, but forces the state to be updated
                                if searchText.isEmpty { foodFilter.searchQuery = nil }
                            }
                    } else {
                        if (foods.isEmpty && !searchText.isEmpty) {
                            Text("Nothing found for \(searchText)")
                                .font(.subheadline)
                                .padding()
                        }
                        List {
                            ForEach(foods) { food in
                                Group {
                                    HStack {
                                        Spacer()
                                        Button {
                                            Task {
                                                await viewModel.queryReviewsForFoodFromServer(with: food.foodId, refreshing: true)
                                            }
                                            Task {
                                                await viewModel.updateInfoForFood(foodId: food.foodId)
                                            }
                                            navModel.navPath.append(food)
                                        } label: {
                                            MealHomeViewCell(food: food)
                                        }
                                        .listRowBackground(Color.clear)
                                        .buttonStyle(.plain)
                                        
                                        Spacer()
                                    }
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(Visibility.hidden)
                            }
                            //Makes sure the empty list is invisible
                            if (foods.isEmpty) {
                                Spacer()
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                            }
                        }
                        .searchable(text: $searchText, prompt: Text("Search by food or restaurant"))
                        .onChange(of: searchText, perform: { newVal in
                            if newVal.isEmpty {
                                foodFilter.searchQuery = nil
                                return
                            }
                            foodFilter.searchQuery = newVal
                        })
                        .refreshable {
                            await viewModel.fetchAllFoods()
                        }
                        .accessibilityIdentifier("foodList")
                        .scrollContentBackground(.hidden)
                        .transition(.opacity)
                        //MARK: - Nav Destination
                        .navigationDestination(for: Food.self) { food in
                            FoodDetailView(food: food)
                                .environmentObject(navModel)
                                .environmentObject(viewModel)
                                .environmentObject(authModel)
                        }
                        .navigationDestination(for: ShowProfileView.self) { _ in
                            ProfileView()
                                .environmentObject(navModel)
                                .environmentObject(viewModel)
                                .environmentObject(authModel)
                        }
                        .listStyle(.inset)
                        .padding()
                        
                    }
                }
                .onAppear {
                    viewModel.initialize()
                }
                .fullScreenCover(isPresented: $showingAddFoodCover) {
                    SubmitFoodView()
                        .environmentObject(viewModel)
                }
                .sheet(isPresented: $showingFilterEditor) {
                    FilterSelectionView(filter: $foodFilter)
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }
                .navigationTitle("Today's Food") //not shown in preview
            } else {
                LoadingView()
                    .navigationTitle("Today's Food")
                    .transition(.opacity)
            }
        }

        .toolbar {
            ToolbarItemGroup {
                Button {
                    Task.init(priority: .userInitiated) {
                        await viewModel.loadUserReviewsFromServer(userId: authModel.userId)
                    }
                    self.navModel.navPath.append(ShowProfileView())
                } label: {
                    Circle()
                        .frame(width: MENUBAR_BUTTON_SIZE, height: MENUBAR_BUTTON_SIZE, alignment: .center)
                        .foregroundColor(.white)
                        .overlay(Image(systemName: "person.crop.circle.fill").font(.system(size: MENUBAR_BUTTON_SIZE/1.2)), alignment: .center)
                }
                .padding(.horizontal, -5)
                //Spacer()
                Button {
                    showingAddFoodCover.toggle()
                } label: {
                    Circle()
                        .frame(width: MENUBAR_BUTTON_SIZE, height: MENUBAR_BUTTON_SIZE, alignment: .center)
                        .foregroundColor(.white)
                        .overlay(Image(systemName: "plus.circle.fill").font(.system(size: MENUBAR_BUTTON_SIZE/1.2)), alignment: .center)
                }
                .buttonStyle(.borderless)
                
                Button {
                    self.showingFilterEditor.toggle()
                } label: {
                    Circle()
                        .frame(width: MENUBAR_BUTTON_SIZE, height: MENUBAR_BUTTON_SIZE, alignment: .center)
                        .foregroundColor(.white)
                        .overlay(Image(systemName: "line.3.horizontal.decrease.circle.fill").font(.system(size: MENUBAR_BUTTON_SIZE/1.2)), alignment: .center)
                    
                }
                .buttonStyle(.borderless)
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
