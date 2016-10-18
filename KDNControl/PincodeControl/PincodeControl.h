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

@interface PincodeControl : QUIckControl<UIKeyInput>

@property (nonatomic, readonly) NSUInteger codeLength;
@property (nonatomic) IBInspectable CGFloat spaceBetweenItems;
@property (nonatomic, readonly) BOOL filled;
@property (nonatomic, readonly) BOOL valid;
@property (nonatomic) UIColor * fillColor;

-(void)setBorderWidth:(CGFloat)borderWidth forState:(UIControlState)state;
-(void)setBorderColor:(UIColor*)borderColor forState:(UIControlState)state;
-(void)setFillColor:(UIColor*)fillColor forState:(UIControlState)state;

@end
