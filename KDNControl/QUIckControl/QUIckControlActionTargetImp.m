//
//  QUIckControlActionTargetImp.m
//  KDNControl
//
//  Created by Denis Koryttsev on 03/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import "QUIckControlActionTargetImp.h"
#import "QUIckControl.h"

@implementation QUIckControlActionTargetImp

-(instancetype)initWithControl:(QUIckControl *)control controlEvents:(UIControlEvents)events {
    if (self = [super init]) {
        _events = events;
        _parentControl = control;
    }
    
    return self;
}

-(void)actionSelector:(QUIckControl*)control {
    if (self.action) self.action(self.parentControl);
}

-(void)start {
    [self.parentControl addTarget:self action:@selector(actionSelector:) forControlEvents:self.events];
}

-(void)stop {
    [self.parentControl removeTarget:self action:@selector(actionSelector:) forControlEvents:self.events];
}

@end
