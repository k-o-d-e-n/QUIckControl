//
//  QUICStateDescriptorKey.h
//  QUIckControl
//
//  Created by Denis Koryttsev on 06/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(short, QUICStateType) {
    QUICStateTypeUsual,
    QUICStateTypeInverted,
    QUICStateTypeIntersected
};

typedef struct {
    UIControlState state;
    QUICStateType type;
} QUICStateDescriptor;

extern QUICStateDescriptor QUICStateDescriptorMake(UIControlState state, QUICStateType type);
extern BOOL QUICStateEvaluateWithState(QUICStateDescriptor descriptor, UIControlState state);

@interface QUICStateDescriptorKey : NSObject<NSCopying>

@property (nonatomic, readonly) QUICStateDescriptor descriptor;

-(instancetype)initWithDescriptor:(QUICStateDescriptor)descriptor;

-(BOOL)evaluateWithState:(UIControlState)state;

@end
