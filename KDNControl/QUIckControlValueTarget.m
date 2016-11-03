//
//  QUIckControlValueTarget.m
//  KDNControl
//
//  Created by Denis Koryttsev on 03/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import "QUIckControlValueTarget.h"
#import "QUIckControlValue.h"

@interface QUIckControlValueTarget ()
@property (nonatomic, strong) NSMutableDictionary<NSString*, QUIckControlValue*> * values;
@property (nonatomic, strong) NSMutableDictionary * defaults;
@property (nonatomic, weak) id target;
@end

@implementation QUIckControlValueTarget

-(instancetype)initWithTarget:(id)target {
    if (self = [super init]) {
        _target = target;
        _defaults = [NSMutableDictionary dictionary];
        _values = [NSMutableDictionary dictionary];
    }
    
    return self;
}

-(void)setValue:(id)value forKeyPath:(NSString *)key forInvertedState:(UIControlState)state {
    QUIckControlValue * keyValue = [self.values objectForKey:key];
    if (!keyValue && value) {
        keyValue = [self registerKey:key];
    }
    [keyValue setValue:value forInvertedState:state];
}

-(void)setValue:(id)value forKeyPath:(NSString *)key forIntersectedState:(UIControlState)state {
    QUIckControlValue * keyValue = [self.values objectForKey:key];
    if (!keyValue && value) {
        keyValue = [self registerKey:key];
    }
    [keyValue setValue:value forIntersectedState:state];
}

-(void)setValue:(id)value forKeyPath:(NSString *)key forState:(UIControlState)state {
    QUIckControlValue * keyValue = [self.values objectForKey:key];
    if (!keyValue && value) {
        keyValue = [self registerKey:key];
    }
    [keyValue setValue:value forState:state];
    
//    if (self.state == state) {
//        [self applyCurrentStateForTarget:target]; // TODO: Apply only this value
//    }
}

-(QUIckControlValue*)registerKey:(NSString*)key {
    QUIckControlValue * keyValue = [[QUIckControlValue alloc] initWithKey:key];
    [self.values setObject:keyValue forKey:key];
    id defaultValue = [self.target valueForKeyPath:key];
    if (defaultValue) {
        [self.defaults setObject:defaultValue forKey:key];
    }
    
    return keyValue;
}

-(void)applyValuesForState:(UIControlState)state {
    for (NSString * key in self.values) {
        [self.target setValue:[[self.values objectForKey:key] valueForState:state] ?: [self.defaults objectForKey:key]
                   forKeyPath:key];
    }
}

// intersected states not corrected working if two intersected states mathed in current state and contained values for same key.
-(id)valueForKey:(NSString*)key forState:(UIControlState)state {    
    return [[self.values objectForKey:key] valueForState:state] ?: [self.defaults objectForKey:key];
}

@end
