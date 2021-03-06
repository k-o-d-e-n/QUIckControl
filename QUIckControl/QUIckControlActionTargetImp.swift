//
//  QUIckControlActionTargetImp.swift
//  QUIckControl
//
//  Created by Denis Koryttsev on 08/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import UIKit

final class QUIckControlActionTargetImp: NSObject, QUIckControlActionTarget {
    weak var parentControl: QUIckControl?
    var events: UIControl.Event!
    var action: ((_ control: QUIckControl) -> ())?
    
    init(control: QUIckControl, controlEvents events: UIControl.Event) {
        super.init()
        
        self.events = events
        self.parentControl = control
    }
    
    @objc func actionSelector(_ control: QUIckControl) {
        action?(control)
    }
    
    func start() {
        self.parentControl?.addTarget(self, action: #selector(self.actionSelector), for: self.events)
    }
    
    func stop() {
        self.parentControl?.removeTarget(self, action: #selector(self.actionSelector), for: self.events)
    }
}
