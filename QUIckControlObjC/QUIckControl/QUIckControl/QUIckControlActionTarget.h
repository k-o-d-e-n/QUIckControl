//
//  QUIckControlActionTarget.h
//  KDNControl
//
//  Created by Denis Koryttsev on 03/11/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

@protocol QUIckControlActionTarget <NSObject>
-(void)start;
-(void)stop;
@end
typedef id<QUIckControlActionTarget> QUIckControlActionTarget;
