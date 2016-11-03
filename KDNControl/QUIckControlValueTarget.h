//
//  QUIckControlValueTarget.h
//  KDNControl
//
//  Created by Denis Koryttsev on 03/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QUIckControlValueTarget : NSObject

@property (nonatomic, weak, readonly) id target;

-(instancetype)initWithTarget:(id)target;

-(void)setValue:(id)value forKeyPath:(NSString *)key forInvertedState:(UIControlState)state;
-(void)setValue:(id)value forKeyPath:(NSString *)key forState:(UIControlState)state;
-(void)setValue:(id)value forKeyPath:(NSString *)key forIntersectedState:(UIControlState)state;

-(void)applyValuesForState:(UIControlState)state;

-(id)valueForKey:(NSString*)key forState:(UIControlState)state;

@end
