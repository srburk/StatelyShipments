//
//  ShippingRouteViewController.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/4/25.
//

// for showing visual of completed route

#import "../Models/State.h"
#import <UIKit/UIKit.h>

@interface ShippingRouteViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) UINavigationController* navigationController;
@property (nonatomic, strong) NSArray<State*>* shippingRoute;

- (id)initWithRoute:(NSArray<State*>*)route;

@end
