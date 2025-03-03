//
//  ViewController.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import "ViewController.h"
#import "Services/ShippingCostService/ShippingCostService.h"

#import "Views/StatePicker/StatePickerViewController.h"

@interface ViewController () <StatePickerViewControllerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

@property ShippingCostService* shippingCostService;

@property (nonatomic, strong) UILabel* sourceLabelTitle;
@property (nonatomic, strong) UILabel* sourceLabel;
@property (nonatomic, strong) StatePickerViewController* sourceStatePicker;
@property (nonatomic, strong) UIButton* openSourceStatePicker;

@property (nonatomic, strong) UILabel* destinationLabelTitle;
@property (nonatomic, strong) UILabel* sourceDestination;
@property (nonatomic, strong) UIButton* openDestinationStatePicker;

@property (nonatomic, strong) UIStackView* stateCalculatorStackView;

@end

@implementation ViewController

- (id)initWithNavigationController:(UINavigationController*)navController {
    if (self = [super init]) {
        self.navigationController = navController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationController;
//    NSLog(@"%@", self.navigationController);
    // testing overlay with solid color background
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    self.sourceLabelTitle = [[UILabel alloc] init];
    self.sourceLabelTitle.text = @"Source";
    self.sourceLabelTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
    self.destinationLabelTitle = [[UILabel alloc] init];
    self.destinationLabelTitle.text = @"Destination";
    self.destinationLabelTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
    UIStackView* stackView = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.sourceLabelTitle,
        self.destinationLabelTitle
    ]];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.spacing = 16;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:stackView];
    
    [NSLayoutConstraint activateConstraints:@[
        [stackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [stackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [stackView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
    
    self.shippingCostService = [[ShippingCostService alloc] init];
    
    // State pickers
    
    self.openSourceStatePicker = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.openSourceStatePicker setTitle:@"State Picker 1" forState:UIControlStateNormal];
    [self.openSourceStatePicker addTarget:self action:@selector(chooseState) forControlEvents:UIControlEventTouchUpInside];
    self.openSourceStatePicker.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.openDestinationStatePicker = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.openDestinationStatePicker setTitle:@"State Picker 2" forState:UIControlStateNormal];
    [self.openDestinationStatePicker addTarget:self action:@selector(chooseState) forControlEvents:UIControlEventTouchUpInside];
    self.openDestinationStatePicker.translatesAutoresizingMaskIntoConstraints = NO;
 
    UIStackView* statePickerStack = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.openSourceStatePicker,
        self.openDestinationStatePicker
    ]];
    statePickerStack.axis = UILayoutConstraintAxisHorizontal;
    statePickerStack.alignment = UIStackViewAlignmentCenter;
    statePickerStack.distribution = UIStackViewDistributionEqualSpacing;
    statePickerStack.spacing = 16;
    statePickerStack.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:statePickerStack];
    
    [NSLayoutConstraint activateConstraints:@[
        [statePickerStack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [statePickerStack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [statePickerStack.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant: -50]
    ]];
}

- (void)chooseState {
    if (self.navigationController) {
        self.sourceStatePicker = [[StatePickerViewController alloc] initWithStates:self.shippingCostService.countryGraph.allKeys];
        self.sourceStatePicker.delegate = self;
        [self.navigationController pushViewController:self.sourceStatePicker animated:YES];
    } else {
        NSLog(@"No nav controller");
    }
}

- (void)statePicker:(UIViewController *)picker didSelectOption:(NSString *)option { 
    [self.openSourceStatePicker setTitle:option forState:UIControlStateNormal];
}

@end
