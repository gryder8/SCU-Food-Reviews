//
//  SubmitFoodView.swift
//  COEN 174
//
//  Created by Gavin Ryder on 2/7/23.
//

import SwiftUI

///Presented as a sheet
struct SubmitFoodView: View {
    
    @StateObject private var creator = ReviewAndFoodCreator()
    
    
    @State private var veganSelected = false
    @State private var gfSelected = false
    
    @State private var foodName: String = ""
    
    @State private var selectedRestaurant: String = ""
    
    @State private var showAlert: Bool = false
    
    @State private var responseText: String = ""
    
    @EnvironmentObject private var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    
    private let foodId: String = UUID().uuidString
    
    var body: some View {
        ZStack {
            AppBackground()
            VStack(spacing: 5) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.white.opacity(0.3))
                            .font(.system(size: 26))
                    }
                    Spacer()
                }
                .padding(.bottom, -20)
                Text("Submit Food")
                    .font(.title)
                    .padding(.top)
                Form {
                    Section {
                        TextField("Food Name", text: $foodName)
                    } header: {
                        Text("Food Info")
                    }
                    .listRowBackground(Color.white.opacity(0.45))
                    .listRowSeparator(.hidden)
                    
                    Section {
                        DisclosureGroup("Select Restaurant") {
                            Picker(selection: $selectedRestaurant) {
                                ForEach(restaurants, id: \.self) { restaurant in
                                    Text(restaurant)
                                        .font(.system(size: 18, design: .rounded))
                                }
                            } label: {
                                EmptyView()
                            }
                            .pickerStyle(.inline)
                        }
                        if (!selectedRestaurant.isEmpty) {
                            HStack {
                                Spacer()
                                Text("Served At: \(selectedRestaurant)")
                                Spacer()
                            }
                            //.listRowBackground(Color.clear)
                            .listRowSeparator(.visible)
                        }
                    } header: {
                        Text("Restaurant")
                    }
                    .listRowBackground(Color.white.opacity(0.45))
                    .listRowSeparator(.hidden)
                    
                    Section {
                        Toggle("Vegan", isOn: $veganSelected)
                        Toggle("Gluten Free", isOn: $gfSelected)
                    } header: {
                        Text("Tags")
                    }
                    .toggleStyle(CheckboxStyle())
                    .listRowBackground(Color.white.opacity(0.45))
                    .listRowSeparator(.hidden)
                    
                    HStack {
                        Spacer()
                        Button("Submit") {
                            sendFood()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    
                    HStack {
                        Spacer()
                        Button("Cancel") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                        .padding(.top)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .padding(.top, -20)
                    
                    if (creator.submittingFood) {
                        HStack {
                            Spacer()
                            LoadingView(text: "Adding...").padding(.top, 5)
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
                //.padding(.top, -20)
                Spacer()
            }
            .padding(.horizontal, 25)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text("Make sure all fields are filled out to submit your review!"), dismissButton: .default(Text("OK")))
        }
        }

    }
    
    func sendFood() {
        guard !foodName.isEmpty, !selectedRestaurant.isEmpty else {
            showAlert = true
            return
        }
        
        var tags: [String] = []
        if (veganSelected) {
            tags.append("Vegan")
        }
        
        if (gfSelected) {
            tags.append("Gluten Free")
        }
        
        creator.submitFood(foodId: foodId, name: foodName, restaurants: [selectedRestaurant], tags: tags.isEmpty ? nil : tags, completion: { result in
            switch result {
            case .success(let code):
                Task.init(priority: .userInitiated) {
                    await viewModel.fetchAllFoods()
                }
                print("Success! Code: \(code)")
                responseText = "Review Submitted!"
            case .failure(let error):
                print("Recieved error: \(error)")
                responseText = "An error occured, try again later"
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                dismiss()
            }
        })
    }
}

struct SubmitFoodView_Previews: PreviewProvider {
    static var previews: some View {
        SubmitFoodView()
    }
}
