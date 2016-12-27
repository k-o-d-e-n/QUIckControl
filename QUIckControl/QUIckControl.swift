//
//  QUIckControl.swift
//  QUIckControl
//
//  Created by Denis Koryttsev on 23/10/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import UIKit
import Statable

public protocol QUIckControlActionTarget {
    func start()
    func stop()
}

open class QUIckControl : UIControl, KnownStatable {
    public typealias Factor = QUIckControlStateFactor<QUIckControl>
    public typealias StateType = UIControlState
    
    public var isTransitionTime = false
    private lazy var thisValueTarget: QUIckControlValueTarget = QUIckControlValueTarget(target: self)
    
    public var factors = [Factor]()
    private var targets = [QUIckControlValueTarget]()
    private let scheduledActions = NSMutableSet()
    private var actionTargets = [QUIckControlActionTarget]()
    private lazy var subscribers: [QUIckControlSubscriber] = [QUIckControlSubscriber]()
    public var lastAppliedState: UIControlState = .normal {
        didSet {
            for subscriber in subscribers {
                subscriber.invoke(ifMatched: lastAppliedState)
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        registerExistedStates()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        registerExistedStates()
    }
    
    private func registerExistedStates() {
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
    
    public func beginTransition() {
        isTransitionTime = true
    }
    
    public func endTransition() {
        isTransitionTime = false
        scheduledActions.removeAllObjects()
    }
    
    public func commitTransition() {
        if !isTransitionTime { return }
        
        isTransitionTime = false
        applyCurrentState()
        for action: Any in scheduledActions {
            sendActions(for: action as! UIControlEvents)
        }
        scheduledActions.removeAllObjects()
    }
    
    public func performTransition(withCommit commit: Bool = true, transition: () -> Void) {
        beginTransition()
        transition()
        commit ? commitTransition() : endTransition()
    }
    
    public func register(_ state: UIControlState, forBoolKeyPath keyPath: String, inverted: Bool) {
        // & UIControlStateApplication ?
//        factors.append(QBoolStateFactor(property: keyPath, state: state, inverted: inverted))
        factors.append(QUIckControlStateFactor(state: state, predicate: NSPredicate(format: "\(keyPath) == \(inverted ? "NO" : "YES")")))
        
        // example use block factor
//        let boolFactor = QBoolStateFactor(property: keyPath, state: state, inverted: inverted)
//        factors.append(StateFactor(state: state, predicate: { (control) -> Bool in
//            return boolFactor.evaluate(with: control)
//        }))
    }
    
    public func register(_ state: UIControlState, with predicate: NSPredicate) {
        factors.append(QUIckControlStateFactor(state: state, predicate: predicate))
    }
    
    // example use block factor
//    func register(_ state: UIControlState, with factor: @escaping (_ object: QUIckControl) -> Bool) {
//        factors.append(StateFactor(state: state, predicate: factor))
//    }
    
    // MARK: - Actions
    
    open func subscribe(on events: UIControlEvents, _ action: @escaping (QUIckControl) -> Void) -> QUIckControlActionTarget {
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
    
    open func subscribe(on state: QUICStateDescriptor, _ action: @escaping () -> ()) {
        self.subscribers.append(QUIckControlSubscriber(for: state, action: action))
    }
    
    // MARK: - Values
    
    public func removeValues(forTarget target: NSObject, forKeyPath key: String, forState state: UIControlState) {
        valueTarget(forTarget: target).removeValues(for: key, forState: state)
    }
    
    public func removeValues(forTarget target: NSObject, forKeyPath key: String) {
        valueTarget(forTarget: target).removeValues(for: key)
    }
    
    public func removeValues(forTarget target: NSObject? = nil) {
        guard let externalTarget = target else { thisValueTarget.removeValues(); return }
        
        let targetIndex = indexOfTarget(externalTarget)
        if targetIndex != nil {
            targets.remove(at: targetIndex!)
        }
    }
    
    public func setValue(_ value: Any?, forTarget target: NSObject, forKeyPath key: String, forInvertedState state: UIControlState) {
        setValue(value, forTarget: target, forKeyPath: key, for: QUICStateDescriptor(inverted: state))
    }
    
    public func setValue(_ value: Any?, forTarget target: NSObject, forKeyPath key: String, forAllStatesContained state: UIControlState) {
        setValue(value, forTarget: target, forKeyPath: key, for: QUICStateDescriptor(intersected: state))
    }
    
    public func setValue(_ value: Any?, forKeyPath key: String, for state: UIControlState) {
        setValue(value, forTarget: self, forKeyPath: key, for: state)
    }
    
    public func setValue(_ value: Any?, forTarget target: NSObject, forKeyPath key: String, for state: UIControlState) {
        setValue(value, forTarget: target, forKeyPath: key, for: QUICStateDescriptor(usual: state))
    }
    
    public func setValue(_ value: Any?, forTarget target: NSObject? = nil, forKeyPath key: String, for descriptor: QUICStateDescriptor) {
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
    
    open func applyCurrentState() {
        guard !isTransitionTime else { return }
        
        let currentState = state
        guard lastAppliedState != currentState else { return }
        
        apply(state: currentState)
        lastAppliedState = currentState
    }
    
    open func applyCurrentState(forTarget target: NSObject) {
        valueTarget(forTarget: target).apply(state: state)
    }
    
    // force apply state
    open func apply(state: UIControlState) {
        setNeedsDisplay()
        setNeedsLayout()
        thisValueTarget.apply(state: state)
        for target: QUIckControlValueTarget in targets {
            target.apply(state: state)
        }
    }
    
    public func value(for target: NSObject, forKey key: String, for state: UIControlState) -> Any? {
        return valueTarget(forTarget: target).valueForKey(key: key, forState: state)
    }
    
    override open var state: UIControlState {
        var result: UIControlState = .normal
        for factor in factors {
            factor.mark(state: &result, ifEvaluatedWith: self)
        }
        return result
    }

    // MARK: Deinitialier
    
    deinit {
        for target in actionTargets {
            target.stop()
        }
        actionTargets.removeAll()
    }
}
