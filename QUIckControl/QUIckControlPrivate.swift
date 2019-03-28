//
//  QUIckControlPrivate.swift
//  QUIckControl
//
//  Created by Denis Koryttsev on 07/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import UIKit
import Statable

private extension Bool {
    init<T : BinaryInteger>(_ integer: T) {
        self.init(integer != 0)
    }
}

public final class QUIckControlStateFactor<Control: QUIckControl>: Predicate, StateFactor {
    public typealias EvaluatedEntity = Control
    public typealias StateType = UIControl.State
    
    let predicate: NSPredicate
    let state: UIControl.State
    
    required public init(state: UIControl.State, predicate: NSPredicate) {
        self.state = state
        self.predicate = predicate
    }
    
    public func evaluate(with object: Control) -> Bool {
        return predicate.evaluate(with: object)
    }
    
    public func mark(state: inout UIControl.State) {
        state.formUnion(self.state)
    }
}

final class QUIckControlSubscriber: StateSubscriber {
    typealias EvaluatedEntity = UIControl.State
    
    let action: () -> ()
    let descriptor: QUICStateDescriptor

    init(for descriptor: QUICStateDescriptor, action: @escaping () -> ()) {
        self.action = action
        self.descriptor = descriptor
    }
    
    func invoke() {
        action()
    }
    
    func evaluate(with entity: UIControl.State) -> Bool {
        return descriptor.evaluate(with: entity)
    }
}

// for example using BlockPredicate
final class QUIckControlFactor<Control: QUIckControl>: BlockPredicate<Control>, StateFactor {
    typealias StateType = UIControl.State
    
    let state: StateType
    
    required init(state: UIControl.State, predicate: @escaping (_ object: Control) -> Bool) {
        self.state = state
        
        super.init(predicate: predicate)
    }
    
    func mark(state: inout UIControl.State) {
        state.formUnion(self.state)
    }
}

// deprecated

struct QBoolStateFactor: Predicate {
    typealias EvaluatedEntity = QUIckControl
    let property: String
    let state: UIControl.State
    let inverted: Bool
    
    func evaluate(with object: QUIckControl) -> Bool {
        let propertyValue = object.value(forKeyPath: property) as! Bool
        return Bool(propertyValue.hashValue ^ inverted.hashValue)
    }
}
