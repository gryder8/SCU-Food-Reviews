//
//  COEN_174Tests.swift
//  COEN 174Tests
//
//  Created by Gavin Ryder on 1/12/23.
//

import XCTest
@testable import COEN_174

final class COEN_174Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetch() async throws {
        let model = APIDataModel.shared
        await model.getAllFoods(completion: { result in
            switch result {
            case .success(let foods):
                XCTAssert(foods.count > 0)
            case .failure(let error):
                XCTFail("API Call Failed! Error: \(error)")
            }
        })
        
        testSortsOnViewModel()
                
    }
    
    
    ///Do not call standalone, API data must be fetched first
    func testSortsOnViewModel() {
        let vm = ViewModel()
        XCTAssert(!vm.mealsSortedByName.isEmpty)
        if let first = vm.mealsSortedByName.first, let last = vm.mealsSortedByName.last {
            print(first.name)
            print(last.name)
            let comp = first.name.caseInsensitiveCompare(last.name)
            XCTAssert(comp == .orderedAscending)
        }
        
        if let first = vm.mealsSortedByRating.first, let last = vm.mealsSortedByRating.last {
            XCTAssert(first.rating >= last.rating)
        }
        
    }

    func testPerformanceExample() async throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
