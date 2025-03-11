//
//  ShippingRouteViewController.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/4/25.
//

// for showing visual of completed route

#import "../Models/State.h"
#import "../MainCoordinator.h"
#import <UIKit/UIKit.h>

@interface ShippingRouteViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) MainCoordinator *coordinator;

@property (nonatomic, strong) NSArray<State*>* shippingRoute;
@property (nonatomic, strong) NSArray<NSNumber*>* fuelCosts;
@property (nonatomic, assign) float totalCost;

@end
