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
    @objc private var functionForTest: (() -> ())? = nil {
        didSet {
//            print(functionForTest)
        }
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func example() {
        print("testExample")
//        XCTAssertTrue(control.isSelected == true)
    }
    
    func secondExample() {
        print("second testExample")
//        XCTAssertTrue(control.isEnabled == false)
    }
    
    func testPerformanceExample() {
        self.measure {
            _ = self.control.value(for: self.control.value(forKey: "applier") as! NSObject, forKey: #keyPath(CAShapeLayer.strokeColor), for: [.invalid, .filled])
        }
    }

    func testCorrectValueForState() {
        control.setValue({ print("test") }, forTarget: self, forKeyPath: #keyPath(QUIckControlTests.functionForTest), for: .selected)
        control.setValue({ print("second") }, forTarget: self, forKeyPath: #keyPath(QUIckControlTests.functionForTest), for: .disabled)
        
        control.isEnabled = false
        if let function: (() -> ()) = functionForTest {
            function()
        }
        control.isEnabled = true
        control.isSelected = true
        functionForTest?()
    }
    
}

struct PrintState: Predicate, StateApplier {
    typealias EvaluatedEntity = StatableObject
    typealias ApplyObject = StatableObject
    
    let value: () -> String
    let evaluateFunction: (_: StatableObject) -> Bool
    
    func evaluate(with entity: StatableObject) -> Bool {
        return evaluateFunction(entity)
    }
    
    func apply(for target: StatableObject) {
        target.printFunction = value
    }
}

class StatableObject: Statable {
    typealias StateType = PrintState
    typealias StateFactor = PrintState
    
    var boolState: Bool = false { didSet { applyCurrentState() } }
    var printFunction: (() -> String)? = nil
    var factors = [PrintState]()
    var defaultState = PrintState(value: { return "default state" }, evaluateFunction: { object in object.boolState == false && object.printFunction == nil })
    var state: PrintState {
        return factors.first { $0.evaluate(with: self) } ?? defaultState
    }
    
    func apply(state: PrintState) {
        state.apply(for: self)
    }
}

class StatableTests: XCTestCase {
    func testStatableObject() {
        let statable = StatableObject()
        statable.applyCurrentState()
        
        XCTAssertTrue(statable.printFunction?() == "default state")
        
        statable.factors.append(PrintState(value: { return "bool is true" }, evaluateFunction: { $0.boolState == true }))
        statable.factors.append(PrintState(value: { return "bool is false" }, evaluateFunction: { $0.boolState == false }))
        
        statable.boolState = true
        XCTAssertTrue(statable.printFunction?() == "bool is true")
        statable.boolState = false
        XCTAssertTrue(statable.printFunction?() == "bool is false")
    }
}
