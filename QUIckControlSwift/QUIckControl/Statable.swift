//
//  Statable.swift
//  Statable
//
//  Created by Denis Koryttsev on 21/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import Foundation

// MARK: Statable

protocol AnonymStatable {
    associatedtype StateType
    associatedtype Factor: Predicate
    
    var factors: [Factor] { get }
    
    func apply(state: StateType)
}

protocol Statable: AnonymStatable {
    var state: StateType { get }
}

extension Statable {
    func applyCurrentState() {
        apply(state: state)
    }
}

/*!
     override func applyCurrentState() {
        let currentState = state
        if (oldState == currentState) return
     
        super.applyCurrentState()
     }
 */
protocol KnownStatable: Statable {
    var storedState: StateType { get }
}

// MARK: Predicates

protocol Predicate {
    associatedtype EvaluatedEntity
    
    func evaluate(with entity: EvaluatedEntity) -> Bool
}

protocol StateFactor: Predicate {
    associatedtype StateType
    
    func mark(state: inout StateType)
}

extension StateFactor {
    func mark(state: inout StateType, ifEvaluatedWith entity: EvaluatedEntity) {
        if evaluate(with: entity) {
            mark(state: &state)
        }
    }
}

protocol StateDescriptor: Predicate {
    var state: EvaluatedEntity { get }
    
    func evaluate(with entity: EvaluatedEntity) -> Bool
}

// MARK: State Appliers

protocol StateApplier {
    associatedtype ApplyTarget
    
    func apply(for target: ApplyTarget)
}

protocol StatesApplier {
    associatedtype StateType
    associatedtype ApplyTarget
    
    func apply(state: StateType, for target: ApplyTarget)
}

// MARK: Subscribers

protocol StateSubscriber: Predicate {
    func invoke()
}

extension StateSubscriber {
    func invoke(ifMatched entity: EvaluatedEntity) {
        if evaluate(with: entity) {
            invoke()
        }
    }
}
