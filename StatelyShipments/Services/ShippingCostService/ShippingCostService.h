//
//  ShippingCostService.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import <Foundation/Foundation.h>
#import "../../Models/State/State.h"

@interface ShippingCostService : NSObject

- (void)cheapestRouteBetweenStates:(State*)stateA andState:(State*)stateB;

@end
