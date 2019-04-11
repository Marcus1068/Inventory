//
//  InventoryTests.swift
//  InventoryTests
//
//  Created by Marcus Deuß on 11.04.19.
//  Copyright © 2019 Marcus Deuß. All rights reserved.
//

import XCTest
@testable import Inventory


class InventoryTests: XCTestCase {

    var inv : Inventory!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        inv = Inventory()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        inv = nil
        
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        // 1. given
        let minmax = Global.minMax(array: [8, -6, 2, 109, 3, 71])!
        
        
        //let guess = sut.targetValue + 5
        
        // 2. when
        //sut.check(guess: guess)
        
        // 3. then
        XCTAssertEqual(minmax.min, -6, "min is wrong")
        XCTAssertEqual(minmax.max, 109, "max is wrong")
        
    }

    func testNil() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        // 1. given
        let minmax = Global.minMax(array: [])
        
        
        //let guess = sut.targetValue + 5
        
        // 2. when
        //sut.check(guess: guess)
        
        // 3. then
        XCTAssertNil(minmax)
        
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
