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
                
                NSString *cacheKey = [self standardizedCacheKeyForState:state andNeighbor:neighbor];
                
                if (self.fuelCostCache[cacheKey]) {
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
        
        dispatch_group_wait(self.fuelCostGroup, DISPATCH_TIME_FOREVER);
        
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
        
        // keep track of paths to all nodes from State A
        NSMutableDictionary *previous = [[NSMutableDictionary alloc] initWithCapacity:50];

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
            
            // MARK: Determine if you want to use early exit or instead cache everything for reuse with other destinations
            if ([currentState isEqual:stateB]) {
                NSLog(@"Reached destination, exiting...");
                break;
            }
            
            for (State* neighbor in currentState.stateNeighbors) {
                
                float weight = [(NSNumber*)self.fuelCostCache[[self standardizedCacheKeyForState:currentState andNeighbor:neighbor]] floatValue];
                
                if (weight < 0) {
                    // can't traverse
                    NSLog(@"\t - %@ | weight = %f | distance = %@, SKIPPING", neighbor.stateCode, weight, distance[neighbor.stateCode]);
                    continue;
                }
                NSLog(@"\t - %@ | weight = %f | distance = %@", neighbor.stateCode, weight, distance[neighbor.stateCode]);
                
                float tentativeWeight = [distance[currentStateCode] floatValue] + weight;
                if ([distance[neighbor.stateCode] floatValue] > tentativeWeight) {
                    [distance setValue:[[NSNumber alloc] initWithFloat:tentativeWeight] forKey:neighbor.stateCode];
                    [previous setValue:currentState.stateCode forKey:neighbor.stateCode];
                    NSLog(@"\t Set neighbor %@ to %f", neighbor.stateCode, tentativeWeight);
                    [queue enqueue:@[neighbor.stateCode, distance[neighbor.stateCode]]];
                }
            }
            
            NSLog(@"\tPriorityQueue State after %@: %@", currentState.stateCode, queue);
            
        }
        
        NSLog(@"Finished Algorithm, final distances are: %@", distance);
        
        NSLog(@"Finished Algorithm, final paths are: %@", previous);
        
        if ([distance[stateB.stateCode] compare:[NSNumber numberWithInt:INT_MAX]]) {
            NSLog(@"Shipping from %@->%@ is possible and will cost: %@", stateA.stateCode, stateB.stateCode, distance[stateB.stateCode]);
            NSLog(@"Route will be (in reverse):");
            NSString* currentStateCode = stateB.stateCode;
            while (currentStateCode) {
                NSLog(@"\t%@", currentStateCode);
                currentStateCode = previous[currentStateCode];
            }
            
        } else {
            NSLog(@"Shipping from %@->%@ is not possible", stateA.stateCode, stateB.stateCode);
        }
        
    });
}

@end
