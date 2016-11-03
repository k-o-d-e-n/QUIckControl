//
//  ViewController.m
//  KDNControl
//
//  Created by Denis Koryttsev on 16/10/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import "ViewController.h"
#import "PinCodeControl.h"

@interface ExampleControl : QUIckControl
@property (nonatomic) BOOL exampleState;
@end

static const UIControlState ExampleState = 1 << 16;

@implementation ExampleControl

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self registerState:ExampleState forBoolKeyPath:keyPath(ExampleControl, exampleState) inverted:NO];
    }
    
    return self;
}

-(void)setExampleState:(BOOL)exampleState {
    _exampleState = exampleState;
    [self applyCurrentState];
}

@end

static const UIControlState QUIckControlStateOpaque = 1 << 16;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dependedLabel;
@property (weak, nonatomic) IBOutlet QUIckControl *control;
@property (weak, nonatomic) IBOutlet ExampleControl *example;
@property (weak, nonatomic) IBOutlet PinCodeControl *pincodeControl;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.control registerState:QUIckControlStateOpaque forBoolKeyPath:keyPath(UIView, opaque) inverted:YES];
    [self.control setValue:[UIColor blackColor] forKeyPath:keyPath(UIView, backgroundColor) forState:QUIckControlStateOpaque];
    [self.control setValue:@2 forKeyPath:keyPath(UIView, layer.borderWidth) forState:UIControlStateSelected];
    [self.control setValue:[UIColor redColor] forKeyPath:keyPath(UIView, backgroundColor) forState:UIControlStateSelected];
    [self.control setValue:[UIColor yellowColor] forKeyPath:keyPath(UIView, backgroundColor) forState:UIControlStateHighlighted | UIControlStateSelected];
    [self.control setValue:[UIColor yellowColor] forKeyPath:keyPath(UIView, backgroundColor) forState:UIControlStateHighlighted];
    [self.control addTarget:self action:@selector(controlTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.control setValue:[UIColor grayColor] forTarget:self.example forKeyPath:keyPath(ExampleControl, backgroundColor) forState:UIControlStateSelected];
    [self.control setValue:@5 forTarget:self.example forKeyPath:keyPath(ExampleControl, layer.borderWidth) forState:UIControlStateSelected];
    
    [self.pincodeControl setValue:[UIColor colorWithWhite:112.0/255.0 alpha:.7] forTarget:self.dependedLabel forKeyPath:keyPath(UILabel, textColor) forState:UIControlStateNormal];
    [self.pincodeControl setValue:[UIColor colorWithWhite:1 alpha:.7] forTarget:self.dependedLabel forKeyPath:keyPath(UILabel, textColor) forState:UIControlStateHighlighted];
    [self.pincodeControl addTarget:self action:@selector(pincodeTypeComplete:) forControlEvents:PinCodeControlEventTypeComplete];
    [[self.pincodeControl addAction:^(__kindof QUIckControl *__weak control) {
        NSLog(@"%@", control);
    } forControlEvents:UIControlEventTouchUpInside] start];
    [self.pincodeControl setValue:[UIColor colorWithWhite:1 alpha:.3] forTarget:self.pincodeControl forKeyPath:keyPath(UIView, backgroundColor) forAllStatesContained:UIControlStateHighlighted];
    [self.pincodeControl setValue:[self starShape:CGRectMake(0, 0, self.pincodeControl.sideSize, self.pincodeControl.sideSize)] forKeyPath:keyPath(PinCodeControl, itemPath) forState:UIControlStateHighlighted];
    [self.pincodeControl setValue:@5 forTarget:self.pincodeControl forKeyPath:keyPath(PinCodeControl, layer.cornerRadius) forInvertedState:PinCodeControlStateFilled];
    [self.pincodeControl setValue:[UIColor grayColor] forTarget:self.pincodeControl forKeyPath:keyPath(PinCodeControl, backgroundColor) forInvertedState:UIControlStateHighlighted];
}

-(UIBezierPath *)starShape:(CGRect)frame {
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.67634 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30729 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97553 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39549 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.78532 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64271 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.79389 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.95451 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.85000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20611 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.95451 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.21468 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64271 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02447 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39549 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.32366 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30729 * CGRectGetHeight(frame))];
    [bezierPath closePath];
    
    return bezierPath;
}

-(void)pincodeTypeComplete:(PinCodeControl*)control {
    NSLog(@"%@", control.code);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:NO];
}

-(void)controlTouchUpInside:(QUIckControl*)control {
    [control setSelected:!control.isSelected];
    self.example.exampleState = control.isSelected;
}

@end
