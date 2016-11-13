//
//  QUIckControlPrivate.swift
//  QUIckControl
//
//  Created by Denis Koryttsev on 07/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import UIKit

private extension Bool {
    init<T : Integer>(_ integer: T) {
        self.init(integer != 0)
    }
}

struct QUIckControlState {
    let property: String
    let controlState: UIControlState // use raw value instead
    let inverted: Bool
    
    func evaluate(_ object: NSObject) -> Bool {
        let propertyValue = object.value(forKeyPath: property) as! Bool
        return Bool(propertyValue.hashValue ^ inverted.hashValue)
    }
}
