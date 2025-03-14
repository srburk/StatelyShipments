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

@interface ShippingCostService ()

@property (atomic) NSMutableDictionary *fuelCostCache;
@property (nonatomic) dispatch_group_t fuelCostGroup;
@property (nonatomic, strong) dispatch_queue_t fuelCostCacheQueue;

- (NSString *)standardizedCacheKeyForState:(NSString *)stateA andNeighbor:(NSString *)stateB;

@end

@implementation ShippingCostService

- (id)init {
    if (self = [super init]) {
        self.fuelCostCache = [NSMutableDictionary dictionary];
        self.stateBorderFee = 0.0;
        self.fuelCostCacheQueue = dispatch_queue_create("com.statelyshipments.fuelCostCacheQueue", DISPATCH_QUEUE_CONCURRENT);
        self.fuelCostGroup = dispatch_group_create();
    }
    return self;
}

- (NSString *)standardizedCacheKeyForState:(NSString *)stateCodeA andNeighbor:(NSString *)stateCodeB {
    NSArray *sortedStates = [@[stateCodeA, stateCodeB] sortedArrayUsingSelector:@selector(compare:)];
    return [NSString stringWithFormat:@"%@-%@", sortedStates[0], sortedStates[1]];
}

// TODO: Cache algorithm results from A in case only B is changed
- (void)cheapestRouteBetweenStates:(State*)stateA andState:(State*)stateB {
    
    // check that states are not nil
    if (![stateA isKindOfClass:[State class]] || ![stateB isKindOfClass:[State class]]) {
        if ([self.delegate respondsToSelector:@selector(shippingCostServiceDidFailWithMessage:)]) {
            [self.delegate shippingCostServiceDidFailWithMessage:@"Please choose a source and destination state."];
        }
        return;
    }
    
    // do everything in the background to keep main thread running well
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (State *state in [[StatesLoader shared] allStatesAlphabetical]) {
            for (State *neighbor in state.stateNeighbors) {
                dispatch_group_enter(self.fuelCostGroup);
                
                NSString *cacheKey = [self standardizedCacheKeyForState:state.stateCode andNeighbor:neighbor.stateCode];
                __block BOOL cacheContainsKey = NO;
                dispatch_sync(self.fuelCostCacheQueue, ^{
                    cacheContainsKey = ([self.fuelCostCache objectForKey:cacheKey] != nil);
                });
                if (cacheContainsKey) {
                    dispatch_group_leave(self.fuelCostGroup);
                    continue;
                }
                
                if ([self.fuelCostService isRoadUsableBetweenNeighborStates:state andState:neighbor]) {
                    
                    [self.fuelCostService fuelCostBetweenNeighborStates:state andState:neighbor completion:^(float result) {
                        dispatch_barrier_async(self.fuelCostCacheQueue, ^{
                            [self.fuelCostCache setObject:[NSNumber numberWithFloat:(roundf(result * 100) / 100)] forKey:cacheKey];
                        });
                        dispatch_group_leave(self.fuelCostGroup);
                    }];
                    
                } else {
                    
                    dispatch_barrier_async(self.fuelCostCacheQueue, ^{
                        [self.fuelCostCache setObject:[NSNumber numberWithFloat:-1] forKey:cacheKey];
                    });
                    dispatch_group_leave(self.fuelCostGroup);
                }
            }
        }
        
        // wait for all fuel costs to be collected
        dispatch_group_wait(self.fuelCostGroup, DISPATCH_TIME_FOREVER);
        
        PriorityQueue *queue = [[PriorityQueue alloc] initWithComparator:^NSComparisonResult(id obj1, id obj2) {
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
        for (State *state in [[StatesLoader shared] allStatesAlphabetical]) {
            // set distances to max, (bad for now, make better pq with heap later)
            if ([state.stateCode isEqualToString:stateA.stateCode]) {
                [distance setValue:@0 forKey:state.stateCode];
            } else {
                [distance setValue:@INT_MAX forKey:state.stateCode];
            }
        }

        // prep first State (starting node) with highest priority
        [queue enqueue:@[stateA.stateCode, @0]];

        // iterate through priority queue until finished
        while (queue.size > 0) {
            NSArray* current = (NSArray*)[queue dequeue];
            NSString* currentStateCode = current[0];
            State* currentState = [[[StatesLoader shared] allStatesGraph] valueForKey:currentStateCode];
            
            // MARK: Determine if you want to use early exit or instead cache everything for reuse with other destinations
            if ([currentState isEqual:stateB]) {
                break;
            }
            
            for (State* neighbor in currentState.stateNeighbors) {
                
                __block NSNumber* fuelCost;
                dispatch_barrier_sync(self.fuelCostCacheQueue, ^{
                    fuelCost = self.fuelCostCache[[self standardizedCacheKeyForState:currentState.stateCode andNeighbor:neighbor.stateCode]];
                });
                
                float weight = [fuelCost floatValue];
                
                if (weight < 0) {
                    // can't traverse for whatever reason, move to next iteration
                    continue;
                }
                
                // calculate what the distance be if used
                float tentativeDistance = [distance[currentStateCode] floatValue] + weight + self.stateBorderFee;
                if ([distance[neighbor.stateCode] floatValue] > tentativeDistance) {
                    [distance setValue:[[NSNumber alloc] initWithFloat:tentativeDistance] forKey:neighbor.stateCode];
                    [previous setValue:currentState.stateCode forKey:neighbor.stateCode];

                    // queue for exploration
                    [queue enqueue:@[neighbor.stateCode, distance[neighbor.stateCode]]];
                }
            }
        }
        
        if ([distance[stateB.stateCode] compare:[NSNumber numberWithInt:INT_MAX]]) {
            
            NSMutableArray* route = [NSMutableArray array];
            
            NSString* currentStateCode = stateB.stateCode;
            while (currentStateCode) {
                [route addObject:[[[StatesLoader shared] allStatesGraph]valueForKey:currentStateCode]];
                currentStateCode = previous[currentStateCode]; // next
            }
            
            // reverse to be in proper order (StateA -> StateB)
            NSArray* reversedRoute = [[route reverseObjectEnumerator] allObjects];
            
            // array for keeping track of costs
            NSMutableArray *borderCrossingCosts = [NSMutableArray array];
            
            for (NSUInteger i = 0; i < reversedRoute.count - 1; i++) {
                State* currentState = reversedRoute[i];
                State* nextState = reversedRoute[i + 1];
                NSNumber* fuelCost = self.fuelCostCache[[self standardizedCacheKeyForState:currentState.stateCode andNeighbor:nextState.stateCode]];
                [borderCrossingCosts addObject:fuelCost];
            }
                        
            // use delegate pattern for return info
            if ([self.delegate respondsToSelector:@selector(shippingCostServiceDidFindRoute: withCosts: withTotalCost:)]) {
//                float totalCost = (reversedRoute.count * self.stateBorderFee) + [distance[stateB.stateCode] floatValue];
                float totalCost = [distance[stateB.stateCode] floatValue];
                [self.delegate shippingCostServiceDidFindRoute:reversedRoute withCosts:borderCrossingCosts withTotalCost:totalCost];
            }
            
        } else {
            if ([self.delegate respondsToSelector:@selector(shippingCostServiceDidFailWithMessage:)]) {
                [self.delegate shippingCostServiceDidFailWithMessage:@"Route does not exist."];
            }
        }
        
    });
}

@end
