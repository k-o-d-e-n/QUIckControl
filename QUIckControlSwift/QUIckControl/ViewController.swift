//
//  ViewController.swift
//  QUIckControl
//
//  Created by Denis Koryttsev on 23/10/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import UIKit

extension UIControlState {
    static let valid = UIControlState(rawValue: 1 << 18)
}

struct PinCodeElementsGroup {
    weak var control: PinCodeControl!
    weak var label: UILabel!
    
    init(control: PinCodeControl, label: UILabel) {
        self.control = control
        self.label = label
        
        self.control.register(.valid, forBoolKeyPath: #keyPath(PinCodeControl.valid), inverted: false)
    }
    
    private func addEnabledDependencyFor(target: NSObject, enabledValue: Any?, disabledValue: Any?, keyPath: String) {
        self.control.setValue(enabledValue, forTarget: target, forKeyPath: keyPath, forAllStatesContained: [.filled, .valid])
        self.control.setValue(disabledValue, forTarget: target, forKeyPath: keyPath, forInvertedState: [.filled, .valid])
    }
    
    func addDependencyFor(group: PinCodeElementsGroup) {
        addEnabledDependencyFor(target: group.control, enabledValue: true, disabledValue: false, keyPath: #keyPath(UIControl.enabled))
        addEnabledDependencyFor(target: group.label, enabledValue: UIColor.gray, disabledValue: UIColor.lightGray.withAlphaComponent(0.5), keyPath: #keyPath(UILabel.textColor))
    }
    
    func addDependencyFor(button: UIButton) {
        addEnabledDependencyFor(target: button, enabledValue: true, disabledValue: false, keyPath: #keyPath(UIButton.enabled))
        addEnabledDependencyFor(target: button, enabledValue: UIColor.black.withAlphaComponent(0.6), disabledValue: UIColor.lightGray.withAlphaComponent(0.2), keyPath: #keyPath(UIButton.backgroundColor))
    }
}

class ViewController: UIViewController {
    var logger: String = "" { didSet { print(logger) } }
    
    @IBOutlet weak var oldPinCodeLabel: UILabel!
    @IBOutlet weak var oldPinCodeControl: PinCodeControl!
    @IBOutlet weak var newPinCodeLabel: UILabel!
    @IBOutlet weak var newPinCodeControl: PinCodeControl!
    @IBOutlet weak var repeatPinCodeLabel: UILabel!
    @IBOutlet weak var repeatPinCodeControl: PinCodeControl!
    @IBOutlet weak var applyButton: UIButton!
    
    lazy var oldGroup: PinCodeElementsGroup = PinCodeElementsGroup(control: self.oldPinCodeControl, label: self.oldPinCodeLabel)
    lazy var newGroup: PinCodeElementsGroup = PinCodeElementsGroup(control: self.newPinCodeControl, label: self.newPinCodeLabel)
    lazy var repeatGroup: PinCodeElementsGroup = PinCodeElementsGroup(control: self.repeatPinCodeControl, label: self.repeatPinCodeLabel)
    
    var stateLogger: String = "" { didSet { print("Received string: " + stateLogger) } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oldGroup.addDependencyFor(group: newGroup)
        newGroup.addDependencyFor(group: repeatGroup)
        repeatGroup.addDependencyFor(button: applyButton)
        
        applyButton.addTarget(self, action: #selector(touchUpInside(sender:)), for: .touchUpInside)
        
        newPinCodeControl.addAction(for: .typeComplete) { print($0) }.start()
        repeatGroup.control.validationBlock = { (code: String) -> Bool in return code == self.newGroup.control.code }

        oldGroup.control.setValue("Old PIN-code is invalid",
                                  forTarget: self,
                                  forKeyPath: #keyPath(ViewController.stateLogger),
                                  for: QUICState(priority: 1001, function: { $0.contains(.invalid) }))
        oldGroup.control.setValue("Old PIN-code is valid",
                                  forTarget: self,
                                  forKeyPath: #keyPath(ViewController.stateLogger),
                                  for: QUICState(priority: 1000, function: { $0.contains(.filled) && !$0.contains(.invalid) }))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(false)
    }
    
    func touchUpInside(sender: UIButton) {
        print("PIN-code '" + newGroup.control.code + "' saved")
        oldGroup.control.clear()
        newGroup.control.clear()
        repeatGroup.control.clear()
    }
}
