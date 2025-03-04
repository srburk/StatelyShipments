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
    
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
//    self.tableView.dataSource = [
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
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
