//
//  QUIckControl.swift
//  QUIckControl
//
//  Created by Denis Koryttsev on 23/10/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import UIKit

protocol QUIckControlActionTarget {
    func start()
    func stop()
}

open class QUIckControl : UIControl, KnownStatable {
    typealias StateFactor = QUIckControlStateFactor<QUIckControl>
    typealias StateType = UIControlState
    
    var isTransitionTime = false
    lazy var thisValueTarget: QUIckControlValueTarget = QUIckControlValueTarget(target: self)
    var factors = [StateFactor]()
    var targets = [QUIckControlValueTarget]()
    let scheduledActions = NSMutableSet()
    var actionTargets = [QUIckControlActionTarget]()
    internal var comparedState: UIControlState = .normal
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        registerExistedStates()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        registerExistedStates()
    }
    
    func registerExistedStates() {
        register(.selected, forBoolKeyPath: #keyPath(UIControl.selected), inverted: false)
        register(.highlighted, forBoolKeyPath: #keyPath(UIControl.highlighted), inverted: false)
        register(.disabled, forBoolKeyPath: #keyPath(UIControl.enabled), inverted: true)
    }
    
    // MARK: States
    
    override open var isSelected: Bool {
        didSet { if oldValue != isSelected { applyCurrentState() } }
    }

    override open var isEnabled: Bool {
        didSet { if oldValue != isEnabled { applyCurrentState() } }
    }
    
    override open var isHighlighted: Bool {
        didSet { if oldValue != isHighlighted { applyCurrentState() } }
    }
    
    func beginTransition() {
        isTransitionTime = true
    }
    
    func endTransition() {
        isTransitionTime = false
        scheduledActions.removeAllObjects()
    }
    
    func commitTransition() {
        if !isTransitionTime { return }
        
        isTransitionTime = false
        applyCurrentState()
        for action: Any in scheduledActions {
            sendActions(for: action as! UIControlEvents)
        }
        scheduledActions.removeAllObjects()
    }
    
    func performTransition(withCommit commit: Bool = true, transition: () -> Void) {
        beginTransition()
        transition()
        commit ? commitTransition() : endTransition()
    }
    
    func register(_ state: UIControlState, forBoolKeyPath keyPath: String, inverted: Bool) {
        // & UIControlStateApplication ?
//        factors.append(QBoolStateFactor(property: keyPath, state: state, inverted: inverted))
        factors.append(QUIckControlStateFactor(state: state, predicate: NSPredicate(format: "\(keyPath) == \(inverted ? "NO" : "YES")")))
        
        // example use block factor
//        let boolFactor = QBoolStateFactor(property: keyPath, state: state, inverted: inverted)
//        factors.append(StateFactor(state: state, predicate: { (control) -> Bool in
//            return boolFactor.evaluate(with: control)
//        }))
    }
    
    func register(_ state: UIControlState, with predicate: NSPredicate) {
        factors.append(QUIckControlStateFactor(state: state, predicate: predicate))
    }
    
    // example use block factor
//    func register(_ state: UIControlState, with factor: @escaping (_ object: QUIckControl) -> Bool) {
//        factors.append(StateFactor(state: state, predicate: factor))
//    }
    
    // MARK: - Actions
    
    func subscribe(on events: UIControlEvents, _ action: @escaping (QUIckControl) -> Void) -> QUIckControlActionTarget {
        let actionTarget = QUIckControlActionTargetImp(control: self, controlEvents: events)
        actionTarget.action = action
        actionTargets.append(actionTarget)
        return actionTarget
    }
    
    override open func sendActions(for controlEvents: UIControlEvents) {
        if isTransitionTime {
            scheduledActions.add(controlEvents)
            return
        }
        super.sendActions(for: controlEvents)
    }
    
    // MARK: - Values
    
    func removeValues(forTarget target: NSObject, forKeyPath key: String, forState state: UIControlState) {
        valueTarget(forTarget: target).removeValues(for: key, forState: state)
    }
    
    func removeValues(forTarget target: NSObject, forKeyPath key: String) {
        valueTarget(forTarget: target).removeValues(for: key)
    }
    
    func removeValues(forTarget target: NSObject? = nil) {
        guard let externalTarget = target else { thisValueTarget.removeValues(); return }
        
        let targetIndex = indexOfTarget(externalTarget)
        if targetIndex != nil {
            targets.remove(at: targetIndex!)
        }
    }
    
    func setValue(_ value: Any?, forTarget target: NSObject, forKeyPath key: String, forInvertedState state: UIControlState) {
        setValue(value, forTarget: target, forKeyPath: key, for: QUICState(state: state, type: .inverted))
    }
    
    func setValue(_ value: Any?, forTarget target: NSObject, forKeyPath key: String, forAllStatesContained state: UIControlState) {
        setValue(value, forTarget: target, forKeyPath: key, for: QUICState(state: state, type: .intersected))
    }
    
    func setValue(_ value: Any?, forKeyPath key: String, for state: UIControlState) {
        setValue(value, forTarget: self, forKeyPath: key, for: state)
    }
    
    func setValue(_ value: Any?, forTarget target: NSObject, forKeyPath key: String, for state: UIControlState) {
        setValue(value, forTarget: target, forKeyPath: key, for: QUICState(state: state, type: .usual))
    }
    
    func setValue(_ value: Any?, forTarget target: NSObject? = nil, forKeyPath key: String, for descriptor: QUICState) {
        let valTarget = valueTarget(forTarget: target ?? self)
        valTarget.setValue(value, forKeyPath: key, for: descriptor)
        if descriptor.evaluate(with: state) {
            valTarget.applyValue(value, forKey: key)
        }
    }
    
    private func indexOfTarget(_ target: NSObject) -> Int? {
        return targets.index(where: { return $0.target.isEqual(target) })
    }
    
    private func valueTarget(forTarget target: NSObject!) -> QUIckControlValueTarget {
        if self == target { return thisValueTarget }
        
        var index = indexOfTarget(target)
        if index == nil {
            let valueTarget = QUIckControlValueTarget(target: target)
            targets.append(valueTarget)
            index = targets.count - 1
        }
        return targets[index!]
    }
    
    // MARK: - Apply state values
    
    func applyCurrentState() {
        guard !isTransitionTime else { return }
        
        let currentState = state
        guard comparedState != currentState else { return }
        
        apply(state: currentState)
        comparedState = currentState
    }
    
    func applyCurrentState(forTarget target: NSObject) {
        valueTarget(forTarget: target).applyValues(for: state)
    }
    
    // force apply state
    internal func apply(state: UIControlState) {
        setNeedsDisplay()
        setNeedsLayout()
        thisValueTarget.applyValues(for: state)
        for target: QUIckControlValueTarget in targets {
            target.applyValues(for: state)
        }
    }
    
    func value(for target: NSObject, forKey key: String, for state: UIControlState) -> Any? {
        return valueTarget(forTarget: target).valueForKey(key: key, forState: state)
    }
    
    override open var state: UIControlState {
        var result: UIControlState = .normal
        for factor in factors {
            factor.mark(state: &result, ifEvaluatedWith: self)
        }
        return result
    }
    
    deinit {
        for target in actionTargets {
            target.stop()
        }
        actionTargets.removeAll()
    }
}
