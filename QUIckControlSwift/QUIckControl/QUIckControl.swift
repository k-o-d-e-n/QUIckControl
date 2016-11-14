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

open class QUIckControl : UIControl {
    var isTransitionTime = false
    lazy var thisValueTarget: QUIckControlValueTarget = QUIckControlValueTarget(target: self)
    var states = [QUIckControlState]()
    var targets = [QUIckControlValueTarget]()
    let scheduledActions = NSMutableSet()
    var actionTargets = [QUIckControlActionTarget]()
    
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
    
    func commitTransition() {
        if !isTransitionTime { return }
        
        isTransitionTime = false
        applyCurrentState()
        for action: Any in scheduledActions {
            sendActions(for: action as! UIControlEvents)
        }
        scheduledActions.removeAllObjects()
    }
    
    func performTransition(_ transition: @escaping () -> Void) {
        beginTransition()
        transition()
        commitTransition()
    }
    
    func register(_ state: UIControlState, forBoolKeyPath keyPath: String, inverted: Bool) {
        // & UIControlStateApplication ?
        states.append(QUIckControlState(property: keyPath, controlState: state, inverted: inverted))
    }
    
    // MARK: - Actions
    
    func addAction(for events: UIControlEvents, _ action: @escaping (QUIckControl) -> Void) -> QUIckControlActionTarget {
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
    
    func removeValues(forTarget target: NSObject) {
        let targetIndex = indexOfTarget(target)
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
        if descriptor.evaluate(state) {
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
    
    func applyCurrentState(forTarget target: NSObject) {
        valueTarget(forTarget: target).applyValues(for: state)
    }
    
    func apply(_ state: UIControlState) {
        if isTransitionTime { return }
        
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
    
    func applyCurrentState() {
        apply(state)
    }
    
    override open var state: UIControlState {
        var result: UInt = 0
        for stateValue in states {
            if stateValue.evaluate(self) {
                result |= stateValue.controlState.rawValue
            }
        }
        return UIControlState(rawValue: result)
    }
    
    deinit {
        for target in actionTargets {
            target.stop()
        }
        actionTargets.removeAll()
    }
}
