//
//  ContentView.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/12/23.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var apiModel: APIDataModel
    @EnvironmentObject private var navModel: NavigationModel
    
    var body: some View {
        List(apiModel.meals) { meal in
            HStack {
                Spacer()
                Button {
                    navModel.navPath.append(meal)
                } label: {
                    MealHomeViewCell(food: meal)
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .listRowSeparator(Visibility.hidden)
        }
        //MARK: - Nav Destinations
        .navigationDestination(for: Food.self) { food in
            Text("\(food.name) detail view here")
        }
        .listStyle(.inset)
        .padding()
        .navigationTitle("Today's Food") //not shown in preview
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(APIDataModel.shared)
    }
}
