//
//  FuelCostService.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import "FuelCostService.h"

static const int timeout = 3; // 3 second timeout

@interface FuelCostService ()

@end

@implementation FuelCostService

- (void)fuelCostBetweenNeighborStates:(State*)stateA andState:(State*)stateB completion: (void(^)(float result))completion {
    
//    int simulatedDelay = arc4random_uniform(4) + 1;
    int simulatedDelay = 2; // for testing I need everything open for now
    int actualDelay = (simulatedDelay > timeout) ? timeout : simulatedDelay; // delay is max 3 seconds
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(actualDelay * NSEC_PER_SEC)), dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        float result = (simulatedDelay > timeout) ? -1 : ((float)arc4random() / UINT32_MAX) * 100.0;
        
        if (completion) {
            completion(result);
        }
    });
}

- (BOOL)isRoadUsableBetweenNeighborStates:(State*)stateA andState:(State*)stateB {
    return arc4random_uniform(100) < 75;
}

@end
