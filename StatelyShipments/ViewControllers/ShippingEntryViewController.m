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
#import "../Views/GovernmentFeeInputView.h"

#import "ShippingRouteViewController.h"
#import "StatePickerViewController.h"
#import "MainViewController.h"

#import "../Utility/Extensions/UINavigationController+SheetControlAdditions.h"

@interface ShippingEntryViewController () <ShippingCostServiceDelegate>

@property (nonatomic, strong) ShippingCostService* shippingCostService;

// indicator that shipping calculation is happening
@property (nonatomic, strong) UIActivityIndicatorView* spinnerView;

@property (nonatomic, strong) StatePickerButton* sourcePickerButton;
@property (nonatomic, strong) State* sourceState;
@property (nonatomic, strong) StatePickerButton* destinationPickerButton;
@property (nonatomic, strong) State* destinationState;

@property (nonatomic, strong) GovernmentFeeInputView* feeInputView;

- (void)navigateToStateSelection:(UIButton *)sender;

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
    
    [self.navigationController animateSmallDetent];
    
    // assign services
    self.shippingCostService = [[ShippingCostService alloc] init];
    self.shippingCostService.delegate = self;
    
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // main vertical stack
    UIStackView *mainStackView = [[UIStackView alloc] init];
    mainStackView.axis = UILayoutConstraintAxisVertical;
    mainStackView.alignment = UIStackViewAlignmentFill;
    mainStackView.distribution = UIStackViewDistributionFill;
    mainStackView.spacing = 25;
    mainStackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // padding
    mainStackView.layoutMargins = UIEdgeInsetsMake(25, 25, 0, 25);
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
    statePickerHStack.alignment = UIStackViewAlignmentTop;
    statePickerHStack.distribution = UIStackViewDistributionEqualCentering;
    statePickerHStack.spacing = 0;
    statePickerHStack.translatesAutoresizingMaskIntoConstraints = NO;
    [mainStackView addArrangedSubview: statePickerHStack];
    
    // source picker
    self.sourcePickerButton = [[StatePickerButton alloc] init];
    [self.sourcePickerButton.button setTitle:@"Pick me" forState:UIControlStateNormal];
    [self.sourcePickerButton.label setText:@"Source"];
    
    [statePickerHStack addArrangedSubview:self.sourcePickerButton];
    [self.sourcePickerButton.button addTarget:self action:@selector(navigateToStateSelection:) forControlEvents:UIControlEventTouchUpInside];
    
    // swap button
    UIButton *swapButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [swapButton setImage:[UIImage systemImageNamed:@"arrow.left.arrow.right"] forState:UIControlStateNormal];
    [swapButton addTarget:self action:@selector(swapStates) forControlEvents:UIControlEventTouchUpInside];
    
    swapButton.tintColor = [UIColor blackColor];
    swapButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [statePickerHStack addArrangedSubview:swapButton];
    
    // destination picker
    self.destinationPickerButton = [[StatePickerButton alloc] init];
    [self.destinationPickerButton.button setTitle:@"Pick me" forState:UIControlStateNormal];
    [self.destinationPickerButton.label setText:@"Destination"];

    [statePickerHStack addArrangedSubview:self.destinationPickerButton];
    [self.destinationPickerButton.button addTarget:self action:@selector(navigateToStateSelection:) forControlEvents:UIControlEventTouchUpInside];
    
    // government fee input
    self.feeInputView = [[GovernmentFeeInputView alloc] init];
    [mainStackView addArrangedSubview:self.feeInputView];
    
    // Setup calculation button
    UIButtonConfiguration *calculateButtonConfiguration = [UIButtonConfiguration filledButtonConfiguration];
    NSAttributedString *calculateButtonAttributedTitle = [[NSAttributedString alloc] initWithString:@"Calculate" attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]}];
    calculateButtonConfiguration.attributedTitle =calculateButtonAttributedTitle;
    calculateButtonConfiguration.baseBackgroundColor = [UIColor blackColor];
    calculateButtonConfiguration.baseForegroundColor = [UIColor whiteColor];
    calculateButtonConfiguration.cornerStyle = UIButtonConfigurationCornerStyleLarge;
    UIButton *calculateButton = [UIButton buttonWithConfiguration:calculateButtonConfiguration primaryAction:nil];
    [calculateButton addTarget:self action:@selector(calculateShippingCost) forControlEvents:UIControlEventTouchUpInside];
    
    self.spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.spinnerView.hidesWhenStopped = YES;
    self.spinnerView.color = [UIColor whiteColor];
    self.spinnerView.translatesAutoresizingMaskIntoConstraints = NO;

    [calculateButton addSubview:self.spinnerView];
    
    [mainStackView addArrangedSubview:calculateButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [calculateButton.bottomAnchor constraintEqualToAnchor:mainStackView.bottomAnchor],
        [calculateButton.heightAnchor constraintEqualToConstant:55],
        
        // put spinner label to the left of button label
        [self.spinnerView.trailingAnchor constraintEqualToAnchor:calculateButton.titleLabel.leadingAnchor constant:-10],
        [self.spinnerView.centerYAnchor constraintEqualToAnchor:calculateButton.titleLabel.centerYAnchor],
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

- (void)navigateToStateSelection:(UIButton *)sender {
    if ([self.navigationController isKindOfClass:[UINavigationController class]]) {
        StatePickerViewController *statePickerViewController = [[StatePickerViewController alloc] init];
        statePickerViewController.navigationController = self.navigationController;
        
        if (sender == self.sourcePickerButton.button) {
            statePickerViewController.selectedState = self.sourceState;
        } else if (sender == self.destinationPickerButton.button) {
            statePickerViewController.selectedState = self.destinationState;
        }
        
        ShippingEntryViewController* __weak weakSelf = self;
        statePickerViewController.selectionHandler = ^(State *selectedState) {
            if (sender == weakSelf.sourcePickerButton.button) {
                weakSelf.sourceState = selectedState;
                // update button text
                [weakSelf.sourcePickerButton updateSelectedState:selectedState];
            } else if (sender == weakSelf.destinationPickerButton.button) {
                weakSelf.destinationState = selectedState;
                [weakSelf.destinationPickerButton updateSelectedState:selectedState];
            }
        };
        
        [self.navigationController pushViewController:statePickerViewController animated:NO];
    }
}

- (void)calculateShippingCost {
    
    NSLog(@"Triggered calculate shipping cost calculation");
    [self.spinnerView startAnimating];
    
    // get float value
    NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString *digitsOnly = [[self.feeInputView.textField.text componentsSeparatedByCharactersInSet:nonDigits] componentsJoinedByString:@""];
        
    double fee = [digitsOnly doubleValue] / 100.0;
        
    NSLog(@"Using fee: %f", fee);
    
    self.shippingCostService.stateBorderFee = fee;
    
    [self.shippingCostService cheapestRouteBetweenStates:self.sourceState andState:self.destinationState];
}

#pragma mark Delegate Actions

- (void)shippingCostServiceDidFailWithMessage:(NSString *)message {
    NSLog(@"Failed to find route: %@", message);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.spinnerView stopAnimating];
    });
}

- (void)shippingCostServiceDidFindRoute:(NSArray *)route withCosts:(NSArray *)fuelCosts withTotalCost:(float)cost {
        
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.spinnerView stopAnimating];
        
        if ([self.navigationController isKindOfClass:[UINavigationController class]]) {
            ShippingRouteViewController *shippingRouteViewController = [[ShippingRouteViewController alloc] init];
            shippingRouteViewController.shippingRoute = route;
            shippingRouteViewController.fuelCosts = fuelCosts;
            shippingRouteViewController.totalCost = cost;
            
            shippingRouteViewController.navigationController = self.navigationController;
            
            [self.navigationController pushViewController:shippingRouteViewController animated:YES];
        }
    });
}

@end
