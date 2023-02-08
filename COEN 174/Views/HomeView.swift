//
//  ContentView.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/12/23.
//

import SwiftUI

struct HomeView: View {
    
    private let MENUBAR_BUTTON_SIZE: CGFloat = 30
    
    @StateObject private var viewModel: ViewModel = ViewModel()
    @EnvironmentObject private var navModel: NavigationModel
    
    @State private var showingAddFoodCover = false
    @State private var showingFilterEditor = false
    
    @State private var foodFilter = FoodFilter()
    
    var body: some View {
        ZStack {
            AppBackground()
            if (!viewModel.fetchingData) {
                VStack {
                    let foods = viewModel.filteredResults(self.foodFilter)
                    if (foods.isEmpty) {
                        Text("No foods meet your criteria, try changing it.")
                            .multilineTextAlignment(.center)
                            .font(.title2.bold())
                    } else {
                        List(foods) { food in
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
