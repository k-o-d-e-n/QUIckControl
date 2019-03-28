//
//  QUIckControlValue.swift
//  QUIckControl
//
//  Created by Denis Koryttsev on 06/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import UIKit

final class QUIckControlValue {
    let key: String
    private var values = [QUICStateDescriptor: Any]()
    
    init(key: String) {
        self.key = key
    }
    
    // TODO: Find decision problem with idle descriptors
    func setValue(_ value: Any?, for descriptor: QUICStateDescriptor) {
        values[descriptor] = value
    }
    
    func value(for state: UIControl.State) -> Any? {
        return values
            .filter { return $0.key.evaluate(with: state) }
            .max { $0.key.priority < $1.key.priority }?
            .value
    }
    
    func removeValues(for state: UIControl.State) {
        while let index = values.index(where: { return $0.key.evaluate(with: state) }) {
            values.remove(at: index)
        }
    }
}
