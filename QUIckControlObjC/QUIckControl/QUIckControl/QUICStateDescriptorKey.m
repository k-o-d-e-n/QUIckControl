//
//  QUICStateDescriptorKey.m
//  QUIckControl
//
//  Created by Denis Koryttsev on 06/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import "QUICStateDescriptorKey.h"

QUICStateDescriptor QUICStateDescriptorMake(UIControlState state, QUICStateType type) {
    QUICStateDescriptor descr; descr.state = state; descr.type = type;
    return descr;
}

BOOL QUICStateEvaluateWithState(QUICStateDescriptor descriptor, UIControlState state) {
    switch (descriptor.type) {
        case QUICStateTypeUsual:
            return descriptor.state == state;
        case QUICStateTypeInverted:
            return state != UIControlStateNormal && (descriptor.state & state) != descriptor.state;
        case QUICStateTypeIntersected:
            return (descriptor.state & state) == descriptor.state;
    }
}

@implementation QUICStateDescriptorKey

-(instancetype)initWithDescriptor:(QUICStateDescriptor)descriptor {
    if (self = [super init]) {
        _descriptor = descriptor;
    }
    
    return self;
}

-(id)copyWithZone:(NSZone *)zone {
    return self;//[[QUICStateDescriptorKey allocWithZone:zone] initWithDescriptor:self.descriptor];
}

-(BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if ([object isKindOfClass:[NSNumber class]]) {
        NSNumber * stateValue = object;
        return [self evaluateWithState:[stateValue unsignedIntegerValue]];
    }
    if ([object isMemberOfClass:self.class]) {
        QUICStateDescriptorKey * stateValue = object;
        return self.descriptor.state == stateValue.descriptor.state &&
                self.descriptor.type == stateValue.descriptor.type;
    }
    
    return NO;
}

-(BOOL)evaluateWithState:(UIControlState)state {
    switch (self.descriptor.type) {
        case QUICStateTypeUsual:
            return self.descriptor.state == state;
        case QUICStateTypeInverted:
            return state != UIControlStateNormal && (self.descriptor.state & state) != self.descriptor.state;
        case QUICStateTypeIntersected:
            return (self.descriptor.state & state) == self.descriptor.state;
    }
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@, %@", @(self.descriptor.state), @(self.descriptor.type)];
}

@end
