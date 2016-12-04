//
//  QUIckControlValueTarget.swift
//  QUIckControl
//
//  Created by Denis Koryttsev on 06/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import UIKit

public func instancetype<T>(object: Any?) -> T? {
    return object as? T
}

class QUIckControlValueTarget: StatesApplier {
    typealias ApplyObject = NSObject
    typealias StateType = UIControlState
    
    private var values = [String: QUIckControlValue]()
    private var defaults = [String: Any]()
    weak var target: NSObject!
    
    init(target: NSObject) {
        self.target = target
    }
    
    func setValue(_ value: Any?, forKeyPath key: String, for descriptor: QUICStateDescriptor) {
        keyValue(forKey: key).setValue(value, for: descriptor)
    }
    
    private func keyValue(forKey key: String) -> QUIckControlValue {
        var keyValue = values[key]
        if (keyValue == nil) {
            keyValue = registerKey(key)
        }
        return keyValue!
    }
    
    private func registerKey(_ key: String) -> QUIckControlValue {
        let keyValue = QUIckControlValue(key: key)
        values[key] = keyValue
        let defaultValue = target.value(forKeyPath: key)
        if (defaultValue != nil) {
            defaults[key] = defaultValue
        }
        return keyValue
    }
    
    func apply(state: UIControlState, for target: NSObject) {
        for (key, value) in values {
            let keyValue = value.value(for: state)
            target.setValue(instancetype(object: keyValue ?? defaults[key]), forKeyPath: key)
        }
    }
    
    func apply(state: UIControlState) {
        apply(state: state, for: target)
    }
    
    func applyValue(_ value: Any?, forKey key: String) {
        target.setValue(instancetype(object: value), forKeyPath: key)
    }
    
    func valueForKey(key: String, forState state: UIControlState) -> Any? {
        return values[key]?.value(for: state) ?? defaults[key]
    }
    
    func removeValues() {
        values.removeAll()
    }
    
    func removeValues(for key: String) {
        values.removeValue(forKey: key)
    }
    
    func removeValues(for key: String, forState state: UIControlState) {
        values[key]?.removeValues(for: state)
    }
}
