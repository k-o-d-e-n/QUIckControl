//
//  QUIckControlValueTarget.h
//  KDNControl
//
//  Created by Denis Koryttsev on 03/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QUICStateDescriptorKey.h"

@interface QUIckControlValueTarget : NSObject

@property (nonatomic, weak, readonly) id target;

-(instancetype)initWithTarget:(id)target;

-(void)setValue:(id)value forKeyPath:(NSString *)key forStateDescriptor:(QUICStateDescriptor)descriptor;

-(void)applyValuesForState:(UIControlState)state;
-(void)applyValue:(id)value forKey:(NSString*)key;

-(id)valueForKey:(NSString*)key forState:(UIControlState)state;

@end
