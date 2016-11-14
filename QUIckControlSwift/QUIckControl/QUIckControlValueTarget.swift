//
//  QUIckControlValueTarget.swift
//  QUIckControl
//
//  Created by Denis Koryttsev on 06/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import UIKit

public func instancetype<T>(object: Any) -> T {
    return object as! T
}

class QUIckControlValueTarget {
    private var values = [String: QUIckControlValue]()
    private var defaults = [String: Any]()
    weak var target: NSObject!
    
    init(target: NSObject) {
        self.target = target
    }
    
    func setValue(_ value: Any?, forKeyPath key: String, for descriptor: QUICState) {
        keyValue(forKey: key, registerIfNeeded: value != nil).setValue(value, for: descriptor)
    }
    
    private func keyValue(forKey key: String, registerIfNeeded needed: Bool) -> QUIckControlValue {
        var keyValue = values[key]
        if (keyValue == nil) && needed {
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
    
    func applyValues(for state: UIControlState) {
        for (key, value) in values {
            let keyValue = value.value(for: state)
            target.setValue(instancetype(object: keyValue ?? defaults[key]), forKeyPath: key)
        }
    }
    
    func applyValue(_ value: Any, forKey key: String) {
        target.setValue(instancetype(object: value), forKeyPath: key)
    }
    
    // intersected states not corrected working if two intersected states mathed in current state and contained values for same key.	
    func valueForKey(key: String, forState state: UIControlState) -> Any? {
        return values[key]?.value(for: state) ?? defaults[key]
    }
}
