//
//  ShippingCostService.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import <Foundation/Foundation.h>

#import "../Models/State.h"
#import "FuelCostService.h"

@protocol ShippingCostServiceDelegate <NSObject>
//- (void)shippingCostServiceDidFindRoute:(NSArray *)route withTotalCost:(float)cost;
- (void)shippingCostServiceDidFindRoute:(NSArray *)route withCosts:(NSArray *)fuelCosts withTotalCost:(float)cost;
- (void)shippingCostServiceDidFailWithMessage:(NSString *)message;
@end

@interface ShippingCostService : NSObject

@property (weak) id <ShippingCostServiceDelegate> delegate;
@property (weak) FuelCostService* fuelCostService;

@property (nonatomic, assign) float stateBorderFee;

-(id)init;
- (void)cheapestRouteBetweenStates:(State*)stateA andState:(State*)stateB;

@end
