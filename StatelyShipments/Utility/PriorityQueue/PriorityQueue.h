//
//  PriorityQueue.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/3/25.
//

#import <Foundation/Foundation.h>

@interface PriorityQueue : NSObject

- (id)init;

- (void)heapifyUp:(int)index;
- (void)heapifyDown:(int)index;

- (void)enqueue:(id)object;
- (id)dequeue;

@end
