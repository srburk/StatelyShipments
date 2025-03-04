//
//  ShippingCostService.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import <Foundation/Foundation.h>
#import "../Utility/StatesLoader.h"
#import "../Utility/PriorityQueue.h"

#import "ShippingCostService.h"
#import "FuelCostService.h"

@interface ShippingCostService ()
@property (atomic) NSMutableDictionary *fuelCostCache;
@property (nonatomic) dispatch_group_t fuelCostGroup;

- (NSString *)standardizedCacheKeyForState:(State *)stateA andNeighbor:(State *)stateB;

@end

@implementation ShippingCostService

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
- (void)cheapestRouteBetweenStates:(State*)stateA andState:(State*)stateB {
    
    // check that states are not nil
    if (![stateA isKindOfClass:[State class]] || ![stateA isKindOfClass:[State class]]) {
        if ([self.delegate respondsToSelector:@selector(shippingCostServiceDidFailWithMessage:)]) {
            [self.delegate shippingCostServiceDidFailWithMessage:@"Please provide valid State objects"];
        }
        return;
    }
    
    // do everything in the background to keep main thread running well
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"Fetching fuel costs from %@ to %@", stateA.stateCode, stateB.stateCode);
        for (State *state in self.countryGraph.allValues) {
            for (State *neighbor in state.stateNeighbors) {
                dispatch_group_enter(self.fuelCostGroup);
                
                NSString *cacheKey = [self standardizedCacheKeyForState:state andNeighbor:neighbor];
                
                if ([self.fuelCostCache valueForKey:cacheKey]) {
                    // already exists in cache, exit this iteration early
                    dispatch_group_leave(self.fuelCostGroup);
                    continue;
                }
                
                if ([[FuelCostService shared] isRoadUsableBetweenNeighborStates:state andState:neighbor]) {
                    
                    [[FuelCostService shared] fuelCostBetweenNeighborStates:state andState:neighbor completion:^(float result) {
                        @synchronized (self.fuelCostCache) {
                            [self.fuelCostCache setObject:[NSNumber numberWithFloat:result] forKey:cacheKey];
                        }
                        dispatch_group_leave(self.fuelCostGroup);
                    }];
                    
                } else {
                    
                    @synchronized (self.fuelCostCache) {
                        [self.fuelCostCache setObject:[NSNumber numberWithFloat:-1] forKey:cacheKey];
                    }
                    dispatch_group_leave(self.fuelCostGroup);
                }
            }
        }
        
        // wait for all fuel costs to be collected
        dispatch_group_wait(self.fuelCostGroup, DISPATCH_TIME_FOREVER);
                
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
        // keep track of all previous nodes for all nodes
        NSMutableDictionary *previous = [[NSMutableDictionary alloc] initWithCapacity:50];
        
        // initialize distances to INF (using INT_MAX) except for start, which is 0
        for (NSString *stateCode in self.countryGraph.allKeys) {
            // set distances to max, (bad for now, make better pq with heap later)
            if ([stateCode isEqualToString:stateA.stateCode]) {
                [distance setValue:@0 forKey:stateCode];
            } else {
                [distance setValue:@INT_MAX forKey:stateCode];
            }
        }

        // prep first State (starting node) with highest priority
        [queue enqueue:@[stateA.stateCode, @0]];

        // iterate through priority queue until finished
        while (queue.size > 0) {
            NSArray* current = (NSArray*)[queue dequeue];
            NSString* currentStateCode = current[0];
            State* currentState = (State*)self.countryGraph[currentStateCode];
            
            // MARK: Determine if you want to use early exit or instead cache everything for reuse with other destinations
            if ([currentState isEqual:stateB]) {
                break;
            }
            
            for (State* neighbor in currentState.stateNeighbors) {
                
                float weight = [(NSNumber*)self.fuelCostCache[[self standardizedCacheKeyForState:currentState andNeighbor:neighbor]] floatValue];
                
                if (weight < 0) {
                    // can't traverse for whatever reason, move to next iteration
                    continue;
                }
                
                // calculate what the distance be if used
                float tentativeDistance = [distance[currentStateCode] floatValue] + weight;
                if ([distance[neighbor.stateCode] floatValue] > tentativeDistance) {
                    [distance setValue:[[NSNumber alloc] initWithFloat:tentativeDistance] forKey:neighbor.stateCode];
                    [previous setValue:currentState.stateCode forKey:neighbor.stateCode];
//                    NSLog(@"\t Set neighbor %@ to %f", neighbor.stateCode, tentativeDistance);
                    // queue for exploration
                    [queue enqueue:@[neighbor.stateCode, distance[neighbor.stateCode]]];
                }
            }
        }
        
        if ([distance[stateB.stateCode] compare:[NSNumber numberWithInt:INT_MAX]]) {
            
            NSMutableArray* route = [NSMutableArray array];
            
            NSString* currentStateCode = stateB.stateCode;
            while (currentStateCode) {
                [route addObject:self.countryGraph[currentStateCode]];
                currentStateCode = previous[currentStateCode];
            }
            
            // reverse to be in proper order (StateA -> StateB)
            NSArray* reversedRoute = [[route reverseObjectEnumerator] allObjects];
                        
            // use delegate pattern for return info
            if ([self.delegate respondsToSelector:@selector(shippingCostServiceDidFindRoute: withFuelCost:)]) {
                [self.delegate shippingCostServiceDidFindRoute:reversedRoute withFuelCost:[distance[stateB.stateCode] floatValue]];
            }
            
        } else {
            if ([self.delegate respondsToSelector:@selector(shippingCostServiceDidFailWithMessage:)]) {
                [self.delegate shippingCostServiceDidFailWithMessage:@"Route does not exist"];
            }
        }
        
    });
}

@end
