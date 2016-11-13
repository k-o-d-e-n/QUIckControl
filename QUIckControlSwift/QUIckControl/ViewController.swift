//
//  ViewController.swift
//  QUIckControl
//
//  Created by Denis Koryttsev on 23/10/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private weak var quickControl: QUIckControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let qControl = QUIckControl(frame: .zero)
        view.addSubview(qControl)
        quickControl = qControl
        quickControl.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        quickControl.setValue(UIColor.black as Any, forKeyPath: #keyPath(UIView.backgroundColor), for: .highlighted)
        
        let button = UIButton(frame: CGRect(x: 100, y: 0, width: 100, height: 100))
        view.addSubview(button)
        button.addTarget(self, action: #selector(touchUpInside(sender:)), for: .touchUpInside)
        
        let pincodeControl = PinCodeControl(codeLength: 4, sideSize: 20, spaceSize: 15)
        pincodeControl.backgroundColor = UIColor.red
        view.addSubview(pincodeControl)
        pincodeControl.frame = CGRect(x: 100, y: 100, width: 200, height: 100)
        pincodeControl.filledItemColor = UIColor.gray
        pincodeControl.setBorderColor(UIColor.black, for: .highlighted)
        pincodeControl.setBorderColor(UIColor.gray, for: .normal)
        pincodeControl.setFill(UIColor.black, forIntersectedState: .normal)
        pincodeControl.addAction(for: .touchUpInside) { control in
            print(control)
        }.start()
    }
    
    func touchUpInside(sender: UIButton) {
        quickControl.isHighlighted = true
    }

}

