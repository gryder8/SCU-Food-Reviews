//
//  FilterSelectionView.swift
//  COEN 174
//
//  Created by Gavin Ryder on 2/7/23.
//

import SwiftUI

struct FilterSelectionView: View {
    
    @Binding var filter:FoodFilter
    
    @Environment(\.dismiss) var dismiss
    
    @State private var showRatingSlider = false
    @State private var showReviewSlider = false
    
    @State private var vegan: Bool = false
    @State private var gf: Bool = false
    @State private var minRating: Double = 0
    @State private var minReviews: Double = 0
    
    private let backgroundColor = Color.white.opacity(0.45)
    
    private func initializeValuesFromBoundFilter() {
        showRatingSlider = filter.minRating != nil
        showReviewSlider = filter.minNumReviews != nil
        gf = filter.glutenFree
        vegan = filter.vegan
        if let rating = filter.minRating {
            self.minRating = rating
        }
        if let reviews = filter.minNumReviews {
            self.minReviews = Double(reviews)
        }
    }
    
    var body: some View {
        ZStack {
            AppBackground(reversed: true)
            Form {
                Toggle("Vegan", isOn: $vegan)
                    .toggleStyle(CheckboxStyle())
                    .onChange(of: vegan) { newVal in
                        filter.vegan = newVal
                    }
                    .listRowBackground(backgroundColor)
                Toggle("Gluten Free", isOn: $gf)
                    .toggleStyle(CheckboxStyle())
                    .onChange(of: gf) { newVal in
                        filter.glutenFree = newVal
                    }
                    .listRowBackground(backgroundColor)
                Toggle("Minimum Rating", isOn: $showRatingSlider)
                    .toggleStyle(CheckboxStyle())
                    .onChange(of: showRatingSlider) { newVal in
                        if newVal == false {
                            filter.minRating = nil
                        }
                    }
                    .listRowBackground(backgroundColor)
                if (showRatingSlider) {
                    HStack(spacing: 0) {
                        Text("Min Rating:")
                            .padding(.trailing, 5)
                        Slider(value: $minRating, in: 1...5, step: 0.5, onEditingChanged: { editing in
                            guard !editing else { return }
                            filter.minRating = self.minRating
                        })
                        Text(String(format: "%.1f", minRating))
                            .padding(.leading, 5)
                    }
                    .listRowBackground(backgroundColor)
                }
                Toggle("Mininum Number of Reviews", isOn: $showReviewSlider)
                    .toggleStyle(CheckboxStyle())
                    .onChange(of: showReviewSlider) { newVal in
                        if newVal == false {
                            filter.minNumReviews = nil
                        }
                    }
                    .listRowBackground(backgroundColor)
                if (showReviewSlider) {
                    VStack {
                        HStack {
        //                    Text("Min # Reviews:")
        //                        .padding(.trailing, 5)
                            Slider(value: $minReviews, in: 0...15, step: 1, onEditingChanged: { editing in
                                guard !editing, showReviewSlider else { return }
                                filter.minNumReviews = Int(self.minReviews)
                            })
                            Text(String(format: "%.0f", minReviews))
                                .padding(.leading, 5)
                            Spacer()
                        }
//                        Stepper(label: {EmptyView()}, onIncrement: {
//                            minReviews = min(15, minReviews+1)
//                            filter.minNumReviews = Int(minReviews)
//                        }, onDecrement: {
//                            minReviews = max(0, minReviews-1)
//                            filter.minNumReviews = Int(minReviews)
//
//                        })
                    }
                    .listRowBackground(backgroundColor)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .onAppear {
            initializeValuesFromBoundFilter()
        }

    }
}

struct FilterSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        FilterSelectionView(filter: Binding.constant(FoodFilter()))
    }
}
