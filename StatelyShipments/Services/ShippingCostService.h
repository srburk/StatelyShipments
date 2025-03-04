//
//  ShippingCostService.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import <Foundation/Foundation.h>
#import "../Models/State.h"

@protocol ShippingCostServiceDelegate <NSObject>
- (void)shippingCostServiceDidFindRoute:(NSArray *)route withFuelCost:(float)cost;
- (void)shippingCostServiceDidFailToFindRoute;
@end

@interface ShippingCostService : NSObject

@property (weak) id <ShippingCostServiceDelegate> delegate;
@property (nonatomic) NSDictionary* countryGraph; // TODO: Maybe refactor  this so it's just an adjacency list and keep state codes alphabetically sorted seperately

-(id)init;
- (void)cheapestRouteBetweenStates:(State*)stateA andState:(State*)stateB;

@end
