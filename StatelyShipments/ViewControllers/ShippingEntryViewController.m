//
//  ShippingEntryViewController.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/3/25.
//

#import <Foundation/Foundation.h>
#import "ShippingEntryViewController.h"

#import "../Services/ShippingCostService.h"
#import "../Views/StatePickerButton.h"

#import "ShippingRouteViewController.h"

@interface ShippingEntryViewController () <ShippingCostServiceDelegate>

@property (nonatomic, strong) ShippingCostService* shippingCostService;

@property (nonatomic, strong) StatePickerButton* sourcePickerButton;
@property (nonatomic, strong) State* sourceState;
@property (nonatomic, strong) StatePickerButton* destinationPickerButton;
@property (nonatomic, strong) State* destinationState;

@end

@implementation ShippingEntryViewController

- (id)initWithNavigationController:(UINavigationController *)navController {
    if (self = [super init]) {
        self.navigationController = navController;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // assign services
    self.shippingCostService = [[ShippingCostService alloc] init];
    self.shippingCostService.delegate = self;
    
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // main vertical stack
    UIStackView *mainStackView = [[UIStackView alloc] init];
    mainStackView.axis = UILayoutConstraintAxisVertical;
    mainStackView.alignment = UIStackViewAlignmentFill;
    mainStackView.distribution = UIStackViewDistributionFill;
    mainStackView.spacing = 15;
    mainStackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // padding
    mainStackView.layoutMargins = UIEdgeInsetsMake(0, 25, 0, 25);
    mainStackView.layoutMarginsRelativeArrangement = YES;
    
    [self.view addSubview:mainStackView];
    
    UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [mainStackView.topAnchor constraintEqualToAnchor:guide.topAnchor],
        [mainStackView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor],
        [mainStackView.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor],
        [mainStackView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor]
    ]];
    
    // horizontal section for state pickers and swap button
    UIStackView *statePickerHStack = [[UIStackView alloc] init];
    statePickerHStack.axis = UILayoutConstraintAxisHorizontal;
    statePickerHStack.alignment = UIStackViewAlignmentCenter;
    statePickerHStack.distribution = UIStackViewDistributionEqualCentering;
    statePickerHStack.spacing = 0;
    statePickerHStack.translatesAutoresizingMaskIntoConstraints = NO;
    [mainStackView addArrangedSubview: statePickerHStack];
    
    // for state pickers
    NSArray* statesAlphabetical = [self.shippingCostService.countryGraph.allValues sortedArrayUsingComparator:^NSComparisonResult(State *state1, State *state2) {
        return [state2.stateCode localizedCaseInsensitiveCompare:state1.stateCode];
    }];
    
    // source picker
    self.sourcePickerButton = [[StatePickerButton alloc] init];
    [self.sourcePickerButton.button setTitle:@"Pick me" forState:UIControlStateNormal];
    [self.sourcePickerButton.label setText:@"Source"];
    [self.sourcePickerButton setupPickerMenu:statesAlphabetical];
    
    [statePickerHStack addArrangedSubview:self.sourcePickerButton];
    
    ShippingEntryViewController* __weak weakSelf = self;
    self.sourcePickerButton.selectionHandler = ^(State *selectedState) {
        weakSelf.sourceState = selectedState;
    };
    
    // swap button
    UIButton *swapButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [swapButton setImage:[UIImage systemImageNamed:@"arrow.left.arrow.right"] forState:UIControlStateNormal];
    [swapButton addTarget:self action:@selector(swapStates) forControlEvents:UIControlEventTouchUpInside];
    swapButton.tintColor = [UIColor blackColor];
    swapButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [statePickerHStack addArrangedSubview:swapButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [swapButton.heightAnchor constraintEqualToConstant:55],
        [swapButton.widthAnchor constraintEqualToConstant:55],
    ]];
    
    // destination picker
    
    self.destinationPickerButton = [[StatePickerButton alloc] init];
    [self.destinationPickerButton.button setTitle:@"Pick me" forState:UIControlStateNormal];
    [self.destinationPickerButton.label setText:@"Destination"];
    [self.destinationPickerButton setupPickerMenu:statesAlphabetical];

    [statePickerHStack addArrangedSubview:self.destinationPickerButton];
    
    self.destinationPickerButton.selectionHandler = ^(State *selectedState) {
        weakSelf.destinationState = selectedState;
    };
    
//    // seperator line
//    UIView *separator = [[UIView alloc] init];
//    separator.translatesAutoresizingMaskIntoConstraints = NO;
//    separator.backgroundColor = [UIColor separatorColor];
//
//    [mainStackView addArrangedSubview:separator];
//    [NSLayoutConstraint activateConstraints:@[
//        [separator.heightAnchor constraintEqualToConstant:(1.0 / [UIScreen mainScreen].scale)],
//    ]];
    
    // Setup calculation button
    UIButtonConfiguration *calculateButtonConfiguration = [UIButtonConfiguration filledButtonConfiguration];
    NSAttributedString *calculateButtonAttributedTitle = [[NSAttributedString alloc] initWithString:@"Calculate" attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]}];
    calculateButtonConfiguration.attributedTitle =calculateButtonAttributedTitle;
    calculateButtonConfiguration.baseBackgroundColor = [UIColor blackColor];
    calculateButtonConfiguration.baseForegroundColor = [UIColor whiteColor];
    calculateButtonConfiguration.cornerStyle = UIButtonConfigurationCornerStyleLarge;
    UIButton *calculateButton = [UIButton buttonWithConfiguration:calculateButtonConfiguration primaryAction:nil];
    [calculateButton addTarget:self action:@selector(calculateShippingCost) forControlEvents:UIControlEventTouchUpInside];
    
    [mainStackView addArrangedSubview:calculateButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [calculateButton.bottomAnchor constraintEqualToAnchor:mainStackView.bottomAnchor],
//        [calculateButton.leadingAnchor constraintEqualToAnchor:mainStackView.leadingAnchor constant:30],
//        [calculateButton.trailingAnchor constraintEqualToAnchor:mainStackView.trailingAnchor constant:-30],
        [calculateButton.heightAnchor constraintEqualToConstant:55],
    ]];
    
}

#pragma mark Button Actions

- (void)swapStates {
    NSLog(@"Swapping states...");
    State *temp = self.sourceState;
    self.sourceState = self.destinationState;
    self.destinationState = temp;
    [self.sourcePickerButton updateSelectedState:self.sourceState];
    [self.destinationPickerButton updateSelectedState:self.destinationState];
}

- (void)calculateShippingCost {
    NSLog(@"Triggered calculate shipping cost calculation");
    [self.shippingCostService cheapestRouteBetweenStates:self.sourceState andState:self.destinationState];
}

#pragma mark Delegate Actions

- (void)shippingCostServiceDidFailToFindRoute {
    NSLog(@"Failed to find route");
}

- (void)shippingCostServiceDidFindRoute:(NSArray *)route withFuelCost:(float)cost { 
    NSLog(@"Found route %@ at cost $%.2f", route, cost);
    // push to navigation
    if ([self.navigationController isKindOfClass:[UINavigationController class]]) {

        dispatch_async(dispatch_get_main_queue(), ^{
            ShippingRouteViewController *shippingRouteViewController = [[ShippingRouteViewController alloc] initWithRoute:route];
            shippingRouteViewController.navigationController = self.navigationController;
            
            [self.navigationController pushViewController:shippingRouteViewController animated:YES];
        });
    }
}

@end
