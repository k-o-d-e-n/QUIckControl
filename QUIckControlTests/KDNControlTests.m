//
//  KDNControlTests.m
//  KDNControlTests
//
//  Created by Denis Koryttsev on 16/10/16.
//  Copyright © 2016 Denis Koryttsev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QUIckControlPrivate.h"

@interface QUIckControlTests : XCTestCase

@end

@interface KeyObject : NSObject<NSCopying>

@end

@implementation KeyObject

-(id)copyWithZone:(NSZone *)zone {
    return [[KeyObject allocWithZone:zone] init];
}

-(BOOL)isEqual:(id)object {
    return YES;
}

@end

@interface TestNSValue : NSValue
@end
@implementation TestNSValue
@end

@implementation QUIckControlTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

-(void)testInverted {
    BOOL inverted = YES;
    BOOL boolProperty = YES;
    XCTAssertTrue(boolProperty ^ inverted);
}

-(void)testNSValueSubclass {
    BOOL yes = YES;
    TestNSValue * value = [TestNSValue value:&yes withObjCType:@encode(BOOL)];
    
    XCTAssertTrue([value isKindOfClass:[TestNSValue class]]);
}

-(void)testQUIckControlStateValueEqual {
//    NSValue * value = [NSValue valueWithQUIckControlState:QUIckControlStateMake(UIControlStateDisabled, YES)];
//    
//    XCTAssertTrue([value isEqualToValue:[NSValue valueWithQUIckControlState:QUIckControlStateMake(UIControlStateDisabled, YES)]]);
}

-(void)testNSDictionaryEqual {
    NSDictionary * dictionary = @{[[KeyObject alloc] init]:@"value"};
    
    XCTAssertTrue([[dictionary objectForKey:[[KeyObject alloc] init]] isEqual:@"value"]);
}

@end
