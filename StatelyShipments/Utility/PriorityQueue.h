//
//  PriorityQueue.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/3/25.
//

#import <Foundation/Foundation.h>

typedef NSComparisonResult (^PriorityQueueComparator)(id obj1, id obj2);

@interface PriorityQueue : NSObject

@property int size;
@property (nonatomic, copy) PriorityQueueComparator comparator;

- (id)initWithCapacity:(int)capacity comparator:(PriorityQueueComparator)comparator;

- (void)heapifyUp:(int)index;
- (void)heapifyDown:(int)index;

- (void)enqueue:(id)object;
- (id)dequeue;

- (NSString*)description;

@end
