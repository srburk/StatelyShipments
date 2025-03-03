//
//  ShippingCostService.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import <Foundation/Foundation.h>
#import "../../Utility/StatesLoader/StatesLoader.h"
#import "ShippingCostService.h"

@implementation ShippingCostService

// TODO: Cache algorithm results from A in case only B is changed
- (void)cheapestRouteBetweenStates:(State *)stateA andState:(State *)stateB {
    NSLog(@"Calculating cheapest route...");
}

- (id)init {
    if (self = [super init]) {
        
        self.countryGraph = [StatesLoader loadStatesFromPlistAtPath:@"States"];
    }
    return self;
}

@end
