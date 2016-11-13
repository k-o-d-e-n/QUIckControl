//
//  MagnitTextField.swift
//  Magnit
//
//  Created by  K-o-D-e-N on 15/08/16.
//  Copyright © 2016 Surf. All rights reserved.
//

import UIKit
//import RxSwift
//import SHSPhoneComponent
//import SnapKit

extension String {
    func sizeFor(width: CGFloat, font: UIFont) -> CGSize {
        return NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
                                                             options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                             attributes: [NSFontAttributeName: font],
                                                             context: nil).size
    }
}

extension NSTextAlignment {
    var caAlignmentValue: String {
        switch self {
        case .center:
            return kCAAlignmentCenter;
        case .justified:
            return kCAAlignmentJustified;
        case .left:
            return kCAAlignmentLeft;
        case .right:
            return kCAAlignmentRight;
        case .natural:
            return kCAAlignmentNatural;
        }
    }
}

extension UIFont {
    var cgFont: CGFont? {
        let cgFont = CGFont(fontName as NSString);
        
        return cgFont!.copy(withVariations: nil)
    }
}

extension CATextLayer {
    var isEmpty: Bool { return string == nil || (string as! String).isEmpty }
}

protocol MagnitTextFieldFormatter {
    func format(text: String) -> String
}

@objc protocol MagnitTextInput: UITextInput, UITextInputTraits {
    var returnKeyType: UIReturnKeyType { get set }
    var string: String? { get set }
    var isEmpty: Bool { get }
    var placeholder: String? { get set }
    var textAlignment: NSTextAlignment { get set }
}

extension UITextField: MagnitTextInput {
    var string: String? { set { text = newValue } get { return text } }
    var isEmpty: Bool { return text == nil || text!.isEmpty }
}

@IBDesignable
class MagnitInputView<InputView>: UIView where InputView: MagnitTextInput, InputView: UIView {
    weak var textInput: InputView!
    fileprivate weak var titleLayer: CATextLayer!
    fileprivate weak var messageLayer: CATextLayer!
    fileprivate weak var requiredIndicator: NSObject!
    fileprivate weak var bottomLineLayer: CALayer!
    
    fileprivate var activeOrNonEmpty: Bool { return textInput.isFirstResponder || !textInput.isEmpty }
    fileprivate var shouldShowRequired: Bool { return isRequired && textInput.isEmpty && !textInput.isFirstResponder }
    fileprivate var valid: Bool = true
    var formatter: MagnitTextFieldFormatter?
    var hasBeenChanged: Bool = false
    
    weak var nextInput: InputView? {
        didSet {
            let isNextButton = nextInput != nil
            textInput.returnKeyType = isNextButton ? UIReturnKeyType.next : UIReturnKeyType.default
        }
    }
    
    @IBInspectable var placeholder: String? {
        didSet { textInput.placeholder = placeholder }
    }
    @IBInspectable var title: String? {
        set { titleLayer.string = newValue }
        get { return titleLayer.string as? String }
    }
    @IBInspectable var message:String? {
        set {
            if newValue != nil && messageLayer == nil {
                loadMessageLayer()
                makeValidState(isValid: isValid)
            }
            messageLayer.string = newValue
        }
        get { return messageLayer != nil ? messageLayer.string as? String : nil }
    }

    @IBInspectable var isRequired: Bool = false {
        didSet {
            if isRequired && requiredIndicator == nil {
                loadRequiredIndicator()
            }
            updateRequiredIndicator()
        }
    }

    var validationRegex: String? {
        didSet {
            if let regex = validationRegex, let text = textInput.string, !text.isEmpty {
//                valid = text.isValidToRegex(regex)
            }
        }
    }

    var reactiveValidation: Bool = false
    var isValid: Bool { return valid }
    var alignment: NSTextAlignment = .left {
        didSet {
            textInput.textAlignment = alignment
            titleLayer.alignmentMode = alignment.caAlignmentValue
        }
    }

    var insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0) {
        didSet {
//            textInput.snp_updateConstraints { (make) in
//                make.leading.equalTo(insets.left)
//                make.trailing.equalTo(insets.right)
//            }
        }
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        clipsToBounds = false
        setupInputView()
        loadSubLayers()
        prepareViewState()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLayer.frame = CGRect(x: textInput.frame.minX, y: activeOrNonEmpty ? 14 : 34, width: textInput.frame.width, height: activeOrNonEmpty ? 16 : 24)
        bottomLineLayer.frame = CGRect(x: textInput.frame.minX, y: textInput.frame.maxY, width: textInput.frame.width, height: 1 / UIScreen.main.scale)
        if messageLayer != nil && !messageLayer.isEmpty {
            let messageTextSize = (messageLayer.string as? String)?.sizeFor(width: textInput.frame.width, font: UIFont(name: messageLayer.font as! String, size: messageLayer.fontSize)!)
            messageLayer.frame = CGRect(x: textInput.frame.minX, y: textInput.frame.maxY, width: textInput.frame.width, height: messageTextSize?.height ?? 30)
        }
    }
    
    private func loadSubLayers() {
        let bottomLine = CALayer()
        layer.addSublayer(bottomLine)
        bottomLineLayer = bottomLine

        let title = CATextLayer()
        layer.addSublayer(title)
        titleLayer = title
//        titleLayer.foregroundColor = Colors.Gray.Text.CGColor
        titleLayer.fontSize = 14
        titleLayer.contentsScale = UIScreen.main.scale
    }
    
    private func loadMessageLayer() {
        let messageTextLayer = CATextLayer()
        layer.addSublayer(messageTextLayer)
        messageLayer = messageTextLayer
        messageLayer.contentsScale = UIScreen.main.scale
//        messageLayer.font = FontFamilyNames.System
        messageLayer.fontSize = 12
//        messageLayer.foregroundColor = Colors.Red.Text.CGColor
    }
    
    fileprivate func loadRequiredIndicator() {}
    fileprivate func loadTextInput() -> InputView! { return nil }
    
    fileprivate func setupInputView() {
        let txtField = loadTextInput()
        txtField?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(txtField!)
        textInput = txtField
//        textInput.snp_makeConstraints { (make) in
//            make.height.equalTo(24)
//            make.leading.equalTo(insets.left)
//            make.top.equalTo(34)
//            make.right.equalTo(insets.right)
//        }
    }
    
    fileprivate func prepareViewState() {
        makeValidState(isValid: isValid)
        makeEmptyNonActiveState(isEmpty: true)
//        rx_gesture(.Tap).subscribeNext { _ in
//            self.textInput.becomeFirstResponder()
//        }.addDisposableTo(rx_disposeBag)
    }
    
    func showValidationResult() {
        makeValidState(isValid: isValid)
    }
    
    func setTitle(title:String?, useAsPlaceholder use: Bool = true) {
        self.title = title
        if use {
            placeholder = title
        }
    }
    
    func clear() {
        textInput.string = nil
    }
    
    fileprivate func updateRequiredIndicator() {}
    
    // TODO: Implement states, observe editing property for change color
    fileprivate func makeEmptyNonActiveState(isEmpty: Bool) {
        textInput.placeholder = isEmpty ? placeholder : nil
//        bottomLineLayer.backgroundColor =
//            (!reactiveValidation || isValid ? (!activeOrNonEmpty ? Colors.Gray.BottomLine : Colors.Yellow.Text)
//            : Colors.Red.Text).CGColor
//        UIView.animateWithDuration(0.3) {
//            self.titleLayer.hidden = isEmpty
//            self.layoutSubviews()
//        }
    }
    
    private func makeValidState(isValid:Bool) {
//        bottomLineLayer.backgroundColor = (isValid ? (!activeOrNonEmpty ? Colors.Gray.BottomLine : Colors.Yellow.Text) : Colors.Red.Text).CGColor
        if let messageTextLayer = messageLayer {
            messageTextLayer.isHidden = isValid
        }
    }
}

class MagnitTextField: MagnitInputView<UITextField> {
    
    override fileprivate func loadTextInput() -> UITextField! {
        return UITextField(frame: .zero)
    }
    
    override fileprivate func setupInputView() {
        super.setupInputView()
        textInput.delegate = self
    }
    
    fileprivate override func prepareViewState() {
        super.prepareViewState()
//        textInput.rx_text.subscribeNext { text in
//            if self.isRequired {
//                let regexValidationResult = text.isValidToRegex(self.validationRegex)
//                self.valid = !text.isEmpty && regexValidationResult
//                if self.reactiveValidation {
//                    self.makeValidState(self.isValid)
//                }
//            }
//            if !self.textInput.editing {
//                self.makeEmptyNonActiveState(text.isEmpty)
//            }
//        }.addDisposableTo(rx_disposeBag)
    }
    
    fileprivate override func loadRequiredIndicator() {
        let indicator = UILabel()
        requiredIndicator = indicator
//        indicator.textColor = Colors.Red.Text
        indicator.font = UIFont.systemFont(ofSize: 16)
        indicator.frame = CGRect(origin: .zero, size: CGSize(width: 10, height: 24))
        indicator.text = "*"
        textInput.leftView = indicator
    }
    
    fileprivate override func updateRequiredIndicator() {
        textInput.leftViewMode = shouldShowRequired ? .always : .never
    }
    
    fileprivate override func makeEmptyNonActiveState(isEmpty: Bool) {
        updateRequiredIndicator()
        super.makeEmptyNonActiveState(isEmpty: isEmpty)
    }
    
    override func clear() {
        super.clear()
        textInput.sendActions(for: .valueChanged)
    }
    
}

extension MagnitInputView where InputView: UITextField {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.makeEmptyNonActiveState(isEmpty: false)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text != nil && !textField.text!.isEmpty {
            return
        }        
        self.makeEmptyNonActiveState(isEmpty: true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.returnKeyType == .next && nextInput != nil {
            textField.resignFirstResponder()
            nextInput!.becomeFirstResponder()
            return false
        }
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        hasBeenChanged = true
        if formatter != nil {
            let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
            textField.text = formatter?.format(text: newText!)
            
            return false
        }
        
        return true
    }

}
extension MagnitTextField: UITextFieldDelegate {}

//class PhoneMagnitTextField: MagnitTextField {
//    weak var phoneTextField: SHSPhoneTextField! { return textInput as! SHSPhoneTextField }
//    
//    private override func loadTextInput() -> UITextField {
//        return SHSPhoneTextField(frame: .zero)
//    }
//    
//    func updateState() {
//        makeEmptyNonActiveState(!activeOrNonEmpty)
//    }
//}

class PlaceholderedTextView: UITextView {
    var placeholder: String?
}

extension PlaceholderedTextView: MagnitTextInput {
    var string: String? { set { text = newValue } get { return text } }
    var isEmpty: Bool { return text.isEmpty }
}

class MagnitTextView: MagnitInputView<PlaceholderedTextView> {
    
    override fileprivate func loadTextInput() -> PlaceholderedTextView! {
        return PlaceholderedTextView(frame: .zero)
    }
    
}
