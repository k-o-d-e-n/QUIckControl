//
//  KDNControl.m
//  KDNControl
//
//  Created by Denis Koryttsev on 16/10/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import "QUIckControl.h"
#import "QUIckControlPrivate.h"

@interface QUIckControl ()
@property (nonatomic) BOOL isTransitionTime;
@property (nonatomic, strong) QUIckControlValueTarget * thisValueTarget;
@property (nonatomic, strong) NSMutableArray * states;
@property (nonatomic, strong) NSMutableArray<QUIckControlValueTarget*> * targets;
@property (nonatomic, strong) NSMutableSet * scheduledActions;
@property (nonatomic, strong) NSMutableArray * actionTargets;
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
    self.states = [NSMutableArray array];
    self.thisValueTarget = [[QUIckControlValueTarget alloc] initWithTarget:self];
    
    self.targets = [NSMutableArray array];
    
    self.scheduledActions = [NSMutableSet set];
    self.actionTargets = [NSMutableArray array];
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
    QUICStateObject * stateObject = [QUICStateObject stateWithProperty:keyPath quickControlState:QUIckControlStateMake(state, inverted)];
    [self.states addObject:stateObject];
}

#pragma mark - Actions

-(QUIckControlActionTarget)addAction:(void (^)(__kindof QUIckControl *__weak))action forControlEvents:(UIControlEvents)events {
    QUIckControlActionTargetImp * actionTarget = [[QUIckControlActionTargetImp alloc] initWithControl:self controlEvents:events];
    actionTarget.action = action;
    [self.actionTargets addObject:actionTarget];
    
    return actionTarget;
}

-(QUIckControlActionTarget)addActionTarget:(QUIckControlActionTarget)target {
    QUIckControlActionTargetImp * sourceTarget = (QUIckControlActionTargetImp*)target;
    QUIckControlActionTargetImp * actionTarget = [[QUIckControlActionTargetImp alloc] initWithControl:self controlEvents:sourceTarget.events];
    actionTarget.action = sourceTarget.action;
    [self.actionTargets addObject:actionTarget];
    
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
    [self setValue:value forTarget:target forKeyPath:key forStateDescriptor:QUICStateDescriptorMake(state, QUICStateTypeInverted)];
}

-(void)setValue:(id)value forTarget:(id)target forKeyPath:(NSString *)key forAllStatesContained:(UIControlState)state {
    [self setValue:value forTarget:target forKeyPath:key forStateDescriptor:QUICStateDescriptorMake(state, QUICStateTypeIntersected)];
}

-(void)setValue:(id)value forKeyPath:(NSString *)key forState:(UIControlState)state {
    [self setValue:value forTarget:self forKeyPath:key forState:state];
}

// TODO: Create possible add values for multiple states
-(void)setValue:(id)value forTarget:(id)target forKeyPath:(NSString *)key forState:(UIControlState)state {
    [self setValue:value forTarget:target forKeyPath:key forStateDescriptor:QUICStateDescriptorMake(state, QUICStateTypeUsual)];
}

-(void)setValue:(id)value forTarget:(id)target forKeyPath:(NSString *)key forStateDescriptor:(QUICStateDescriptor)descr {
    QUIckControlValueTarget * valueTarget = [self valueTargetForTarget:target];
    [valueTarget setValue:value forKeyPath:key forStateDescriptor:descr];
    if (QUICStateEvaluateWithState(descr, self.state)) {
        [valueTarget applyValue:value forKey:key];
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
    
    for (QUICStateObject * stateValue in self.states) {
        if ([stateValue evaluateWithObject:self]) {
            state |= stateValue.state.controlState;
        }
    }
    
    return state;
}

-(void)dealloc {
    for (QUIckControlActionTarget target in self.actionTargets) {
        [target stop];
    }
    [self.actionTargets removeAllObjects];
}

@end
