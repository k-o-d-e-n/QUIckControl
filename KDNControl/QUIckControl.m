//
//  KDNControl.m
//  KDNControl
//
//  Created by Denis Koryttsev on 16/10/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import "QUIckControl.h"
#import "QUIckControlActionTargetImp.h"
#import "QUIckControlArrayWrapper.h"
#import "QUIckControlValueTarget.h"

static NSString * const QUIckControlBoolKeyPathKey = @"boolKey";
static NSString * const QUIckControlInvertedKey = @"inverted";
static NSString * const QUIckControlTargetKey = @"target";
static NSString * const QUIckControlValueKey = @"value";
static NSString * const QUIckControlIntersectedKey = @"intersected";

@interface QUIckControl ()
@property (nonatomic) BOOL isTransitionTime;
@property (nonatomic, strong) QUIckControlValueTarget * thisValueTarget;
@property (nonatomic, strong) NSMutableDictionary * states;
@property (nonatomic, strong) NSMutableArray<QUIckControlValueTarget*> * targets;
@property (nonatomic, strong) NSMutableSet * scheduledActions;
@property (nonatomic, strong) NSPointerArray * actionTargets;
@end

@implementation QUIckControl

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
    self.thisValueTarget = [[QUIckControlValueTarget alloc] initWithTarget:self];
    
    self.targets = [NSMutableArray array];
    
    self.scheduledActions = [NSMutableSet set];
    self.actionTargets = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsStrongMemory];
}

#pragma mark - States

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

-(void)beginTransition {
    self.isTransitionTime = YES;
}

-(void)commitTransition {
    if (!self.isTransitionTime) return;
    
    self.isTransitionTime = NO;
    [self applyCurrentState];
    for (NSNumber * action in self.scheduledActions) {
        [self sendActionsForControlEvents:[action unsignedIntegerValue]];
    }
    [self.scheduledActions removeAllObjects];
}

-(void)performTransition:(void(^)())transition {
    [self beginTransition];
    transition();
    [self commitTransition];
}

-(void)registerState:(UIControlState)state forBoolKeyPath:(NSString*)keyPath inverted:(BOOL)inverted {
    // & UIControlStateApplication ?
    [self.states setObject:@{QUIckControlBoolKeyPathKey:keyPath, QUIckControlInvertedKey:@(inverted)} forKey:@(state)];
}

#pragma mark - Actions

-(QUIckControlActionTarget)addAction:(void (^)(__kindof QUIckControl *__weak))action forControlEvents:(UIControlEvents)events {
    QUIckControlActionTargetImp * actionTarget = [[QUIckControlActionTargetImp alloc] initWithControl:self controlEvents:events];
    actionTarget.action = action;
    [self.actionTargets addPointer:(__bridge void * _Nullable)(actionTarget)];
    
    return actionTarget;
}

-(QUIckControlActionTarget)addActionTarget:(QUIckControlActionTarget)target {
    QUIckControlActionTargetImp * sourceTarget = (QUIckControlActionTargetImp*)target;
    QUIckControlActionTargetImp * actionTarget = [[QUIckControlActionTargetImp alloc] initWithControl:self controlEvents:sourceTarget.events];
    actionTarget.action = sourceTarget.action;
    [self.actionTargets addPointer:(__bridge void * _Nullable)(actionTarget)];
    
    return actionTarget;
}

-(void)sendActionsForControlEvents:(UIControlEvents)controlEvents {
    if (self.isTransitionTime) { [self.scheduledActions addObject:@(controlEvents)]; return; }
    
    [super sendActionsForControlEvents:controlEvents];
}

#pragma mark - Values

-(void)removeValuesForTarget:(id)target {
    NSUInteger targetIndex = [self indexOfTarget:target];
    if (targetIndex != NSNotFound) {
        [self.targets removeObjectAtIndex:targetIndex];
    }
}

-(void)setValue:(id)value forTarget:(id)target forKeyPath:(NSString *)key forInvertedState:(UIControlState)state {
    [[self valueTargetForTarget:target] setValue:value forKeyPath:key forInvertedState:state]; // TODO: Resolve problem with apply value if current state contained inverted state
}

// TODO: Create possible set value for inverted state (current state not contained state)
-(void)setValue:(id)value forTarget:(id)target forKeyPath:(NSString *)key forAllStatesContained:(UIControlState)state {
    [[self valueTargetForTarget:target] setValue:value forKeyPath:key forIntersectedState:state]; // TODO: Resolve problem with apply value if current state contained intersected state
}

-(void)setValue:(id)value forKeyPath:(NSString *)key forState:(UIControlState)state {
    [self setValue:value forTarget:self forKeyPath:key forState:state];
}

// TODO: Create possible add values for multiple states
-(void)setValue:(id)value forTarget:(id)target forKeyPath:(NSString *)key forState:(UIControlState)state {
    QUIckControlValueTarget * valueTarget = [self valueTargetForTarget:target];
    [valueTarget setValue:value forKeyPath:key forState:state];
    
    if (self.state == state) {
        [valueTarget applyValuesForState:state]; // TODO: Apply only this value
    }
}

-(NSUInteger)indexOfTarget:(id)target {
    return [self.targets indexOfObjectPassingTest:^BOOL(QUIckControlValueTarget *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.target isEqual:target]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
}

-(QUIckControlValueTarget*)valueTargetForTarget:(id)target {
    if (self == target) return self.thisValueTarget;
    
    NSUInteger index = [self indexOfTarget:target];
    if (index == NSNotFound) {
//        if ([target conformsToProtocol:@protocol(NSFastEnumeration)]) {
//            target = [[QUIckControlArrayWrapper alloc] initWithEnumeratedObject:target];
//        }
        QUIckControlValueTarget * valueTarget = [[QUIckControlValueTarget alloc] initWithTarget:target];
        [self.targets addObject:valueTarget];
        index = self.targets.count - 1;
    }
    
    return [self.targets objectAtIndex:index];
}

#pragma mark - Apply state values

-(void)applyCurrentStateForTarget:(id)target {
    [[self valueTargetForTarget:target] applyValuesForState:self.state];
}

-(void)applyState:(UIControlState)state {
    if (self.isTransitionTime) return;
    
    [self setNeedsDisplay];
    [self setNeedsLayout];
    
    [self.thisValueTarget applyValuesForState:state];
    for (QUIckControlValueTarget * target in self.targets) {
        [target applyValuesForState:state];
    }
}

-(id)valueForTarget:(id)target forKey:(NSString*)key forState:(UIControlState)state {
    return [[self valueTargetForTarget:target] valueForKey:key forState:state];
}

-(void)applyCurrentState {
    [self applyState:self.state];
}

- (UIControlState)state {
    UIControlState state = UIControlStateNormal;
    
    for (NSNumber * stateValue in self.states) {
        UIControlState substate = [stateValue unsignedIntegerValue];
        NSDictionary * boolProperty = [self.states objectForKey:stateValue];
        BOOL inverted = [[boolProperty objectForKey:QUIckControlInvertedKey] boolValue];
        BOOL propertyValue = [[self valueForKeyPath:[boolProperty objectForKey:QUIckControlBoolKeyPathKey]] boolValue];
        
        if (propertyValue ^ inverted) {
            state |= substate;
        }
    }
    
    return state;
}

-(void)dealloc {
    for (QUIckControlActionTarget target in self.actionTargets) {
        [target stop];
    }
    self.actionTargets.count = 0;
}

@end
