//
//  KDNControl.m
//  KDNControl
//
//  Created by Denis Koryttsev on 16/10/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import "KDNControl.h"

@interface KDNControlArrayWrapper : NSObject
-(instancetype)initWithEnumeratedObject:(id<NSFastEnumeration>)object;
@end

@interface KDNControlArrayWrapper ()
@property (nonatomic, strong) NSMutableArray * array;
@end

@implementation KDNControlArrayWrapper

-(instancetype)initWithEnumeratedObject:(id<NSFastEnumeration>)object {
    if (self = [super init]) {
        _array = [NSMutableArray array];
        for (id obj in object) {
            [_array addObject:obj];
        }
    }
    
    return self;
}

-(void)setValue:(id)value forKey:(NSString *)key {
    if ([value conformsToProtocol:@protocol(NSFastEnumeration)]) {
        id<NSFastEnumeration> collection = value;
        short i = 0;
        for (id value in collection) {
            if (i == _array.count) return;
            [_array[i] setValue:value forKey:key];
            ++i;
        }
    } else {
        [_array setValue:value forKey:key];
    }
}

-(BOOL)isEqual:(id)object {
    return self == object || [self.array isEqual:object];
}

@end

static NSString * const KDNControlBoolKeyPathKey = @"boolKey";
static NSString * const KDNControlInvertedKey = @"inverted";
static NSString * const KDNControlTargetKey = @"target";
static NSString * const KDNControlValueKey = @"value";
static NSString * const KDNControlDefaultValueKey = @"default";

@interface KDNControl ()
@property (nonatomic, strong) NSMutableDictionary * stateValues;
@property (nonatomic, strong) NSMutableDictionary * states;
@property (nonatomic, strong) NSMutableDictionary * defaults;
@property (nonatomic, strong) NSMutableArray * targets;
@property (nonatomic, strong) NSMutableArray * values;
@property (nonatomic, strong) NSMutableArray * targetsDefaults;
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
    self.defaults = [NSMutableDictionary dictionary];
    
    self.targets = [NSMutableArray array];
    self.values = [NSMutableArray array];
    self.targetsDefaults = [NSMutableArray array];
}

-(void)setSelected:(BOOL)selected {
    if (self.selected != selected) {
        [super setSelected:selected];
        [self applyCurrentState];
    }
}

-(void)setEnabled:(BOOL)enabled {
    if (self.enabled != enabled) {
        [super setEnabled:enabled];
        [self applyCurrentState];
    }
}

-(void)setHighlighted:(BOOL)highlighted {
    if (self.highlighted != highlighted) {
        [super setHighlighted:highlighted];
        [self applyCurrentState];
    }
}

-(void)setValue:(id)value forKeyPath:(NSString *)key forState:(UIControlState)state {
    [self setValue:value forTarget:self forKeyPath:key forState:state];
}

-(void)setValue:(id)value forTarget:(id)target forKeyPath:(NSString *)key forState:(UIControlState)state {
    NSMutableDictionary * values = [self valuesForTarget:target];
    NSMutableDictionary * valuesForKey = [values objectForKey:key];
    if (!valuesForKey && value) {
        valuesForKey = [self registerKey:key forValues:values withTarget:target];
    }
    value ? [valuesForKey setObject:value forKey:@(state)] : [valuesForKey removeObjectForKey:@(state)];
    
    if (self.state == state) {
        [self applyState:state];
    }
}

// TODO: values should be object with this method
-(NSMutableDictionary*)registerKey:(NSString*)key forValues:(NSMutableDictionary*)values withTarget:(id)target {
    NSMutableDictionary * keyValues = [NSMutableDictionary dictionary];
    [values setObject:keyValues forKey:key];
    id defaultValue = [target valueForKeyPath:key];
    if (defaultValue) {
//        [keyValues setObject:defaultValue forKey:KDNControlDefaultValueKey];
        [[self defaultsForTarget:target] setObject:defaultValue forKey:key];
    }
    
    return keyValues;
}

-(NSMutableDictionary*)defaultsForTarget:(id)target {
    if (self == target) return self.defaults;
    
    return [self.targetsDefaults objectAtIndex:[self.targets indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqual:target]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }]];
}

-(NSMutableDictionary*)valuesForTarget:(id)target {
    if (self == target) return self.stateValues;
    
    NSUInteger index = [self.targets indexOfObject:target];
    if (index == NSNotFound) {
        if ([target conformsToProtocol:@protocol(NSFastEnumeration)]) {
            target = [[KDNControlArrayWrapper alloc] initWithEnumeratedObject:target];
        }
        [self.targets addObject:target];
        [self.values addObject:[NSMutableDictionary dictionary]];
        [self.targetsDefaults addObject:[NSMutableDictionary dictionary]];
        index = self.targets.count - 1;
    }
    
    return [self.values objectAtIndex:index];
}

-(void)registerState:(UIControlState)state forBoolKeyPath:(NSString*)keyPath inverted:(BOOL)inverted {
    // & UIControlStateApplication ?
    [self.states setObject:@{KDNControlBoolKeyPathKey:keyPath, KDNControlInvertedKey:@(inverted)} forKey:@(state)];
}

-(void)applyState:(UIControlState)state {
    [self setNeedsDisplay];
    [self setNeedsLayout];
    
    [self applyValuesForTarget:self forState:state];
    for (id target in self.targets) {
        [self applyValuesForTarget:target forState:state];
    }
}

-(void)applyValuesForTarget:(id)target forState:(UIControlState)state {
    NSDictionary * values = [self valuesForTarget:target];
    NSDictionary * defaults = [self defaultsForTarget:target];
    for (NSString * key in values) {
        id value = [[values objectForKey:key] objectForKey:@(state)] ?: [defaults objectForKey:key];
        [target setValue:value forKeyPath:key];
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
