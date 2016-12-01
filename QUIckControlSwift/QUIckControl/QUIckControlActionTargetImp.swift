//
//  QUIckControlActionTargetImp.swift
//  QUIckControl
//
//  Created by Denis Koryttsev on 08/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import UIKit

class QUIckControlActionTargetImp: NSObject, QUIckControlActionTarget {
    
    weak var parentControl: QUIckControl!
    var events: UIControlEvents!
    var action: ((_ control: QUIckControl) -> ())?
    
    init(control: QUIckControl, controlEvents events: UIControlEvents) {
        super.init()
        
        self.events = events
        self.parentControl = control
    }
    
    func actionSelector(_ control: QUIckControl) {
        action?(parentControl)
    }
    
    func start() {
        self.parentControl.addTarget(self, action: #selector(self.actionSelector), for: self.events)
    }
    
    func stop() {
        self.parentControl.removeTarget(self, action: #selector(self.actionSelector), for: self.events)
    }
    
}
