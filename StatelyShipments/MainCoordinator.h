//
//  MainCoordinator.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/10/25.
//

#import <UIKit/UIKit.h>
#import "Models/State.h"

@class MainViewController;

// main coordinator for managing application state
@interface MainCoordinator: NSObject

@property (nonatomic, strong, readonly) UINavigationController *navigationController;

@property (nonatomic, strong) MainViewController *mainViewController;

// MARK: Application State
@property (nonatomic, strong, readonly) State* sourceState;
@property (nonatomic, strong, readonly) State* destinationState;
@property float stateBorderFee;

-(id)initWithNavigationController:(UINavigationController *)navigationController;

// MARK: Actions
- (void)swapSelectedStates;
- (void)calculateCheapestRoute;
- (void)showErrorWithTitle:(NSString*)title andMessage:(NSString*)message;

// MARK: Navigation Functions
- (void)showShippingCalculator;
- (void)showStateSelectionForSource:(BOOL)isSource;
- (void)closeStateSelection;
- (void)showShippingResultsForRoute:(NSArray *)route withCosts:(NSArray *)fuelCosts withTotalCost:(float)cost;
- (void)closeShippingResults;
- (void)focusMapOnRoute;

@end
