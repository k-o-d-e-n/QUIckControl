//
//  QUICStateDescriptorKey.swift
//  QUIckControl
//
//  Created by Denis Koryttsev on 06/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import UIKit

protocol QUICStateProtocol {
    var state: UIControlState { get }
    func evaluate(_ controlState: UIControlState) -> Bool
}

enum QUICStateType : Int16 {
    case usual
    case inverted
    case intersected
}

struct QUICStateDescriptor: QUICStateProtocol {
    let state: UIControlState
    let type: QUICStateType
    private let evaluateFunction: (_ state: UIControlState) -> Bool
    
    init(state: UIControlState, type: QUICStateType) {
        self.state = state
        self.type = type
        switch (type) {
        case .usual:
            evaluateFunction = { state == $0 }
        case .inverted:
            evaluateFunction = { $0 != .normal && (state.rawValue & $0.rawValue) != state.rawValue }
        case .intersected:
            evaluateFunction = { (state.rawValue & $0.rawValue) == state.rawValue }
        }
    }
    
    func evaluate(_ controlState: UIControlState) -> Bool {
        return evaluateFunction(controlState)
    }
}
