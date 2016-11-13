//
//  QUIckControlValue.swift
//  QUIckControl
//
//  Created by Denis Koryttsev on 06/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import UIKit

class QUIckControlValue {
    let key: String
    private var values = [UInt: Any]()
    private var intersectedValues = [UInt: Any]() // TODO: Try apply some transform for state and save to values
    private let intersectedStates = NSMutableIndexSet()
    private let invertedStates = NSMutableIndexSet()
    
    init(key: String) {
        self.key = key
    }
    
    // TODO: state descriptor not used on full power, need remake select value.
    func setValue(_ value: Any, for descriptor: QUICStateDescriptor) {
        switch descriptor.type {
        case .usual:
            setValue(value, for: descriptor.state)
        case .inverted:
            setValue(value, forInvertedState: descriptor.state)
        case .intersected:
            setValue(value, forIntersectedState: descriptor.state)
        }
    }
    
    private func setValue(_ value: Any?, forInvertedState state: UIControlState) {
        invertedStates.add(Int(state.rawValue))
        if let val = value {
            values[~state.rawValue] = val
        } else {
            values.removeValue(forKey: ~state.rawValue)
        }
    }
    
    private func setValue(_ value: Any?, forIntersectedState state: UIControlState) {
        intersectedStates.add(Int(state.rawValue))
        if let val = value {
            intersectedValues[state.rawValue] = val
        } else {
            intersectedValues.removeValue(forKey: state.rawValue)
        }
    }
    
    private func setValue(_ value: Any?, for state: UIControlState) {
        if let val = value {
            values[state.rawValue] = val
        } else {
            values.removeValue(forKey: state.rawValue)
        }
    }
    
    func value(for state: UIControlState) -> Any? {
        var value = values[state.rawValue]
        if (value == nil) {
            let invertedState = invertedStates.index(options: NSEnumerationOptions(rawValue: 0)) { (invertedState, stop) -> Bool in
                if (state.rawValue & UInt(invertedState)) != UInt(invertedState) { // now not inverted, need rename
                    stop.pointee = true
                    return true
                }
                return false
            }
            if invertedState != NSNotFound {
                value = values[~UInt(invertedState)]
            }
        }
        if (value == nil) {
            let intersectedState = self.intersectedStates.index(options: NSEnumerationOptions(rawValue: 0)) { (intersectedState, stop) -> Bool in
                if (state.rawValue & UInt(intersectedState)) == UInt(intersectedState) {
                    stop.pointee = true
                    return true
                }
                return false
            }
            if intersectedState != NSNotFound {
                value = intersectedValues[UInt(intersectedState)]
            }
        }
        return value
    }
}
