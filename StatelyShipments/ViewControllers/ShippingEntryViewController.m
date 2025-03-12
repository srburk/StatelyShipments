//
//  ShippingEntryViewController.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/3/25.
//

#import <Foundation/Foundation.h>
#import "ShippingEntryViewController.h"

#import "../Utility/StatesLoader.h"
#import "../Views/GovernmentFeeInputView.h"

#import "ShippingRouteViewController.h"
#import "StatePickerViewController.h"
#import "MainViewController.h"

@interface ShippingEntryViewController ()

// indicator that shipping calculation is happening
@property (nonatomic, strong) UIActivityIndicatorView* spinnerView;

@property (nonatomic, strong) StatePickerButton* sourcePickerButton;
@property (nonatomic, strong) StatePickerButton* destinationPickerButton;
@property (nonatomic, strong) UIButton *calculateButton;

@property (nonatomic, strong) GovernmentFeeInputView* feeInputView;

@end

@implementation ShippingEntryViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
        
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
    statePickerHStack.alignment = UIStackViewAlignmentCenter;
    statePickerHStack.distribution = UIStackViewDistributionFillEqually;
    statePickerHStack.spacing = 0;
    statePickerHStack.translatesAutoresizingMaskIntoConstraints = NO;
    [mainStackView addArrangedSubview: statePickerHStack];
    
    // source picker
    self.sourcePickerButton = [[StatePickerButton alloc] init];
    [self.sourcePickerButton.label setText:@"Source"];
    
    [statePickerHStack addArrangedSubview:self.sourcePickerButton];
    [self.sourcePickerButton.button addTarget:self action:@selector(navigateToStateSelection:) forControlEvents:UIControlEventTouchUpInside];

    // swap button
    UIButton *swapButton = [UIButton buttonWithType:UIButtonTypeSystem];
    swapButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    swapButton.tintColor = [UIColor colorNamed:@"PrimaryColor"];
    [swapButton setImage:[UIImage systemImageNamed:@"arrow.left.arrow.right"] forState:UIControlStateNormal];
    [swapButton addTarget:self.coordinator action:@selector(swapSelectedStates) forControlEvents:UIControlEventTouchUpInside];
    
    swapButton.tintColor = [UIColor blackColor];
    swapButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [statePickerHStack addArrangedSubview:swapButton];
    
    // destination picker
    self.destinationPickerButton = [[StatePickerButton alloc] init];
    self.destinationPickerButton.label.textAlignment = NSTextAlignmentRight;
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
    calculateButtonConfiguration.baseBackgroundColor = [UIColor tintColor];
    calculateButtonConfiguration.baseForegroundColor = [UIColor whiteColor];
    calculateButtonConfiguration.cornerStyle = UIButtonConfigurationCornerStyleLarge;
    self.calculateButton = [UIButton buttonWithConfiguration:calculateButtonConfiguration primaryAction:nil];
    [self.calculateButton addTarget:self.coordinator action:@selector(calculateCheapestRoute) forControlEvents:UIControlEventTouchUpInside];
    
    self.spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.spinnerView.hidesWhenStopped = YES;
    self.spinnerView.color = [UIColor whiteColor];
    self.spinnerView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.calculateButton addSubview:self.spinnerView];
    
    [mainStackView addArrangedSubview:self.calculateButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.calculateButton.bottomAnchor constraintEqualToAnchor:mainStackView.bottomAnchor],
        [self.calculateButton.heightAnchor constraintEqualToConstant:55],
        
        // put spinner label to the left of button label
        [self.spinnerView.trailingAnchor constraintEqualToAnchor:self.calculateButton.titleLabel.leadingAnchor constant:-10],
        [self.spinnerView.centerYAnchor constraintEqualToAnchor:self.calculateButton.titleLabel.centerYAnchor],
    ]];
    
}

- (double)getStateBorderFee {
    NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString *digitsOnly = [[self.feeInputView.textField.text componentsSeparatedByCharactersInSet:nonDigits] componentsJoinedByString:@""];

    double fee = [digitsOnly doubleValue] / 100.0;
    return fee;
}

#pragma mark Button Actions

- (void)navigateToStateSelection:(UIButton *)sender {
        
    if (sender == self.sourcePickerButton.button) {
        [self.coordinator showStateSelectionForSource:YES];
    } else if (sender == self.destinationPickerButton.button) {
        [self.coordinator showStateSelectionForSource:NO];
    }
}

@end
