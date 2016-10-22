//
//  ViewController.m
//  KDNControl
//
//  Created by Denis Koryttsev on 16/10/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import "ViewController.h"
#import "PincodeControl.h"

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
@property (weak, nonatomic) ExampleControl * example;
@property (weak, nonatomic) IBOutlet PincodeControl *pincodeControl;
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
    
    ExampleControl * example = [[ExampleControl alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
//    [example setValue:[UIColor grayColor] forKeyPath:keyPath(ExampleControl, backgroundColor) forState:ExampleState];
    [self.view addSubview:example]; self.example = example;
    [self.control setValue:[UIColor grayColor] forTarget:self.example forKeyPath:keyPath(ExampleControl, backgroundColor) forState:UIControlStateSelected];
    [self.control setValue:@5 forTarget:self.example forKeyPath:keyPath(ExampleControl, layer.borderWidth) forState:UIControlStateSelected];
    
    self.pincodeControl.fillColor = [UIColor whiteColor];
    [self.pincodeControl setBorderColor:[UIColor colorWithRed:86.0/255.0 green:86.0/255.0 blue:86.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.pincodeControl setBorderColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.pincodeControl setFillColor:[UIColor colorWithRed:1 green:176.0/255.0 blue:89.0/255.0 alpha:1] forState:PincodeControlStateFilled];
    [self.pincodeControl setFillColor:[UIColor colorWithRed:1 green:176.0/255.0 blue:89.0/255.0 alpha:1] forState:PincodeControlStateFilled | UIControlStateHighlighted];
    [self.pincodeControl setBorderColor:[UIColor colorWithRed:1 green:176.0/255.0 blue:89.0/255.0 alpha:1] forState:PincodeControlStateFilled];
    [self.pincodeControl setBorderColor:[UIColor colorWithRed:1 green:176.0/255.0 blue:89.0/255.0 alpha:1] forState:PincodeControlStateFilled | UIControlStateHighlighted];
//    [self.pincodeControl setFillColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [self.pincodeControl setFillColor:[UIColor colorWithRed:250.0/255.0 green:88.0/255.0 blue:87.0/255.0 alpha:1] forState:PincodeControlStateInvalid];
    [self.pincodeControl setFillColor:[UIColor colorWithRed:250.0/255.0 green:88.0/255.0 blue:87.0/255.0 alpha:1] forState:PincodeControlStateInvalid | UIControlStateHighlighted];
    [self.pincodeControl setBorderColor:[UIColor colorWithRed:250.0/255.0 green:88.0/255.0 blue:87.0/255.0 alpha:1] forState:PincodeControlStateInvalid];
    [self.pincodeControl setBorderColor:[UIColor colorWithRed:250.0/255.0 green:88.0/255.0 blue:87.0/255.0 alpha:1] forState:PincodeControlStateInvalid | UIControlStateHighlighted];
    
    [self.pincodeControl setValue:[UIColor colorWithWhite:112.0/255.0 alpha:.7] forTarget:self.dependedLabel forKeyPath:keyPath(UILabel, textColor) forState:UIControlStateNormal];
    [self.pincodeControl setValue:[UIColor colorWithWhite:1 alpha:.7] forTarget:self.dependedLabel forKeyPath:keyPath(UILabel, textColor) forState:UIControlStateHighlighted];
    [self.pincodeControl addTarget:self action:@selector(pincodeTypeComplete:) forControlEvents:PincodeControlEventTypeComplete];
    [self.pincodeControl setValue:@1 forTarget:self.pincodeControl forKeyPath:keyPath(UIView, layer.borderWidth) forAllStatesContained:UIControlStateHighlighted];
    [self.pincodeControl setValue:[self starShape:CGRectMake(0, 0, self.pincodeControl.sideSize, self.pincodeControl.sideSize)] forKeyPath:keyPath(PincodeControl, elementPath) forState:UIControlStateHighlighted];
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

-(void)pincodeTypeComplete:(PincodeControl*)control {
    NSLog(@"%@", control.code);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:NO];
}

-(void)controlTouchUpInside:(QUIckControl*)control {
    [control setSelected:!control.isSelected];
    if (!control.isSelected) {
        [self.control removeValuesForTarget:self.example];
    }
//    self.example.exampleState = control.isSelected;
}

@end
