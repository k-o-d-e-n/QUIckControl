//
//  QUIckControlArrayWrapper.h
//  KDNControl
//
//  Created by Denis Koryttsev on 03/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QUIckControlArrayWrapper : NSObject
-(instancetype)initWithEnumeratedObject:(id<NSFastEnumeration>)object;
@end
