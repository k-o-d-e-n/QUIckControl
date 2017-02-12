//
//  PinCodeControl.swift
//  QUIckControl
//
//  Created by Denis Koryttsev on 07/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import UIKit
import Statable
import QUIckControl

extension UIControlEvents {
    public static var typeComplete = UIControlEvents(rawValue: 1 << 24)
}

extension UIControlState {
    public static var filled = UIControlState(rawValue: 1 << 16)
    public static var invalid = UIControlState(rawValue: 1 << 17)
    public static let valid = UIControlState(rawValue: (1 << 18) | filled.rawValue)
}

fileprivate class ValueApplier: NSObject {
    private weak var control: PinCodeControl!
    
    init(control: PinCodeControl) {
        super.init()
        
        self.control = control
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        if control.sublayers.count == 0 { return }
        
        if !key.isEqual(#keyPath(CAShapeLayer.fillColor)) || control.codeLength == control.code.characters.count {
            control.sublayers.forEach { $0.setValue(value, forKey: key) }
            return
        }
        for i in 0..<control.codeLength {
            let value = i < control.code.characters.count ? (control.filledItemColor?.cgColor as Any?) : value
            control.sublayers[i].setValue(value, forKey: key)
        }
    }
    
    override func value(forKeyPath keyPath: String) -> Any? {
        return control.sublayers.last?.value(forKeyPath: keyPath)
    }
}

// TODO: Remove limit on input only numbers. Create enum with types of control for enter secure code. Create base class SecureCodeControl with private class PinCodeControl.
@IBDesignable open class PinCodeControl: QUIckControl, UIKeyInput, UITextInputTraits {
    /// preset states
    public enum States {
        public static let plain = QUICStateDescriptor(inverted: .filled)
        public static let valid = QUICStateDescriptor(intersected: .valid)
        public static let invalid = QUICStateDescriptor(intersected: [.filled, .invalid])
        public static let highlighted = QUICStateDescriptor(intersected: .highlighted)
        public static let disabled = QUICStateDescriptor(intersected: .disabled, priority: 1000)
    }
    
    /// structure for initialize
    public struct Parameters {
        let length: Int
        let spaceSize: CGFloat
        let sideSize: CGFloat
        
        public init(length: Int, spaceSize: CGFloat, sideSize: CGFloat) {
            self.length = length
            self.spaceSize = spaceSize
            self.sideSize = sideSize
        }
    }
    
    /// current code string
    open var code: String { return text }
    
    /// full pin code length == count code items
    @IBInspectable open private(set) var codeLength: Int = 0 {
        didSet { if (oldValue != codeLength) { loadSublayers() } }
    }
    
    /// space between code items
    @IBInspectable open var spaceSize: CGFloat = 15 {
        didSet { if (oldValue != spaceSize && codeLength != 0) { setNeedsLayout() } }
    }
    
    /// size of side code item
    @IBInspectable open private(set) var sideSize: CGFloat = 0 {
        didSet { if (oldValue != sideSize) { loadDefaultPath(); setNeedsLayout() } }
    }
    
    /// filled state, yes when code type ended.
    open private(set) var filled = false {
        didSet {
            if oldValue != filled {
                applyCurrentState()
                if filled { sendActions(for: .typeComplete) }
            }
        }
    }
    
    /// valid state, yes if entered code is valid.
    open private(set) var valid = true {
        didSet { if oldValue != valid { applyCurrentState() } }
    }
    
    /// object for user validation pin code value.
    open var validator: BlockPredicate<String>?
    
    /// if true, then code equal strings, such as '1111', '1234', '9876' will be defined as invalid values
    open var shouldUseDefaultValidation = true
    
    /// color for filled code item
    open dynamic var filledItemColor: UIColor?
    
    /// bezier path for code item
    open var itemPath: UIBezierPath?
    
    private lazy var applier: ValueApplier = ValueApplier(control: self)
    private var text = String()
    fileprivate var sublayers: [CAShapeLayer] { return (layer.sublayers as? [CAShapeLayer]) ?? [] }
    private var defaultPath: UIBezierPath!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeInstance()
    }
    
    required public init(parameters: Parameters, frame: CGRect? = nil) {
        super.init(frame: frame ?? .zero)
        initializeInstance()
        
        self.spaceSize = parameters.spaceSize
        self.sideSize = parameters.sideSize
        self.codeLength = parameters.length
        
        loadDefaultPath()
        loadSublayers()
    }
    
    public override init(frame: CGRect) {
        #if !TARGET_INTERFACE_BUILDER
            fatalError("You should use init(parameters: Parameters, frame: CGRect?).")
        #else
            super.init(frame: frame)
        #endif
    }
    
    private func initializeInstance() {
        register(.filled, forBoolKeyPath: #keyPath(PinCodeControl.filled), inverted: false)
        register(.invalid, forBoolKeyPath: #keyPath(PinCodeControl.valid), inverted: true)
//        register(.valid, with: NSPredicate(format: "\(#keyPath(PinCodeControl.valid)) == YES AND \(#keyPath(PinCodeControl.filled)) == YES"))
        register(.valid, with: NSPredicate { control, _ in
            let control = control as! PinCodeControl
        
            return control.filled && control.valid
        })
        // example use block factor
//        register(.valid) { control in
//            let control = control as! PinCodeControl
//            
//            return control.filled && control.valid
//        }
        if PinCodeControl.isDisabledAppearance {
            loadAppearance()
        }
    }
    
    private func loadDefaultPath() {
        defaultPath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: sideSize, height: sideSize)))
    }
    
    private func loadSublayers() {
        let strokeColor = value(for: applier, forKey: #keyPath(CAShapeLayer.strokeColor), for: lastAppliedState)
        let fillColor = value(for: applier, forKey: #keyPath(CAShapeLayer.fillColor), for: lastAppliedState)
        
        for _ in 0..<codeLength {
            let sublayer = CAShapeLayer()
            let borderLayer = CAShapeLayer()
            sublayer.actions = [#keyPath(CAShapeLayer.fillColor): NSNull(), #keyPath(CAShapeLayer.lineWidth): NSNull(), #keyPath(CAShapeLayer.strokeColor): NSNull()]
//            borderLayer.actions = [#keyPath(CAShapeLayer.fillColor): NSNull(), #keyPath(CAShapeLayer.lineWidth): NSNull(), #keyPath(CAShapeLayer.strokeColor): NSNull()]
            sublayer.strokeColor = UIColor.lightGray.cgColor
//            borderLayer.fillColor = nil
            sublayer.fillColor = nil
            sublayer.addSublayer(borderLayer)
            layer.addSublayer(sublayer)
        }
        setNeedsLayout()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        layoutCodeItemLayers()
    }
    
    private func layoutCodeItemLayers() {
        let fullWidth: CGFloat = CGFloat((codeLength * Int(sideSize)) + (codeLength - 1) * Int(spaceSize))
        let originX: CGFloat = bounds.midX - (fullWidth / 2)
        
        for (i, sublayer) in sublayers.enumerated() {
            sublayer.frame = CGRect(x: originX + (CGFloat(i) * (spaceSize + sideSize)), y: bounds.midY - sideSize / 2, width: sideSize, height: sideSize)
            let currentPath = itemPath ?? defaultPath
            sublayer.path = currentPath!.cgPath
//            let currentBorderWidth = sublayers.last!.lineWidth
//            let borderPath = UIBezierPath(cgPath: currentPath!.cgPath)
//            var transform = CGAffineTransform(scaleX: 1 + (currentBorderWidth / currentPath!.bounds.size.width), y: 1 + (currentBorderWidth / currentPath!.bounds.size.height))
//            transform = transform.translatedBy(x: -currentBorderWidth/2, y: -currentBorderWidth/2)
//            borderPath.apply(transform)
//            (sublayer.sublayers?.first as! CAShapeLayer).path = borderPath.cgPath
        }
    }
    
    /// clear entered code
    open func clear() {
        deleteCharacters(in: 0..<text.characters.count)
        performTransition { _ in
            self.filled = false
            self.valid = true
        }
    }
    
    // MARK: - QUIckControl
    
    /// Sets fill color for state. In most cases, you can use preset states in PinCodeControl.State
    open func setFillColor(fillColor: UIColor?, for state: QUICStateDescriptor) {
        setValue(fillColor?.cgColor, forTarget: applier, forKeyPath: #keyPath(CAShapeLayer.fillColor), for: state)
    }
    
    /// Sets border color for state. In most cases, you can use preset states in PinCodeControl.State
    open func setBorderColor(borderColor: UIColor?, for state: QUICStateDescriptor) {
        setValue(borderColor?.cgColor, forTarget: applier, forKeyPath: #keyPath(CAShapeLayer.strokeColor), for: state)
    }
    
    /// Sets border width for state. In most cases, you can use preset states in PinCodeControl.State
    open func setBorderWidth(borderWidth: CGFloat, for state: QUICStateDescriptor) {
        setValue(borderWidth, forTarget: applier, forKeyPath: #keyPath(CAShapeLayer.lineWidth), for: state)
    }
    
    open func setForValidState(fillColor: UIColor?, borderColor: UIColor?, borderWidth: CGFloat = 1) {
        setFillColor(fillColor: fillColor, for: States.valid)
        setBorderColor(borderColor: borderColor, for: States.valid)
        setBorderWidth(borderWidth: borderWidth, for: States.valid)
    }
    
    open func setForInvalidState(fillColor: UIColor?, borderColor: UIColor?, borderWidth: CGFloat = 1) {
        setFillColor(fillColor: fillColor, for: States.invalid)
        setBorderColor(borderColor: borderColor, for: States.invalid)
        setBorderWidth(borderWidth: borderWidth, for: States.invalid)
    }
    
    open func setForPlainState(fillColor: UIColor?, borderColor: UIColor?, borderWidth: CGFloat = 1) {
        setFillColor(fillColor: fillColor, for: States.plain)
        setBorderColor(borderColor: borderColor, for: States.plain)
        setBorderWidth(borderWidth: borderWidth, for: States.plain)
    }
    
    open func setForHighlightedState(fillColor: UIColor?, borderColor: UIColor?, borderWidth: CGFloat = 1) {
        setFillColor(fillColor: fillColor, for: States.highlighted)
        setBorderColor(borderColor: borderColor, for: States.highlighted)
        setBorderWidth(borderWidth: borderWidth, for: States.highlighted)
    }
    
    open func setForDisabledState(fillColor: UIColor?, borderColor: UIColor?, borderWidth: CGFloat = 1) {
        setFillColor(fillColor: fillColor, for: States.disabled)
        setBorderColor(borderColor: borderColor, for: States.disabled)
        setBorderWidth(borderWidth: borderWidth, for: States.disabled)
    }
    
    // MARK: - UIResponder
    
    override open var canBecomeFirstResponder: Bool { return true }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        performTransition(withCommit: false) {
            super.touchesBegan(touches, with: event)
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        performTransition {
            super.touchesEnded(touches, with: event)
            _ = self.becomeFirstResponder()
        }
    }
    
    override open func becomeFirstResponder() -> Bool {
        isHighlighted = true
        return super.becomeFirstResponder()
    }
    
    override open func resignFirstResponder() -> Bool {
        isHighlighted = false
        return super.resignFirstResponder()
    }
    
    // MARK: - UIKeyInput
    
    public var hasText: Bool { return text.characters.count > 0 }
    
    public func deleteBackward() {
        if hasText {
            if text.characters.count == codeLength {
                beginTransition()
                filled = false
                valid = true
            }
            deleteCharacters(in: text.characters.count-1..<text.characters.count)
            commitTransition()
        }
    }
    
    private func deleteCharacters(in range: Range<Int>) {
        let start = text.index(text.startIndex, offsetBy: range.lowerBound)
        let end = text.index(text.startIndex, offsetBy: range.upperBound)
        text.removeSubrange(start..<end)
        
        let val = value(for: applier, forKey: #keyPath(CAShapeLayer.fillColor), for: state)
        sublayers[range].forEach { $0.fillColor = instancetype(object: val) }
    }
    
    public func insertText(_ txt: String) {
        if text.characters.count < codeLength {
            sublayers[text.characters.count].fillColor = filledItemColor?.cgColor
            text += txt
            if text.characters.count == codeLength {
                performTransition { _ in
                    self.filled = true
                    self.valid = self.validate()
                }
            }
        }
    }
    
    /// read only. Always has UITextAutocorrectionType.no value.
    public var autocorrectionType: UITextAutocorrectionType {
        set { _ = newValue }
        get { return .no }
    }
    
    /// read only. Always has UIKeyboardType.numberPad value.
    public var keyboardType: UIKeyboardType {
        set { _ = newValue }
        get { return .numberPad }
    }
    
    /// read only. Always has UITextAutocapitalizationType.none value.
    public var autocapitalizationType: UITextAutocapitalizationType {
        set { _ = newValue }
        get { return .none }
    }
    
    // MARK: - Validation
    
    /// perform validation current code value
    public func validate() -> Bool {
        return validate(text)
    }
    
    /// method for validation entered pin code. Declared for subclasses override.
    open func validate(_ pin: String) -> Bool {
        return (shouldUseDefaultValidation ? defaultValidator.evaluate(with: pin) : true) && (validator != nil ? validator!.evaluate(with: pin) : true)
    }
    
    private let defaultValidator = BlockPredicate<String> { (pin) -> Bool in
        let result = pin.characters.reduce((true, true, true, 0)) { (result, character) -> (Bool, Bool, Bool, Int) in
            if result.3 == pin.characters.count - 1 { return result }
            
            let number: Int = Int(String(character))!
            let next: Int = Int(String(pin[pin.index(pin.startIndex, offsetBy: result.3 + 1)]))!
            return (result.0 && number == next, result.1 && (number + 1) == next, result.2 && (number - 1) == next, result.3 + 1)
        }
        return !(result.0 || result.1 || result.2)
    }
}

/// Methods for configure appearance
// TODO: Create appearance configurator class.
fileprivate extension PinCodeControl {
    static var isDisabledAppearance: Bool = true
    
    override open class func initialize() {
        if self == PinCodeControl.self && !isDisabledAppearance {
            PinCodeControl.appearance().loadAppearance()
        }
    }
    
    fileprivate func loadAppearance() {
        filledItemColor = UIColor.gray
        let filledColor = UIColor(red: 76.0 / 255.0, green: 145.0 / 255.0, blue: 65.0 / 255.0, alpha: 1).withAlphaComponent(0.7)
        let invalidColor = UIColor(red: 250.0 / 255.0, green: 88.0 / 255.0, blue: 87.0 / 255.0, alpha: 1)
        
        setFillColorForDisabledState(fillColor: filledItemColor!.withAlphaComponent(0.5))
        setBorderColorForDisabledState(borderColor: UIColor.black.withAlphaComponent(0.3))
        setBorderColorForPlainState(borderColor: UIColor.gray)
        setBorderColorForHighlightedState(borderColor: UIColor.lightGray.withAlphaComponent(0.5))
        setFillColorForValidState(fillColor: filledColor)
        setBorderColorForValidState(borderColor: filledColor)
        setFillColorForInvalidState(fillColor: invalidColor)
        setBorderColorForInvalidState(borderColor: invalidColor)
    }
    
    fileprivate dynamic func setFillColorForDisabledState(fillColor: UIColor?) {
        setFillColor(fillColor: fillColor, for: States.disabled)
    }
    
    fileprivate dynamic func setFillColorForValidState(fillColor: UIColor?) {
        setFillColor(fillColor: fillColor, for: States.valid)
    }
    
    fileprivate dynamic func setFillColorForInvalidState(fillColor: UIColor?) {
        setFillColor(fillColor: fillColor, for: States.invalid)
    }
    
    fileprivate dynamic func setBorderColorForDisabledState(borderColor: UIColor?) {
        setBorderColor(borderColor: borderColor, for: States.disabled)
    }
    
    fileprivate dynamic func setBorderColorForPlainState(borderColor: UIColor?) {
        setBorderColor(borderColor: borderColor, for: States.plain)
    }
    
    fileprivate dynamic func setBorderColorForHighlightedState(borderColor: UIColor?) {
        setBorderColor(borderColor: borderColor, for: States.highlighted)
    }
    
    fileprivate dynamic func setBorderColorForValidState(borderColor: UIColor?) {
        setBorderColor(borderColor: borderColor, for: States.valid)
    }
    
    fileprivate dynamic func setBorderColorForInvalidState(borderColor: UIColor?) {
        setBorderColor(borderColor: borderColor, for: States.invalid)
    }
}
