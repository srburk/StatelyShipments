//
//  FuelCostService.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import "FuelCostService.h"

@implementation FuelCostService

- (float)fuelCostBetweenNeighborStates:(State*)stateA andState:(State*)stateB {
    return ((float)arc4random() / UINT32_MAX) * 100.0;
}

- (BOOL)isRoadUsableBetweenNeighborStates:(State*)stateA andState:(State*)stateB {
    return arc4random_uniform(100) < 75;
}

- (id)init {
    self = [super init];
    return self;
}

@end
