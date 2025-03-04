//
//  ShippingCostService.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import <Foundation/Foundation.h>
#import "../../Models/State/State.h"

@protocol ShippingCostServiceDelegate <NSObject>
- (void)shippingCostServiceDidFindRoute:(NSArray *)route withFuelCost:(float)cost;
- (void)shippingCostServiceDidFailToFindRoute;
@end

@interface ShippingCostService : NSObject

@property (weak) id <ShippingCostServiceDelegate> delegate;
@property (nonatomic) NSDictionary* countryGraph;

-(id)init;
- (void)cheapestRouteBetweenStates:(State*)stateA andState:(State*)stateB;

@end
