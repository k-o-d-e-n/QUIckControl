//
//  QUICStateDescriptorKey.swift
//  QUIckControl
//
//  Created by Denis Koryttsev on 06/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import UIKit
import Statable

public final class QUICStateDescriptor: BlockPredicate<UIControl.State>, Hashable, StateDescriptor {
    public typealias StateType = UIControl.State
    
    public let priority: Int
    public let state: UIControl.State // is used only as identifier, may be deleted, because not used as required
    public func hash(into hasher: inout Hasher) {
        hasher.combine(state.rawValue)
        hasher.combine(priority)
    }

    override init(predicate: @escaping (_ object: UIControl.State) -> Bool) {
        fatalError("This initializer not used")
    }
    
    public convenience init(usual: UIControl.State, priority: Int = 1000) {
        self.init(state: usual, priority: priority, predicate: { usual == $0 })
    }
    
    public convenience init(inverted: UIControl.State, priority: Int = 750) {
        self.init(state: inverted, priority: priority, predicate: { (inverted.rawValue & $0.rawValue) != inverted.rawValue })
    }
    
    public convenience init(intersected: UIControl.State, priority: Int = 999) {
        self.init(state: intersected, priority: priority, predicate: { (intersected.rawValue & $0.rawValue) == intersected.rawValue })
    }
    
    public convenience init(oneOfSeveral: UIControl.State, priority: Int = 500) {
        self.init(state: oneOfSeveral, priority: priority, predicate: { (oneOfSeveral.rawValue & $0.rawValue) != 0 })
    }
    
    public convenience init(noneOfThis: UIControl.State, priority: Int = 500) {
        self.init(state: noneOfThis, priority: priority, predicate: { (noneOfThis.rawValue & $0.rawValue) == 0 })
    }
    
    public init(state: UIControl.State, priority: Int, predicate: @escaping (_ state: UIControl.State) -> Bool) {
        self.priority = priority
        self.state = state
        super.init(predicate: predicate)
    }
    
    static public func ==(lhs: QUICStateDescriptor, rhs: QUICStateDescriptor) -> Bool {
        return lhs.state == rhs.state && lhs.priority == rhs.priority
    }
}

// deprecated

enum QUICStateType : Int16 {
    case usual
    case intersected
    case inverted
    case oneOfSeveral
    case noneOfThis
    case custom
}
