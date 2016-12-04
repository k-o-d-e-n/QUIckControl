//
//  QUICStateDescriptorKey.swift
//  QUIckControl
//
//  Created by Denis Koryttsev on 06/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import UIKit

protocol QUICStateDescriptor: Hashable, StateDescriptor {
    var priority: Int { get }
}

enum QUICStateType : Int16 {
    case usual
    case intersected
    case inverted
    case oneOfSeveral
    case noneOfThis
    case custom
}

struct QUICState: QUICStateDescriptor {
    typealias StateType = UIControlState
    typealias EvaluatedEntity = UIControlState
    
    let priority: Int
    let state: UIControlState
    let type: QUICStateType
    private let predicate: (_ state: UIControlState) -> Bool
    var hashValue: Int { return Int(state.rawValue) * priority }
    
    init(priority: Int, predicate: @escaping (_ state: UIControlState) -> Bool) {
        self.init(state: .normal, type: .custom, priority: priority, predicate: predicate)
    }
    
    init(state: UIControlState, type: QUICStateType) {
        self.init(state: state, type: type, priority: QUICState.priorityFor(stateType: type), predicate: nil)
    }
    
    private init(state: UIControlState, type: QUICStateType, priority: Int, predicate: ((_ state: UIControlState) -> Bool)?) {
        self.priority = priority
        self.state = state
        self.type = type
        switch (type) {
        case .usual:
            self.predicate = { state == $0 }
        case .inverted:
            self.predicate = { (state.rawValue & $0.rawValue) != state.rawValue }
        case .intersected:
            self.predicate = { (state.rawValue & $0.rawValue) == state.rawValue }
        case .oneOfSeveral:
            self.predicate = { (state.rawValue & $0.rawValue) != 0 }
        case .noneOfThis:
            self.predicate = { (state.rawValue & $0.rawValue) == 0 }
        case .custom:
            self.predicate = predicate ?? { _ in return true }
        }
    }
    
    func evaluate(with entity: UIControlState) -> Bool {
        return predicate(entity)
    }
    
    static public func ==(lhs: QUICState, rhs: QUICState) -> Bool {
        return lhs.state == rhs.state && lhs.priority == rhs.priority
    }
    
    private static func priorityFor(stateType type: QUICStateType) -> Int {
        switch type {
        case .usual: return 1000
        case .intersected: return 999
        case .inverted: return 750
        case .oneOfSeveral, .noneOfThis: return 500
        default: return 250
        }
    }
}
