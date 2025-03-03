//
//  ShippingCostService.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import <Foundation/Foundation.h>

@interface ShippingService : NSObject

- (float)fuelCostBetweenNeighborStates:stateA andState:stateB;
- (BOOL)isRoadUsableBetweenNeighborStates:stateA andState:stateB;

- (id)init;

@end
