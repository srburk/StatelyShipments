//
//  FuelCostService.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import "FuelCostService.h"

#define TIMEOUT 3 // 3 second timeout

@interface FuelCostService ()

// format for key: stateCodeA-stateCodeB
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSNumber*>* fuelCostCache;
@property (nonatomic, strong) dispatch_queue_t cacheQueue;
@end

@implementation FuelCostService

- (void)fuelCostBetweenNeighborStates:(State*)stateA andState:(State*)stateB completion: (void(^)(float result))completion {
    
    NSString *cacheKey = [NSString stringWithFormat:@"%@-%@", stateA.stateCode, stateB.stateCode];
    
    __block NSNumber *cachedValue;
    dispatch_sync(self.cacheQueue, ^{
        cachedValue = self.fuelCostCache[cacheKey];
    });
    
    // first check the cache
    if (cachedValue) {
        // cache entry exists
        if (completion) {
            NSLog(@"Found cached value for route: %@", cacheKey);
            completion([self.fuelCostCache[cacheKey] floatValue]);
        }
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        int simulatedDelay = arc4random_uniform(5) + 1;
        NSLog(@"Simulated network delay: %d seconds", simulatedDelay);
        int actualDelay = (simulatedDelay > TIMEOUT) ? TIMEOUT : simulatedDelay; // delay is max 3 seconds
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(actualDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            float result = (simulatedDelay > TIMEOUT) ? -1 : ((float)arc4random() / UINT32_MAX) * 100.0;
            
            dispatch_barrier_async(self.cacheQueue, ^{
                self.fuelCostCache[cacheKey] = @(result);
            });
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(result);
                }
            });
        });
    });
}

- (BOOL)isRoadUsableBetweenNeighborStates:(State*)stateA andState:(State*)stateB {
    return arc4random_uniform(100) < 75;
}

- (id)init {
    if (self = [super init]) {

        // load from disk here unless past cache policy date
        self.fuelCostCache = [[NSMutableDictionary alloc] init];
        self.cacheQueue = dispatch_queue_create("com.StatelyShipments.fuelCostCacheQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)flushFuelCostCache {
    self.fuelCostCache = [NSMutableDictionary dictionary];
    NSLog(@"Cleared FuelCostService cache");
}

@end
