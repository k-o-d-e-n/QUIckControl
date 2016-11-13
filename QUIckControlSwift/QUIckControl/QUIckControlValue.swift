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
    private var values = [QUICState: Any]()
    
    init(key: String) {
        self.key = key
    }
    
    func setValue(_ value: Any, for descriptor: QUICState) {
        values[descriptor] = value
    }
    
    func value(for state: UIControlState) -> Any? {
        return values
            .filter { return $0.key.evaluate(state) }
            .max { $0.key.priority < $1.key.priority }?
            .value
    }
}
