//
//  QUIckControlArrayWrapper.m
//  KDNControl
//
//  Created by Denis Koryttsev on 03/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import "QUIckControlArrayWrapper.h"

@interface QUIckControlArrayWrapper ()
@property (nonatomic, strong) NSMutableArray * array;
@end

@implementation QUIckControlArrayWrapper

-(instancetype)initWithEnumeratedObject:(id<NSFastEnumeration>)object {
    if (self = [super init]) {
        _array = [NSMutableArray array];
        for (id obj in object) {
            [_array addObject:obj];
        }
    }
    
    return self;
}

-(void)setValue:(id)value forKey:(NSString *)key {
    // Disable animation temporarily.
    //    [CATransaction flush];
    //    [CATransaction begin];
    //    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    if ([value conformsToProtocol:@protocol(NSFastEnumeration)]) {
        id<NSFastEnumeration> collection = value;
        short i = 0;
        for (id value in collection) {
            if (i == _array.count) return;
            [_array[i] setValue:value forKey:key];
            ++i;
        }
    } else {
        [_array setValue:value forKey:key];
    }
    // Re-enable animation.
    //    [CATransaction commit];
}

-(BOOL)isEqual:(id)object {
    return self == object || [self.array isEqual:object];
}

@end
