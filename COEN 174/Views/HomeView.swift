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
    
    private let viewOptions = ["All Food", "Trending"]
    @State private var currentViewSelection = "All Food"
    @State private var showingFoodRec = false
        
    
    @ViewBuilder
    private func FoodCellButton(food: Food) -> some View {
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
    }
    
    @ViewBuilder
    private func PickerView() -> some View {
        Picker("Select View", selection: $currentViewSelection) {
            ForEach(viewOptions, id: \.self) { option in
                Text(option)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func ProfileButton() -> some View {
        Button {
            Task.init(priority: .userInitiated) {
                await viewModel.loadUserReviewsFromServer(userId: authModel.userId)
            }
            self.navModel.navPath.append(ShowProfileView())
        } label: {
            Circle()
                .frame(width: MENUBAR_BUTTON_SIZE, height: MENUBAR_BUTTON_SIZE, alignment: .center)
                .foregroundColor(.white)
                .overlay(Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: MENUBAR_BUTTON_SIZE/1.2))
                         , alignment: .center)
        }
        .padding(.horizontal, -5)
    }
    
    @ViewBuilder
    private func AddFoodButton() -> some View {
        Button {
            showingAddFoodCover.toggle()
        } label: {
            Circle()
                .frame(width: MENUBAR_BUTTON_SIZE, height: MENUBAR_BUTTON_SIZE, alignment: .center)
                .foregroundColor(.white)
                .overlay(Image(systemName: "plus.circle.fill").font(.system(size: MENUBAR_BUTTON_SIZE/1.2)), alignment: .center)
        }
        .buttonStyle(.borderless)
    }
    
    @ViewBuilder
    private func FilterButton() -> some View {
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
    
    @ViewBuilder
    private func FoodsListContent(_ foods: [Food]) -> some View {
        ForEach(foods) { food in
            Group {
                HStack {
                    Spacer()
                    FoodCellButton(food: food)
                        .swipeActions {
                            if (viewModel.adminModeEnabled) {
                                Button(role: .destructive) {
                                    print("Delete food selected!")
                                    Task {
                                        await viewModel.removeFood(food: food)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                        }
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(Visibility.hidden)
        }
    }
    
    var body: some View {
        ZStack {
            AppBackground()
            if (!viewModel.fetchingData) {
                VStack {
                    let foods = viewModel.filteredResults(self.foodFilter)
                    if let error = viewModel.errorMessage { //make sure this view is on top of the hierarchy to avoid removing the stack
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
                        //MARK: - Food Rec Disclosure Group
                        DisclosureGroup(isExpanded: $showingFoodRec) {
                            if viewModel.fetchingFoodRec {
                                Text("Loading...")
                                    .foregroundColor(.material)
                                    .font(.title3.italic())
                                    .padding(.vertical, 5)
                            } else {
                                if let food = viewModel.foodRec {
                                    FoodCellButton(food: food)
                                        .padding(.vertical, 5)
                                } else {
                                    Text("No Recommendation 😕")
                                }
                            }
                        } label: {
                            Image(systemName: "star.fill")
                            Text("Today's Recommended Food")
                            Image(systemName: "chevron.right")
                                .rotationEffect(Angle(degrees: showingFoodRec ? 90 : 0))
                        }
                        .onChange(of: showingFoodRec) { newVal in
                            guard newVal == true, !viewModel.fetchingFoodRec, viewModel.foodRec == nil else { return }
                            Task {
                                await viewModel.getFoodRec()
                            }
                            
                        }
                        .buttonStyle(.plain)
                        .tint(Color.clear) //hides default disclosure arrow
                        .foregroundColor(.material)
                        .padding(.horizontal)
                        
                        PickerView()
                        
                        if (foods.isEmpty && !searchText.isEmpty) {
                            Text("Nothing found for \(searchText)")
                                .font(.subheadline)
                                .padding()
                        }
                        List {
                            FoodsListContent(foods)
                            //Makes sure the empty list is invisible
                            if (foods.isEmpty) {
                                Spacer()
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                            }
                        }
                        .searchable(text: $searchText, prompt: Text("Search by food or restaurant"))
                        .onChange(of: currentViewSelection) { val in
                            withAnimation {
                                foodFilter.trending = (val == "Trending")
                            }
                        }
                        .onChange(of: searchText, perform: { newVal in
                            withAnimation {
                                if newVal.isEmpty {
                                    foodFilter.searchQuery = nil
                                    return
                                }
                                foodFilter.searchQuery = newVal
                            }
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
                        
                        .listStyle(.inset)
                        .padding()
                        
                    }
                }
                .onAppear {
                    viewModel.initialize()
                    showingFoodRec = false
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
        .navigationDestination(for: ShowProfileView.self) { _ in
            ProfileView()
                .environmentObject(navModel)
                .environmentObject(viewModel)
                .environmentObject(authModel)
        }
        
        .toolbar {
            ToolbarItemGroup {
                if (viewModel.adminModeEnabled) {
                    Image(systemName: "person.badge.shield.checkmark")
                }
                
                ProfileButton()

                AddFoodButton()
                
                FilterButton()
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
