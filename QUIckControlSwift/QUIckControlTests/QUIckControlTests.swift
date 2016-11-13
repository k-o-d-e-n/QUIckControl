//
//  QUIckControlTests.swift
//  QUIckControlTests
//
//  Created by Denis Koryttsev on 23/10/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import XCTest
@testable import QUIckControl

class QUIckControlTests: XCTestCase {
    private var control = PinCodeControl(codeLength: 4, sideSize: 20, spaceSize: 10)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        self.measure {
            _ = self.control.value(for: self.control.applier, forKey: #keyPath(CAShapeLayer.strokeColor), for: [.invalid, .filled])
        }
    }
    
}
