//
//  PincodeControl.m
//  KDNControl
//
//  Created by Denis Koryttsev on 16/10/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import "PinCodeControl.h"

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

@interface ValueApplier : NSObject
@property (nonatomic) id defaultValue;
@property (nonatomic, weak) PinCodeControl * control;
@end

@interface PinCodeControl ()
@property (nonatomic, strong) ValueApplier * applier;
@property (nonatomic, strong) NSMutableString * text;
@property (nonatomic, readwrite) IBInspectable NSUInteger codeLength;
@property (nonatomic) BOOL filled;
@property (nonatomic) BOOL valid;
@property (nonatomic, readonly) NSArray<CAShapeLayer*>* sublayers;
@property (nonatomic, strong) UIBezierPath * defaultPath;
@end

@implementation ValueApplier

-(instancetype)initWithControl:(PinCodeControl*)control {
    if (self = [super init]) {
        _control = control;
    }
    
    return self;
}

-(void)setValue:(id)value forKey:(NSString *)key {
    if (![key isEqual:keyPath(CAShapeLayer, fillColor)] || self.control.codeLength == self.control.code.length) {
        [self.control.sublayers setValue:value forKey:key];
        return;
    }
    
    for (short i = 0; i < self.control.codeLength; ++i) {
        [self.control.sublayers[i] setValue:i < self.control.code.length ? (id)self.control.filledItemColor.CGColor : value
                                           forKey:key];
    }
}

-(id)valueForKeyPath:(NSString *)keyPath {
    return [self.control.sublayers.lastObject valueForKeyPath:keyPath];
}

@end

@implementation PinCodeControl

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializeInstance];
    }
    
    return self;
}

-(instancetype)initWithCodeLength:(NSUInteger)codeLength sideSize:(CGFloat)sideSize {
    if (self = [self initWithFrame:CGRectZero]) {
        _spaceBetweenItems = 15;
        self.sideSize = sideSize;
        self.codeLength = codeLength;
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializeInstance];
    }
    
    return self;
}

-(void)initializeInstance {
    _valid = YES;
    _shouldUseDefaultValidation = YES;
    self.text = [[NSMutableString alloc] init];
    self.applier = [[ValueApplier alloc] initWithControl:self];
    
    [self registerState:PinCodeControlStateFilled forBoolKeyPath:keyPath(PinCodeControl, filled) inverted:NO];
    [self registerState:PinCodeControlStateInvalid forBoolKeyPath:keyPath(PinCodeControl, valid) inverted:YES];
}

-(NSArray<CAShapeLayer *> *)sublayers {
    return (NSArray*)self.layer.sublayers;
}

-(NSString *)code {
    return [self.text copy];
}

-(void)setSideSize:(CGFloat)sideSize {
    _sideSize = sideSize;
    self.defaultPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, self.sideSize, self.sideSize)];
}

-(void)setFilled:(BOOL)filled {
    if (_filled != filled) {
        _filled = filled;
        [self applyCurrentState];
        if (filled) {
            [self sendActionsForControlEvents:PinCodeControlEventTypeComplete];
        }
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
    [self loadDefaults];
}

-(void)loadDefaults {
    self.filledItemColor = [UIColor grayColor];
    UIColor * filledColor = [UIColor colorWithRed:76.0/255.0 green:145.0/255.0 blue:65.0/255.0 alpha:1];
    UIColor * invalidColor = [UIColor colorWithRed:250.0/255.0 green:88.0/255.0 blue:87.0/255.0 alpha:1];
    [self setBorderColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self setBorderColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//    [self setFillColor:filledColor forState:PinCodeControlStateFilled];
//    [self setBorderColor:filledColor forState:PinCodeControlStateFilled];
//    [self setFillColor:filledColor forState:PinCodeControlStateFilled | UIControlStateHighlighted];
//    [self setBorderColor:filledColor forState:PinCodeControlStateFilled | UIControlStateHighlighted];
//    [self setFillColor:filledColor forIntersectedState:PinCodeControlStateFilled];
//    [self setBorderColor:filledColor forIntersectedState:PinCodeControlStateFilled];
    [self setFillColor:filledColor forInvertedState:PinCodeControlStateInvalid];
    [self setBorderColor:filledColor forInvertedState:PinCodeControlStateInvalid];
    [self setFillColor:nil forInvertedState:PinCodeControlStateFilled];
    [self setBorderColor:nil forInvertedState:PinCodeControlStateFilled];
    [self setFillColor:invalidColor forIntersectedState:PinCodeControlStateInvalid | PinCodeControlStateFilled];
    [self setBorderColor:invalidColor forIntersectedState:PinCodeControlStateInvalid | PinCodeControlStateFilled];
    [self applyCurrentState];
}

-(void)loadSublayers {
    for (NSUInteger i = 0; i < self.codeLength; ++i) {
        CAShapeLayer * sublayer = [CAShapeLayer layer];
        sublayer.actions = @{keyPath(CAShapeLayer, fillColor):[NSNull null], keyPath(CAShapeLayer, lineWidth):[NSNull null],
                             keyPath(CAShapeLayer, strokeColor):[NSNull null]};
        sublayer.lineWidth = 1;
        sublayer.strokeColor = [UIColor lightGrayColor].CGColor;
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
    CGFloat fullWidth = (self.codeLength * (self.sideSize)) + (self.codeLength - 1) * self.spaceBetweenItems;
    CGFloat originX = CGRectGetMidX(self.bounds) - (fullWidth / 2);
    for (NSUInteger i = 0; i < self.layer.sublayers.count; ++i) {
        CAShapeLayer * sublayer = (CAShapeLayer*)self.layer.sublayers[i];
        [sublayer setFrame:CGRectMake(originX + (i * (self.spaceBetweenItems + self.sideSize)), CGRectGetMidY(self.bounds) - self.sideSize / 2, self.sideSize, self.sideSize)];
        sublayer.path = self.itemPath.CGPath ?: self.defaultPath.CGPath;
    }
}

-(void)clear {
    [self deleteCharactersInRange:NSMakeRange(0, self.text.length)];
    [self performTransition:^{
        self.filled = NO;
        self.valid = YES;
    }];
}

#pragma mark - UIControl

-(void)setBorderWidth:(CGFloat)borderWidth forInvertedState:(UIControlState)state {
    [self setValue:@(borderWidth) forTarget:self.applier forKeyPath:keyPath(CAShapeLayer, lineWidth) forInvertedState:state];
}

-(void)setBorderColor:(UIColor*)borderColor forInvertedState:(UIControlState)state {
    [self setValue:(id)borderColor.CGColor forTarget:self.applier forKeyPath:keyPath(CAShapeLayer, strokeColor) forInvertedState:state];
}

-(void)setFillColor:(UIColor*)fillColor forInvertedState:(UIControlState)state {
    [self setValue:(id)fillColor.CGColor forTarget:self.applier forKeyPath:keyPath(CAShapeLayer, fillColor) forInvertedState:state];
}

-(void)setBorderWidth:(CGFloat)borderWidth forIntersectedState:(UIControlState)state {
    [self setValue:@(borderWidth) forTarget:self.applier forKeyPath:keyPath(CAShapeLayer, lineWidth) forAllStatesContained:state];
}

-(void)setBorderColor:(UIColor*)borderColor forIntersectedState:(UIControlState)state {
    [self setValue:(id)borderColor.CGColor forTarget:self.applier forKeyPath:keyPath(CAShapeLayer, strokeColor) forAllStatesContained:state];
}

-(void)setFillColor:(UIColor*)fillColor forIntersectedState:(UIControlState)state {
    [self setValue:(id)fillColor.CGColor forTarget:self.applier forKeyPath:keyPath(CAShapeLayer, fillColor) forAllStatesContained:state];
}

-(void)setBorderWidth:(CGFloat)borderWidth forState:(UIControlState)state {
    [self setValue:@(borderWidth) forTarget:self.applier forKeyPath:keyPath(CAShapeLayer, lineWidth) forState:state];
}

-(void)setBorderColor:(UIColor*)borderColor forState:(UIControlState)state {
    [self setValue:(id)borderColor.CGColor forTarget:self.applier forKeyPath:keyPath(CAShapeLayer, strokeColor) forState:state];
}

-(void)setFillColor:(UIColor*)fillColor forState:(UIControlState)state {
    [self setValue:(id)fillColor.CGColor forTarget:self.applier forKeyPath:keyPath(CAShapeLayer, fillColor) forState:state];
}

#pragma mark - UIResponder

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self performTransition:^{
        [super touchesEnded:touches withEvent:event];
        [self becomeFirstResponder];
    }];
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
            [self beginTransition];
            self.filled = NO;
            self.valid = YES;
        }
        [self deleteCharactersInRange:NSMakeRange(self.text.length - 1, 1)];
        [self commitTransition];
    }
}

-(void)deleteCharactersInRange:(NSRange)range {
    [self.text deleteCharactersInRange:range];
    NSArray * elements = [self.layer.sublayers subarrayWithRange:range];
    [elements setValue:[self valueForTarget:self.applier forKey:keyPath(CAShapeLayer, fillColor) forState:self.state] forKey:keyPath(CAShapeLayer, fillColor)];
}

-(void)insertText:(NSString *)text {
    if (self.text.length < self.codeLength) {
        [self.sublayers[self.text.length] setFillColor:self.filledItemColor.CGColor];
        [self.text appendString:text];
        if (self.text.length == self.codeLength) {
            [self performTransition:^{
                self.filled = YES;
                self.valid = [self validate:self.text];
            }];
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

-(BOOL)validate:(NSString*)pin {
    return (self.shouldUseDefaultValidation ? [self defaultValidation:pin] : YES) &&
            (self.validationBlock ? self.validationBlock([pin copy]) : YES);
}

-(BOOL)defaultValidation:(NSString*)pin {
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
