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
    
    @State private var showMinRatingSlider = false
    @State private var showMinReviewsSlider = false
    @State private var showMaxRatingSlider = false
    @State private var showMaxReviewsSlider = false
    
    @State private var vegan: Bool = false
    @State private var gf: Bool = false
    @State private var minRating: Double = 1
    @State private var maxRating: Double = 5
    @State private var minReviews: Double = 1
    @State private var maxReviews: Double = 1
    
    private let backgroundColor = Color.white.opacity(0.45)
    
    private func initializeValuesFromBoundFilter() {
        showMinRatingSlider = filter.minRating != nil
        showMinReviewsSlider = filter.minNumReviews != nil
        showMaxRatingSlider = filter.maxRating != nil
        showMaxReviewsSlider = filter.maxNumReviews != nil
        gf = filter.glutenFree
        vegan = filter.vegan
        if let minRating = filter.minRating {
            self.minRating = minRating
        }
        if let minReviews = filter.minNumReviews {
            self.minReviews = Double(minReviews)
        }
        if let maxRating = filter.maxRating {
            self.maxRating = maxRating
        }
        if let maxReviews = filter.maxNumReviews {
            self.maxReviews = Double(maxReviews)
        }
    }
    
    
    var body: some View {
        ZStack {
            AppBackground(reversed: true)
            Form {
                //MARK: - Toggles
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
                //MARK: - Rating Toggles and Sliders
                Toggle("Minimum Rating", isOn: $showMinRatingSlider)
                    .toggleStyle(CheckboxStyle())
                    .onChange(of: showMinRatingSlider) { newVal in
                        if newVal == false {
                            filter.minRating = nil
                            minRating = 1
                        }
                    }
                    .listRowBackground(backgroundColor)
                if (showMinRatingSlider) {
                    HStack(spacing: 0) {
                        Text("Min Rating:")
                            .padding(.trailing, 5)
                        Slider(value: $minRating, in: 1...5, step: 0.5, onEditingChanged: { editing in
                            guard !editing else { return }
                            maxRating = max(maxReviews, min(minRating, 5))
                            minRating = min(minRating, max(maxRating, 1))
                            filter.minRating = self.minRating
                        })
                        Text(String(format: "%.1f", minRating))
                            .padding(.leading, 5)
                    }
                    .listRowBackground(backgroundColor)
                }
                Toggle("Maximum Rating", isOn: $showMaxRatingSlider)
                    .toggleStyle(CheckboxStyle())
                    .onChange(of: showMaxRatingSlider) { newVal in
                        if newVal == false {
                            filter.maxRating = nil
                            maxRating = 1
                        } else {
                            maxRating = minRating
                        }
                    }
                    .listRowBackground(backgroundColor)
                if (showMaxRatingSlider) {
                    HStack(spacing: 0) {
                        Text("Max Rating:")
                            .padding(.trailing, 5)
                        Slider(value: $maxRating, in: 1...5, step: 0.5, onEditingChanged: { editing in
                            guard !editing, showMaxRatingSlider else { return }
                            minRating = min(minRating, max(maxRating, 1))
                            maxRating = max(maxRating, min(minRating, 5))
                            filter.maxRating = self.maxRating
                        })
                        Text(String(format: "%.1f", maxRating))
                            .padding(.leading, 5)
                    }
                    .listRowBackground(backgroundColor)
                }
                //MARK: - Review Toggles and Sliders
                Toggle("Mininum Number of Reviews", isOn: $showMinReviewsSlider)
                    .toggleStyle(CheckboxStyle())
                    .onChange(of: showMinReviewsSlider) { newVal in
                        if newVal == false {
                            filter.minNumReviews = nil
                        } else {
                            minRating = maxRating
                        }
                    }
                    .listRowBackground(backgroundColor)
                if (showMinReviewsSlider) {
                    VStack {
                        HStack {
                            Slider(value: $minReviews, in: 1...15, step: 1, onEditingChanged: { editing in
                                guard !editing, showMinReviewsSlider else { return }
                                maxReviews = max(maxReviews, 1, minReviews)
                                minReviews = min(minReviews, maxReviews, 15)
                                filter.minNumReviews = Int(self.minReviews)
                            })
                            Text(String(format: "%.0f", minReviews))
                                .padding(.leading, 5)
                            Spacer()
                        }
                    }
                    .listRowBackground(backgroundColor)
                }
                Toggle("Maximum Number of Reviews", isOn: $showMaxReviewsSlider)
                    .toggleStyle(CheckboxStyle())
                    .onChange(of: showMaxReviewsSlider) { newVal in
                        if newVal == false {
                            filter.maxNumReviews = nil
                        }
                    }
                    .listRowBackground(backgroundColor)
                if (showMaxReviewsSlider) {
                    VStack {
                        HStack {
                            Slider(value: $maxReviews, in: 1...15, step: 1, onEditingChanged: { editing in
                                guard !editing, showMaxReviewsSlider else { return }
                                minReviews = min(minReviews, 15, maxReviews)
                                maxReviews = max(maxReviews, minReviews, 1)
                                filter.maxNumReviews = Int(self.maxReviews)
                            })
                            Text(String(format: "%.0f", maxReviews))
                                .padding(.leading, 5)
                            Spacer()
                        }
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

//MARK: - Preview
struct FilterSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        FilterSelectionView(filter: Binding.constant(FoodFilter()))
    }
}
