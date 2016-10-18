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
@property (weak, nonatomic) IBOutlet QUIckControl *control;
@property (weak, nonatomic) IBOutlet UIButton *testButton;
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
    [self.pincodeControl setFillColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [self.pincodeControl setFillColor:[UIColor colorWithRed:250.0/255.0 green:88.0/255.0 blue:87.0/255.0 alpha:1] forState:PincodeControlStateInvalid];
    [self.pincodeControl setFillColor:[UIColor colorWithRed:250.0/255.0 green:88.0/255.0 blue:87.0/255.0 alpha:1] forState:PincodeControlStateInvalid | UIControlStateHighlighted];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:NO];
}

-(void)controlTouchUpInside:(QUIckControl*)control {
    [control setSelected:!control.isSelected];
//    self.example.exampleState = control.isSelected;
}

- (IBAction)testButton:(UIButton *)sender {
    [sender setSelected:!sender.isSelected];
    self.control.opaque = self.testButton.isSelected;
}

@end