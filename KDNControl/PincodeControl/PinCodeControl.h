//
//  PincodeControl.h
//  KDNControl
//
//  Created by Denis Koryttsev on 16/10/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import "QUIckControl.h"

static const UIControlState PinCodeControlStateFilled = 1 << 16;
static const UIControlState PinCodeControlStateInvalid = 1 << 17;
static const UIControlEvents PinCodeControlEventTypeComplete = 1 << 24;

@interface PinCodeControl : QUIckControl<UIKeyInput>

// current code string
@property (nonatomic, readonly) NSString * code;

// full code length, defined number elements
@property (nonatomic, readonly) NSUInteger codeLength;

// space between code items
@property (nonatomic) IBInspectable CGFloat spaceBetweenItems;

// size of side code item
@property (nonatomic, readonly) IBInspectable CGFloat sideSize;

// filled state, yes when code type ended.
@property (nonatomic, readonly) BOOL filled;

// valid state, yes if entered code is valid.
@property (nonatomic, readonly) BOOL valid;

@property (nonatomic, copy) BOOL(^validationBlock)(NSString * code);

@property (nonatomic) BOOL shouldUseDefaultValidation;

// color for fill code item when user input code symbol
@property (nonatomic) UIColor * filledItemColor;

// bezier path for code item
@property (nonatomic) UIBezierPath * itemPath;

-(instancetype)initWithCodeLength:(NSUInteger)codeLength sideSize:(CGFloat)sideSize;

// border width of code item
-(void)setBorderWidth:(CGFloat)borderWidth forState:(UIControlState)state;
-(void)setBorderWidth:(CGFloat)borderWidth forIntersectedState:(UIControlState)state;

// border color of code item
-(void)setBorderColor:(UIColor*)borderColor forState:(UIControlState)state;
-(void)setBorderColor:(UIColor*)borderColor forIntersectedState:(UIControlState)state;

// fill color of code item
-(void)setFillColor:(UIColor*)fillColor forState:(UIControlState)state;
-(void)setFillColor:(UIColor*)fillColor forIntersectedState:(UIControlState)state;

// clear all entered code
-(void)clear;

@end
