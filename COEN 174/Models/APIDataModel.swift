//
//  APIDataModel.swift
//  COEN 174
//
//  Created by Gavin Ryder on 1/24/23.
//

import Foundation

class APIDataModel: ObservableObject {
    
    //MARK: - Singleton Config
    private init(){self.useTestData()}
    static let shared = APIDataModel()
    
    //MARK: - Published Fields
    @Published var meals: [Food] = [Food]()
    
    //MARK: - API Base URL
    private let baseURLString = "<BASE STRING URL HERE>" //append endpoints onto this as needed
    
    public func useTestData() {
        let food1 = Food(name: "Breakfast Burrito", rating: 4.5)
        let food2 = Food(name: "Ramen", rating: 1)
        let food3 = Food(name: "Acai Bowl", rating: 5)
        DispatchQueue.main.async {
            self.meals = [food1, food2, food3]
        }
    }
    
    
}
