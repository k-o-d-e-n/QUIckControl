//
//  StatableSupport.swift
//  Statable
//
//  Created by Denis Koryttsev on 03/12/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

import Foundation

// issue: does not conform Predicate protocol, this is expirement
class QNSPredicate<Evaluated: AnonymStatable>: NSPredicate {
    typealias EvaluatedEntity = Evaluated
}

extension NSPredicate: Predicate {
    typealias EvaluatedEntity = Any?
}

class BlockPredicate<Evaluated>: Predicate {
    typealias EvaluatedEntity = Evaluated
    
    internal let predicate: (_ object: Evaluated) -> Bool
    
    init(predicate: @escaping (_ object: Evaluated) -> Bool) {
        self.predicate = predicate
    }
    
    func evaluate(with object: Evaluated) -> Bool {
        return predicate(object)
    }
}
