//
//  QUIckControlValue.m
//  KDNControl
//
//  Created by Denis Koryttsev on 03/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import "QUIckControlValue.h"

static NSString * const QUIckControlIntersectedKey = @"intersected";

@interface QUIckControlValue ()
@property (nonatomic, strong) NSString * key;
@property (nonatomic, strong) NSMutableDictionary * values;
@property (nonatomic, strong) NSMutableDictionary * intersectedValues; // TODO: Try apply some transform for state and save to values
@property (nonatomic, strong) NSMutableIndexSet * intersectedStates;
@property (nonatomic, strong) NSMutableIndexSet * invertedStates;
@end

@implementation QUIckControlValue

// TODO: Init containers only when need - implement lazy initialization.
-(instancetype)initWithKey:(NSString *)key {
    if (self = [super init]) {
        _key = key;
        _values = [NSMutableDictionary dictionary];
        _intersectedValues = [NSMutableDictionary dictionary];
        _intersectedStates = [NSMutableIndexSet indexSet];
        _invertedStates = [NSMutableIndexSet indexSet];
    }
    
    return self;
}

-(void)setValue:(id)value forInvertedState:(UIControlState)state {
    [self.invertedStates addIndex:state];
    value ? [self.values setObject:value forKey:@(~state)] : [self.values removeObjectForKey:@(~state)];
}

-(void)setValue:(id)value forIntersectedState:(UIControlState)state {
    [self.intersectedStates addIndex:state];
    value ? [self.intersectedValues setObject:value forKey:@(state)] : [self.intersectedValues removeObjectForKey:@(state)];
}

-(void)setValue:(id)value forState:(UIControlState)state {
    value ? [self.values setObject:value forKey:@(state)] : [self.values removeObjectForKey:@(state)];
}

-(id)valueForState:(UIControlState)state {
    id value = [self.values objectForKey:@(state)];
    
    if (!value) {
        NSUInteger invertedState = [self.invertedStates indexPassingTest:^BOOL(NSUInteger invertedState, BOOL * _Nonnull stop) {
            if ((state & invertedState) == 0) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        if (invertedState != NSNotFound) {
            value = [self.values objectForKey:@(~invertedState)];
        }
    }
    
    if (!value) {
        NSUInteger intersectedState = [self.intersectedStates indexPassingTest:^BOOL(NSUInteger intersectedState, BOOL * _Nonnull stop) {
            if ((state & intersectedState) == intersectedState) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        if (intersectedState != NSNotFound) {
            value = [self.intersectedValues objectForKey:@(intersectedState)];
        }
    }

    return value;
}

@end
