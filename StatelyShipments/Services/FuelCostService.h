//
//  FuelCostService.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import <Foundation/Foundation.h>
#import "../Models/State.h"

@interface FuelCostService : NSObject

- (void)fuelCostBetweenNeighborStates:(State*)stateA andState:(State*)stateB completion: (void(^)(float result))completion;
- (BOOL)isRoadUsableBetweenNeighborStates:(State*)stateA andState:(State*)stateB;

@end
