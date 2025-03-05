//
//  ShippingRouteViewController.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/4/25.
//

#import "ShippingRouteViewController.h"

@interface ShippingRouteViewController ()

@property (nonatomic, strong) UITableView* tableView;

@end

@implementation ShippingRouteViewController

- (id)initWithRoute:(NSArray<State*>*)route andTotalCost:(float)totalCost {
    if (self = [super init]) {
        self.shippingRoute = route;
        self.totalCost = totalCost;
    } else {
        self.totalCost = 0.0;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    // hide navbar
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // show navbar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // configure total cost label in nav bar
    UILabel *totalCostLabel = [[UILabel alloc] init];
    totalCostLabel.text = [NSString stringWithFormat:@"$%.2f", self.totalCost];
    totalCostLabel.textColor = [UIColor blackColor];
    totalCostLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];

    // using a button because I need a label in the menu bar but don't want it to be interactive yet
    UIBarButtonItem *totalCostButton = [[UIBarButtonItem alloc] initWithCustomView:totalCostLabel];
    self.navigationItem.rightBarButtonItem = totalCostButton;
    
    // TODO: Make a header that has the total cost instead
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath { 
    static NSString * const cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.shippingRoute[indexPath.row].stateName;
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return self.shippingRoute.count;
}

@end
