//
//  ShippingRouteViewController.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/4/25.
//

#import "ShippingRouteViewController.h"
#import "../Views/ShippingRouteViewCell.h"

#import "../Utility/Extensions/UINavigationController+SheetControlAdditions.h"

@interface ShippingRouteViewController ()

@property (nonatomic, strong) UITableView* tableView;

- (void)closeTapped;

@end

@implementation ShippingRouteViewController
//
//- (void)viewWillDisappear:(BOOL)animated {
//    // hide navbar
//    [super viewWillDisappear:animated];
//    [self.navigationController animateSmallDetent];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // show navbar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // force medium detent
    [self.navigationController animateMediumDetent];

    // configure total cost label in nav bar
    UILabel *totalCostLabel = [[UILabel alloc] init];
    totalCostLabel.text = [NSString stringWithFormat:@"$%.2f", self.totalCost];
    totalCostLabel.textColor = [UIColor blackColor];
    totalCostLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];

    // using a button because I need a label in the menu bar but don't want it to be interactive yet
    UIBarButtonItem *totalCostButton = [[UIBarButtonItem alloc] initWithCustomView:totalCostLabel];
    self.navigationItem.rightBarButtonItem = totalCostButton;
    
    // back button
    UIButtonConfiguration* backButtonConfiguration = [UIButtonConfiguration plainButtonConfiguration];
    
    backButtonConfiguration.baseForegroundColor = [UIColor blackColor];
    backButtonConfiguration.image = [UIImage systemImageNamed:@"chevron.backward"];
    backButtonConfiguration.imagePadding = 0;
    
    UIButton *backButton = [UIButton buttonWithConfiguration:backButtonConfiguration primaryAction:nil];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];
    [backButton sizeToFit];

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
    // TODO: validate states
    self.navigationItem.title = [NSString stringWithFormat:@"%@ → %@", self.shippingRoute.firstObject.stateCode, self.shippingRoute.lastObject.stateCode];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = YES;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
    
}

- (void)closeTapped {
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController animateSmallDetent];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark Delegate TableView Actions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // fixed height for all cells
    return 50;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath { 
    static NSString * const cellIdentifier = @"ShippingRouteViewCell";
    ShippingRouteViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
         cell = [[ShippingRouteViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.text = self.shippingRoute[indexPath.row].stateName;
    
    if (indexPath.row > 0) {
        cell.fuelCostLabel.text = [NSString stringWithFormat:@"+$%.2f", [self.fuelCosts[indexPath.row - 1] floatValue]];
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return self.shippingRoute.count;
}

@end
