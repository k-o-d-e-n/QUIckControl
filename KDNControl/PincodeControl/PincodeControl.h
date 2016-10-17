//
//  PincodeControl.h
//  KDNControl
//
//  Created by Denis Koryttsev on 16/10/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import "KDNControl.h"

static const UIControlState PincodeControlStateFilled = 1 << 16;

@interface PincodeControl : KDNControl<UIKeyInput>

@property (nonatomic, readonly) NSUInteger codeLength;
@property (nonatomic) IBInspectable CGFloat spaceBetweenItems;
@property (nonatomic, readonly) BOOL filled;

-(void)setBorderWidth:(CGFloat)borderWidth forState:(UIControlState)state;
-(void)setBorderColor:(UIColor*)borderColor forState:(UIControlState)state;

@end
