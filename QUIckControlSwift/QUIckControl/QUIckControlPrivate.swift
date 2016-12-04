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

class QUIckControlStateFactor<Control: QUIckControl>: Predicate, StateFactor {
    typealias EvaluatedEntity = Control
    typealias StateType = UIControlState
    
    let predicate: NSPredicate
    let state: UIControlState
    
    required init(state: UIControlState, predicate: NSPredicate) {
        self.state = state
        self.predicate = predicate
    }
    
    func evaluate(with object: Control) -> Bool {
        return predicate.evaluate(with: object)
    }
    
    func mark(state: inout UIControlState) {
        state.formUnion(self.state)
    }
}

class QUIckControlSubscriber: StateSubscriber {
    typealias EvaluatedEntity = UIControlState
    
    let action: () -> ()
    let descriptor: QUICStateDescriptor

    init(for descriptor: QUICStateDescriptor, action: @escaping () -> ()) {
        self.action = action
        self.descriptor = descriptor
    }
    
    func invoke() {
        action()
    }
    
    func evaluate(with entity: UIControlState) -> Bool {
        return descriptor.evaluate(with: entity)
    }
}

// for example using BlockPredicate
class QUIckControlFactor<Control: QUIckControl>: BlockPredicate<Control>, StateFactor {
    typealias StateType = UIControlState
    
    let state: StateType
    
    required init(state: UIControlState, predicate: @escaping (_ object: Control) -> Bool) {
        self.state = state
        
        super.init(predicate: predicate)
    }
    
    func mark(state: inout UIControlState) {
        state.formUnion(self.state)
    }
}

// deprecated

struct QBoolStateFactor: Predicate {
    typealias EvaluatedEntity = QUIckControl
    let property: String
    let state: UIControlState
    let inverted: Bool
    
    func evaluate(with object: QUIckControl) -> Bool {
        let propertyValue = object.value(forKeyPath: property) as! Bool
        return Bool(propertyValue.hashValue ^ inverted.hashValue)
    }
}
