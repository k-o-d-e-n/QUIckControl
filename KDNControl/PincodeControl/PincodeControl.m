//
//  PincodeControl.m
//  KDNControl
//
//  Created by Denis Koryttsev on 16/10/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import "PincodeControl.h"

@interface PincodeControl ()
@property (nonatomic, strong) NSMutableString * text;
@property (nonatomic, readwrite) IBInspectable NSUInteger codeLength;
@property (nonatomic) BOOL filled;
@end

@implementation PincodeControl

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self loadInstances];
        [self loadSublayers];
    }
    
    return self;
}

-(instancetype)initWithCodeLength:(NSUInteger)codeLength {
    if (self = [self initWithFrame:CGRectZero]) {
        self.codeLength = codeLength;
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self loadInstances];
        [self loadSublayers];
    }
    
    return self;
}

-(void)setFilled:(BOOL)filled {
    if (_filled != filled) {
        _filled = filled;
        [self applyCurrentState];
    }
}

-(void)setCodeLength:(NSUInteger)codeLength {
    _codeLength = codeLength;
    [self loadSublayers];
}

-(void)loadInstances {
    self.text = [[NSMutableString alloc] init];
}

-(void)loadSublayers {
    for (NSUInteger i = 0; i < self.codeLength; ++i) {
        CAShapeLayer * sublayer = [CAShapeLayer layer];
        
        sublayer.backgroundColor = [UIColor grayColor].CGColor;
        
        [self.layer addSublayer:sublayer];
    }
    [self setNeedsLayout];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self layoutCodeItemLayers];
}

-(void)layoutCodeItemLayers {
    CGFloat itemWidth = (self.bounds.size.width - (self.spaceBetweenItems * (self.codeLength - 1))) / self.codeLength;
    for (NSUInteger i = 0; i < self.layer.sublayers.count; ++i) {
        CALayer * sublayer = self.layer.sublayers[i];
        [sublayer setFrame:CGRectMake((itemWidth * i) + (i * self.spaceBetweenItems), CGRectGetMidY(self.bounds) - itemWidth / 2, itemWidth, itemWidth)];
        sublayer.cornerRadius = itemWidth / 2;
    }
}

#pragma mark - UIControl

-(void)setBorderWidth:(CGFloat)borderWidth forState:(UIControlState)state {
    [self setValue:@(borderWidth) forTarget:self.layer.sublayers forKeyPath:keyPath(CALayer, borderWidth) forState:state];
}

-(void)setBorderColor:(UIColor*)borderColor forState:(UIControlState)state {
    [self setValue:(id)borderColor.CGColor forTarget:self.layer.sublayers forKeyPath:keyPath(CALayer, borderColor) forState:state];
}

#pragma mark - UIResponder

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [super touchesEnded:touches withEvent:event];
    [self becomeFirstResponder];
}

-(BOOL)becomeFirstResponder {
    self.highlighted = YES;
    return [super becomeFirstResponder];
}

-(BOOL)resignFirstResponder {
    self.highlighted = NO;
    return [super resignFirstResponder];
}

#pragma mark - UIKeyInput

-(BOOL)hasText {
    return self.text.length > 0;
}

-(void)deleteBackward {
    if ([self hasText]) {
        if (self.text.length == self.codeLength) {
            self.filled = NO;
        }
        [self.text deleteCharactersInRange:NSMakeRange(self.text.length - 1, 1)];
        [self.layer.sublayers[self.text.length] setBackgroundColor:[UIColor grayColor].CGColor];
    }
}

-(void)insertText:(NSString *)text {
    if (self.text.length < self.codeLength) {
        [self.layer.sublayers[self.text.length] setBackgroundColor:[UIColor greenColor].CGColor];
        [self.text appendString:text];
    } else {
        self.filled = YES;
    }
}

-(UITextAutocorrectionType)autocorrectionType {
    return UITextAutocorrectionTypeNo;
}

-(UIKeyboardType)keyboardType {
    return UIKeyboardTypeNumberPad;
}

-(UITextAutocapitalizationType)autocapitalizationType {
    return UITextAutocapitalizationTypeNone;
}

@end
