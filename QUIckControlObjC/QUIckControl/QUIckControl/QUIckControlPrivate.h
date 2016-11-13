//
//  QUIckControlPrivate.h
//  KDNControl
//
//  Created by Denis Koryttsev on 05/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import "QUIckControlActionTargetImp.h"
#import "QUIckControlValueTarget.h"
#import "QUICStateDescriptorKey.h"

typedef struct {
    UIControlState controlState;
    BOOL inverted;
} QUIckControlState;

QUIckControlState QUIckControlStateMake(UIControlState state, BOOL inverted) {
    QUIckControlState qstate; qstate.controlState = state; qstate.inverted = inverted;
    return qstate;
}

@interface QUICStateObject : NSObject

@property (nonatomic, copy, readonly) NSString * boolProperty;
@property (nonatomic, readonly) QUIckControlState state;

+(QUICStateObject*)stateWithProperty:(NSString*)name quickControlState:(QUIckControlState)state;

-(instancetype)initWithPropertyName:(NSString*)name state:(QUIckControlState)state;

@end

@implementation QUICStateObject

+(QUICStateObject *)stateWithProperty:(NSString *)name quickControlState:(QUIckControlState)state {
    return [[QUICStateObject alloc] initWithPropertyName:name state:state];
}

-(instancetype)initWithPropertyName:(NSString*)name state:(QUIckControlState)state {
    if (self = [super init]) {
        _boolProperty = name;
        _state = state;
    }
    
    return self;
}

-(BOOL)evaluateWithObject:(id)object {
    return [[object valueForKeyPath:self.boolProperty] boolValue] ^ self.state.inverted;
}

@end