//
//  PinCodeControl.swift
//  QUIckControl
//
//  Created by Denis Koryttsev on 07/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import UIKit

extension UIControlEvents {
    public static var typeComplete = UIControlEvents(rawValue: 1 << 24)
}

extension UIControlState {
    public static var filled = UIControlState(rawValue: 1 << 16)
    public static var invalid = UIControlState(rawValue: 1 << 17)
    public static let valid = UIControlState(rawValue: (1 << 18) | filled.rawValue)
}

class ValueApplier: NSObject {
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

@IBDesignable
open class PinCodeControl: QUIckControl, UIKeyInput, UITextInputTraits {
    // current code string
    open var code: String { return text }
    
    // full code length, defined number elements
    @IBInspectable open private(set) var codeLength: Int = 0
    
    // space between code items
    @IBInspectable open var spaceBetweenItems: CGFloat = 15
    
    // size of side code item
    @IBInspectable open private(set) var sideSize: CGFloat = 0
    
    // filled state, yes when code type ended.
    open var filled = false {
        didSet {
            if oldValue != filled {
                applyCurrentState()
                if filled { sendActions(for: .typeComplete) }
            }
        }
    }
    
    // valid state, yes if entered code is valid.
    open var valid = true {
        didSet { if oldValue != valid { applyCurrentState() } }
    }
    
    open var validationBlock: ((_ code: String) -> Bool)?
    
    open var shouldUseDefaultValidation = true
    
    // color for fill code item when user input code symbol
    open var filledItemColor: UIColor?
    
    // bezier path for code item
    open var itemPath: UIBezierPath?
    
    private lazy var applier: ValueApplier = ValueApplier(control: self)
    private var text = String()
    fileprivate var sublayers: [CAShapeLayer] { return (layer.sublayers as? [CAShapeLayer]) ?? [] }
    private var defaultPath: UIBezierPath!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initializeInstance()
    }
    
    required convenience public init(codeLength: Int, sideSize: CGFloat, spaceSize: CGFloat) {
        self.init(frame: CGRect.zero)
        
        self.spaceBetweenItems = spaceSize
        self.sideSize = sideSize
        self.codeLength = codeLength
        didLoadRequiredParameters()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeInstance()
    }
    
    func initializeInstance() {
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
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        didLoadRequiredParameters()
    }
    
    private func didLoadRequiredParameters() {
        defaultPath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: sideSize, height: sideSize)))
        loadSublayers()
        loadDefaults()
    }
    
    func loadDefaults() {
        filledItemColor = UIColor.gray
        let filledColor = UIColor(red: 76.0 / 255.0, green: 145.0 / 255.0, blue: 65.0 / 255.0, alpha: 1).withAlphaComponent(0.7)
        let invalidColor = UIColor(red: 250.0 / 255.0, green: 88.0 / 255.0, blue: 87.0 / 255.0, alpha: 1)
        
        setForDisabledState(filledItemColor!.withAlphaComponent(0.5), borderColor: UIColor.black.withAlphaComponent(0.3), borderWidth: nil)
        setForPlainState(nil, borderColor: UIColor.gray, borderWidth: 1)
        setForHighlightedState(nil, borderColor: UIColor.lightGray.withAlphaComponent(0.5), borderWidth: nil)
        setForValidState(filledColor, borderColor: filledColor, borderWidth: nil)
        setForInvalidState(invalidColor, borderColor: invalidColor, borderWidth: nil)
    }
    
    func loadSublayers() {
        for _ in 0..<codeLength {
            let sublayer = CAShapeLayer()
            sublayer.actions = [#keyPath(CAShapeLayer.fillColor): NSNull(), #keyPath(CAShapeLayer.lineWidth): NSNull(), #keyPath(CAShapeLayer.strokeColor): NSNull()]
            sublayer.lineWidth = 1
            sublayer.strokeColor = UIColor.lightGray.cgColor
            sublayer.fillColor = UIColor.clear.cgColor
            layer.addSublayer(sublayer)
        }
        setNeedsLayout()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        layoutCodeItemLayers()
    }
    
    func layoutCodeItemLayers() {
        let fullWidth: CGFloat = CGFloat((codeLength * Int(sideSize)) + (codeLength - 1) * Int(spaceBetweenItems))
        let originX: CGFloat = bounds.midX - (fullWidth / 2)
        
        for (i, sublayer) in sublayers.enumerated() {
            sublayer.frame = CGRect(x: originX + (CGFloat(i) * (spaceBetweenItems + sideSize)), y: bounds.midY - sideSize / 2, width: sideSize, height: sideSize)
            sublayer.path = itemPath?.cgPath ?? defaultPath.cgPath
        }
    }
    
    func clear() {
        deleteCharacters(in: 0..<text.characters.count)
        performTransition { _ in
            self.filled = false
            self.valid = true
        }
    }
    
    // MARK: - QUIckControl
    
    func setForValidState(_ fillColor: UIColor?, borderColor: UIColor?, borderWidth: CGFloat?) {
        let validDescriptor = QUICStateDescriptor(intersected: .valid)
        setValue(fillColor?.cgColor, forTarget: applier, forKeyPath: #keyPath(CAShapeLayer.fillColor), for: validDescriptor)
        setValue(borderColor?.cgColor, forTarget: applier, forKeyPath: #keyPath(CAShapeLayer.strokeColor), for: validDescriptor)
        setValue(borderWidth, forTarget: applier, forKeyPath: #keyPath(CAShapeLayer.lineWidth), for: validDescriptor)
    }
    
    func setForInvalidState(_ fillColor: UIColor?, borderColor: UIColor?, borderWidth: CGFloat?) {
        let invalidDescriptor = QUICStateDescriptor(intersected: [.filled, .invalid])
        setValue(fillColor?.cgColor, forTarget: applier, forKeyPath: #keyPath(CAShapeLayer.fillColor), for: invalidDescriptor)
        setValue(borderColor?.cgColor, forTarget: applier, forKeyPath: #keyPath(CAShapeLayer.strokeColor), for: invalidDescriptor)
        setValue(borderWidth, forTarget: applier, forKeyPath: #keyPath(CAShapeLayer.lineWidth), for: invalidDescriptor)
    }
    
    func setForPlainState(_ fillColor: UIColor?, borderColor: UIColor?, borderWidth: CGFloat?) {
        let plainDescriptor = QUICStateDescriptor(inverted: .filled)
        setValue(fillColor?.cgColor, forTarget: applier, forKeyPath: #keyPath(CAShapeLayer.fillColor), for: plainDescriptor)
        setValue(borderColor?.cgColor, forTarget: applier, forKeyPath: #keyPath(CAShapeLayer.strokeColor), for: plainDescriptor)
        setValue(borderWidth, forTarget: applier, forKeyPath: #keyPath(CAShapeLayer.lineWidth), for: plainDescriptor)
    }
    
    func setForHighlightedState(_ fillColor: UIColor?, borderColor: UIColor?, borderWidth: CGFloat?) {
        let highlightedDescriptor = QUICStateDescriptor(intersected: .highlighted)
        setValue(borderColor?.cgColor, forTarget: applier, forKeyPath: #keyPath(CAShapeLayer.strokeColor), for: highlightedDescriptor)
        setValue(fillColor?.cgColor, forTarget: applier, forKeyPath: #keyPath(CAShapeLayer.fillColor), for: highlightedDescriptor)
        setValue(borderWidth, forTarget: applier, forKeyPath: #keyPath(CAShapeLayer.lineWidth), for: highlightedDescriptor)
    }
    
    func setForDisabledState(_ fillColor: UIColor?, borderColor: UIColor?, borderWidth: CGFloat?) {
        let disableDescriptor = QUICStateDescriptor(intersected: .disabled, priority: 1000)
        setValue(fillColor?.cgColor, forTarget: applier, forKeyPath: #keyPath(CAShapeLayer.fillColor), for: disableDescriptor)
        setValue(borderColor?.cgColor, forTarget: applier, forKeyPath: #keyPath(CAShapeLayer.strokeColor), for: disableDescriptor)
        setValue(borderWidth, forTarget: applier, forKeyPath: #keyPath(CAShapeLayer.lineWidth), for: disableDescriptor)
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
    
    func deleteCharacters(in range: Range<Int>) {
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
                    self.valid = self.validate(self.text)
                }
            }
        }
    }
    
    public var autocorrectionType: UITextAutocorrectionType {
        set { _ = newValue }
        get { return .no }
    }
    
    public var keyboardType: UIKeyboardType {
        set { _ = newValue }
        get { return .numberPad }
    }
    
    public var autocapitalizationType: UITextAutocapitalizationType {
        set { _ = newValue }
        get { return .none }
    }
    
    // MARK: - Validation
    
    func validate(_ pin: String) -> Bool {
        return (shouldUseDefaultValidation ? defaultValidation(pin) : true) && (validationBlock != nil ? validationBlock!(pin) : true)
    }
    
    func defaultValidation(_ pin: String) -> Bool {
        let result = pin.characters.reduce((true, true, true, 0)) { (result, character) -> (Bool, Bool, Bool, Int) in
            if result.3 == pin.characters.count - 1 { return result }
            
            let number: Int = Int(String(character))!
            let next: Int = Int(String(pin[pin.index(pin.startIndex, offsetBy: result.3 + 1)]))!
            return (result.0 && number == next, result.1 && (number + 1) == next, result.2 && (number - 1) == next, result.3 + 1)
        }
        return !(result.0 || result.1 || result.2)
    }
}
