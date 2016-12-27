//
//  QUICStateDescriptorKey.swift
//  QUIckControl
//
//  Created by Denis Koryttsev on 06/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import UIKit
import Statable

public class QUICStateDescriptor: BlockPredicate<UIControlState>, Hashable, StateDescriptor {
    public typealias StateType = UIControlState
    
    public let priority: Int
    public let state: UIControlState // is used only as identifier, may be deleted, because not used as required
    public var hashValue: Int { return Int(state.rawValue) * priority }
    
    override init(predicate: @escaping (_ object: UIControlState) -> Bool) {
        fatalError("This initializer not used")
    }
    
    public convenience init(usual: UIControlState, priority: Int = 1000) {
        self.init(state: usual, priority: priority, predicate: { usual == $0 })
    }
    
    public convenience init(inverted: UIControlState, priority: Int = 750) {
        self.init(state: inverted, priority: priority, predicate: { (inverted.rawValue & $0.rawValue) != inverted.rawValue })
    }
    
    public convenience init(intersected: UIControlState, priority: Int = 999) {
        self.init(state: intersected, priority: priority, predicate: { (intersected.rawValue & $0.rawValue) == intersected.rawValue })
    }
    
    public convenience init(oneOfSeveral: UIControlState, priority: Int = 500) {
        self.init(state: oneOfSeveral, priority: priority, predicate: { (oneOfSeveral.rawValue & $0.rawValue) != 0 })
    }
    
    public convenience init(noneOfThis: UIControlState, priority: Int = 500) {
        self.init(state: noneOfThis, priority: priority, predicate: { (noneOfThis.rawValue & $0.rawValue) == 0 })
    }
    
    public init(state: UIControlState, priority: Int, predicate: @escaping (_ state: UIControlState) -> Bool) {
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
