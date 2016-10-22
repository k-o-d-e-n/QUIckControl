//
//  PincodeControl.h
//  KDNControl
//
//  Created by Denis Koryttsev on 16/10/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import "QUIckControl.h"

static const UIControlState PincodeControlStateFilled = 1 << 16;
static const UIControlState PincodeControlStateInvalid = (1 << 17) | PincodeControlStateFilled;
static const UIControlEvents PincodeControlEventTypeComplete = 1 << 24;

@interface PincodeControl : QUIckControl<UIKeyInput>

@property (nonatomic, readonly) NSString * code;
@property (nonatomic, readonly) NSUInteger codeLength;
@property (nonatomic) IBInspectable CGFloat spaceBetweenItems;
@property (nonatomic, readonly) IBInspectable CGFloat sideSize;
@property (nonatomic, readonly) BOOL filled;
@property (nonatomic, readonly) BOOL valid;
@property (nonatomic) UIColor * fillColor;
@property (nonatomic) UIBezierPath * elementPath;

-(void)setBorderWidth:(CGFloat)borderWidth forState:(UIControlState)state;
-(void)setBorderColor:(UIColor*)borderColor forState:(UIControlState)state;
-(void)setFillColor:(UIColor*)fillColor forState:(UIControlState)state;

-(void)clear;

@end
