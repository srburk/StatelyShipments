//
//  ShippingRouteViewController.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/4/25.
//

#import "ShippingRouteViewController.h"
#import "../Views/ShippingRouteViewCell.h"
#import "../Views/ShippingRouteViewHeader.h"

@interface ShippingRouteViewController ()

@property (nonatomic, strong) UITableView* tableView;

@end

@implementation ShippingRouteViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // back button
    UIButtonConfiguration* backButtonConfiguration = [UIButtonConfiguration plainButtonConfiguration];
    
    backButtonConfiguration.baseForegroundColor = [UIColor blackColor];
    backButtonConfiguration.image = [UIImage systemImageNamed:@"chevron.backward"];
    backButtonConfiguration.imagePadding = 0;
    
    UIButton *backButton = [UIButton buttonWithConfiguration:backButtonConfiguration primaryAction:nil];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    
    [backButton addTarget:self.coordinator action:@selector(closeShippingResults) forControlEvents:UIControlEventTouchUpInside];
    [backButton sizeToFit];

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
    // TODO: validate states
//    self.navigationItem.title = [NSString stringWithFormat:@"%@ → %@", self.shippingRoute.firstObject.stateCode, self.shippingRoute.lastObject.stateCode];
    self.navigationItem.title = @"Route Details";
    
    
    // MARK: TableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = YES;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.delegate = self;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 60, 0, 25);
    
    [self.view addSubview:self.tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
    
    // MARK: Table Header
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 85)];
    ShippingRouteViewHeader *headerCardView = [[ShippingRouteViewHeader alloc] initWithFrame:CGRectMake(15, 0, headerView.frame.size.width - 30, headerView.frame.size.height)];
    headerCardView.totalCostLabel.text = [NSString stringWithFormat:@"$%.2f", self.totalCost];
    
    // error check for route display
    if ([self.shippingRoute count] > 0) {
        headerCardView.sourceStateLabel.text = self.shippingRoute.firstObject.stateCode;
        headerCardView.destinationStateLabel.text = self.shippingRoute.lastObject.stateCode;
    } else {
        NSLog(@"Error no route");
    }

    [headerView addSubview:headerCardView];
    
    self.tableView.tableHeaderView = headerView;
    
}

// MARK: Delegate TableView Actions

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
