//
//  FuelCostService.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import <Foundation/Foundation.h>
#import "../../Models/State/State.h"

@interface FuelCostService : NSObject

- (float)fuelCostBetweenNeighborStates:(State*)stateA andState:(State*)stateB;
- (BOOL)isRoadUsableBetweenNeighborStates:(State*)stateA andState:(State*)stateB;

- (id)init;

@end
