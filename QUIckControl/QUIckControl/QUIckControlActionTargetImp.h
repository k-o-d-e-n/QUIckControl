//
//  QUIckControlActionTargetImp.h
//  KDNControl
//
//  Created by Denis Koryttsev on 03/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QUIckControlActionTarget.h"

@class QUIckControl;

@interface QUIckControlActionTargetImp : NSObject<QUIckControlActionTarget>

@property (nonatomic, weak) QUIckControl * parentControl;
@property (nonatomic) UIControlEvents events;
@property (nonatomic, copy) void(^action)(__weak QUIckControl* control);

-(instancetype)initWithControl:(QUIckControl*)control controlEvents:(UIControlEvents)events;

@end
