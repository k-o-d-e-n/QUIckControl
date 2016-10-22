//
//  KDNControl.h
//  KDNControl
//
//  Created by Denis Koryttsev on 16/10/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import <UIKit/UIKit.h>

#define keyPath(class, key) ((class *)nil).key ? @#key : @#key

@interface QUIckControl : UIControl

-(void)beginTransition; // after call this method applyCurrentState method not effect
-(void)commitTransition; // close transition process and apply changes. If call without beginTransition not effect - for update you should use applyCurrentState method.
-(void)performTransition:(void(^)())transition; // block wrapper for beginTransition and commitTransition

-(void)setValue:(id)value forTarget:(id)target forKeyPath:(NSString *)key forState:(UIControlState)state;
-(void)setValue:(id)value forTarget:(id)target forKeyPath:(NSString *)key forAllStatesContained:(UIControlState)state;
-(void)setValue:(id)value forKeyPath:(NSString *)key forState:(UIControlState)state; // in good case should use only in superclass, or inside subclass
-(void)registerState:(UIControlState)state forBoolKeyPath:(NSString*)keyPath inverted:(BOOL)inverted;
-(void)removeValuesForTarget:(id)target;

-(void)applyCurrentState;
-(void)applyCurrentStateForTarget:(id)target;

-(id)valueForTarget:(id)target forKey:(NSString*)key forState:(UIControlState)state;

@end
