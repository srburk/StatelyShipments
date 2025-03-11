//
//  MainCoordinator.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/10/25.
//

#import <Foundation/Foundation.h>
#import "MainCoordinator.h"
#import "Utility/Extensions/UINavigationController+SheetControlAdditions.h"

// VCs
#import "ViewControllers/ShippingEntryViewController.h"
#import "ViewControllers/ShippingRouteViewController.h"
#import "ViewControllers/MainViewController.h"

// Views
#import "ViewControllers/StatePickerViewController.h"

// Services
#import "Services/ShippingCostService.h"

@interface MainCoordinator () <ShippingCostServiceDelegate>

@property (nonatomic, strong) ShippingCostService *shippingCostService;
@property (nonatomic, strong) UINavigationController *navigationController;

// State
@property (nonatomic, strong) State* sourceState;
@property (nonatomic, strong) State* destinationState;
@property (nonatomic, strong) NSArray<State*>* route;

@property (nonatomic, strong) ShippingEntryViewController* shippingEntryViewController;
@property (nonatomic, strong) ShippingRouteViewController* shippingRouteViewController;

@end

@implementation MainCoordinator

- (id)initWithNavigationController:(UINavigationController *)navigationController {
    if (self = [super init]) {
        self.navigationController = navigationController;
        self.navigationController.modalInPresentation = YES;
        self.navigationController.navigationBarHidden = YES;
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        
        self.shippingCostService = [[ShippingCostService alloc] init];
        self.shippingCostService.delegate = self;
    }
    return self;
}


// MARK: Actions
- (void)swapSelectedStates {
    State *temp = self.sourceState;
    self.sourceState = self.destinationState;
    self.destinationState = temp;
    
    [self.shippingEntryViewController.sourcePickerButton updateSelectedState:self.sourceState];
    [self.shippingEntryViewController.destinationPickerButton updateSelectedState:self.destinationState];
}

- (void)calculateCheapestRoute {
    [self.shippingEntryViewController.spinnerView startAnimating];

    // get float value
    self.stateBorderFee = [self.shippingEntryViewController getStateBorderFee];

    NSLog(@"Using fee: %f", self.stateBorderFee);

    self.shippingCostService.stateBorderFee = self.stateBorderFee;
    [self.shippingCostService cheapestRouteBetweenStates:self.sourceState andState:self.destinationState];
}


// MARK: Navigation Functions
- (void)showShippingCalculator {
    self.shippingEntryViewController = [[ShippingEntryViewController alloc] init];
    self.shippingEntryViewController.coordinator = self;
    [self.navigationController animateSmallDetent];

    [self.navigationController setViewControllers:@[self.shippingEntryViewController]];
    [self.navigationController animateSmallDetent];
}

- (void)showStateSelectionForSource:(BOOL)isSource {
    StatePickerViewController *statePickerViewController = [[StatePickerViewController alloc] init];
    statePickerViewController.coordinator = self;
    
    __weak typeof(self) weakSelf = self;
    statePickerViewController.selectionHandler = ^(State *selectedState) {
        if (isSource) {
            weakSelf.sourceState = selectedState;
            [weakSelf.shippingEntryViewController.sourcePickerButton updateSelectedState:selectedState];
        } else {
            weakSelf.destinationState = selectedState;
            [weakSelf.shippingEntryViewController.destinationPickerButton updateSelectedState:selectedState];
        }
    };
    
    [self.navigationController pushViewController:statePickerViewController animated:NO];
    [self.navigationController animateMediumDetent];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)closeStateSelection {
    [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController animateSmallDetent];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)showShippingResultsForRoute:(NSArray *)route withCosts:(NSArray *)fuelCosts withTotalCost:(float)cost {
    self.shippingRouteViewController = [[ShippingRouteViewController alloc] init];
    
    self.shippingRouteViewController.shippingRoute = route;
    self.shippingRouteViewController.fuelCosts = fuelCosts;
    self.shippingRouteViewController.totalCost = cost;
    self.shippingRouteViewController.coordinator = self;
    
    [self.navigationController pushViewController:self.shippingRouteViewController animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController animateMediumDetent];
}

- (void)closeShippingResults {
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController animateSmallDetent];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // reset map
    [self.mainViewController clearMap];
}

- (void)focusMapOnRoute {
    
    // get framing points
    if (self.route.count == 0) {
        return;
    }
        
    double minLat = DBL_MAX, maxLat = -DBL_MAX;
    double minLon = DBL_MAX, maxLon = -DBL_MAX;
    
    for (State *state in self.route) {
        double latitude = [state.latitude doubleValue];
        double longitude = [state.longitude doubleValue];
        
        if (latitude < minLat) minLat = latitude;
        if (latitude > maxLat) maxLat = latitude;
        if (longitude < minLon) minLon = longitude;
        if (longitude > maxLon) maxLon = longitude;
    }
    
    CLLocationCoordinate2D coordinate1 = CLLocationCoordinate2DMake(minLat, minLon);
    CLLocationCoordinate2D coordinate2 = CLLocationCoordinate2DMake(maxLat, maxLon);
    
    // animate set up focus on state route
    MKMapPoint point1 = MKMapPointForCoordinate(coordinate1);
    MKMapPoint point2 = MKMapPointForCoordinate(coordinate2);
    
    [self.mainViewController focusMapOnPoint:point1 andPoint:point2];
}

// MARK: Shipping Service Delegate Actions
- (void)shippingCostServiceDidFailWithMessage:(NSString *)message {
    NSLog(@"Failed to find route: %@", message);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.shippingEntryViewController.spinnerView stopAnimating];
    });
}

- (void)shippingCostServiceDidFindRoute:(NSArray *)route withCosts:(NSArray *)fuelCosts withTotalCost:(float)cost {
        
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.shippingEntryViewController.spinnerView stopAnimating];
        [self showShippingResultsForRoute:route withCosts:fuelCosts withTotalCost:cost];
        
        self.route = route;
        [self focusMapOnRoute];
        
        // draw route
        [self.mainViewController drawRoute:route];
    });
}

@end
