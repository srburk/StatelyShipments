//
//  ShippingCostService.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import <Foundation/Foundation.h>
#import "../../Utility/StatesLoader/StatesLoader.h"
#import "../../Utility/PriorityQueue/PriorityQueue.h"

#import "ShippingCostService.h"
#import "../FuelCostService/FuelCostService.h"

@interface ShippingCostService ()
@property (atomic) NSMutableDictionary *fuelCostCache;
@property (nonatomic) dispatch_group_t fuelCostGroup;

- (NSString *)standardizedCacheKeyForState:(State *)stateA andNeighbor:(State *)stateB;

@end

@implementation ShippingCostService

+ (id) shared {
    static dispatch_once_t pred = 0;
    static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    if (self = [super init]) {
        self.countryGraph = [StatesLoader loadStatesFromPlistAtPath:@"States"];
        self.fuelCostCache = [NSMutableDictionary dictionary];
        self.fuelCostGroup = dispatch_group_create();
    }
    return self;
}

- (NSString *)standardizedCacheKeyForState:(State *)stateA andNeighbor:(State *)stateB {
    NSArray *sortedStates = [@[stateA.stateCode, stateB.stateCode] sortedArrayUsingSelector:@selector(compare:)];
    return [NSString stringWithFormat:@"%@-%@", sortedStates[0], sortedStates[1]];
}

// TODO: Cache algorithm results from A in case only B is changed
- (void)cheapestRouteBetweenStates:(State *)stateA andState:(State *)stateB {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"Fetching fuel costs");
        for (State *state in self.countryGraph.allValues) {
            for (State *neighbor in state.stateNeighbors) {
                dispatch_group_enter(self.fuelCostGroup);
                [[FuelCostService shared] fuelCostBetweenNeighborStates:state andState:neighbor completion:^(float result) {
                    NSString *cacheKey = [self standardizedCacheKeyForState:state andNeighbor:neighbor];
                    @synchronized (self.fuelCostCache) {
                        [self.fuelCostCache setObject:[NSNumber numberWithFloat:result] forKey:cacheKey];
                    }
                    dispatch_group_leave(self.fuelCostGroup);
                }];
            }
        }
        
        
        dispatch_group_wait(self.fuelCostGroup, DISPATCH_TIME_FOREVER);
        NSLog(@"Finished fetching all fuel costs, found %lu roads", (unsigned long)self.fuelCostCache.count);
        
        NSLog(@"Calculating cheapest route from %@ to %@", stateA.stateCode, stateB.stateCode);
        
        PriorityQueue *queue = [[PriorityQueue alloc] initWithCapacity:(int)self.countryGraph.count comparator:^NSComparisonResult(id obj1, id obj2) {
            // we know how these objects are structured, but we'll check just in case
            if (![obj1 isKindOfClass:[NSArray class]] || ![obj2 isKindOfClass:[NSArray class]]) {
                NSLog(@"Error: Priority Queue objects are not expected type");
                return NSOrderedSame;
            }
            return [obj1[1] compare:obj2[1]];
        }];

        // keep track of distances to all nodes from State A
        NSMutableDictionary *distance = [[NSMutableDictionary alloc] initWithCapacity:50];

        for (NSString *stateCode in self.countryGraph.allKeys) {
            // set distances to max, (bad for now, make better pq with heap later)
            if ([stateCode isEqualToString:stateA.stateCode]) {
                [distance setValue:@0 forKey:stateCode];
            } else {
                [distance setValue:@INT_MAX forKey:stateCode];
            }
        }

        [queue enqueue:@[stateA.stateCode, @0]];

        while (queue.size > 0) {
            NSArray* current = (NSArray*)[queue dequeue];
            NSString* currentStateCode = current[0];
            State* currentState = (State*)self.countryGraph[currentStateCode];
            NSLog(@"Current State: %@", currentState);
        }
        
    });
    
//    dispatch_async(self.shippingCostServiceQueue, ^{
//        
//        for (State *state in self.countryGraph.allValues) {
//            for (State *neighbor in state.stateNeighbors) {
//                dispatch_group_enter(self.fuelCostGroup);
//                
//                [[FuelCostService shared] fuelCostBetweenNeighborStates:state andState:neighbor completion:^(float result) {
//                    dispatch_barrier_async(self.shippingCostServiceQueue, ^{
//                        NSString *cacheKey = [NSString stringWithFormat:@"%@-%@", state.stateCode, neighbor.stateCode];
//                        self.fuelCostCache[cacheKey] = @(result);
//                    });
//                    
//                    dispatch_group_leave(self.fuelCostGroup);
//                }];
//            }
//        }
//        
//        dispatch_group_wait(self.fuelCostGroup, DISPATCH_TIME_FOREVER);
//        NSLog(@"Finished fetching all fuel costs");
//        
//        NSLog(@"%@", self.fuelCostCache);
        
//    });
}

@end
