//
//  ViewController.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UILabel* sourceLabelTitle;
@property (nonatomic, strong) UILabel* sourceLabel;

@property (nonatomic, strong) UILabel* destinationLabelTitle;
@property (nonatomic, strong) UILabel* sourceDestination;

@property (nonatomic, strong) UIStackView* stateCalculatorStackView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationController;
//    NSLog(@"%@", self.navigationController);
    // testing overlay with solid color background
    self.view.backgroundColor = [UIColor systemGray5Color];
    
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
    
    // main stack for calculator screen
//    self.stateCalculatorStackView = [[UIStackView alloc] init];
    
    [self.view addSubview:stackView];
    
    [NSLayoutConstraint activateConstraints:@[
        [stackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [stackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [stackView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
}


@end
