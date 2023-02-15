//
//  COEN_174Tests.swift
//  COEN 174Tests
//
//  Created by Gavin Ryder on 1/12/23.
//

import XCTest
@testable import COEN_174
import SwiftUI
//@testable import GoogleSignInSwift


final class COEN_174Tests: XCTestCase {
    let model = APIDataModel.shared
    let vm = ViewModel()
    let auth = UserAuthModel()
    let navModel = NavigationModel()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    //MARK: - API Call and Resulting Sort Tests
    /*
     **XCTest runs things alphabetically!!**
     */
    func testFetch() async throws {
        await model.getAllFoods(completion: { result in
            switch result {
            case .success(let foods):
                XCTAssert(foods.count > 0)
            case .failure(let error):
                XCTFail("API Call Failed! Error: \(error)")
            }
        })

        //testSortsOnViewModel()

    }
    
    
    ///Precondition: Do not call standalone, API data must be fetched first! This method should be called after `testFetch()`
    func testSort() {
        XCTAssertFalse(vm.mealsSortedByName.isEmpty)
        if let first = vm.mealsSortedByName.first, let last = vm.mealsSortedByName.last {
            print(first.name)
            print(last.name)
            let comp = first.name.caseInsensitiveCompare(last.name)
            XCTAssertTrue(comp == .orderedAscending)
        }
        
        if let first = vm.mealsSortedByRating.first, let last = vm.mealsSortedByRating.last {
            print("First Rating: \(first.rating)")
            print("Last Rating: \(last.rating)")
            XCTAssertTrue(first.rating >= last.rating)
        }
        
    }
    
    func testArrayToString() {
        let arr = ["A", "B", "C", "D", "E"]
        XCTAssertEqual(commaSeparatedListFromStringArray(arr), "A,B,C,D,E")
    }
    
    func testEmailValidation() {
        XCTAssertTrue(auth.validateEmail("gryder@scu.edu"))
        XCTAssertFalse(auth.validateEmail("gryder@gmail.com"))
        XCTAssertFalse(auth.validateEmail("attacker@scu.edu@gmail.com"))
        XCTAssertFalse(auth.validateEmail(""))

    }
    
    func testPopToRoot() {
        navModel.navPath.append(1)
        navModel.navPath.append(2)
        navModel.navPath.append(3)
        navModel.navPath.append(4)
        navModel.navPath.append(5)
        
        XCTAssertTrue(navModel.navPath.count == 5)
        DispatchQueue.main.async { [self] in //avoid race condition by doing sequentially on main thread
            navModel.popToRoot()
            XCTAssertTrue(navModel.navPath.count == 0)
        }
        
    }
    

    func testPerformanceExample() async throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            testSort()
        }
    }

}
