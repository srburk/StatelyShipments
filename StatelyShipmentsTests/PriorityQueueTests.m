//
//  PriorityQueueTests.m
//  StatelyShipmentsTests
//
//  Created by Sam Burkhard on 3/3/25.
//

#import <XCTest/XCTest.h>
#import "PriorityQueue.h"

@interface PriorityQueueTests : XCTestCase

@end

@implementation PriorityQueueTests

- (void)testPriorityQueue {
    PriorityQueue *pq = [[PriorityQueue alloc] init];

    [pq enqueue:@5];
    [pq enqueue:@3];
    [pq enqueue:@8];
    [pq enqueue:@1];
    
    XCTAssertEqualObjects([pq dequeue], @1, @"Dequeued element should be 1");
    XCTAssertEqualObjects([pq dequeue], @3, @"Dequeued element should be 3");
    XCTAssertEqualObjects([pq dequeue], @5, @"Dequeued element should be 5");
    XCTAssertEqualObjects([pq dequeue], @8, @"Dequeued element should be 8");
    XCTAssertNil([pq dequeue], @"Queue should be empty now");
}

@end
