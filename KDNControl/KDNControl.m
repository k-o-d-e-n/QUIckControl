//
//  KDNControl.m
//  KDNControl
//
//  Created by Denis Koryttsev on 16/10/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import "KDNControl.h"

static NSString * const KDNControlBoolKeyPathKey = @"boolKey";
static NSString * const KDNControlInvertedKey = @"inverted";

@interface KDNControl ()
@property (nonatomic, strong) NSMutableDictionary * stateValues;
@property (nonatomic, strong) NSMutableDictionary * states;
@property (nonatomic, strong) NSMutableDictionary * defaultValues;
@end

@implementation KDNControl

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self loadStorages];
        [self registerExistedStates];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self loadStorages];
        [self registerExistedStates];
    }
    
    return self;
}

-(void)registerExistedStates {
    [self registerState:UIControlStateSelected forBoolKeyPath:keyPath(UIControl, selected) inverted:NO];
    [self registerState:UIControlStateHighlighted forBoolKeyPath:keyPath(UIControl, highlighted) inverted:NO];
    [self registerState:UIControlStateDisabled forBoolKeyPath:keyPath(UIControl, enabled) inverted:YES];
}

-(void)loadStorages {
    self.states = [NSMutableDictionary dictionary];
    self.stateValues = [NSMutableDictionary dictionary];
    self.defaultValues = [NSMutableDictionary dictionary];
}

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self applyCurrentState];
}

-(void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self applyCurrentState];
}

-(void)setOpaque:(BOOL)opaque {
    [super setOpaque:opaque];
    [self applyCurrentState];
}

-(void)setValue:(id)value forKeyPath:(NSString *)key forState:(UIControlState)state {
    NSMutableDictionary * values = [self.stateValues objectForKey:key];
    if (!values && value) {
        values = [self registerKey:key];
    }
    value ? [values setObject:value forKey:@(state)] : [values removeObjectForKey:@(state)];
    
    if (self.state == state) {
        [self applyState:state];
    }
}

-(NSMutableDictionary*)registerKey:(NSString*)key {
    NSMutableDictionary * values = [NSMutableDictionary dictionary];
    [self.stateValues setObject:values forKey:key];
    id defaultValue = [self valueForKeyPath:key];
    if (defaultValue) {
        [self.defaultValues setObject:defaultValue forKey:key];
    }
    
    return values;
}

-(void)registerState:(UIControlState)state forBoolKeyPath:(NSString*)keyPath inverted:(BOOL)inverted {
    // & UIControlStateApplication ?
    [self.states setObject:@{KDNControlBoolKeyPathKey:keyPath, KDNControlInvertedKey:@(inverted)} forKey:@(state)];
}

-(void)applyState:(UIControlState)state {
    [self setNeedsDisplay];
    [self setNeedsLayout];
    
    for (NSString * key in self.stateValues) {
        id value = [[self.stateValues objectForKey:key] objectForKey:@(state)] ?: [self.defaultValues objectForKey:key];
        [self setValue:value forKeyPath:key];
    }
}

-(BOOL)needBorder {
    return YES;
}

-(void)applyCurrentState {
    [self applyState:self.state];
}

- (UIControlState)state {
    UIControlState state = UIControlStateNormal;
    
    for (NSNumber * stateValue in self.states) {
        UIControlState substate = [stateValue unsignedIntegerValue];
        NSDictionary * boolProperty = [self.states objectForKey:stateValue];
        BOOL stateEnabled = [[boolProperty objectForKey:KDNControlInvertedKey] boolValue] ?
        ![[self valueForKeyPath:[boolProperty objectForKey:KDNControlBoolKeyPathKey]] boolValue] :
        [[self valueForKeyPath:[boolProperty objectForKey:KDNControlBoolKeyPathKey]] boolValue];
        
        if (stateEnabled) {
            state |= substate;
        }
    }
    
    return state;
}

@end
