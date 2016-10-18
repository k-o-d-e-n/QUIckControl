//
//  PincodeControl.m
//  KDNControl
//
//  Created by Denis Koryttsev on 16/10/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import "PincodeControl.h"

@interface NSString (PincodeControl)
-(void)enumerateCharacters:(void(^)(NSString* character, NSUInteger index, BOOL * stop))enumerator;
@end

@implementation NSString (PincodeControl)

-(void)enumerateCharacters:(void(^)(NSString* character, NSUInteger index, BOOL * stop))enumerator {
    BOOL stop = NO;
    NSRange range = NSMakeRange(0, 1);
    for (range.location = 0; range.location < [self length]; ++range.location) {
        enumerator([self substringWithRange:range], range.location, &stop);
        if (stop) return;
    }
}

@end

@interface PincodeControl ()
@property (nonatomic, strong) NSMutableString * text;
@property (nonatomic, readwrite) IBInspectable NSUInteger codeLength;
@property (nonatomic) BOOL filled;
@property (nonatomic) BOOL valid;
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

-(void)setValid:(BOOL)valid {
    if (_valid != valid) {
        _valid = valid;
        [self applyCurrentState];
    }
}

-(void)setCodeLength:(NSUInteger)codeLength {
    _codeLength = codeLength;
    [self loadSublayers];
}

-(void)loadInstances {
    _valid = YES;
    self.text = [[NSMutableString alloc] init];
    [self registerState:PincodeControlStateFilled forBoolKeyPath:keyPath(PincodeControl, filled) inverted:NO];
    [self registerState:PincodeControlStateInvalid forBoolKeyPath:keyPath(PincodeControl, valid) inverted:YES];
}

-(void)loadSublayers {
    for (NSUInteger i = 0; i < self.codeLength; ++i) {
        CAShapeLayer * sublayer = [CAShapeLayer layer];
        sublayer.borderWidth = 1;
        sublayer.fillColor = [UIColor clearColor].CGColor;
        
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
        CAShapeLayer * sublayer = (CAShapeLayer*)self.layer.sublayers[i];
        [sublayer setFrame:CGRectMake((itemWidth * i) + (i * self.spaceBetweenItems), CGRectGetMidY(self.bounds) - itemWidth / 2, itemWidth, itemWidth)];
        sublayer.cornerRadius = itemWidth / 2;
        sublayer.path = [UIBezierPath bezierPathWithOvalInRect:sublayer.bounds].CGPath;
    }
}

#pragma mark - UIControl

-(void)setBorderWidth:(CGFloat)borderWidth forState:(UIControlState)state {
    [self setValue:@(borderWidth) forTarget:self.layer.sublayers forKeyPath:keyPath(CALayer, borderWidth) forState:state];
}

-(void)setBorderColor:(UIColor*)borderColor forState:(UIControlState)state {
    [self setValue:(id)borderColor.CGColor forTarget:self.layer.sublayers forKeyPath:keyPath(CALayer, borderColor) forState:state];
}

-(void)setFillColor:(UIColor*)fillColor forState:(UIControlState)state {
    [self setValue:(id)fillColor.CGColor forTarget:self.layer.sublayers forKeyPath:keyPath(CAShapeLayer, fillColor) forState:state];
}

//-(UIControlState)state {
//    return self.valid ? [super state] | PincodeControlStateInvalid : [super state];
//}

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

// TODO: Make performStateChanges for multiply state transition. And add possible set bool state property without apply content
-(void)deleteBackward {
    if ([self hasText]) {
        if (self.text.length == self.codeLength) {
            _filled = NO;
            _valid = YES;
            [self applyCurrentState];
        }
        [self.text deleteCharactersInRange:NSMakeRange(self.text.length - 1, 1)];
        [self.layer.sublayers[self.text.length] setBackgroundColor:(CGColorRef)[self valueForTarget:self.layer.sublayers forKey:keyPath(CALayer, backgroundColor) forState:self.state]];
    }
}

-(void)insertText:(NSString *)text {
    if (self.text.length < self.codeLength) {
        [self.layer.sublayers[self.text.length] setBackgroundColor:self.fillColor.CGColor];
        [self.text appendString:text];
        if (self.text.length == self.codeLength) {
            self.filled = YES;
            self.valid = [self isMeetRequirements:self.text];
        }
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

#pragma mark - Validation

-(BOOL)isMeetRequirements:(NSString*)pin {
    __block BOOL isEqual = YES;
    __block BOOL isIncremented = YES;
    __block BOOL isDecremented = YES;
    [pin enumerateCharacters:^(NSString *character, NSUInteger index, BOOL *stop) {
        BOOL isLast = index == pin.length - 1;
        if (isLast) return;
        
        short number = character.intValue;
        short next = [pin substringWithRange:NSMakeRange(index + 1, 1)].intValue;
        isEqual = isEqual && number == next;
        isIncremented = isIncremented && (number + 1) == next;
        isDecremented = isDecremented && (number - 1) == next;
    }];
    
    return !(isEqual || isIncremented || isDecremented);
}

@end
