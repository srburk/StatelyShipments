//
//  ShippingCostViewController.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/3/25.
//

#import <Foundation/Foundation.h>
#import "ShippingCostViewController.h"

#import "../Services/ShippingCostService.h"

#import "../Views/StatePickerButton.h"

@interface ShippingCostViewController () <ShippingCostServiceDelegate>

@property (nonatomic, strong) ShippingCostService* shippingCostService;

@property (nonatomic, strong) StatePickerButton* sourcePickerButton;
@property (nonatomic, strong) StatePickerButton* destinationPickerButton;

@end

@implementation ShippingCostViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // assign services
    self.shippingCostService = [[ShippingCostService alloc] init];
    self.shippingCostService.delegate = self;
    
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // main vertical stack
    UIStackView *mainStackView = [[UIStackView alloc] init];
    mainStackView.axis = UILayoutConstraintAxisVertical;
    mainStackView.alignment = UIStackViewAlignmentCenter;
    mainStackView.distribution = UIStackViewDistributionFill;
    mainStackView.spacing = 0;
    mainStackView.translatesAutoresizingMaskIntoConstraints = NO;
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
    
    self.sourcePickerButton = [[StatePickerButton alloc] init];
    [self.sourcePickerButton.button setTitle:@"Pick me" forState:UIControlStateNormal];
    [self.sourcePickerButton.label setText:@"Source"];
    
    [statePickerHStack addArrangedSubview:self.sourcePickerButton];
    
//    destinationPicker
    self.destinationPickerButton = [[StatePickerButton alloc] init];
    [self.destinationPickerButton.button setTitle:@"Pick me" forState:UIControlStateNormal];
    [self.destinationPickerButton.label setText:@"Destination"];
    
    [statePickerHStack addArrangedSubview:self.destinationPickerButton];
    
    [NSLayoutConstraint activateConstraints:@[
//        [statePickerHStack.topAnchor constraintEqualToAnchor:mainStackView.topAnchor],
//        [statePickerHStack.bottomAnchor constraintEqualToAnchor:typeContainer. constant:-7],
        [statePickerHStack.leadingAnchor constraintEqualToAnchor:mainStackView.leadingAnchor constant:30],
        [statePickerHStack.trailingAnchor constraintEqualToAnchor:mainStackView.trailingAnchor constant:-30]
    ]];
    
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
        [calculateButton.leadingAnchor constraintEqualToAnchor:mainStackView.leadingAnchor constant:30],
        [calculateButton.trailingAnchor constraintEqualToAnchor:mainStackView.trailingAnchor constant:-30],
        [calculateButton.heightAnchor constraintEqualToConstant:55],
    ]];
    
}

#pragma mark Button Actions

- (void)calculateShippingCost {
    NSLog(@"Triggered calculate shipping cost calculation");
}

#pragma mark Delegate Actions

- (void)shippingCostServiceDidFailToFindRoute {
    
}

- (void)shippingCostServiceDidFindRoute:(NSArray *)route withFuelCost:(float)cost { 
    
}

@end
