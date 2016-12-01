//
//  Statable.swift
//  Statable
//
//  Created by Denis Koryttsev on 21/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import Foundation

protocol Statable {
    associatedtype StateType
    associatedtype StatePredicate
    
    var stateUnits: [StatePredicate] { get }
    var state: StateType { get } // TODO: optional
    
    func apply(_ state: StateType)
}

extension Statable {
    func applyCurrentState() {
        apply(state)
    }
}

protocol StatePredicate/*: Equatable*/ {
    //    associatedtype StateType
    associatedtype EvaluatedObject: Statable
    //    var state: StateType { get } // optional
    
    func evaluate(_ object: EvaluatedObject) -> Bool
}

protocol StateApplier {
    associatedtype ApplyObject: Statable
    
    func apply(_ object: ApplyObject)
}
