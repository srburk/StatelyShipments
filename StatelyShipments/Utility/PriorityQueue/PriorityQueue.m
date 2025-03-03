//
//  PriorityQueue.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/3/25.
//

#import <Foundation/Foundation.h>
#import "PriorityQueue.h"

@interface PriorityQueue ()

@property NSMutableArray* items;
@property int size;

- (void)swap:(int)a with:(int)b;

@end

@implementation PriorityQueue

- (id)init {
    if (self = [super init]) {
        self.items = [NSMutableArray array];
        self.size = 0;
    }
    return self;
}

- (void)enqueue:(id)object {
    [self.items addObject:object];
    self.size++;
    [self heapifyUp:self.size - 1];
}

- (id)dequeue {
    if (!self.size) {
        return nil;
    }

    id item = self.items[0];
    self.items[0] = self.items.lastObject;
    [self.items removeLastObject];
    self.size--;

    if (self.size > 0) {
        [self heapifyDown:0];
    }

    return item;
}

- (void)heapifyUp:(int)index {
    while (index > 0) {
        int parentIndex = (index - 1) / 2;
        if ([self.items[index] compare:self.items[parentIndex]] == NSOrderedAscending) {
            [self swap:index with:parentIndex];
            index = parentIndex;
        } else {
            break;
        }
    }
}

- (void)heapifyDown:(int)index {
    int leftChild, rightChild, smallest;
    while (true) {
        leftChild = 2 * index + 1;
        rightChild = 2 * index + 2;
        smallest = index;

        if (leftChild < self.size && [self.items[leftChild] compare:self.items[smallest]] == NSOrderedAscending) {
            smallest = leftChild;
        }

        if (rightChild < self.size && [self.items[rightChild] compare:self.items[smallest]] == NSOrderedAscending) {
            smallest = rightChild;
        }

        if (smallest != index) {
            [self swap:index with:smallest];
            index = smallest;
        } else {
            break;
        }
    }
}

- (void)swap:(int)index1 with:(int)index2 {
    id temp = self.items[index1];
    self.items[index1] = self.items[index2];
    self.items[index2] = temp;
}

@end
