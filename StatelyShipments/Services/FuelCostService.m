//
//  FuelCostService.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import "FuelCostService.h"

#define TIMEOUT 3 // 3 second timeout

@interface FuelCostService ()

@end

@implementation FuelCostService

+ (id) shared {
    static dispatch_once_t pred = 0;
    static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)fuelCostBetweenNeighborStates:(State*)stateA andState:(State*)stateB completion: (void(^)(float result))completion {
    
//    int simulatedDelay = arc4random_uniform(4) + 1;
    int simulatedDelay = 2; // for testing I need everything open for now
    int actualDelay = (simulatedDelay > TIMEOUT) ? TIMEOUT : simulatedDelay; // delay is max 3 seconds
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(actualDelay * NSEC_PER_SEC)), dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        float result = (simulatedDelay > TIMEOUT) ? -1 : ((float)arc4random() / UINT32_MAX) * 100.0;
        
        if (completion) {
            completion(result);
        }
    });
}

- (BOOL)isRoadUsableBetweenNeighborStates:(State*)stateA andState:(State*)stateB {
    return arc4random_uniform(100) < 75;
}

- (id)init {
    if (self = [super init]) {

    }
    return self;
}

@end
